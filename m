Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8037BC282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:22:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 051212082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:22:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 051212082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73CCE6B026F; Mon, 10 Jun 2019 04:22:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C7236B0270; Mon, 10 Jun 2019 04:22:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B59A6B0271; Mon, 10 Jun 2019 04:22:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0D716B026F
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:22:03 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id c4so1723693lfh.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:22:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zIdhBSREihM4eazWwzmdYaAJOT/oT6HiQLq4Eti0VtA=;
        b=SEe0hBmLR4row3UesGQAFHz2WfB5s8kmA1fa0wrvrkTf0ZWOf++FmUDYBcSeccjLhA
         wBz2bJe+ZmKy5/ErZAs2DsXE7XEtHFRiZytZOwRWCqkiAwk0Xqg1KGS+Hwye+nMmPeV2
         nv/Tk3PaaSZCXpbWmdZi1PiDl7cjqbZH8sjOeY/sMrEG7L4DZMpkYf0d8I5/6kPpLgr1
         FdDO6PjiHM4MxIYcNu2zZ4y9PaBcBwpUP/rlm3Vgza/q7q4BMM79l618r7XD+JWHi766
         79OuuKQ0XHbQUmn878FvZ5bWvZ3rwH0lWOtV+C9AYgmrHHCIAYP6fH6uzb1u4QYdP05k
         j7LA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXkP05wac6MiIJyU3TpmHMkd+ahKA/veJya+0TtJ/KQrrVG36jw
	Um/3wJFl5HFlIMxdHH9gy4Vm2c6EkKt6K9co7ghvm98OQTMWH9EDqCfXUpLnXQxf5Rejvf0Bd6u
	4Q8se8Ymv4MqFED5qFi9xRjkypAwxDdKzXU5C3KSv87BeVJlvSEOQ3kJzY+i++haWhQ==
X-Received: by 2002:a2e:8602:: with SMTP id a2mr9229841lji.206.1560154923157;
        Mon, 10 Jun 2019 01:22:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzWN/WZ57poIKqfMvWq9QzyyUiEMRdYlXrlJR/EPioTDEWZnZVTXRMrook31BAxgFW9Q/V
X-Received: by 2002:a2e:8602:: with SMTP id a2mr9229745lji.206.1560154921230;
        Mon, 10 Jun 2019 01:22:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560154921; cv=none;
        d=google.com; s=arc-20160816;
        b=uzxxzbofw2Qj+7UmF5y7hM45+qKZ1P3WMyWpQhqT40DKdUQN6aOPL17WDWXNSBkmV6
         cL03kAIjS4E2uHw39AsB84bIAks9h3EKsbHRNEJl2EU8OWL1663BktG/4kpUb0yVCy9q
         4kz6F64lB4oGWE68nnxqib3KsqKKYjv3mlzjxaDjdMoETv+BaaiK6bcMeX1MEPjfA7du
         23QMJ43TVXFnOdhmPcsdS2rzR4vKGKcEX7OKZSPkPjqyzqv4hS2mLZxcYMnzGsHoQX+z
         DJ1jWaSMQmY359K7HPuEeWpB3zSeQKjyuV22SD7fz2JhgYF9lkJz1WTNejvMnu9L599F
         T1xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zIdhBSREihM4eazWwzmdYaAJOT/oT6HiQLq4Eti0VtA=;
        b=dZiXOd+JtZOU2VHhWG65zBOfPLt9b3XrN1KIFgcXAjwEy2/g8Nh2heKIDgfSNJzSkJ
         3vfMLILXzVV6vLdwMeNErVTMdg1shfsInz5a2VaBeFgwPHegOgf49N0jEN5vN6GoQFTC
         lDqvt9aHy4Jq4L5VZ5j0R+M1d/GWLhZrojZzZEbVUdgYGN9M1scGnWlSvZY4zldhEUNJ
         GP/XnYWwUIkX0aLQS+uggxDIlh6jCsu+hiib4VrBYAJQbWop7WZ58Fzo6T7KkxqbdN2X
         5xjFvm6ofOYQoNbeygj7uLCcWeCAThLArw2J95PJaG4aZ/MRzdibvcEQ0206FrYAqASr
         Q7RA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q2si768630ljq.75.2019.06.10.01.22.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:22:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1haFYy-0001aZ-Pc; Mon, 10 Jun 2019 11:21:56 +0300
Subject: Re: [PATCH 2/4] mm: thp: make deferred split shrinker memcg aware
To: Yang Shi <yang.shi@linux.alibaba.com>, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559887659-23121-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <b26a9a64-6f74-d2a0-121a-9cfccbe201d5@virtuozzo.com>
Date: Mon, 10 Jun 2019 11:21:55 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1559887659-23121-3-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Yang,

On 07.06.2019 09:07, Yang Shi wrote:
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
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/huge_mm.h    | 15 ++++++++++
>  include/linux/memcontrol.h |  4 +++
>  include/linux/mm_types.h   |  1 +
>  mm/huge_memory.c           | 71 +++++++++++++++++++++++++++++++++-------------
>  mm/memcontrol.c            | 19 +++++++++++++
>  mm/swap.c                  |  4 +++
>  6 files changed, 94 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 7cd5c15..8137c3a 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -250,6 +250,17 @@ static inline bool thp_migration_supported(void)
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
> +extern void del_thp_from_deferred_split_queue(struct page *);
> +
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> @@ -368,6 +379,10 @@ static inline bool thp_migration_supported(void)
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
> index bc74d6a..5d3c10c 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -316,6 +316,10 @@ struct mem_cgroup {
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
> index 8ec38b1..4eabf80 100644
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
> index 81cf759..3307697 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -492,10 +492,15 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>  	return pmd;
>  }
>  
> -static inline struct list_head *page_deferred_list(struct page *page)
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

memory_cgrp_subsys is not early initialized, so at the beginning of boot
root_mem_cgroup is NULL, and pages will use &pgdat->deferred_split_queue
list head. But after root_mem_cgroup is initialized, another list head
will be used, won't it?! So there will be two different list heads used
for same cgroup.

This may be a reason of a problem (I won't say you, where the problem will
occur).

>  }
>  
>  void prep_transhuge_page(struct page *page)
> @@ -2658,7 +2663,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  {
>  	struct page *head = compound_head(page);
>  	struct pglist_data *pgdata = NODE_DATA(page_to_nid(head));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue = get_deferred_split_queue(page);
>  	struct anon_vma *anon_vma = NULL;
>  	struct address_space *mapping = NULL;
>  	int count, mapcount, extra_pins, ret;
> @@ -2792,25 +2797,36 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  	return ret;
>  }
>  
> -void free_transhuge_page(struct page *page)
> +void del_thp_from_deferred_split_queue(struct page *page)
>  {
> -	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> -	if (!list_empty(page_deferred_list(page))) {
> -		ds_queue->split_queue_len--;
> -		list_del(page_deferred_list(page));
> +	/*
> +	 * The THP may be not on LRU at this point, e.g. the old page of
> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
> +	 * with other compound page, e.g. skb, THP destructor is not used
> +	 * anymore and will be removed, so the compound order sounds like
> +	 * the only choice here.
> +	 */
> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
> +		struct deferred_split *ds_queue = get_deferred_split_queue(page);
> +		unsigned long flags;
> +		spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> +			if (!list_empty(page_deferred_list(page))) {
> +				ds_queue->split_queue_len--;
> +				list_del(page_deferred_list(page));
> +			}
> +		spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  	}
> -	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
> +}
> +
> +void free_transhuge_page(struct page *page)
> +{
>  	free_compound_page(page);
>  }
>  
>  void deferred_split_huge_page(struct page *page)
>  {
> -	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue = get_deferred_split_queue(page);
> +	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
>  	unsigned long flags;
>  
>  	VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> @@ -2820,6 +2836,9 @@ void deferred_split_huge_page(struct page *page)
>  		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
>  		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
>  		ds_queue->split_queue_len++;
> +		if (memcg)
> +			memcg_set_shrinker_bit(memcg, page_to_nid(page),
> +					       deferred_split_shrinker.id);
>  	}
>  	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  }
> @@ -2827,8 +2846,15 @@ void deferred_split_huge_page(struct page *page)
>  static unsigned long deferred_split_count(struct shrinker *shrink,
>  		struct shrink_control *sc)
>  {
> -	struct pglist_data *pgdata = NODE_DATA(sc->nid);
> -	struct deferred_split *ds_queue = &pgdata->deferred_split_queue;
> +	struct deferred_split *ds_queue;
> +
> +	if (!sc->memcg) {
> +		struct pglist_data *pgdata = NODE_DATA(sc->nid);
> +		ds_queue = &pgdata->deferred_split_queue;
> +		return READ_ONCE(ds_queue->split_queue_len);
> +	}
> +
> +	ds_queue = &sc->memcg->deferred_split_queue;
>  	return READ_ONCE(ds_queue->split_queue_len);
>  }
>  
> @@ -2836,12 +2862,17 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
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
> +	if (sc->memcg)
> +		ds_queue = &sc->memcg->deferred_split_queue;
> +	else
> +		ds_queue = &pgdata->deferred_split_queue;
> +
>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>  	/* Take pin on all head pages to avoid freeing them under us */
>  	list_for_each_safe(pos, next, &ds_queue->split_queue) {
> @@ -2888,7 +2919,7 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>  	.count_objects = deferred_split_count,
>  	.scan_objects = deferred_split_scan,
>  	.seeks = DEFAULT_SEEKS,
> -	.flags = SHRINKER_NUMA_AWARE,
> +	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
>  };
>  
>  #ifdef CONFIG_DEBUG_FS
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e50a2db..fe7e544 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4579,6 +4579,11 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
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
> @@ -4949,6 +4954,20 @@ static int mem_cgroup_move_account(struct page *page,
>  		__mod_memcg_state(to, NR_WRITEBACK, nr_pages);
>  	}
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (compound && !list_empty(page_deferred_list(page))) {
> +		spin_lock(&from->deferred_split_queue.split_queue_lock);
> +		list_del(page_deferred_list(page));
> +		from->deferred_split_queue.split_queue_len--;
> +		spin_unlock(&from->deferred_split_queue.split_queue_lock);

Won't be better to assign

page->mem_cgroup = to;

after removing from one list and before linking to another list?
There is possible no a problem, but another people writing code
on top of this may not expect such the behavior.
> +		spin_lock(&to->deferred_split_queue.split_queue_lock);
> +		list_add_tail(page_deferred_list(page),
> +			      &to->deferred_split_queue.split_queue);
> +		to->deferred_split_queue.split_queue_len++;
> +		spin_unlock(&to->deferred_split_queue.split_queue_lock);
> +	}
> +#endif
>  	/*
>  	 * It is safe to change page->mem_cgroup here because the page
>  	 * is referenced, charged, and isolated - we can't race with
> diff --git a/mm/swap.c b/mm/swap.c
> index 3a75722..3348295 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -69,6 +69,10 @@ static void __page_cache_release(struct page *page)
>  		del_page_from_lru_list(page, lruvec, page_off_lru(page));
>  		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
>  	}
> +
> +	/* Delete THP from deferred split queue before memcg uncharge */
> +	del_thp_from_deferred_split_queue(page);
> +
>  	__ClearPageWaiters(page);
>  	mem_cgroup_uncharge(page);
>  }

