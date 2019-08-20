Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32756C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5FB920C01
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 11:06:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5FB920C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AAF46B000C; Tue, 20 Aug 2019 07:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7346C6B000D; Tue, 20 Aug 2019 07:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FC8E6B000E; Tue, 20 Aug 2019 07:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0056.hostedemail.com [216.40.44.56])
	by kanga.kvack.org (Postfix) with ESMTP id 405E46B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:06:45 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EBF75180AD808
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:06:44 +0000 (UTC)
X-FDA: 75842528328.19.year29_1dad04d5f1a60
X-HE-Tag: year29_1dad04d5f1a60
X-Filterd-Recvd-Size: 12534
Received: from relay.sw.ru (relay.sw.ru [185.231.240.75])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 11:06:43 +0000 (UTC)
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1i01yK-0004pj-LF; Tue, 20 Aug 2019 14:06:40 +0300
Subject: Re: [v5 PATCH 4/4] mm: thp: make deferred split shrinker memcg aware
To: Yang Shi <yang.shi@linux.alibaba.com>, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, cai@lca.pw, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1565144277-36240-1-git-send-email-yang.shi@linux.alibaba.com>
 <1565144277-36240-5-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <c60410b0-96ec-a663-6887-4fccd648a4d7@virtuozzo.com>
Date: Tue, 20 Aug 2019 14:06:39 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1565144277-36240-5-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.08.2019 05:17, Yang Shi wrote:
> Currently THP deferred split shrinker is not memcg aware, this may cause
> premature OOM with some configuration. For example the below test would
> run into premature OOM easily:
> 
> $ cgcreate -g memory:thp
> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
> $ cgexec -g memory:thp transhuge-stress 4000
> 
> transhuge-stress comes from kernel selftest.
> 
> It is easy to hit OOM, but there are still a lot THP on the deferred
> split queue, memcg direct reclaim can't touch them since the deferred
> split shrinker is not memcg aware.
> 
> Convert deferred split shrinker memcg aware by introducing per memcg
> deferred split queue.  The THP should be on either per node or per memcg
> deferred split queue if it belongs to a memcg.  When the page is
> immigrated to the other memcg, it will be immigrated to the target
> memcg's deferred split queue too.
> 
> Reuse the second tail page's deferred_list for per memcg list since the
> same THP can't be on multiple deferred split queues.
> 
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

But, please, see below one small suggestion.

> ---
>  include/linux/huge_mm.h    |  9 ++++++
>  include/linux/memcontrol.h |  4 +++
>  include/linux/mm_types.h   |  1 +
>  mm/huge_memory.c           | 76 +++++++++++++++++++++++++++++++++++++++-------
>  mm/memcontrol.c            | 24 +++++++++++++++
>  5 files changed, 103 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 45ede62..61c9ffd 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -267,6 +267,15 @@ static inline bool thp_migration_supported(void)
>  	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
>  }
>  
> +static inline struct list_head *page_deferred_list(struct page *page)
> +{
> +	/*
> +	 * Global or memcg deferred list in the second tail pages is
> +	 * occupied by compound_head.
> +	 */
> +	return &page[2].deferred_list;
> +}
> +
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 5771816..cace365 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -312,6 +312,10 @@ struct mem_cgroup {
>  	struct list_head event_list;
>  	spinlock_t event_list_lock;
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	struct deferred_split deferred_split_queue;
> +#endif
> +
>  	struct mem_cgroup_per_node *nodeinfo[0];
>  	/* WARNING: nodeinfo must be the last member here */
>  };
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3a37a89..156640c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -139,6 +139,7 @@ struct page {
>  		struct {	/* Second tail page of compound page */
>  			unsigned long _compound_pad_1;	/* compound_head */
>  			unsigned long _compound_pad_2;
> +			/* For both global and memcg */
>  			struct list_head deferred_list;
>  		};
>  		struct {	/* Page table pages */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e0d8e08..c9a596e 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -495,11 +495,25 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>  	return pmd;
>  }
>  
> -static inline struct list_head *page_deferred_list(struct page *page)
> +#ifdef CONFIG_MEMCG
> +static inline struct deferred_split *get_deferred_split_queue(struct page *page)
>  {
> -	/* ->lru in the tail pages is occupied by compound_head. */
> -	return &page[2].deferred_list;
> +	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
> +	struct pglist_data *pgdat = NODE_DATA(page_to_nid(page));
> +
> +	if (memcg)
> +		return &memcg->deferred_split_queue;
> +	else
> +		return &pgdat->deferred_split_queue;
> +}
> +#else
> +static inline struct deferred_split *get_deferred_split_queue(struct page *page)
> +{
> +	struct pglist_data *pgdat = NODE_DATA(page_to_nid(page));
> +
> +	return &pgdat->deferred_split_queue;
>  }
> +#endif
>  
>  void prep_transhuge_page(struct page *page)
>  {
> @@ -2658,7 +2672,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  {
>  	struct page *head = compound_head(page);
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue = get_deferred_split_queue(page);
>  	struct anon_vma *anon_vma = NULL;
>  	struct address_space *mapping = NULL;
>  	int count, mapcount, extra_pins, ret;
> @@ -2794,8 +2808,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  
>  void free_transhuge_page(struct page *page)
>  {
> -	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue = get_deferred_split_queue(page);
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> @@ -2809,17 +2822,37 @@ void free_transhuge_page(struct page *page)
>  
>  void deferred_split_huge_page(struct page *page)
>  {
> -	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue = get_deferred_split_queue(page);
> +#ifdef CONFIG_MEMCG
> +	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
> +#endif
>  	unsigned long flags;
>  
>  	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>  
> +	/*
> +	 * The try_to_unmap() in page reclaim path might reach here too,
> +	 * this may cause a race condition to corrupt deferred split queue.
> +	 * And, if page reclaim is already handling the same page, it is
> +	 * unnecessary to handle it again in shrinker.
> +	 *
> +	 * Check PageSwapCache to determine if the page is being
> +	 * handled by page reclaim since THP swap would add the page into
> +	 * swap cache before calling try_to_unmap().
> +	 */
> +	if (PageSwapCache(page))
> +		return;
> +
>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	if (list_empty(page_deferred_list(page))) {
>  		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
>  		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
>  		ds_queue->split_queue_len++;
> +#ifdef CONFIG_MEMCG
> +		if (memcg)
> +			memcg_set_shrinker_bit(memcg, page_to_nid(page),
> +					       deferred_split_shrinker.id);
> +#endif
>  	}
>  	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  }
> @@ -2827,8 +2860,19 @@ void deferred_split_huge_page(struct page *page)
>  static unsigned long deferred_split_count(struct shrinker *shrink,
>  		struct shrink_control *sc)
>  {
> +	struct deferred_split *ds_queue;
>  	struct pglist_data *pgdata = NODE_DATA(sc->nid);
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +
> +#ifdef CONFIG_MEMCG
> +	if (!sc->memcg) {
> +		ds_queue = &pgdata->deferred_split_queue;
> +		return READ_ONCE(ds_queue->split_queue_len);
> +	}
> +
> +	ds_queue = &sc->memcg->deferred_split_queue;
> +#else
> +	ds_queue = &pgdata->deferred_split_queue;
> +#endif
>  	return READ_ONCE(ds_queue->split_queue_len);
>  }

Can we write this a little more compact?

	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;

#ifdef CONFIG_MEMCG
	if (sc->memcg)
		ds_queue = &sc->memcg->deferred_split_queue;
#endif

Or just introduce a helper (something like get_sc_deferred_split_queue).
The same is in .scan method.

>  
> @@ -2836,12 +2880,21 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  		struct shrink_control *sc)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(sc->nid);
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue;
>  	unsigned long flags;
>  	LIST_HEAD(list), *pos, *next;
>  	struct page *page;
>  	int split = 0;
>  
> +#ifdef CONFIG_MEMCG
> +	if (sc->memcg)
> +		ds_queue = &sc->memcg->deferred_split_queue;
> +	else
> +		ds_queue = &pgdata->deferred_split_queue;
> +#else
> +	ds_queue = &pgdata->deferred_split_queue;
> +#endif
> +
>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	/* Take pin on all head pages to avoid freeing them under us */
>  	list_for_each_safe(pos, next, &ds_queue->split_queue) {
> @@ -2888,7 +2941,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  	.count_objects = deferred_split_count,
>  	.scan_objects = deferred_split_scan,
>  	.seeks = DEFAULT_SEEKS,
> -	.flags = SHRINKER_NUMA_AWARE,
> +	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE |
> +		 SHRINKER_NONSLAB,
>  };
>  
>  #ifdef CONFIG_DEBUG_FS
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index d90ded1..da4a411 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4698,6 +4698,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>  #ifdef CONFIG_CGROUP_WRITEBACK
>  	INIT_LIST_HEAD(&memcg->cgwb_list);
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	spin_lock_init(&memcg->deferred_split_queue.split_queue_lock);
> +	INIT_LIST_HEAD(&memcg->deferred_split_queue.split_queue);
> +	memcg->deferred_split_queue.split_queue_len = 0;
> +#endif
>  	idr_replace(&mem_cgroup_idr, memcg, memcg->id.id);
>  	return memcg;
>  fail:
> @@ -5071,6 +5076,14 @@ static int mem_cgroup_move_account(struct page *page,
>  		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
>  	}
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (compound && !list_empty(page_deferred_list(page))) {
> +		spin_lock(&from->deferred_split_queue.split_queue_lock);
> +		list_del_init(page_deferred_list(page));
> +		from->deferred_split_queue.split_queue_len--;
> +		spin_unlock(&from->deferred_split_queue.split_queue_lock);
> +	}
> +#endif
>  	/*
>  	 * It is safe to change page->mem_cgroup here because the page
>  	 * is referenced, charged, and isolated - we can't race with
> @@ -5079,6 +5092,17 @@ static int mem_cgroup_move_account(struct page *page,
>  
>  	/* caller should have done css_get */
>  	page->mem_cgroup = to;
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (compound && list_empty(page_deferred_list(page))) {
> +		spin_lock(&to->deferred_split_queue.split_queue_lock);
> +		list_add_tail(page_deferred_list(page),
> +			      &to->deferred_split_queue.split_queue);
> +		to->deferred_split_queue.split_queue_len++;
> +		spin_unlock(&to->deferred_split_queue.split_queue_lock);
> +	}
> +#endif
> +
>  	spin_unlock_irqrestore(&from->move_lock, flags);
>  
>  	ret = 0;
> 


