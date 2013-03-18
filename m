Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 5C5B96B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 10:52:03 -0400 (EDT)
Date: Mon, 18 Mar 2013 15:51:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/9] migrate: add migrate_entry_wait_huge()
Message-ID: <20130318145159.GP10192@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361475708-25991-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Thu 21-02-13 14:41:40, Naoya Horiguchi wrote:
[...]
> diff --git v3.8.orig/mm/migrate.c v3.8/mm/migrate.c
> index 2fd8b4a..7d84f4c 100644
> --- v3.8.orig/mm/migrate.c
> +++ v3.8/mm/migrate.c
> @@ -236,6 +236,30 @@ void migration_entry_wait(struct mm_struct *mm, pmd_t *pmd,
>  	pte_unmap_unlock(ptep, ptl);
>  }
>  
> +void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
> +				unsigned long address)
> +{
> +	spinlock_t *ptl = pte_lockptr(mm, pmd);
> +	pte_t pte;
> +	swp_entry_t entry;
> +	struct page *page;
> +
> +	spin_lock(ptl);
> +	pte = huge_ptep_get((pte_t *)pmd);
> +	if (!is_hugetlb_entry_migration(pte))
> +		goto out;
> +	entry = pte_to_swp_entry(pte);
> +	page = migration_entry_to_page(entry);
> +	if (!get_page_unless_zero(page))
> +		goto out;
> +	spin_unlock(ptl);
> +	wait_on_page_locked(page);
> +	put_page(page);
> +	return;
> +out:
> +	spin_unlock(ptl);
> +}

This duplicates a lot of code from migration_entry_wait. Can we just
teach the generic one to be HugePage aware instead?
All it takes is just opencoding pte_offset_map_lock and calling
huge_ptep_get ofr HugePage and pte_offset_map otherwise.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
