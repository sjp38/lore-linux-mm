Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2970D6B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:36:31 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d5-v6so454448edq.3
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:36:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6-v6si614786edt.166.2018.07.26.00.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 00:36:29 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:36:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: fix page_freeze_refs and page_unfreeze_refs in
 comments.
Message-ID: <20180726073627.GT28386@dhcp22.suse.cz>
References: <1532590226-106038-1-git-send-email-jiang.biao2@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532590226-106038-1-git-send-email-jiang.biao2@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Biao <jiang.biao2@zte.com.cn>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Thu 26-07-18 15:30:26, Jiang Biao wrote:
> page_freeze_refs/page_unfreeze_refs have already been relplaced by
> page_ref_freeze/page_ref_unfreeze , but they are not modified in
> the comments.
> 
> Signed-off-by: Jiang Biao <jiang.biao2@zte.com.cn>

This looks better.

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
> v1: fix comments in vmscan.
> v2: fix other two places and fix typoes.
> 
>  mm/ksm.c            | 4 ++--
>  mm/memory-failure.c | 2 +-
>  mm/vmscan.c         | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index a6d43cf..4c39cb67 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -703,7 +703,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  	 * We cannot do anything with the page while its refcount is 0.
>  	 * Usually 0 means free, or tail of a higher-order page: in which
>  	 * case this node is no longer referenced, and should be freed;
> -	 * however, it might mean that the page is under page_freeze_refs().
> +	 * however, it might mean that the page is under page_ref_freeze().
>  	 * The __remove_mapping() case is easy, again the node is now stale;
>  	 * but if page is swapcache in migrate_page_move_mapping(), it might
>  	 * still be our page, in which case it's essential to keep the node.
> @@ -714,7 +714,7 @@ static struct page *get_ksm_page(struct stable_node *stable_node, bool lock_it)
>  		 * work here too.  We have chosen the !PageSwapCache test to
>  		 * optimize the common case, when the page is or is about to
>  		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
> -		 * in the freeze_refs section of __remove_mapping(); but Anon
> +		 * in the ref_freeze section of __remove_mapping(); but Anon
>  		 * page->mapping reset to NULL later, in free_pages_prepare().
>  		 */
>  		if (!PageSwapCache(page))
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 9d142b9..c83a174 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1167,7 +1167,7 @@ int memory_failure(unsigned long pfn, int flags)
>  	 *    R/W the page; let's pray that the page has been
>  	 *    used and will be freed some time later.
>  	 * In fact it's dangerous to directly bump up page count from 0,
> -	 * that may make page_freeze_refs()/page_unfreeze_refs() mismatch.
> +	 * that may make page_ref_freeze()/page_ref_unfreeze() mismatch.
>  	 */
>  	if (!(flags & MF_COUNT_INCREASED) && !get_hwpoison_page(p)) {
>  		if (is_free_buddy_page(p)) {
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 03822f8..02d0c20 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -744,7 +744,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
>  		refcount = 2;
>  	if (!page_ref_freeze(page, refcount))
>  		goto cannot_free;
> -	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
> +	/* note: atomic_cmpxchg in page_ref_freeze provides the smp_rmb */
>  	if (unlikely(PageDirty(page))) {
>  		page_ref_unfreeze(page, refcount);
>  		goto cannot_free;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
