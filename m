Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49B01C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:19:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB5D420B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:19:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB5D420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3232E6B0005; Thu, 13 Jun 2019 04:19:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D3096B0006; Thu, 13 Jun 2019 04:19:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C2DA6B0007; Thu, 13 Jun 2019 04:19:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 985B66B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:19:56 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id x19so2011958ljh.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:19:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8TFL0AAjHtA+k7YSaJbJeskDgFmHLAXfxe3sKV9nrLc=;
        b=M4k3zIQE61Y17gC93qGWHLCDx7YvvqjumdJv17+/93FeK006eXmqkB8pLz566vuua6
         WppfyiQ0YYIyWeW14UWJitSqzly4dGRL+J53qApa19a8s+Yol8oKkSqFsG7L661PmvVo
         LPnzgvClmgLROQPg4upKuJ1xxEYrW2/hyKaWHCFuUVtDX8SNCRIX/mA6iC7F86cCWs5y
         +QZfR0xNQTM6SMpd1l5S46OtluTU7aKBLZZDauVDXxUHuGt8BHf8ljhQxoBb20HTktO8
         AgcwTwwmm4GbCXmyyMz321t9m/NtsRurh8ihimU+WUG1QAhxjaWt5S6Znp9blDgRUFXz
         BMzg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXCE4/vd8If2TlKoD1S/uxuDJaLYXQe/CJqr0ZsPd8b1jKvZCYB
	LzSo3IRKyLAld5B9Rq2cwecst8Jsh+TWyQQuBI4fcshDiuXyeXR4xMlgl0BBVtXEHX/BGSVzveh
	QySFnOutB+CAw6NYRIAAGv1wP0aWi7dgt6Sn/Ei9aFlnWAACGopBLwxt4vH8/5M+jYA==
X-Received: by 2002:a19:710b:: with SMTP id m11mr38593566lfc.135.1560413996034;
        Thu, 13 Jun 2019 01:19:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrhFKuImq0Ifmz7ZD2qhNHXUKOLLBmoTtBDXZrTeQCHOva+dNf+H5J7Vbdb+S9SHFRGcGY
X-Received: by 2002:a19:710b:: with SMTP id m11mr38593512lfc.135.1560413994927;
        Thu, 13 Jun 2019 01:19:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560413994; cv=none;
        d=google.com; s=arc-20160816;
        b=v1GsblyybIeON1JtlpeybXdQh5HVAaqDFdIb5yKkrnFW+V9lmto8EZ4PATHkumOMXF
         RM55Ap00ac3tQ2sIn0RBCNbsm8K5YYRBic49D36w+2qAtaB4H9aoVaETc2QuPsqRS+xd
         q8+auQyARKXvRxX/+7OjCpzxV+aMcpbqVeD14HDk4VPJOIV9Td0iBpPirev5IqrZ90AO
         IbdN5cJ1xCzrZ1sqiM2n/GeN3V43aaMyLgWH5tXFOrqYCyazB293HFqWmET7v1702B28
         BuRcG0KANDYQf4vWIH0+TeuIgbOkCAY0i55LwzyN48l1GAKokZygrEl4Vb5T8EeT1j+d
         +OyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8TFL0AAjHtA+k7YSaJbJeskDgFmHLAXfxe3sKV9nrLc=;
        b=dmZ6qh0NvUwC/xDSjWgot8bGOVYVpUKGsbeCKawrnhFTQk+8WcXsrMinJPcl9b3pZq
         XPDUgTjBLnnj4ZDkMeuGSnABd059aOJJLl7HQteXCT03sO5Nzp17mc56V8xZLM6wAaV3
         9zlq/0KwqMMhguxYt1FKUgOjZfQsUirr3hCULyCJuaNKBJIwHNplyXmXESJL5ijfD8d8
         /FiI+WxsLkVxROKGvUebFTBsmD7y7QXRMxZEcwVl268y/BqdsIOh9bhbL6i07kRWuoa2
         cdJKweG/GuIPuSu/uHXhKOy2dzz/vbzk/Uxs9jBJObhH/UUoaT6IT5JtzBInJW4W38SB
         C/XA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id h12si2170200lfm.45.2019.06.13.01.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 01:19:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hbKxa-00084e-89; Thu, 13 Jun 2019 11:19:50 +0300
Subject: Re: [PATCH 1/3] mm: thp: make deferred split shrinker memcg aware
To: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
 mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com,
 shakeelb@google.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559047464-59838-1-git-send-email-yang.shi@linux.alibaba.com>
 <1559047464-59838-2-git-send-email-yang.shi@linux.alibaba.com>
 <487665fe-c792-5078-292a-481f33d31d30@virtuozzo.com>
 <f57d9c67-8e20-b430-2ca3-74fa2f31415a@linux.alibaba.com>
 <20fe4ea6-c1c5-67bb-5c7e-2db0a9af6892@virtuozzo.com>
 <cb1f0ecd-d127-89ec-da2f-47fba1d6ba79@linux.alibaba.com>
 <c82f24d9-035b-e7e8-f8be-3489803a8319@virtuozzo.com>
 <1845149e-cb25-a6be-3979-0348ece3cae0@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <a6129da4-be23-cb65-eff9-3e467308b1fa@virtuozzo.com>
Date: Thu, 13 Jun 2019 11:19:50 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1845149e-cb25-a6be-3979-0348ece3cae0@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.06.2019 20:25, Yang Shi wrote:
> 
> 
> On 6/10/19 1:23 AM, Kirill Tkhai wrote:
>> On 29.05.2019 14:25, Yang Shi wrote:
>>>
>>> On 5/29/19 4:14 PM, Kirill Tkhai wrote:
>>>> On 29.05.2019 05:43, Yang Shi wrote:
>>>>> On 5/28/19 10:42 PM, Kirill Tkhai wrote:
>>>>>> Hi, Yang,
>>>>>>
>>>>>> On 28.05.2019 15:44, Yang Shi wrote:
>>>>>>> Currently THP deferred split shrinker is not memcg aware, this may cause
>>>>>>> premature OOM with some configuration. For example the below test would
>>>>>>> run into premature OOM easily:
>>>>>>>
>>>>>>> $ cgcreate -g memory:thp
>>>>>>> $ echo 4G > /sys/fs/cgroup/memory/thp/memory/limit_in_bytes
>>>>>>> $ cgexec -g memory:thp transhuge-stress 4000
>>>>>>>
>>>>>>> transhuge-stress comes from kernel selftest.
>>>>>>>
>>>>>>> It is easy to hit OOM, but there are still a lot THP on the deferred
>>>>>>> split queue, memcg direct reclaim can't touch them since the deferred
>>>>>>> split shrinker is not memcg aware.
>>>>>>>
>>>>>>> Convert deferred split shrinker memcg aware by introducing per memcg
>>>>>>> deferred split queue.  The THP should be on either per node or per memcg
>>>>>>> deferred split queue if it belongs to a memcg.  When the page is
>>>>>>> immigrated to the other memcg, it will be immigrated to the target
>>>>>>> memcg's deferred split queue too.
>>>>>>>
>>>>>>> And, move deleting THP from deferred split queue in page free before
>>>>>>> memcg uncharge so that the page's memcg information is available.
>>>>>>>
>>>>>>> Reuse the second tail page's deferred_list for per memcg list since the
>>>>>>> same THP can't be on multiple deferred split queues.
>>>>>>>
>>>>>>> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
>>>>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>>>>> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
>>>>>>> Cc: Hugh Dickins <hughd@google.com>
>>>>>>> Cc: Shakeel Butt <shakeelb@google.com>
>>>>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>>>>> ---
>>>>>>>     include/linux/huge_mm.h    |  24 ++++++
>>>>>>>     include/linux/memcontrol.h |   6 ++
>>>>>>>     include/linux/mm_types.h   |   7 +-
>>>>>>>     mm/huge_memory.c           | 182 +++++++++++++++++++++++++++++++++------------
>>>>>>>     mm/memcontrol.c            |  20 +++++
>>>>>>>     mm/swap.c                  |   4 +
>>>>>>>     6 files changed, 194 insertions(+), 49 deletions(-)
>>>>>>>
>>>>>>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>>>>>>> index 7cd5c15..f6d1cde 100644
>>>>>>> --- a/include/linux/huge_mm.h
>>>>>>> +++ b/include/linux/huge_mm.h
>>>>>>> @@ -250,6 +250,26 @@ static inline bool thp_migration_supported(void)
>>>>>>>         return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
>>>>>>>     }
>>>>>>>     +static inline struct list_head *page_deferred_list(struct page *page)
>>>>>>> +{
>>>>>>> +    /*
>>>>>>> +     * Global deferred list in the second tail pages is occupied by
>>>>>>> +     * compound_head.
>>>>>>> +     */
>>>>>>> +    return &page[2].deferred_list;
>>>>>>> +}
>>>>>>> +
>>>>>>> +static inline struct list_head *page_memcg_deferred_list(struct page *page)
>>>>>>> +{
>>>>>>> +    /*
>>>>>>> +     * Memcg deferred list in the second tail pages is occupied by
>>>>>>> +     * compound_head.
>>>>>>> +     */
>>>>>>> +    return &page[2].memcg_deferred_list;
>>>>>>> +}
>>>>>>> +
>>>>>>> +extern void del_thp_from_deferred_split_queue(struct page *);
>>>>>>> +
>>>>>>>     #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>>>>>>>     #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>>>>>>>     #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
>>>>>>> @@ -368,6 +388,10 @@ static inline bool thp_migration_supported(void)
>>>>>>>     {
>>>>>>>         return false;
>>>>>>>     }
>>>>>>> +
>>>>>>> +static inline void del_thp_from_deferred_split_queue(struct page *page)
>>>>>>> +{
>>>>>>> +}
>>>>>>>     #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>>>>>>       #endif /* _LINUX_HUGE_MM_H */
>>>>>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>>>>>> index bc74d6a..9ff5fab 100644
>>>>>>> --- a/include/linux/memcontrol.h
>>>>>>> +++ b/include/linux/memcontrol.h
>>>>>>> @@ -316,6 +316,12 @@ struct mem_cgroup {
>>>>>>>         struct list_head event_list;
>>>>>>>         spinlock_t event_list_lock;
>>>>>>>     +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>>>>>>> +    struct list_head split_queue;
>>>>>>> +    unsigned long split_queue_len;
>>>>>>> +    spinlock_t split_queue_lock;
>>>>>>> +#endif
>>>>>>> +
>>>>>>>         struct mem_cgroup_per_node *nodeinfo[0];
>>>>>>>         /* WARNING: nodeinfo must be the last member here */
>>>>>>>     };
>>>>>>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>>>>>>> index 8ec38b1..405f5e6 100644
>>>>>>> --- a/include/linux/mm_types.h
>>>>>>> +++ b/include/linux/mm_types.h
>>>>>>> @@ -139,7 +139,12 @@ struct page {
>>>>>>>             struct {    /* Second tail page of compound page */
>>>>>>>                 unsigned long _compound_pad_1;    /* compound_head */
>>>>>>>                 unsigned long _compound_pad_2;
>>>>>>> -            struct list_head deferred_list;
>>>>>>> +            union {
>>>>>>> +                /* Global THP deferred split list */
>>>>>>> +                struct list_head deferred_list;
>>>>>>> +                /* Memcg THP deferred split list */
>>>>>>> +                struct list_head memcg_deferred_list;
>>>>>> Why we need two namesakes for this list entry?
>>>>>>
>>>>>> For me it looks redundantly: it does not give additional information,
>>>>>> but it leads to duplication (and we have two helpers page_deferred_list()
>>>>>> and page_memcg_deferred_list() instead of one).
>>>>> Yes, kind of. Actually I was also wondering if this is worth or not. My point is this may improve the code readability. We can figure out what split queue (per node or per memcg) is being manipulated just by the name of the list.
>>>>>
>>>>> If the most people thought this is unnecessary, I'm definitely ok to just keep one name.
>>>>>
>>>>>>> +            };
>>>>>>>             };
>>>>>>>             struct {    /* Page table pages */
>>>>>>>                 unsigned long _pt_pad_1;    /* compound_head */
>>>>>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>>>>>> index 9f8bce9..0b9cfe1 100644
>>>>>>> --- a/mm/huge_memory.c
>>>>>>> +++ b/mm/huge_memory.c
>>>>>>> @@ -492,12 +492,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>>>>>>>         return pmd;
>>>>>>>     }
>>>>>>>     -static inline struct list_head *page_deferred_list(struct page *page)
>>>>>>> -{
>>>>>>> -    /* ->lru in the tail pages is occupied by compound_head. */
>>>>>>> -    return &page[2].deferred_list;
>>>>>>> -}
>>>>>>> -
>>>>>>>     void prep_transhuge_page(struct page *page)
>>>>>>>     {
>>>>>>>         /*
>>>>>>> @@ -505,7 +499,10 @@ void prep_transhuge_page(struct page *page)
>>>>>>>          * as list_head: assuming THP order >= 2
>>>>>>>          */
>>>>>>>     -    INIT_LIST_HEAD(page_deferred_list(page));
>>>>>>> +    if (mem_cgroup_disabled())
>>>>>>> +        INIT_LIST_HEAD(page_deferred_list(page));
>>>>>>> +    else
>>>>>>> +        INIT_LIST_HEAD(page_memcg_deferred_list(page));
>>>>>>>         set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>>>>>>>     }
>>>>>>>     @@ -2664,6 +2661,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>>>>>>         bool mlocked;
>>>>>>>         unsigned long flags;
>>>>>>>         pgoff_t end;
>>>>>>> +    struct mem_cgroup *memcg = head->mem_cgroup;
>>>>>>>           VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
>>>>>>>         VM_BUG_ON_PAGE(!PageLocked(page), page);
>>>>>>> @@ -2744,17 +2742,30 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>>>>>>         }
>>>>>>>           /* Prevent deferred_split_scan() touching ->_refcount */
>>>>>>> -    spin_lock(&pgdata->split_queue_lock);
>>>>>>> +    if (!memcg)
>>>>>>> +        spin_lock(&pgdata->split_queue_lock);
>>>>>>> +    else
>>>>>>> +        spin_lock(&memcg->split_queue_lock);
>>>>>>>         count = page_count(head);
>>>>>>>         mapcount = total_mapcount(head);
>>>>>>>         if (!mapcount && page_ref_freeze(head, 1 + extra_pins)) {
>>>>>>> -        if (!list_empty(page_deferred_list(head))) {
>>>>>>> -            pgdata->split_queue_len--;
>>>>>>> -            list_del(page_deferred_list(head));
>>>>>>> +        if (!memcg) {
>>>>>>> +            if (!list_empty(page_deferred_list(head))) {
>>>>>>> +                pgdata->split_queue_len--;
>>>>>>> +                list_del(page_deferred_list(head));
>>>>>>> +            }
>>>>>>> +        } else {
>>>>>>> +            if (!list_empty(page_memcg_deferred_list(head))) {
>>>>>>> +                memcg->split_queue_len--;
>>>>>>> +                list_del(page_memcg_deferred_list(head));
>>>>>>> +            }
>>>>>>>             }
>>>>>>>             if (mapping)
>>>>>>>                 __dec_node_page_state(page, NR_SHMEM_THPS);
>>>>>>> -        spin_unlock(&pgdata->split_queue_lock);
>>>>>>> +        if (!memcg)
>>>>>>> +            spin_unlock(&pgdata->split_queue_lock);
>>>>>>> +        else
>>>>>>> +            spin_unlock(&memcg->split_queue_lock);
>>>>>>>             __split_huge_page(page, list, end, flags);
>>>>>>>             if (PageSwapCache(head)) {
>>>>>>>                 swp_entry_t entry = { .val = page_private(head) };
>>>>>>> @@ -2771,7 +2782,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>>>>>>                 dump_page(page, "total_mapcount(head) > 0");
>>>>>>>                 BUG();
>>>>>>>             }
>>>>>>> -        spin_unlock(&pgdata->split_queue_lock);
>>>>>>> +        if (!memcg)
>>>>>>> +            spin_unlock(&pgdata->split_queue_lock);
>>>>>>> +        else
>>>>>>> +            spin_unlock(&memcg->split_queue_lock);
>>>>>>>     fail:        if (mapping)
>>>>>>>                 xa_unlock(&mapping->i_pages);
>>>>>>>             spin_unlock_irqrestore(&pgdata->lru_lock, flags);
>>>>>>> @@ -2791,17 +2805,40 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>>>>>>         return ret;
>>>>>>>     }
>>>>>>>     -void free_transhuge_page(struct page *page)
>>>>>>> +void del_thp_from_deferred_split_queue(struct page *page)
>>>>>>>     {
>>>>>>>         struct pglist_data *pgdata = NODE_DATA(page_to_nid(page));
>>>>>>>         unsigned long flags;
>>>>>>> +    struct mem_cgroup *memcg = compound_head(page)->mem_cgroup;
>>>>>>>     -    spin_lock_irqsave(&pgdata->split_queue_lock, flags);
>>>>>>> -    if (!list_empty(page_deferred_list(page))) {
>>>>>>> -        pgdata->split_queue_len--;
>>>>>>> -        list_del(page_deferred_list(page));
>>>>>>> +    /*
>>>>>>> +     * The THP may be not on LRU at this point, e.g. the old page of
>>>>>>> +     * NUMA migration.  And PageTransHuge is not enough to distinguish
>>>>>>> +     * with other compound page, e.g. skb, THP destructor is not used
>>>>>>> +     * anymore and will be removed, so the compound order sounds like
>>>>>>> +     * the only choice here.
>>>>>>> +     */
>>>>>>> +    if (PageTransHuge(page) && compound_order(page) == HPAGE_PMD_ORDER) {
>>>>>>> +        if (!memcg) {
>>>>>>> +            spin_lock_irqsave(&pgdata->split_queue_lock, flags);
>>>>>>> +            if (!list_empty(page_deferred_list(page))) {
>>>>>>> +                pgdata->split_queue_len--;
>>>>>>> +                list_del(page_deferred_list(page));
>>>>>>> +            }
>>>>>>> +            spin_unlock_irqrestore(&pgdata->split_queue_lock, flags);
>>>>>>> +        } else {
>>>>>>> +            spin_lock_irqsave(&memcg->split_queue_lock, flags);
>>>>>>> +            if (!list_empty(page_memcg_deferred_list(page))) {
>>>>>>> +                memcg->split_queue_len--;
>>>>>>> +                list_del(page_memcg_deferred_list(page));
>>>>>>> +            }
>>>>>>> +            spin_unlock_irqrestore(&memcg->split_queue_lock, flags);
>>>>>> Such the patterns look like a duplication of functionality, we already have
>>>>>> in list_lru: it handles both root_mem_cgroup and all children memcg.
>>>>> Would you please point me to some example code?
>>>> I mean that we do almost the same in list_lru_add(): check for whether
>>>> item is already added, find the desired list, maintain the list's len.
>>>>
>>>> It looks all the above we may replace with something like
>>>>
>>>> list_lru_add(defered_thp_lru, page_deferred_list(page))
>>>>
>>>> after necessary preparations (some rewriting of the rest of code is needed).
>>> Aha, I got your point. I'm not quite familiar with that code. I took a quick loot at it, it looks the current APIs are not good enough for deferred split, which needs irqsave/irqrestore version list add/del/move/walk and page refcount bumped version walk.
>> I missed the point about refcount bumping, could you please clarify?
> 
> The deferred_split_scan() need bump refcount for every head page when scanning the deferred split queue.

Why can't we increment refcount in isolate callback of __list_lru_walk_one() function?

Kirill

