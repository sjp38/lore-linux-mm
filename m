Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 220A06B0031
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 12:54:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 8 Sep 2013 22:12:14 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6DF72394004D
	for <linux-mm@kvack.org>; Sun,  8 Sep 2013 22:23:45 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r88Gtptj21954658
	for <linux-mm@kvack.org>; Sun, 8 Sep 2013 22:25:52 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r88Gruji017047
	for <linux-mm@kvack.org>; Sun, 8 Sep 2013 22:23:56 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
In-Reply-To: <1378416466-30913-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1378416466-30913-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1378416466-30913-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Sun, 08 Sep 2013 22:23:55 +0530
Message-ID: <871u4zi7a4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Currently all of page table handling by hugetlbfs code are done under
> mm->page_table_lock. So when a process have many threads and they heavily
> access to the memory, lock contention happens and impacts the performance.
>
> This patch makes hugepage support split page table lock so that we use
> page->ptl of the leaf node of page table tree which is pte for normal pages
> but can be pmd and/or pud for hugepages of some architectures.
>
> ChangeLog v3:
>  - disable split ptl for ppc with USE_SPLIT_PTLOCKS_HUGETLB.
>  - remove replacement in some architecture dependent code. This is justified
>    because an allocation of pgd/pud/pmd/pte entry can race with other
>    allocation, not with read/write access, so we can use different locks.
>    http://thread.gmane.org/gmane.linux.kernel.mm/106292/focus=106458
>
> ChangeLog v2:
>  - add split ptl on other archs missed in v1
>  - drop changes on arch/{powerpc,tile}/mm/hugetlbpage.c
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/hugetlb.h  | 20 +++++++++++
>  include/linux/mm_types.h |  2 ++
>  mm/hugetlb.c             | 92 +++++++++++++++++++++++++++++-------------------
>  mm/mempolicy.c           |  5 +--
>  mm/migrate.c             |  4 +--
>  mm/rmap.c                |  2 +-
>  6 files changed, 84 insertions(+), 41 deletions(-)
>
> diff --git v3.11-rc3.orig/include/linux/hugetlb.h v3.11-rc3/include/linux/hugetlb.h
> index 0393270..5cb8a4e 100644
> --- v3.11-rc3.orig/include/linux/hugetlb.h
> +++ v3.11-rc3/include/linux/hugetlb.h
> @@ -80,6 +80,24 @@ extern const unsigned long hugetlb_zero, hugetlb_infinity;
>  extern int sysctl_hugetlb_shm_group;
>  extern struct list_head huge_boot_pages;
>
> +#if USE_SPLIT_PTLOCKS_HUGETLB
> +#define huge_pte_lockptr(mm, ptep) ({__pte_lockptr(virt_to_page(ptep)); })
> +#else	/* !USE_SPLIT_PTLOCKS_HUGETLB */
> +#define huge_pte_lockptr(mm, ptep) ({&(mm)->page_table_lock; })
> +#endif	/* USE_SPLIT_PTLOCKS_HUGETLB */
> +
> +#define huge_pte_offset_lock(mm, address, ptlp)		\
> +({							\
> +	pte_t *__pte = huge_pte_offset(mm, address);	\
> +	spinlock_t *__ptl = NULL;			\
> +	if (__pte) {					\
> +		__ptl = huge_pte_lockptr(mm, __pte);	\
> +		*(ptlp) = __ptl;			\
> +		spin_lock(__ptl);			\
> +	}						\
> +	__pte;						\
> +})


why not a static inline function ?


> +
>  /* arch callbacks */
>
>  pte_t *huge_pte_alloc(struct mm_struct *mm,> @@ -164,6 +182,8 @@ static inline void __unmap_hugepage_range(struct mmu_gather *tlb,
>  	BUG();
>  }
>
> +#define huge_pte_lockptr(mm, ptep) 0
> +
>  #endif /* !CONFIG_HUGETLB_PAGE */
>
>  #define HUGETLB_ANON_FILE "anon_hugepage"
> diff --git v3.11-rc3.orig/include/linux/mm_types.h v3.11-rc3/include/linux/mm_types.h
> index fb425aa..cfb8c6f 100644
> --- v3.11-rc3.orig/include/linux/mm_types.h
> +++ v3.11-rc3/include/linux/mm_types.h
> @@ -24,6 +24,8 @@
>  struct address_space;
>
>  #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
> +#define USE_SPLIT_PTLOCKS_HUGETLB	\
> +	(USE_SPLIT_PTLOCKS && !defined(CONFIG_PPC))
>

Is that a common pattern ? Don't we generally use
HAVE_ARCH_SPLIT_PTLOCKS in arch config file ? Also are we sure this is
only an issue with PPC ?



-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
