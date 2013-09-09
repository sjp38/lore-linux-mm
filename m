Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id D813A6B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:26:26 -0400 (EDT)
Date: Mon, 09 Sep 2013 12:26:08 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378743968-y0p22iff-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <871u4zi7a4.fsf@linux.vnet.ibm.com>
References: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1378416466-30913-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <871u4zi7a4.fsf@linux.vnet.ibm.com>
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

On Sun, Sep 08, 2013 at 10:23:55PM +0530, Aneesh Kumar K.V wrote:
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
> > ChangeLog v3:
> >  - disable split ptl for ppc with USE_SPLIT_PTLOCKS_HUGETLB.
> >  - remove replacement in some architecture dependent code. This is justified
> >    because an allocation of pgd/pud/pmd/pte entry can race with other
> >    allocation, not with read/write access, so we can use different locks.
> >    http://thread.gmane.org/gmane.linux.kernel.mm/106292/focus=106458
> >
> > ChangeLog v2:
> >  - add split ptl on other archs missed in v1
> >  - drop changes on arch/{powerpc,tile}/mm/hugetlbpage.c
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  include/linux/hugetlb.h  | 20 +++++++++++
> >  include/linux/mm_types.h |  2 ++
> >  mm/hugetlb.c             | 92 +++++++++++++++++++++++++++++-------------------
> >  mm/mempolicy.c           |  5 +--
> >  mm/migrate.c             |  4 +--
> >  mm/rmap.c                |  2 +-
> >  6 files changed, 84 insertions(+), 41 deletions(-)
> >
> > diff --git v3.11-rc3.orig/include/linux/hugetlb.h v3.11-rc3/include/linux/hugetlb.h
> > index 0393270..5cb8a4e 100644
> > --- v3.11-rc3.orig/include/linux/hugetlb.h
> > +++ v3.11-rc3/include/linux/hugetlb.h
> > @@ -80,6 +80,24 @@ extern const unsigned long hugetlb_zero, hugetlb_infinity;
> >  extern int sysctl_hugetlb_shm_group;
> >  extern struct list_head huge_boot_pages;
> >
> > +#if USE_SPLIT_PTLOCKS_HUGETLB
> > +#define huge_pte_lockptr(mm, ptep) ({__pte_lockptr(virt_to_page(ptep)); })
> > +#else	/* !USE_SPLIT_PTLOCKS_HUGETLB */
> > +#define huge_pte_lockptr(mm, ptep) ({&(mm)->page_table_lock; })
> > +#endif	/* USE_SPLIT_PTLOCKS_HUGETLB */
> > +
> > +#define huge_pte_offset_lock(mm, address, ptlp)		\
> > +({							\
> > +	pte_t *__pte = huge_pte_offset(mm, address);	\
> > +	spinlock_t *__ptl = NULL;			\
> > +	if (__pte) {					\
> > +		__ptl = huge_pte_lockptr(mm, __pte);	\
> > +		*(ptlp) = __ptl;			\
> > +		spin_lock(__ptl);			\
> > +	}						\
> > +	__pte;						\
> > +})
> 
> 
> why not a static inline function ?

I'm not sure how these two make change in runtime (maybe optimized to
similar code?).
I just used the same pattern with pte_offset_map_lock(). I think that
this may show that this function is the variant of pte_offset_map_lock().
But if we have a good reason to make it static inline, I'm glad to do this.
Do you have any specific ideas?

> 
> > +
> >  /* arch callbacks */
> >
> >  pte_t *huge_pte_alloc(struct mm_struct *mm,> @@ -164,6 +182,8 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
> >  	BUG();
> >  }
> >
> > +#define huge_pte_lockptr(mm, ptep) 0
> > +
> >  #endif /* !CONFIG_HUGETLB_PAGE */
> >
> >  #define HUGETLB_ANON_FILE "anon_hugepage"
> > diff --git v3.11-rc3.orig/include/linux/mm_types.h v3.11-rc3/include/linux/mm_types.h
> > index fb425aa..cfb8c6f 100644
> > --- v3.11-rc3.orig/include/linux/mm_types.h
> > +++ v3.11-rc3/include/linux/mm_types.h
> > @@ -24,6 +24,8 @@
> >  struct address_space;
> >
> >  #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
> > +#define USE_SPLIT_PTLOCKS_HUGETLB	\
> > +	(USE_SPLIT_PTLOCKS && !defined(CONFIG_PPC))
> >
> 
> Is that a common pattern ? Don't we generally use
> HAVE_ARCH_SPLIT_PTLOCKS in arch config file ?

Do you mean that HAVE_ARCH_SPLIT_PTLOCKS enables/disables whole split
ptl mechanism (not only split ptl for hugepages) depending on archs? 
If you do, we can do this with adding a line 'default "999999" if PPC'.
(Note that if we do this, we can lose the performance benefit from
existing split ptl for normal pages. So I'm not sure it's acceptible
for users of the arch.)

> Also are we sure this is
> only an issue with PPC ?

Not confirmed yet (so let me take some time to check this).
I think that split ptl for hugepage should work on any archtectures
where every entry pointing to hugepage is stored in 4kB page allocated
for page table trees. So I'll check it.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
