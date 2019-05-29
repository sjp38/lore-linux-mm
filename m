Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DD6AC04AB6
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:44:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B2BDB21019
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 02:44:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2BDB21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E5F36B026B; Tue, 28 May 2019 22:44:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794F96B0271; Tue, 28 May 2019 22:44:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65C986B0279; Tue, 28 May 2019 22:44:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 299006B026B
	for <linux-mm@kvack.org>; Tue, 28 May 2019 22:44:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bb9so547247plb.2
        for <linux-mm@kvack.org>; Tue, 28 May 2019 19:44:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=2LaFdGqLmHYFzCVRO112Dv1lP6yiH7evW+k7ukAXZjc=;
        b=NgvGS1ZPY+Yto5iFaHQjrqxWjYXJ5NFCg+NSTHHOti7stGapZEJEgBT4LLV5DPj7Y7
         kWuJdxLM1hS8x1asTcvsvqSTUEd8kaF8PRSWlw8uDsppyVGrDwPXTniPpZV4UU4frerS
         8Wft48S3mrGTsxTN3J9/3KTrsRLP/gKOvEs94BVz7dYdl0VkgCtSklwEMoS44Shey8MK
         3C2iD5hKplg7wOB8pGGfk5ytAUw//HM1pRBNaDkSChPIucL8/sv4dSCEy6AQNs2dAhXD
         XGcALh6dSGPIiVrMhrxgWgoFr0PiBlvgUKD1i08GxCJXIsQY/a8pndWTkVl+pGkhR8Cn
         mQWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUkEitek/Hz4wvWFqXXMlvnpfmyTckCypvJD5J8lZS65KSZzH7l
	rwFgn3bCgmVqeWJ1K56f8B0H50Q8KwUej+wjEiee+4A2oElnpS4Gqr+eUQbSUuCxLb/W94dj0Ai
	p4nYvAQzB7K5PMB1vwCwkAKCzM5NlK3khojimBOIZiKNeT8VkJjGFHtJ5klkr+OE27g==
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr92351139pls.50.1559097840755;
        Tue, 28 May 2019 19:44:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwc5UQxJ8ru0kpZH60q2CL5D3Xc+u2LoARJUbBgaAWiEMj/Iey484ulpAcon4Zceqmp42fd
X-Received: by 2002:a17:902:b949:: with SMTP id h9mr92351086pls.50.1559097839868;
        Tue, 28 May 2019 19:43:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559097839; cv=none;
        d=google.com; s=arc-20160816;
        b=W1RnZy4hvxffeYCqTKPkL/+ZiiQYMtxbVqlg8mc/TMBx7qCJcoWR8WoOdUtzCLhBeS
         2EaSrIJqZEI8Jo7lR6vo2qCEMYh/QZO3P+iGAnrUS5AAiO3ripB/PUqx/EcG6y/0TEUM
         qdH7fT+nBFEDj4HPWuLII585JFGoNYVODSVVNm9qEQ227LkCas292CCTm4vI61FXnCar
         5F7V2PA38e10YsOfOZqMYWSq6LTi+qhlna5ufFrVfVQ6Psx17Y8sQyk2OJFx7HSc0T3Q
         DLi9MR5rZhHqj7AMsQt7L54ZdDkyrpDW2DjS8W1jZMsJRxeZ9ZWyACR0nrFIePnUehcZ
         iCZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2LaFdGqLmHYFzCVRO112Dv1lP6yiH7evW+k7ukAXZjc=;
        b=QAuEQ/jogNoZZ1bT3cnFx24rdQ/hYlaughPGUKpFHge0Ge1g1aLDLRacUDZ0nkI5Vi
         cATeStP2KZcfWrTtrSbKALfWd6tPMsoAl2t88j4qgwr50DBPq0p+Iq9NIsbzMeJBuI5E
         LyvfbCwthr9JRtI/vH5IXgUdCUSN8+aG93Y0RekeXaLftZfSOb3/NagBpLm80lywfkZB
         WXhC0EjMrQIJL3ofrbqGtlG0c3nyPLyrD8qcLQOsBQgY/ASpe6s8kLb4e1X9XyiVFlvE
         jQrB3YqszPIqmqvUvgXxj9x9o3ZTd8ZQrEQdMtsF8sPWDO7YuYtVPubXD+Pyzv/0DfFY
         KWnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id bo4si5108053pjb.63.2019.05.28.19.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 19:43:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TSv4tkL_1559097836;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSv4tkL_1559097836)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 29 May 2019 10:43:57 +0800
Subject: Re: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
To: Kirill Tkhai <ktkhai@virtuozzo.com>, hannes@cmpxchg.org, mhocko@suse.com,
 kirill.shutemov@linux.intel.com, hughd@google.com, shakeelb@google.com,
 akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
 <487665fe-c792-5078-292a-481f33d31d30@virtuozzo.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f57d9c67-8e20-b430-2ca3-74fa2f31415a@linux.alibaba.com>
Date: Wed, 29 May 2019 10:43:56 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <487665fe-c792-5078-292a-481f33d31d30@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/28/19 10:42 PM, Kirill Tkhai wrote:
> Hi, Yang,
>
> On 28.05.2019 15:44, Yang Shi wrote:
>> Currently THP deferred split shrinker is not memcg aware, this may cause
>> premature OOM with some configuration. For example the below test would
>> run into premature OOM easily:
>>
>> $ cgcreate -g memory:thp
>> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
>> $ cgexec -g memory:thp transhuge-stress 4000
>>
>> transhuge-stress comes from kernel selftest.
>>
>> It is easy to hit OOM, but there are still a lot THP on the deferred
>> split queue, memcg direct reclaim can't touch them since the deferred
>> split shrinker is not memcg aware.
>>
>> Convert deferred split shrinker memcg aware by introducing per memcg
>> deferred split queue.  The THP should be on either per node or per memcg
>> deferred split queue if it belongs to a memcg.  When the page is
>> immigrated to the other memcg, it will be immigrated to the target
>> memcg's deferred split queue too.
>>
>> And, move deleting THP from deferred split queue in page free before
>> memcg uncharge so that the page's memcg information is available.
>>
>> Reuse the second tail page's deferred_list for per memcg list since the
>> same THP can't be on multiple deferred split queues.
>>
>> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shakeel Butt <shakeelb@google.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   include/linux/huge_mm.h    |  24 ++++++
>>   include/linux/memcontrol.h |   6 ++
>>   include/linux/mm_types.h   |   7 +-
>>   mm/huge_memory.c           | 182 +++++++++++++++++++++++++++++++++------------
>>   mm/memcontrol.c            |  20 +++++
>>   mm/swap.c                  |   4 +
>>   6 files changed, 194 insertions(+), 49 deletions(-)
>>
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 7cd5c15..f6d1cde 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -250,6 +250,26 @@ static inline bool thp_migration_supported(void)
>>   	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
>>   }
>>   
>> +static inline struct list_head *page_deferred_list(struct page *page)
>> +{
>> +	/*
>> +	 * Global deferred list in the second tail pages is occupied by
>> +	 * compound_head.
>> +	 */
>> +	return &page[2].deferred_list;
>> +}
>> +
>> +static inline struct list_head *page_memcg_deferred_list(struct page *page)
>> +{
>> +	/*
>> +	 * Memcg deferred list in the second tail pages is occupied by
>> +	 * compound_head.
>> +	 */
>> +	return &page[2].memcg_deferred_list;
>> +}
>> +
>> +extern void del_thp_from_deferred_split_queue(struct page *);
>> +
>>   #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>>   #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>>   #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
>> @@ -368,6 +388,10 @@ static inline bool thp_migration_supported(void)
>>   {
>>   	return false;
>>   }
>> +
>> +static inline void del_thp_from_deferred_split_queue(struct page *page)
>> +{
>> +}
>>   #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>   
>>   #endif /* _LINUX_HUGE_MM_H */
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index bc74d6a..9ff5fab 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -316,6 +316,12 @@ struct mem_cgroup {
>>   	struct list_head event_list;
>>   	spinlock_t event_list_lock;
>>   
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +	struct list_head split_queue;
>> +	unsigned long split_queue_len;
>> +	spinlock_t split_queue_lock;
>> +#endif
>> +
>>   	struct mem_cgroup_per_node *nodeinfo[0];
>>   	/* WARNING: nodeinfo must be the last member here */
>>   };
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 8ec38b1..405f5e6 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -139,7 +139,12 @@ struct page {
>>   		struct {	/* Second tail page of compound page */
>>   			unsigned long _compound_pad_1;	/* compound_head */
>>   			unsigned long _compound_pad_2;
>> -			struct list_head deferred_list;
>> +			union {
>> +				/* Global THP deferred split list */
>> +				struct list_head deferred_list;
>> +				/* Memcg THP deferred split list */
>> +				struct list_head memcg_deferred_list;
> Why we need two namesakes for this list entry?
>
> For me it looks redundantly: it does not give additional information,
> but it leads to duplication (and we have two helpers page_deferred_list()
> and page_memcg_deferred_list() instead of one).

Yes, kind of. Actually I was also wondering if this is worth or not. My 
point is this may improve the code readability. We can figure out what 
split queue (per node or per memcg) is being manipulated just by the 
name of the list.

If the most people thought this is unnecessary, I'm definitely ok to 
just keep one name.

>
>> +			};
>>   		};
>>   		struct {	/* Page table pages */
>>   			unsigned long _pt_pad_1;	/* compound_head */
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 9f8bce9..0b9cfe1 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -492,12 +492,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>>   	return pmd;
>>   }
>>   
>> -static inline struct list_head *page_deferred_list(struct page *page)
>> -{
>> -	/* ->lru in the tail pages is occupied by compound_head. */
>> -	return &page[2].deferred_list;
>> -}
>> -
>>   void prep_transhuge_page(struct page *page)
>>   {
>>   	/*
>> @@ -505,7 +499,10 @@ void prep_transhuge_page(struct page *page)
>>   	 * as list_head: assuming THP order >= 2
>>   	 */
>>   
>> -	INIT_LIST_HEAD(page_deferred_list(page));
>> +	if (mem_cgroup_disabled())
>> +		INIT_LIST_HEAD(page_deferred_list(page));
>> +	else
>> +		INIT_LIST_HEAD(page_memcg_deferred_list(page));
>>   	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>>   }
>>   
>> @@ -2664,6 +2661,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>   	bool mlocked;
>>   	unsigned long flags;
>>   	pgoff_t end;
>> +	struct mem_cgroup *memcg = head->mem_cgroup;
>>   
>>   	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
>>   	VM_BUG_ON_PAGE(!PageLocked(page), page);
>> @@ -2744,17 +2742,30 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>   	}
>>   
>>   	/* Prevent deferred_split_scan() touching ->_refcount */
>> -	spin_lock(&pgdata->split_queue_lock);
>> +	if (!memcg)
>> +		spin_lock(&pgdata->split_queue_lock);
>> +	else
>> +		spin_lock(&memcg->split_queue_lock);
>>   	count = page_count(head);
>>   	mapcount = total_mapcount(head);
>>   	if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
>> -		if (!list_empty(page_deferred_list(head))) {
>> -			pgdata->split_queue_len--;
>> -			list_del(page_deferred_list(head));
>> +		if (!memcg) {
>> +			if (!list_empty(page_deferred_list(head))) {
>> +				pgdata->split_queue_len--;
>> +				list_del(page_deferred_list(head));
>> +			}
>> +		} else {
>> +			if (!list_empty(page_memcg_deferred_list(head))) {
>> +				memcg->split_queue_len--;
>> +				list_del(page_memcg_deferred_list(head));
>> +			}
>>   		}
>>   		if (mapping)
>>   			__dec_node_page_state(page, NR_SHMEM_THPS);
>> -		spin_unlock(&pgdata->split_queue_lock);
>> +		if (!memcg)
>> +			spin_unlock(&pgdata->split_queue_lock);
>> +		else
>> +			spin_unlock(&memcg->split_queue_lock);
>>   		__split_huge_page(page, list, end, flags);
>>   		if (PageSwapCache(head)) {
>>   			swp_entry_t entry = { .val = page_private(head) };
>> @@ -2771,7 +2782,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>   			dump_page(page, "total_mapcount(head) > 0");
>>   			BUG();
>>   		}
>> -		spin_unlock(&pgdata->split_queue_lock);
>> +		if (!memcg)
>> +			spin_unlock(&pgdata->split_queue_lock);
>> +		else
>> +			spin_unlock(&memcg->split_queue_lock);
>>   fail:		if (mapping)
>>   			xa_unlock(&mapping->i_pages);
>>   		spin_unlock_irqrestore(&pgdata->lru_lock, flags);
>> @@ -2791,17 +2805,40 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>   	return ret;
>>   }
>>   
>> -void free_transhuge_page(struct page *page)
>> +void del_thp_from_deferred_split_queue(struct page *page)
>>   {
>>   	struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
>>   	unsigned long flags;
>> +	struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
>>   
>> -	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
>> -	if (!list_empty(page_deferred_list(page))) {
>> -		pgdata->split_queue_len--;
>> -		list_del(page_deferred_list(page));
>> +	/*
>> +	 * The THP may be not on LRU at this point, e.g. the old page of
>> +	 * NUMA migration.  And PageTransHuge is not enough to distinguish
>> +	 * with other compound page, e.g. skb, THP destructor is not used
>> +	 * anymore and will be removed, so the compound order sounds like
>> +	 * the only choice here.
>> +	 */
>> +	if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
>> +		if (!memcg) {
>> +			spin_lock_irqsave(&pgdata->split_queue_lock, flags);
>> +			if (!list_empty(page_deferred_list(page))) {
>> +				pgdata->split_queue_len--;
>> +				list_del(page_deferred_list(page));
>> +			}
>> +			spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
>> +		} else {
>> +			spin_lock_irqsave(&memcg->split_queue_lock, flags);
>> +			if (!list_empty(page_memcg_deferred_list(page))) {
>> +				memcg->split_queue_len--;
>> +				list_del(page_memcg_deferred_list(page));
>> +			}
>> +			spin_unlock_irqrestore(&memcg->split_queue_lock, flags);
> Such the patterns look like a duplication of functionality, we already have
> in list_lru: it handles both root_mem_cgroup and all children memcg.

Would you please point me to some example code?

>
> Should we try to reuse that code, and to switch huge pages shrinker
> into generic code?

Definitely if it is feasible.

>
> (Yeah, currently we allocate memcg_cache_ida IDS only for kmem, but we may
>   consider to allocate them for any cases, since now we have new memcg shrinkers
>   like you introduce).

The patch 3/3 removes the restriction.

>
> [...]
>
> Thanks,
> Kirill

