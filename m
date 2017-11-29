Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 352696B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:53:03 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 79so3792959ioi.10
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 11:53:03 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j194si2241668ite.79.2017.11.29.11.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 11:53:02 -0800 (PST)
Subject: Re: [PATCH RFC 2/2] mm, hugetlb: do not rely on overcommit limit
 during migration
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
 <20171128141211.11117-1-mhocko@kernel.org>
 <20171128141211.11117-3-mhocko@kernel.org>
 <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <425a8947-d32a-d6bb-3a0a-2e30275c64c9@oracle.com>
Date: Wed, 29 Nov 2017 11:52:53 -0800
MIME-Version: 1.0
In-Reply-To: <20171129092234.eluli2gl7gotj35x@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On 11/29/2017 01:22 AM, Michal Hocko wrote:
> What about this on top. I haven't tested this yet though.

Yes, this would work.

However, I think a simple modification to your previous free_huge_page
changes would make this unnecessary.  I was confused in your previous
patch because you decremented the per-node surplus page count, but not
the global count.  I think it would have been correct (and made this
patch unnecessary) if you decremented the global counter there as well.

Of course, this patch makes the surplus accounting more explicit.

If we move forward with this patch, one issue below.

> ---
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 1b6d7783c717..f5fcd4e355dc 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -119,6 +119,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>  						long freed);
>  bool isolate_huge_page(struct page *page, struct list_head *list);
>  void putback_active_hugepage(struct page *page);
> +void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason);
>  void free_huge_page(struct page *page);
>  void hugetlb_fix_reserve_counts(struct inode *inode);
>  extern struct mutex *hugetlb_fault_mutex_table;
> @@ -232,6 +233,7 @@ static inline bool isolate_huge_page(struct page *page, struct list_head *list)
>  	return false;
>  }
>  #define putback_active_hugepage(p)	do {} while (0)
> +#define move_hugetlb_state(old, new, reason)	do {} while (0)
>  
>  static inline unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  		unsigned long address, unsigned long end, pgprot_t newprot)
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 037bf0f89463..30601c1c62f3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -34,6 +34,7 @@
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/node.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/page_owner.h>
>  #include "internal.h"
>  
>  int hugetlb_max_hstate __read_mostly;
> @@ -4830,3 +4831,34 @@ void putback_active_hugepage(struct page *page)
>  	spin_unlock(&hugetlb_lock);
>  	put_page(page);
>  }
> +
> +void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
> +{
> +	struct hstate *h = page_hstate(oldpage);
> +
> +	hugetlb_cgroup_migrate(oldpage, newpage);
> +	set_page_owner_migrate_reason(newpage, reason);
> +
> +	/*
> +	 * transfer temporary state of the new huge page. This is
> +	 * reverse to other transitions because the newpage is going to
> +	 * be final while the old one will be freed so it takes over
> +	 * the temporary status.
> +	 *
> +	 * Also note that we have to transfer the per-node surplus state
> +	 * here as well otherwise the global surplus count will not match
> +	 * the per-node's.
> +	 */
> +	if (PageHugeTemporary(newpage)) {
> +		int old_nid = page_to_nid(oldpage);
> +		int new_nid = page_to_nid(newpage);
> +
> +		SetPageHugeTemporary(oldpage);
> +		ClearPageHugeTemporary(newpage);
> +
> +		if (h->surplus_huge_pages_node[old_nid]) {
> +			h->surplus_huge_pages_node[old_nid]--;
> +			h->surplus_huge_pages_node[new_nid]++;
> +		}

You need to take hugetlb_lock before adjusting the surplus counts.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
