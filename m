Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0ECFC6B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 13:35:41 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so8915992pbb.24
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 10:35:41 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcj@linux.vnet.ibm.com>;
	Tue, 8 Oct 2013 23:05:30 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6FE1A125803F
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 23:05:48 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r98HbvHY42205398
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 23:07:58 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r98HZOk3005922
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 23:05:24 +0530
Date: Tue, 8 Oct 2013 12:35:21 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] vmsplice: Add limited zero copy to vmsplice
Message-ID: <20131008173521.GA6129@linux.vnet.ibm.com>
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
 <1381177293-27125-3-git-send-email-rcj@linux.vnet.ibm.com>
 <525436A5.20808@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <525436A5.20808@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

* Dave Hansen (dave@sr71.net) wrote:
> On 10/07/2013 01:21 PM, Robert C Jennings wrote:
> > +	if (!buf->offset && (buf->len == PAGE_SIZE) &&
> > +	    (buf->flags & PIPE_BUF_FLAG_GIFT) && (sd->flags & SPLICE_F_MOVE)) {
> > +		struct page *page = buf->page;
> > +		struct mm_struct *mm;
> > +		struct vm_area_struct *vma;
> > +		spinlock_t *ptl;
> > +		pte_t *ptep, pte;
> > +		unsigned long useraddr;
> > +
> > +		if (!PageAnon(page))
> > +			goto copy;
> > +		if (PageCompound(page))
> > +			goto copy;
> > +		if (PageHuge(page) || PageTransHuge(page))
> > +			goto copy;
> > +		if (page_mapped(page))
> > +			goto copy;
> 
> I'd really like to see some comments about those cases.  You touched on
> page_mapped() above, but could you replicate some of that in a comment?

Yes, I'll add comments in the code for these cases.

> Also, considering that this is being targeted at QEMU VMs, I would
> imagine that you're going to want to support PageTransHuge() in here
> pretty fast.  Do you anticipate that being very much trouble?  Have you
> planned for it in here?

My focus with this patch set was to get agreement on the change in the
first patch of the vmsplice syscall flags to perform page flipping rather
than copying.

I am working on support of PageTransHuge() but it is not complete.
It reworks this function to coalesce PAGE_SIZE pipe buffers into THP-sized
units and operate on those.

> > +		useraddr = (unsigned long)sd->u.userptr;
> > +		mm = current->mm;
> > +
> > +		ret = -EAGAIN;
> > +		down_read(&mm->mmap_sem);
> > +		vma = find_vma_intersection(mm, useraddr, useraddr + PAGE_SIZE);
> 
> If oyu are only doing these a page at a time, why bother with
> find_vma_intersection()?  Why not a plain find_vma()?

You're correct, I can change this to use find_vma().

> Also, if we fail to find a VMA, won't this return -EAGAIN?  That seems
> like a rather uninformative error code to get returned back out to
> userspace, especially since retrying won't help.

Yes, -EAGAIN is not good for this case, I will use -EFAULT.

> > +		if (IS_ERR_OR_NULL(vma))
> > +			goto up_copy;
> > +		if (!vma->anon_vma) {
> > +			ret = anon_vma_prepare(vma);
> > +			if (ret)
> > +				goto up_copy;
> > +		}
> 
> The first thing anon_vma_prepare() does is check vma->anon_vma.  This
> extra check seems unnecessary.

I'll fix this, thanks.

> > +		zap_page_range(vma, useraddr, PAGE_SIZE, NULL);
> > +		ret = lock_page_killable(page);
> > +		if (ret)
> > +			goto up_copy;
> > +		ptep = get_locked_pte(mm, useraddr, &ptl);
> > +		if (!ptep)
> > +			goto unlock_up_copy;
> > +		pte = *ptep;
> > +		if (pte_present(pte))
> > +			goto unlock_up_copy;
> > +		get_page(page);
> > +		page_add_anon_rmap(page, vma, useraddr);
> > +		pte = mk_pte(page, vma->vm_page_prot);
> 
> 'pte' is getting used for two different things here, which makes it a
> bit confusing.  I'd probably just skip this first assignment and
> directly do:
> 
> 		if (pte_present(*ptep))
> 			goto unlock_up_copy;

I'll fix this, thanks.

> > +		set_pte_at(mm, useraddr, ptep, pte);
> > +		update_mmu_cache(vma, useraddr, ptep);
> > +		pte_unmap_unlock(ptep, ptl);
> > +		ret = 0;
> > +unlock_up_copy:
> > +		unlock_page(page);
> > +up_copy:
> > +		up_read(&mm->mmap_sem);
> > +		if (!ret) {
> > +			ret = sd->len;
> > +			goto out;
> > +		}
> > +		/* else ret < 0 and we should fallback to copying */
> > +		VM_BUG_ON(ret > 0);
> > +	}
> 
> This also screams to be broken out in to a helper function instead of
> just being thrown in with the existing code.

You're right, it's very self-contained already.  I'll pull it out. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
