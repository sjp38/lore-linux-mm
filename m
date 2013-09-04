Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 174ED6B0032
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 03:13:33 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 4 Sep 2013 12:31:48 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id E993F394004D
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 12:43:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r847DJuh36307060
	for <linux-mm@kvack.org>; Wed, 4 Sep 2013 12:43:20 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r847DKXW004922
	for <linux-mm@kvack.org>; Wed, 4 Sep 2013 12:43:21 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] hugetlbfs: support split page table lock
In-Reply-To: <1377883120-5280-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1377883120-5280-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1377883120-5280-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Wed, 04 Sep 2013 12:43:19 +0530
Message-ID: <87li3dvz3k.fsf@linux.vnet.ibm.com>
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
> ChangeLog v2:
>  - add split ptl on other archs missed in v1
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/powerpc/mm/hugetlbpage.c |  6 ++-
>  arch/tile/mm/hugetlbpage.c    |  6 ++-
>  include/linux/hugetlb.h       | 20 ++++++++++
>  mm/hugetlb.c                  | 92 ++++++++++++++++++++++++++-----------------
>  mm/mempolicy.c                |  5 ++-
>  mm/migrate.c                  |  4 +-
>  mm/rmap.c                     |  2 +-
>  7 files changed, 90 insertions(+), 45 deletions(-)
>
> diff --git v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> index d67db4b..7e56cb7 100644
> --- v3.11-rc3.orig/arch/powerpc/mm/hugetlbpage.c
> +++ v3.11-rc3/arch/powerpc/mm/hugetlbpage.c
> @@ -124,6 +124,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  {
>  	struct kmem_cache *cachep;
>  	pte_t *new;
> +	spinlock_t *ptl;
>
>  #ifdef CONFIG_PPC_FSL_BOOK3E
>  	int i;
> @@ -141,7 +142,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  	if (! new)
>  		return -ENOMEM;
>
> -	spin_lock(&mm->page_table_lock);
> +	ptl = huge_pte_lockptr(mm, new);
> +	spin_lock(ptl);


Are you sure we can do that for ppc ?
	new = kmem_cache_zalloc(cachep, GFP_KERNEL|__GFP_REPEAT);

The page for new(pte_t) could be shared right ? which mean a deadlock ?

May be you should do it at the pmd level itself for ppc

>  #ifdef CONFIG_PPC_FSL_BOOK3E
>  	/*
>  	 * We have multiple higher-level entries that point to the same
> @@ -174,7 +176,7 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>  #endif
>  	}
>  #endif
> -	spin_unlock(&mm->page_table_lock);
> +	spin_unlock(ptl);
>  	return 0;
>  }
>


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
