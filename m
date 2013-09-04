Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B94B46B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 12:32:28 -0400 (EDT)
Date: Wed, 04 Sep 2013 12:32:10 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378312330-afoa3r2y-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87li3dvz3k.fsf@linux.vnet.ibm.com>
References: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1377883120-5280-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <87li3dvz3k.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Hi Aneesh,

On Wed, Sep 04, 2013 at 12:43:19PM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > Currently all of page table handling by hugetlbfs code are done under
> > mm->page_table_lock. So when a process have many threads and they heavily
> > access to the memory, lock contention happens and impacts the performance.
> >
> > This patch makes hugepage support split page table lock so that we use
> > page->ptl of the leaf node of page table tree which is pte for normal pages
> > but can be pmd and/or pud for hugepages of some architectures.
> >
> > ChangeLog v2:
> >  - add split ptl on other archs missed in v1
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  arch/powerpc/mm/hugetlbpage.c |  6 ++-
> >  arch/tile/mm/hugetlbpage.c    |  6 ++-
> >  include/linux/hugetlb.h       | 20 ++++++++++
> >  mm/hugetlb.c                  | 92 ++++++++++++++++++++++++++-----------------
> >  mm/mempolicy.c                |  5 ++-
> >  mm/migrate.c                  |  4 +-
> >  mm/rmap.c                     |  2 +-
> >  7 files changed, 90 insertions(+), 45 deletions(-)
> >
> > diff --git v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> > index d67db4b..7e56cb7 100644
> > --- v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c
> > +++ v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> > @@ -124,6 +124,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> >  {
> >  	struct kmem_cache *cachep;
> >  	pte_t *new;
> > +	spinlock_t *ptl;
> >
> >  #ifdef CONFIG_PPC_FSL_BOOK3E
> >  	int i;
> > @@ -141,7 +142,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> >  	if (! new)
> >  		return -ENOMEM;
> >
> > -	spin_lock(&mm->page_table_lock);
> > +	ptl = huge_pte_lockptr(mm, new);
> > +	spin_lock(ptl);
> 
> 
> Are you sure we can do that for ppc ?
> 	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);

Ah, thanks. new is not a pointer to one full page occupied by page
table entries, so trying to use struct page of it is totally wrong.

> The page for new(pte_t) could be shared right ? which mean a deadlock ?

Yes, that's disastrous.

> May be you should do it at the pmd level itself for ppc

Yes, that's possible, but I simply drop the changes in __hugepte_alloc()
for now because this lock seems to protect us from the race between concurrent
calls of __hugepte_alloc(), not between allocation and read/write access.
Split ptl is used to avoid race between read/write accesses, so I think
that using different types of locks here is not dangerous.
# I guess that that's why we now use mm->page_table_lock for __pte_alloc()
# and its family even if USE_SPLIT_PTLOCKS is true.

A bit off-topic, but I found that we have a bogus comment on
hugetlb_free_pgd_range in arch/powerpc/mm/hugetlbpage.c saying
"Must be called with pagetable lock held."
This seems not true because the caller free_pgtables() and its
callers (unmap_region() and exit_mmap()) never hold it.
I guess that it's just copied from free_pgd_range() and it's also
false for this function. I'll post a patch to remove this later.

Anyway, thank you for valuable comments!

Thanks,
Naoya Horiguchi

> >  #ifdef CONFIG_PPC_FSL_BOOK3E
> >  	/*
> >  	 * We have multiple higher-level entries that point to the same
> > @@ -174,7 +176,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
> >  #endif
> >  	}
> >  #endif
> > -	spin_unlock(&mm->page_table_lock);
> > +	spin_unlock(ptl);
> >  	return 0;
> >  }
> >
> 
> 
> -aneesh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
