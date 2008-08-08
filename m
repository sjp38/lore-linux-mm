Date: Fri, 8 Aug 2008 11:16:46 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] allocate structures for reservation tracking in
	hugetlbfs outside of spinlocks
Message-ID: <20080808101646.GJ14829@brain>
References: <1218033802.7764.31.camel@ubuntu> <1218140903-9757-1-git-send-email-apw@shadowen.org> <20080807143824.8e0803da.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080807143824.8e0803da.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: gerald.schaefer@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Thu, Aug 07, 2008 at 02:38:24PM -0700, Andrew Morton wrote:
> On Thu,  7 Aug 2008 21:28:23 +0100
> Andy Whitcroft <apw@shadowen.org> wrote:
> 
> > [Andrew, this fixes a problem in the private reservations stack, shown up
> > by some testing done by Gerald on s390 with PREEMPT.  It fixes an attempt
> > at allocation while holding locks.  This should be merged up to mainline
> > as a bug fix to those patches.]
> > 
> > In the normal case, hugetlbfs reserves hugepages at map time so that the
> > pages exist for future faults.  A struct file_region is used to track
> > when reservations have been consumed and where.  These file_regions
> > are allocated as necessary with kmalloc() which can sleep with the
> > mm->page_table_lock held.  This is wrong and triggers may-sleep warning
> > when PREEMPT is enabled.
> > 
> > Updates to the underlying file_region are done in two phases.  The first
> > phase prepares the region for the change, allocating any necessary memory,
> > without actually making the change.  The second phase actually commits
> > the change.  This patch makes use of this by checking the reservations
> > before the page_table_lock is taken; triggering any necessary allocations.
> > This may then be safely repeated within the locks without any allocations
> > being required.
> > 
> > Credit to Mel Gorman for diagnosing this failure and initial versions of
> > the patch.
> > 
> 
> After applying the patch:
> 
> : int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> : 			unsigned long address, int write_access)
> : {
> : 	pte_t *ptep;
> : 	pte_t entry;
> : 	int ret;
> : 	struct page *pagecache_page = NULL;
> : 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
> : 	struct hstate *h = hstate_vma(vma);
> : 
> : 	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
> : 	if (!ptep)
> : 		return VM_FAULT_OOM;
> : 
> : 	/*
> : 	 * Serialize hugepage allocation and instantiation, so that we don't
> : 	 * get spurious allocation failures if two CPUs race to instantiate
> : 	 * the same page in the page cache.
> : 	 */
> : 	mutex_lock(&hugetlb_instantiation_mutex);
> : 	entry = huge_ptep_get(ptep);
> : 	if (huge_pte_none(entry)) {
> : 		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
> : 		mutex_unlock(&hugetlb_instantiation_mutex);
> : 		return ret;
> : 	}
> : 
> : 	ret = 0;
> : 
> : 	/*
> : 	 * If we are going to COW the mapping later, we examine the pending
> : 	 * reservations for this page now. This will ensure that any
> : 	 * allocations necessary to record that reservation occur outside the
> : 	 * spinlock. For private mappings, we also lookup the pagecache
> : 	 * page now as it is used to determine if a reservation has been
> : 	 * consumed.
> : 	 */
> : 	if (write_access && !pte_write(entry)) {
> : 		vma_needs_reservation(h, vma, address);
> : 
> : 		if (!(vma->vm_flags & VM_SHARED))
> : 			pagecache_page = hugetlbfs_pagecache_page(h,
> : 								vma, address);
> : 	}
> 
> There's a seeming race window here, where a new page can get
> instantiated.  But down-read(mmap_sem) plus hugetlb_instantiation_mutex
> prevents that, yes?

Although that is true, I would prefer to not think of the
instantiation_mutex as protection for this, its primary concern is
serialisation.  I believe that the combination of down_read(mmap_sem),
the page lock, and perversely the page_table_lock protect this.

At this point we know that the PTE was not pte_none else we would
have branched to no_page.  No mapping operations can be occuring as
we have down_read(mmap_sem).  Any truncates racing with us first clear
the PTEs and then the pagecache references.  Should we pick up a stale
pagecache reference, we will detect it when we recheck the PTE under
the page_table_lock; this will also detect any racing instantiations.

Obviously we have the instantiation_mutex, and the locking rules for
the regions need it.  But I believe we are safe against this race even
without the instantiation_mutex.

> : 	spin_lock(&mm->page_table_lock);
> : 	/* Check for a racing update before calling hugetlb_cow */
> : 	if (likely(pte_same(entry, huge_ptep_get(ptep))))
> : 		if (write_access && !pte_write(entry))
> : 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
> : 							pagecache_page);
> : 	spin_unlock(&mm->page_table_lock);
> : 
> : 	if (pagecache_page) {
> : 		unlock_page(pagecache_page);
> : 		put_page(pagecache_page);
> : 	}
> : 
> : 	mutex_unlock(&hugetlb_instantiation_mutex);
> : 
> : 	return ret;
> : }
> : 
> : 

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
