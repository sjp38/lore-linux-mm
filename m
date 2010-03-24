Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BCC126B0213
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 18:49:05 -0400 (EDT)
Date: Wed, 24 Mar 2010 23:48:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [rfc 5/5] mincore: transparent huge page support
Message-ID: <20100324224858.GP10659@random.random>
References: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org>
 <1269354902-18975-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1269354902-18975-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 03:35:02PM +0100, Johannes Weiner wrote:
> +static int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> +			unsigned long addr, unsigned long end,
> +			unsigned char *vec)
> +{
> +	int huge = 0;
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	spin_lock(&vma->vm_mm->page_table_lock);
> +	if (likely(pmd_trans_huge(*pmd))) {
> +		huge = !pmd_trans_splitting(*pmd);

Under mmap_sem (read or write) a hugepage can't materialize under
us. So here the pmd_trans_huge can be lockless and run _before_ taking
the page_table_lock. That's the invariant I used to keep identical
performance for all fast paths.

And if it wasn't the case it wouldn't be safe to return huge = 0 as
the page_table_lock is released at that point.

> +		spin_unlock(&vma->vm_mm->page_table_lock);
> +		/*
> +		 * If we have an intact huge pmd entry, all pages in
> +		 * the range are present in the mincore() sense of
> +		 * things.
> +		 *
> +		 * But if the entry is currently being split into
> +		 * normal page mappings, wait for it to finish and
> +		 * signal the fallback to ptes.
> +		 */
> +		if (huge)
> +			memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> +		else
> +			wait_split_huge_page(vma->anon_vma, pmd);
> +	} else
> +		spin_unlock(&vma->vm_mm->page_table_lock);
> +#endif
> +	return huge;
> +}
> +

It's probably cleaner to move the block into huge_memory.c and create
a dummy for the #ifndef version like I did for all the rest.


I'll incorporate and take care of those changes myself if you don't
mind, as I'm going to do a new submit for -mm. I greatly appreciated
you taken the time to port to transhuge it helps a lot! ;)

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
