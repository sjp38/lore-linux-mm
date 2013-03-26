Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EC2B06B00E3
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 07:29:53 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 26 Mar 2013 16:55:52 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id EC9D63940023
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:59:46 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2QBTgPt10944968
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 16:59:43 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2QBTffF028541
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 22:29:44 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of migrate_huge_page()
In-Reply-To: <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Tue, 26 Mar 2013 16:59:40 +0530
Message-ID: <87boa69z6j.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> Currently migrate_huge_page() takes a pointer to a hugepage to be
> migrated as an argument, instead of taking a pointer to the list of
> hugepages to be migrated. This behavior was introduced in commit
> 189ebff28 ("hugetlb: simplify migrate_huge_page()"), and was OK
> because until now hugepage migration is enabled only for soft-offlining
> which takes only one hugepage in a single call.
>
> But the situation will change in the later patches in this series
> which enable other users of page migration to support hugepage migration.
> They can kick migration for both of normal pages and hugepages
> in a single call, so we need to go back to original implementation
> of using linked lists to collect the hugepages to be migrated.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 15 ++++++++++++---
>  mm/migrate.c        |  2 ++
>  2 files changed, 14 insertions(+), 3 deletions(-)
>
> diff --git v3.9-rc3.orig/mm/memory-failure.c v3.9-rc3/mm/memory-failure.c
> index df0694c..4e01082 100644
> --- v3.9-rc3.orig/mm/memory-failure.c
> +++ v3.9-rc3/mm/memory-failure.c
> @@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	int ret;
>  	unsigned long pfn = page_to_pfn(page);
>  	struct page *hpage = compound_head(page);
> +	LIST_HEAD(pagelist);
>
>  	/*
>  	 * This double-check of PageHWPoison is to avoid the race with
> @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	unlock_page(hpage);
>
>  	/* Keep page count to indicate a given hugepage is isolated. */
> -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> -				MIGRATE_SYNC);
> -	put_page(hpage);
> +	list_move(&hpage->lru, &pagelist);

we use hpage->lru to add the hpage to h->hugepage_activelist. This will
break a hugetlb cgroup removal isn't it ?


> +	ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> +				MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  	if (ret) {
>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  			pfn, ret, page->flags);
> +		/*
> +		 * We know that soft_offline_huge_page() tries to migrate
> +		 * only one hugepage pointed to by hpage, so we need not
> +		 * run through the pagelist here.
> +		 */
> +		putback_active_hugepage(hpage);
> +		if (ret > 0)
> +			ret = -EIO;
>  	} else {
>  		set_page_hwpoison_huge_page(hpage);
>  		dequeue_hwpoisoned_huge_page(hpage);
> diff --git v3.9-rc3.orig/mm/migrate.c v3.9-rc3/mm/migrate.c
> index f69f354..66030b6 100644
> --- v3.9-rc3.orig/mm/migrate.c
> +++ v3.9-rc3/mm/migrate.c
> @@ -981,6 +981,8 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
>
>  	unlock_page(hpage);
>  out:
> +	if (rc != -EAGAIN)
> +		putback_active_hugepage(hpage);
>  	put_page(new_hpage);
>  	if (result) {
>  		if (rc)
> -- 

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
