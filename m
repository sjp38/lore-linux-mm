Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69190C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:53:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA547206DF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 10:53:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA547206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36E8B6B0007; Tue, 20 Aug 2019 06:53:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31F9B6B0008; Tue, 20 Aug 2019 06:53:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 235086B000A; Tue, 20 Aug 2019 06:53:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id F113A6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:53:30 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8D336181AC9BA
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:53:30 +0000 (UTC)
X-FDA: 75842494980.08.event25_3ba227d586561
X-HE-Tag: event25_3ba227d586561
X-Filterd-Recvd-Size: 9880
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 10:53:29 +0000 (UTC)
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1i01lU-0004m9-5j; Tue, 20 Aug 2019 13:53:24 +0300
Subject: Re: [v5 PATCH 1/4] mm: thp: extract split_queue_* into a struct
To: Yang Shi <yang.shi@linux.alibaba.com>, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, cai@lca.pw, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
 <1565144277-36240-2-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c1bc953a-d165-b1a6-7e12-90a8f0f4458a@virtuozzo.com>
Date: Tue, 20 Aug 2019 13:53:23 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1565144277-36240-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.08.2019 05:17, Yang Shi wrote:
> Put split_queue, split_queue_lock and split_queue_len into a struct in
> order to reduce code duplication when we convert deferred_split to memcg
> aware in the later patches.
> 
> Suggested-by: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/mmzone.h | 12 +++++++++---
>  mm/huge_memory.c       | 45 +++++++++++++++++++++++++--------------------
>  mm/page_alloc.c        |  8 +++++---
>  3 files changed, 39 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d77d717..d8ec773 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -676,6 +676,14 @@ struct zonelist {
>  extern struct page *mem_map;
>  #endif
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +struct deferred_split {
> +	spinlock_t split_queue_lock;
> +	struct list_head split_queue;
> +	unsigned long split_queue_len;
> +};
> +#endif
> +
>  /*
>   * On NUMA machines, each NUMA node would have a pg_data_t to describe
>   * it's memory layout. On UMA machines there is a single pglist_data which
> @@ -755,9 +763,7 @@ struct zonelist {
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -	spinlock_t split_queue_lock;
> -	struct list_head split_queue;
> -	unsigned long split_queue_len;
> +	struct deferred_split deferred_split_queue;
>  #endif
>  
>  	/* Fields commonly accessed by the page reclaim scanner */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 1334ede..e0d8e08 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2658,6 +2658,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  {
>  	struct page *head = compound_head(page);
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
> +	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
>  	struct anon_vma *anon_vma = NULL;
>  	struct address_space *mapping = NULL;
>  	int count, mapcount, extra_pins, ret;
> @@ -2744,17 +2745,17 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	}
>  
>  	/* Prevent deferred_split_scan() touching ->_refcount */
> -	spin_lock(&pgdata->split_queue_lock);
> +	spin_lock(&ds_queue->split_queue_lock);
>  	count = page_count(head);
>  	mapcount = total_mapcount(head);
>  	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
>  		if (!list_empty(page_deferred_list(head))) {
> -			pgdata->split_queue_len--;
> +			ds_queue->split_queue_len--;
>  			list_del(page_deferred_list(head));
>  		}
>  		if (mapping)
>  			__dec_node_page_state(page, NR_SHMEM_THPS);
> -		spin_unlock(&pgdata->split_queue_lock);
> +		spin_unlock(&ds_queue->split_queue_lock);
>  		__split_huge_page(page, list, end, flags);
>  		if (PageSwapCache(head)) {
>  			swp_entry_t entry = { .val = page_private(head) };
> @@ -2771,7 +2772,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			dump_page(page, "total_mapcount(head) > 0");
>  			BUG();
>  		}
> -		spin_unlock(&pgdata->split_queue_lock);
> +		spin_unlock(&ds_queue->split_queue_lock);
>  fail:		if (mapping)
>  			xa_unlock(&mapping->i_pages);
>  		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
> @@ -2794,52 +2795,56 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  void free_transhuge_page(struct page *page)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> +	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> +	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	if (!list_empty(page_deferred_list(page))) {
> -		pgdata->split_queue_len--;
> +		ds_queue->split_queue_len--;
>  		list_del(page_deferred_list(page));
>  	}
> -	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> +	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  	free_compound_page(page);
>  }
>  
>  void deferred_split_huge_page(struct page *page)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> +	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
>  	unsigned long flags;
>  
>  	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>  
> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> +	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	if (list_empty(page_deferred_list(page))) {
>  		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
> -		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
> -		pgdata->split_queue_len++;
> +		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
> +		ds_queue->split_queue_len++;
>  	}
> -	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> +	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  }
>  
>  static unsigned long deferred_split_count(struct shrinker *shrink,
>  		struct shrink_control *sc)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(sc->nid);
> -	return READ_ONCE(pgdata->split_queue_len);
> +	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	return READ_ONCE(ds_queue->split_queue_len);
>  }
>  
>  static unsigned long deferred_split_scan(struct shrinker *shrink,
>  		struct shrink_control *sc)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(sc->nid);
> +	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
>  	unsigned long flags;
>  	LIST_HEAD(list), *pos, *next;
>  	struct page *page;
>  	int split = 0;
>  
> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> +	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	/* Take pin on all head pages to avoid freeing them under us */
> -	list_for_each_safe(pos, next, &pgdata->split_queue) {
> +	list_for_each_safe(pos, next, &ds_queue->split_queue) {
>  		page = list_entry((void *)pos, struct page, mapping);
>  		page = compound_head(page);
>  		if (get_page_unless_zero(page)) {
> @@ -2847,12 +2852,12 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  		} else {
>  			/* We lost race with put_compound_page() */
>  			list_del_init(page_deferred_list(page));
> -			pgdata->split_queue_len--;
> +			ds_queue->split_queue_len--;
>  		}
>  		if (!--sc->nr_to_scan)
>  			break;
>  	}
> -	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> +	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  
>  	list_for_each_safe(pos, next, &list) {
>  		page = list_entry((void *)pos, struct page, mapping);
> @@ -2866,15 +2871,15 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  		put_page(page);
>  	}
>  
> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> -	list_splice_tail(&list, &pgdata->split_queue);
> -	spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> +	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> +	list_splice_tail(&list, &ds_queue->split_queue);
> +	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  
>  	/*
>  	 * Stop shrinker if we didn't split any page, but the queue is empty.
>  	 * This can happen if pages were freed under us.
>  	 */
> -	if (!split && list_empty(&pgdata->split_queue))
> +	if (!split && list_empty(&ds_queue->split_queue))
>  		return SHRINK_STOP;
>  	return split;
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 272c6de..df02a88 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6649,9 +6649,11 @@ static unsigned long __init calc_memmap_size(unsigned long spanned_pages,
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  static void pgdat_init_split_queue(struct pglist_data *pgdat)
>  {
> -	spin_lock_init(&pgdat->split_queue_lock);
> -	INIT_LIST_HEAD(&pgdat->split_queue);
> -	pgdat->split_queue_len = 0;
> +	struct deferred_split *ds_queue = &pgdat->deferred_split_queue;
> +
> +	spin_lock_init(&ds_queue->split_queue_lock);
> +	INIT_LIST_HEAD(&ds_queue->split_queue);
> +	ds_queue->split_queue_len = 0;
>  }
>  #else
>  static void pgdat_init_split_queue(struct pglist_data *pgdat) {}
> 


