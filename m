Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 7FF4B6B0078
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 06:13:45 -0400 (EDT)
Date: Mon, 25 Mar 2013 11:13:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 01/10] migrate: add migrate_entry_wait_huge()
Message-ID: <20130325101340.GQ2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Fri 22-03-13 16:23:46, Naoya Horiguchi wrote:
> When we have a page fault for the address which is backed by a hugepage
> under migration, the kernel can't wait correctly until the migration
> finishes. This is because pte_offset_map_lock() can't get a correct
> migration entry for hugepage. This patch adds migration_entry_wait_huge()
> to separate code path between normal pages and hugepages.

The changelog is missing a description what is the effect of the bug. I
assume that we end up busy looping on the huge page page fault until
migration finishes, right?

Should this be applied to the stable tree or the current usage of the huge
page migration (HWPOISON) is not spread enough?

I like how you got rid of the duplication but I think this still doesn't
work for all archs/huge page sizes.

[...]
> diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> index 0a0be33..98a478e 100644
> --- v3.9-rc3.orig/mm/hugetlb.c
> +++ v3.9-rc3/mm/hugetlb.c
> @@ -2819,7 +2819,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (ptep) {
>  		entry = huge_ptep_get(ptep);
>  		if (unlikely(is_hugetlb_entry_migration(entry))) {
> -			migration_entry_wait(mm, (pmd_t *)ptep, address);
> +			migration_entry_wait_huge(mm, (pmd_t *)ptep, address);

e.g. ia64 returns pte_t *

[...]
> +void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
> +				unsigned long address)
> +{
> +	spinlock_t *ptl = pte_lockptr(mm, pmd);
> +	__migration_entry_wait(mm, (pte_t *)pmd, ptl);

So you are trying to get lockptr from pmd but you have pte in fact. No
biggy for !USE_SPLIT_PTLOCKS but doesn't work otherwise. So you probably
need a arch specific huge_pte_lockptr callback for USE_SPLIT_PTLOCKS.

Or am I missing something here? All the pte usage in hugetlb is one
giant mess and I wouldn't be surprised if there were more places
hardcoded to pmd there.

> +}
> +
>  #ifdef CONFIG_BLOCK
>  /* Returns true if all buffers are successfully locked */
>  static bool buffer_migrate_lock_buffers(struct buffer_head *head,
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
