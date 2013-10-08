Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7896B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 12:46:01 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9080328pad.16
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 09:46:00 -0700 (PDT)
Message-ID: <525436A5.20808@sr71.net>
Date: Tue, 08 Oct 2013 09:45:25 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] vmsplice: Add limited zero copy to vmsplice
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com> <1381177293-27125-3-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1381177293-27125-3-git-send-email-rcj@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert C Jennings <rcj@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/07/2013 01:21 PM, Robert C Jennings wrote:
> +	if (!buf->offset && (buf->len == PAGE_SIZE) &&
> +	    (buf->flags & PIPE_BUF_FLAG_GIFT) && (sd->flags & SPLICE_F_MOVE)) {
> +		struct page *page = buf->page;
> +		struct mm_struct *mm;
> +		struct vm_area_struct *vma;
> +		spinlock_t *ptl;
> +		pte_t *ptep, pte;
> +		unsigned long useraddr;
> +
> +		if (!PageAnon(page))
> +			goto copy;
> +		if (PageCompound(page))
> +			goto copy;
> +		if (PageHuge(page) || PageTransHuge(page))
> +			goto copy;
> +		if (page_mapped(page))
> +			goto copy;

I'd really like to see some comments about those cases.  You touched on
page_mapped() above, but could you replicate some of that in a comment?

Also, considering that this is being targeted at QEMU VMs, I would
imagine that you're going to want to support PageTransHuge() in here
pretty fast.  Do you anticipate that being very much trouble?  Have you
planned for it in here?

> +		useraddr = (unsigned long)sd->u.userptr;
> +		mm = current->mm;
> +
> +		ret = -EAGAIN;
> +		down_read(&mm->mmap_sem);
> +		vma = find_vma_intersection(mm, useraddr, useraddr + PAGE_SIZE);

If oyu are only doing these a page at a time, why bother with
find_vma_intersection()?  Why not a plain find_vma()?

Also, if we fail to find a VMA, won't this return -EAGAIN?  That seems
like a rather uninformative error code to get returned back out to
userspace, especially since retrying won't help.

> +		if (IS_ERR_OR_NULL(vma))
> +			goto up_copy;
> +		if (!vma->anon_vma) {
> +			ret = anon_vma_prepare(vma);
> +			if (ret)
> +				goto up_copy;
> +		}

The first thing anon_vma_prepare() does is check vma->anon_vma.  This
extra check seems unnecessary.

> +		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
> +		ret = lock_page_killable(page);
> +		if (ret)
> +			goto up_copy;
> +		ptep = get_locked_pte(mm, useraddr, &ptl);
> +		if (!ptep)
> +			goto unlock_up_copy;
> +		pte = *ptep;
> +		if (pte_present(pte))
> +			goto unlock_up_copy;
> +		get_page(page);
> +		page_add_anon_rmap(page, vma, useraddr);
> +		pte = mk_pte(page, vma->vm_page_prot);

'pte' is getting used for two different things here, which makes it a
bit confusing.  I'd probably just skip this first assignment and
directly do:

		if (pte_present(*ptep))
			goto unlock_up_copy;

> +		set_pte_at(mm, useraddr, ptep, pte);
> +		update_mmu_cache(vma, useraddr, ptep);
> +		pte_unmap_unlock(ptep, ptl);
> +		ret = 0;
> +unlock_up_copy:
> +		unlock_page(page);
> +up_copy:
> +		up_read(&mm->mmap_sem);
> +		if (!ret) {
> +			ret = sd->len;
> +			goto out;
> +		}
> +		/* else ret < 0 and we should fallback to copying */
> +		VM_BUG_ON(ret > 0);
> +	}

This also screams to be broken out in to a helper function instead of
just being thrown in with the existing code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
