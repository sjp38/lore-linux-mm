Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E7A036B0087
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 08:31:31 -0400 (EDT)
Date: Mon, 25 Mar 2013 13:31:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 03/10] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Message-ID: <20130325123128.GU2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:48, Naoya Horiguchi wrote:
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

If the purpose of this patch is to reduce code duplication then you
should remove migrate_huge_page as it doesn't have any caller anymore.

[...]
> @@ -1482,12 +1483,20 @@ static int soft_offline_huge_page(struct page *page, int flags)
>  	unlock_page(hpage);
>  
>  	/* Keep page count to indicate a given hugepage is isolated. */
> -	ret = migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL,
> -				MIGRATE_SYNC);
> -	put_page(hpage);
> +	list_move(&hpage->lru, &pagelist);
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

Maybe I am missing something but why we didn't need to call this before
when using migrate_huge_page?

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

And why do you put it here? If it is called from migrate_pages then the
caller already does the clean-up (putback_lru_pages).

>  	put_page(new_hpage);
>  	if (result) {
>  		if (rc)
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
