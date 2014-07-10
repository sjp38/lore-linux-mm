Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9336B0031
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 07:32:33 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so310913wgh.3
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 04:32:32 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id wr4si32622662wjb.15.2014.07.10.04.32.32
        for <linux-mm@kvack.org>;
        Thu, 10 Jul 2014 04:32:32 -0700 (PDT)
Date: Thu, 10 Jul 2014 14:32:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 05/13] clear_refs: remove clear_refs_private->vma and
 introduce clear_refs_test_walk()
Message-ID: <20140710113219.GA30954@node.dhcp.inet.fi>
References: <1404234451-21695-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1404234451-21695-6-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404234451-21695-6-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 01, 2014 at 01:07:23PM -0400, Naoya Horiguchi wrote:
> @@ -822,38 +844,14 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		};
>  		struct mm_walk clear_refs_walk = {
>  			.pmd_entry = clear_refs_pte_range,
> +			.test_walk = clear_refs_test_walk,
>  			.mm = mm,
>  			.private = &cp,
>  		};
>  		down_read(&mm->mmap_sem);
>  		if (type == CLEAR_REFS_SOFT_DIRTY)
>  			mmu_notifier_invalidate_range_start(mm, 0, -1);
> -		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -			cp.vma = vma;
> -			if (is_vm_hugetlb_page(vma))
> -				continue;
> -			/*
> -			 * Writing 1 to /proc/pid/clear_refs affects all pages.
> -			 *
> -			 * Writing 2 to /proc/pid/clear_refs only affects
> -			 * Anonymous pages.
> -			 *
> -			 * Writing 3 to /proc/pid/clear_refs only affects file
> -			 * mapped pages.
> -			 *
> -			 * Writing 4 to /proc/pid/clear_refs affects all pages.
> -			 */
> -			if (type == CLEAR_REFS_ANON && vma->vm_file)
> -				continue;
> -			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> -				continue;
> -			if (type == CLEAR_REFS_SOFT_DIRTY) {
> -				if (vma->vm_flags & VM_SOFTDIRTY)
> -					vma->vm_flags &= ~VM_SOFTDIRTY;
> -			}
> -			walk_page_range(vma->vm_start, vma->vm_end,
> -					&clear_refs_walk);
> -		}
> +		walk_page_range(0, ~0UL, &clear_refs_walk);

'vma' variable is now unused in the clear_refs_write().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
