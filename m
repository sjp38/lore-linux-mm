Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9838CC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:42:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E3EB20679
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 14:42:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E3EB20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC0676B0276; Tue, 28 May 2019 10:42:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6FD96B0279; Tue, 28 May 2019 10:42:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B601B6B027A; Tue, 28 May 2019 10:42:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD286B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 10:42:32 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id d11so3808369lji.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 07:42:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=l/DpzdGQSWER3ela1TYtHnmscu7JarTDL+pk6Ar031o=;
        b=s1p3f+5CSbNabsQ2VcsVkX23VH0KPtfZG687/rZpj55LajxeS7v5uVXJ9siLrGGgzp
         oPi74jyrFT25G/QB1kxSQI2qTMv4lGbh1vcIFEkt6N4hfSagykZ0iNh85+nAk+7D4PHy
         ttWsykuZlD9UGgefspF4U8pWmO8YdLpvSpNWzoaIkJ93apAlxYp0+XPxvn0/MbvF4L0E
         9wKPtpXzsmucuUOlSsZbiE3o1ffx7NtNHUL/VY5Kxrm9mC4MEpbtVcADhXRWmhQhQOYl
         ZPvcKZz3SUNnItY4FfiJQ6PeYFiwnSN6laqCzIIFskAnYeU/OJIHdkeXoiKvThiSbYvC
         /a0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUDUY4QLGhydJ9XqtMerXNSCTCyxqtLLOx0MS90iaQ8sRiyK6kv
	thJbWoWR6ZbqSTaGAkiJZcMemTXLES+oUXc2aSGpg/RFSk8PKF8Q95h0HKKzu7PSaLzSD3fWv7D
	mdALMEMVbwHQm9uxWTSXrZzgfxxMiVwNzOEwv2xiKwbZ4Px7ApgyCtsnJ9jEbYsv7gQ==
X-Received: by 2002:a2e:7212:: with SMTP id n18mr12154021ljc.209.1559054551513;
        Tue, 28 May 2019 07:42:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzfHlBG1ogBHoky3bVy2e/W+UKhUdM/73+mwShDPM2sKDa4ioIXBvIv7AdIoWpew1i7sZi
X-Received: by 2002:a2e:7212:: with SMTP id n18mr12153947ljc.209.1559054550134;
        Tue, 28 May 2019 07:42:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559054550; cv=none;
        d=google.com; s=arc-20160816;
        b=To6V5tjewhAWTaPqZgpKpYHr9q/QIA9FiBgU0wESWVi36AnmxdBFryLHIcB3CpA4Nc
         uMmX2ergo1U9FEip4GCMuZ4MuV2N7W7+hfoZTD4RY/FYW6xi41UB7kpXjB5q4zAT9RER
         VjzrgT5ztgnamZ/NfyFA6ZZQmrm3FdFXySsBoPEuvegXLQNBz3jC8HGp/mVsN1BSSuVQ
         3ICqzOl03bDm83Ljlp4BlHvVLVuGayzuM+66m6X+uGDxR6pQW/dJ9Z1ST6v0o3qhJtHV
         L4ERVYzbzZDuvxDK88gMYeU/tN+r+Up1o7c15DW0+0RMlqTFAtiE3YyjEn5UHr5hQirv
         cozw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=l/DpzdGQSWER3ela1TYtHnmscu7JarTDL+pk6Ar031o=;
        b=CrpF3Eov65QfjjTH53SOih/+wMKMQQpCZIOM79F3wH4V9xkAdKI9rL8LGCZviOO//F
         bllLjEOmoBtGTJnOt6nbPbphX0gqOg/eSbuYhqo6lQbn0UIoL9Cyqgv5sDk2kKm5VwBn
         zPsjt/fKfyGGdFdc3WnwCxfekkQjDnI9+swHop7/ZwnqQZ6GB/aYp6ur9QL4N4eIQbUp
         pykyt9Lrl8pIaGi0sax7F8I4dCmyaH2uvzZGRZlbjWhSYsbWT5Wf/BmX2K8dsVl1ib4Q
         j0Tav/esRKUEKsnCUW7DNGgAMAX5WdoV8ZzmqoMKUhZfJd/zdMe+MNgwph8xTaGo2yBr
         33Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 18si343626ljv.157.2019.05.28.07.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 07:42:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hVdJ4-000562-M9; Tue, 28 May 2019 17:42:26 +0300
Subject: Re: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
To: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
 mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com,
 shakeelb@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <487665fe-c792-5078-292a-481f33d31d30@virtuozzo.com>
Date: Tue, 28 May 2019 17:42:25 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Yang,

On 28.05.2019 15:44, Yang Shi wrote:
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
> And, move deleting THP from deferred split queue in page free before
> memcg uncharge so that the page's memcg information is available.
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
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/huge_mm.h    |  24 ++++++
>  include/linux/memcontrol.h |   6 ++
>  include/linux/mm_types.h   |   7 +-
>  mm/huge_memory.c           | 182 +++++++++++++++++++++++++++++++++------------
>  mm/memcontrol.c            |  20 +++++
>  mm/swap.c                  |   4 +
>  6 files changed, 194 insertions(+), 49 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7cd5c15..f6d1cde 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -250,6 +250,26 @@ static inline bool thp_migration_supported(void)
>  	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
>  }
>  
> +static inline struct list_head *page_deferred_list(struct page *page)
> +{
> +	/*
> +	 * Global deferred list in the second tail pages is occupied by
> +	 * compound_head.
> +	 */
> +	return &page[2].deferred_list;
> +}
> +
> +static inline struct list_head *page_memcg_deferred_list(struct page *page)
> +{
> +	/*
> +	 * Memcg deferred list in the second tail pages is occupied by
> +	 * compound_head.
> +	 */
> +	return &page[2].memcg_deferred_list;
> +}
> +
> +extern void del_thp_from_deferred_split_queue(struct page *);
> +
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> @@ -368,6 +388,10 @@ static inline bool thp_migration_supported(void)
>  {
>  	return false;
>  }
> +
> +static inline void del_thp_from_deferred_split_queue(struct page *page)
> +{
> +}
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  #endif /* _LINUX_HUGE_MM_H */
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index bc74d6a..9ff5fab 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -316,6 +316,12 @@ struct mem_cgroup {
>  	struct list_head event_list;
>  	spinlock_t event_list_lock;
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	struct list_head split_queue;
> +	unsigned long split_queue_len;
> +	spinlock_t split_queue_lock;
> +#endif
> +
>  	struct mem_cgroup_per_node *nodeinfo[0];
>  	/* WARNING: nodeinfo must be the last member here */
>  };
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 8ec38b1..405f5e6 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -139,7 +139,12 @@ struct page {
>  		struct {	/* Second tail page of compound page */
>  			unsigned long _compound_pad_1;	/* compound_head */
>  			unsigned long _compound_pad_2;
> -			struct list_head deferred_list;
> +			union {
> +				/* Global THP deferred split list */
> +				struct list_head deferred_list;
> +				/* Memcg THP deferred split list */
> +				struct list_head memcg_deferred_list;

Why we need two namesakes for this list entry?

For me it looks redundantly: it does not give additional information,
but it leads to duplication (and we have two helpers page_deferred_list()
and page_memcg_deferred_list() instead of one).

> +			};
>  		};
>  		struct {	/* Page table pages */
>  			unsigned long _pt_pad_1;	/* compound_head */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9f8bce9..0b9cfe1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -492,12 +492,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>  	return pmd;
>  }
>  
> -static inline struct list_head *page_deferred_list(struct page *page)
> -{
> -	/* ->lru in the tail pages is occupied by compound_head. */
> -	return &page[2].deferred_list;
> -}
> -
>  void prep_transhuge_page(struct page *page)
>  {
>  	/*
> @@ -505,7 +499,10 @@ void prep_transhuge_page(struct page *page)
>  	 * as list_head: assuming THP order >= 2
>  	 */
>  
> -	INIT_LIST_HEAD(page_deferred_list(page));
> +	if (mem_cgroup_disabled())
> +		INIT_LIST_HEAD(page_deferred_list(page));
> +	else
> +		INIT_LIST_HEAD(page_memcg_deferred_list(page));
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>  }
>  
> @@ -2664,6 +2661,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	bool mlocked;
>  	unsigned long flags;
>  	pgoff_t end;
> +	struct mem_cgroup *memcg = head->mem_cgroup;
>  
>  	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> @@ -2744,17 +2742,30 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	}
>  
>  	/* Prevent deferred_split_scan() touching ->_refcount */
> -	spin_lock(&pgdata->split_queue_lock);
> +	if (!memcg)
> +		spin_lock(&pgdata->split_queue_lock);
> +	else
> +		spin_lock(&memcg->split_queue_lock);
>  	count = page_count(head);
>  	mapcount = total_mapcount(head);
>  	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
> -		if (!list_empty(page_deferred_list(head))) {
> -			pgdata->split_queue_len--;
> -			list_del(page_deferred_list(head));
> +		if (!memcg) {
> +			if (!list_empty(page_deferred_list(head))) {
> +				pgdata->split_queue_len--;
> +				list_del(page_deferred_list(head));
> +			}
> +		} else {
> +			if (!list_empty(page_memcg_deferred_list(head))) {
> +				memcg->split_queue_len--;
> +				list_del(page_memcg_deferred_list(head));
> +			}
>  		}
>  		if (mapping)
>  			__dec_node_page_state(page, NR_SHMEM_THPS);
> -		spin_unlock(&pgdata->split_queue_lock);
> +		if (!memcg)
> +			spin_unlock(&pgdata->split_queue_lock);
> +		else
> +			spin_unlock(&memcg->split_queue_lock);
>  		__split_huge_page(page, list, end, flags);
>  		if (PageSwapCache(head)) {
>  			swp_entry_t entry = { .val = page_private(head) };
> @@ -2771,7 +2782,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  			dump_page(page, "total_mapcount(head) > 0");
>  			BUG();
>  		}
> -		spin_unlock(&pgdata->split_queue_lock);
> +		if (!memcg)
> +			spin_unlock(&pgdata->split_queue_lock);
> +		else
> +			spin_unlock(&memcg->split_queue_lock);
>  fail:		if (mapping)
>  			xa_unlock(&mapping->i_pages);
>  		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
> @@ -2791,17 +2805,40 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	return ret;
>  }
>  
> -void free_transhuge_page(struct page *page)
> +void del_thp_from_deferred_split_queue(struct page *page)
>  {
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
>  	unsigned long flags;
> +	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
>  
> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> -	if (!list_empty(page_deferred_list(page))) {
> -		pgdata->split_queue_len--;
> -		list_del(page_deferred_list(page));
> +	/*
> +	 * The THP may be not on LRU at this point, e.g. the old page of
> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
> +	 * with other compound page, e.g. skb, THP destructor is not used
> +	 * anymore and will be removed, so the compound order sounds like
> +	 * the only choice here.
> +	 */
> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
> +		if (!memcg) {
> +			spin_lock_irqsave(&pgdata->split_queue_lock, flags);
> +			if (!list_empty(page_deferred_list(page))) {
> +				pgdata->split_queue_len--;
> +				list_del(page_deferred_list(page));
> +			}
> +			spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
> +		} else {
> +			spin_lock_irqsave(&memcg->split_queue_lock, flags);
> +			if (!list_empty(page_memcg_deferred_list(page))) {
> +				memcg->split_queue_len--;
> +				list_del(page_memcg_deferred_list(page));
> +			}
> +			spin_unlock_irqrestore(&memcg->split_queue_lock, flags);

Such the patterns look like a duplication of functionality, we already have
in list_lru: it handles both root_mem_cgroup and all children memcg.

Should we try to reuse that code, and to switch huge pages shrinker
into generic code?

(Yeah, currently we allocate memcg_cache_ida IDS only for kmem, but we may
 consider to allocate them for any cases, since now we have new memcg shrinkers
 like you introduce).

[...]

Thanks,
Kirill

