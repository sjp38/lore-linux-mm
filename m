Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 28B256B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 18:07:39 -0400 (EDT)
Date: Tue, 4 Sep 2012 15:07:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V1 1/2] mm: Move all mmu notifier invocations to be done
 outside the PT lock
Message-Id: <20120904150737.a6774600.akpm@linux-foundation.org>
In-Reply-To: <1346748081-1652-2-git-send-email-haggaie@mellanox.com>
References: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
	<1346748081-1652-2-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Andrea Arcangeli <andrea@qumranet.com>

On Tue,  4 Sep 2012 11:41:20 +0300
Haggai Eran <haggaie@mellanox.com> wrote:

> From: Sagi Grimberg <sagig@mellanox.com>
> 
> In order to allow sleeping during mmu notifier calls, we need to avoid
> invoking them under the page table spinlock. This patch solves the
> problem by calling invalidate_page notification after releasing
> the lock (but before freeing the page itself), or by wrapping the page
> invalidation with calls to invalidate_range_begin and
> invalidate_range_end.
> 
>
> ...
>
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -868,12 +868,14 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  		cond_resched();
>  	}
>  
> +	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
> +
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_same(*pmd, orig_pmd)))
>  		goto out_free_pages;
>  	VM_BUG_ON(!PageHead(page));
>  
> -	pmdp_clear_flush_notify(vma, haddr, pmd);
> +	pmdp_clear_flush(vma, haddr, pmd);
>  	/* leave pmd empty until pte is filled */
>  
>  	pgtable = get_pmd_huge_pte(mm);
> @@ -896,6 +898,9 @@ static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
>  	page_remove_rmap(page);
>  	spin_unlock(&mm->page_table_lock);
>  
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, haddr,
> +					  haddr + HPAGE_PMD_SIZE);

But `haddr' has been altered by the time we get here.  We should have
saved the original value?

That's a thing I don't like about this patchset - it adds maintenance
overhead.  This need to retain values of local variables or incoming
args across lengthy code sequences is fragile.  We could easily break
your changes as the core code evolves, and it would take a long long
time before anyone noticed the breakage.

I'm wondering if it would be better to adopt the convention throughout
this patchset that mmu_notifier_invalidate_range_start() and
mmu_notifier_invalidate_range_end() always use their own locals.  ie:

	unsigned long mmun_start;	/* For mmu_notifiers */
	unsigned long mmun_end;		/* For mmu_notifiers */

	...

	mmun_start = ...;
	mmun_end = ...;

	...

	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);

	...

	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);


This is verbose, but it is explicit and clear and more robust than what
you have.  It shouldn't generate any additional text or stack usage or
register usage unless gcc is having an especially stupid day.


>  	ret |= VM_FAULT_WRITE;
>  	put_page(page);
>  
>
> ...
>
> @@ -1382,7 +1391,7 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  	spinlock_t *ptl;
>  	struct page *page;
>  	unsigned long address;
> -	unsigned long end;
> +	unsigned long start, end;

You'll note that this function uses the one-definition-per-line
convention, which has a few (smallish) advantages over
multiple-definitions-per-line.  One such advantage is that it leaves
room for a nice little comment at the RHS.  Take that as a hint ;)

>  	int ret = SWAP_AGAIN;
>  	int locked_vma = 0;
>  
> @@ -1405,6 +1414,9 @@ static int try_to_unmap_cluster(unsigned long cursor, unsigned int *mapcount,
>  	if (!pmd_present(*pmd))
>  		return ret;
>  
> +	start = address;
> +	mmu_notifier_invalidate_range_start(mm, start, end);

`end' is used uninitialised in this function.

I'm surprised that it didn't generate a warning(?) and I worry about
the testing coverage?

>  	/*
>  	 * If we can acquire the mmap_sem for read, and vma is VM_LOCKED,
>  	 * keep the sem while scanning the cluster for mlocking pages.
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
