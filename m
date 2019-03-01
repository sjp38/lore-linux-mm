Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80A6CC10F06
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:46:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3604F20848
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 19:46:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3604F20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFABF8E0003; Fri,  1 Mar 2019 14:46:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A84088E0001; Fri,  1 Mar 2019 14:46:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972918E0003; Fri,  1 Mar 2019 14:46:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4488E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 14:46:37 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id p9so4357711ljb.16
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 11:46:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/9pYijVspOTO1OQlh3GdyD/R1MCNfqHdIZs0yu+GNAo=;
        b=TGuREvFF0ILLRiKaUapE7hGcG8jJ4Z2mL2+mrvMCqM6DCW+UgMhJvDCbctnJyDECQO
         9t9vX6mauI161rJFwOfDW4Ky2S+BdjSEBagmS2dBfVV0Gtq3e257ewEdJ73OXIdX51bV
         K6wT0ywuaZ0IYLM3DXjW5aWw4gxxgeoAt9DJ4gJqWGYGYOLnDbbjVkIzrhcObn9zsHAc
         KQO2nVNaQaMR05DKpiSgOA4UKljYZTpzbO9/VkUG1dLPk1vcWWdM89swizPwB18AMptI
         yxfe0xovChcYmVDlpBKTWo3rcdrBr7zpDW6UJ8khnwLjnudb93Q7YEYzoB6Tfc5e1qPi
         cA9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV/LkM+Fyv8XNnl+VjyjjJcVFhkGj0v00eFDS0XdRTxKLb01qkG
	P7Qyxx/Poj6nVtcisR8pygfqorqtOhJCUBhSjffZgN0eiN9qy6dTT1kV3ugHFE+Hj1NIC/RaNAp
	oTGRxcazJ55bRn1Cc7ZjC6e2lpRqTsOK5B5qVw0ChOi6DtPN5hVWt1JaG6bK7slVLig==
X-Received: by 2002:ac2:43b8:: with SMTP id t24mr4073237lfl.81.1551469596354;
        Fri, 01 Mar 2019 11:46:36 -0800 (PST)
X-Google-Smtp-Source: APXvYqwGdPO9dlQKmmCHxLpJV34JduLYAG9PxedMqEgDGWIRE46/oZE7nJoA4jf7cLMu2nqObUmn
X-Received: by 2002:ac2:43b8:: with SMTP id t24mr4073193lfl.81.1551469594890;
        Fri, 01 Mar 2019 11:46:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551469594; cv=none;
        d=google.com; s=arc-20160816;
        b=z6HOmzMy/LMZ7OWZ3vnN4/+/JCW+R9ED+DbqiUnMcqBIzt+oT5NKTCkyMc/t397Tlz
         CN8CXAoxgOkNBCZz0+jOHUFWEFPqt/d5scZZ9w9F1DeqVyE4gnHy1fue6yAggzCYN3Gh
         JfDiHyP+tFnUcCNlTxxdrUJM7SjcoQ7taqTiZSW0jCgi8ZQUymSv6W+MWBJfr6q94uJv
         gZjmvGBKW1yf7S7qWsFU8h7DHeVOWet5QjVe12IAiHGLtoXOKwr4Regu+90PhfAdlEkl
         sKDMa0xqgEuaBZve2WHUtVi8m/6SVfv6sGU5g39mspGCm2jhTAW8/qzMKFuLWntPNEd/
         Eg0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/9pYijVspOTO1OQlh3GdyD/R1MCNfqHdIZs0yu+GNAo=;
        b=g4DRElnsJYmIluntJpisWstHaMmxJ5FTgahdcP9oEAQGLz0qm2IB9tWbbBEsR8vMQe
         UeHBibNHMVontso8kT5Z4nUpAjTqfhcSHTQzbLmf1EaRt3/y6tnDf9RqIqnp46nqg6e9
         f13mSxgOf/rtdUEctSov8v0LHdfxVA27mmW4Z6LsDZroWozZJrMcc549WO/5UdTTtzan
         pFBFrDO78fsk508oXtieicUN493gtlqiFezNEhXkhMQ/+kmuArCGKoHHHNEjWE0PhcYh
         ReU1+qAwkNWeyrNNWNaOmNbAISaIOT/KE5NKRJBWQKZkKqDNH5o23vIiByiHnqEKdu3Q
         ErdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id s9si17421154lje.100.2019.03.01.11.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 11:46:34 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzo6q-0007Uo-RS; Fri, 01 Mar 2019 22:46:17 +0300
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
 Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>,
 Shakeel Butt <shakeelb@google.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
 <20190222191552.GA15922@cmpxchg.org>
 <f752c208-599c-9b5a-bc42-e4282df43616@virtuozzo.com>
 <7c915942-6f52-e7a4-b879-e4c99dd65968@virtuozzo.com>
 <20190301174907.GA2375@cmpxchg.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <51ac7aaa-6890-c674-854d-1e2d132b83f9@virtuozzo.com>
Date: Fri, 1 Mar 2019 22:46:34 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190301174907.GA2375@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/1/19 8:49 PM, Johannes Weiner wrote:
> Hello Andrey,
> 
> On Fri, Mar 01, 2019 at 01:38:26PM +0300, Andrey Ryabinin wrote:
>> On 2/26/19 3:50 PM, Andrey Ryabinin wrote:
>>> On 2/22/19 10:15 PM, Johannes Weiner wrote:
>>>> On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
>>>>> In a presence of more than 1 memory cgroup in the system our reclaim
>>>>> logic is just suck. When we hit memory limit (global or a limit on
>>>>> cgroup with subgroups) we reclaim some memory from all cgroups.
>>>>> This is sucks because, the cgroup that allocates more often always wins.
>>>>> E.g. job that allocates a lot of clean rarely used page cache will push
>>>>> out of memory other jobs with active relatively small all in memory
>>>>> working set.
>>>>>
>>>>> To prevent such situations we have memcg controls like low/max, etc which
>>>>> are supposed to protect jobs or limit them so they to not hurt others.
>>>>> But memory cgroups are very hard to configure right because it requires
>>>>> precise knowledge of the workload which may vary during the execution.
>>>>> E.g. setting memory limit means that job won't be able to use all memory
>>>>> in the system for page cache even if the rest the system is idle.
>>>>> Basically our current scheme requires to configure every single cgroup
>>>>> in the system.
>>>>>
>>>>> I think we can do better. The idea proposed by this patch is to reclaim
>>>>> only inactive pages and only from cgroups that have big
>>>>> (!inactive_is_low()) inactive list. And go back to shrinking active lists
>>>>> only if all inactive lists are low.
>>>>
>>>> Yes, you are absolutely right.
>>>>
>>>> We shouldn't go after active pages as long as there are plenty of
>>>> inactive pages around. That's the global reclaim policy, and we
>>>> currently fail to translate that well to cgrouped systems.
>>>>
>>>> Setting group protections or limits would work around this problem,
>>>> but they're kind of a red herring. We shouldn't ever allow use-once
>>>> streams to push out hot workingsets, that's a bug.
>>>>
>>>>> @@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>>>>>  
>>>>>  		scan >>= sc->priority;
>>>>>  
>>>>> +		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
>>>>> +						file, memcg, sc, false))
>>>>> +			scan = 0;
>>>>> +
>>>>>  		/*
>>>>>  		 * If the cgroup's already been deleted, make sure to
>>>>>  		 * scrape out the remaining cache.
>>>>> @@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>>>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>>>>>  	unsigned long nr_reclaimed, nr_scanned;
>>>>>  	bool reclaimable = false;
>>>>> +	bool retry;
>>>>>  
>>>>>  	do {
>>>>>  		struct mem_cgroup *root = sc->target_mem_cgroup;
>>>>> @@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>>>  		};
>>>>>  		struct mem_cgroup *memcg;
>>>>>  
>>>>> +		retry = false;
>>>>> +
>>>>>  		memset(&sc->nr, 0, sizeof(sc->nr));
>>>>>  
>>>>>  		nr_reclaimed = sc->nr_reclaimed;
>>>>> @@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>>>  			}
>>>>>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>>>>>  
>>>>> +		if ((sc->nr_scanned - nr_scanned) == 0 &&
>>>>> +		     !sc->may_shrink_active) {
>>>>> +			sc->may_shrink_active = 1;
>>>>> +			retry = true;
>>>>> +			continue;
>>>>> +		}
>>>>
>>>> Using !scanned as the gate could be a problem. There might be a cgroup
>>>> that has inactive pages on the local level, but when viewed from the
>>>> system level the total inactive pages in the system might still be low
>>>> compared to active ones. In that case we should go after active pages.
>>>>
>>>> Basically, during global reclaim, the answer for whether active pages
>>>> should be scanned or not should be the same regardless of whether the
>>>> memory is all global or whether it's spread out between cgroups.
>>>>
>>>> The reason this isn't the case is because we're checking the ratio at
>>>> the lruvec level - which is the highest level (and identical to the
>>>> node counters) when memory is global, but it's at the lowest level
>>>> when memory is cgrouped.
>>>>
>>>> So IMO what we should do is:
>>>>
>>>> - At the beginning of global reclaim, use node_page_state() to compare
>>>>   the INACTIVE_FILE:ACTIVE_FILE ratio and then decide whether reclaim
>>>>   can go after active pages or not. Regardless of what the ratio is in
>>>>   individual lruvecs.
>>>>
>>>> - And likewise at the beginning of cgroup limit reclaim, walk the
>>>>   subtree starting at sc->target_mem_cgroup, sum up the INACTIVE_FILE
>>>>   and ACTIVE_FILE counters, and make inactive_is_low() decision on
>>>>   those sums.
>>>>
>>>
>>> Sounds reasonable.
>>>
>>
>> On the second thought it seems to be better to keep the decision on lru level.
>> There are couple reasons for this:
>>
>> 1) Using bare node_page_state() (or sc->targe_mem_cgroup's total_[in]active counters) would be wrong.
>>  Because some cgroups might have protection set (memory.low) and we must take it into account. Also different
>> cgroups have different available swap space/memory.swappiness and it must be taken into account as well to.
>>
>> So it has to be yet another full memcg-tree iteration.
> 
> It should be possible to take that into account on the first iteration
> and adjust the inactive/active counters in proportion to how much of
> the cgroup's total memory is exempt by memory.low or min, right?
> 

Should be possible, more complexity though to this subtle code.


>> 2) Let's consider simple case. Two cgroups, one with big 'active' set of pages the other allocates one-time used pages.
>> So the total inactive is low, thus checking inactive ratio on higher level will result in reclaiming pages.
>> While with check on lru-level only inactive will be reclaimed.
> 
> It's the other way around. Let's say you have two cgroups, A and B:
> 
>         A:  500M inactive   10G active -> inactive is low
>         B:   10G inactive  500M active -> inactive is NOT low
>    ----------------------------------------------------------
>    global: 10.5G inactive 10.5G active -> inactive is NOT low
> 
> Checking locally will scan active pages from A.

No, checking locally will not scan active from A. Initial state of sc->may_shrink_active = 0, so A group
will be skipped completely, and will reclaim from B. Since overall reclaim was successful, sc->may_shrink_active remain 0
and A will be protected as long as B supply enough inactive pages. 

> Checking globally will
> not, because there is plenty of use-once pages from B.
> 

That is correct. So in this example global vs local check will not make a difference.

> So if you check globally, without any protection, A and B compete
> evenly during global reclaim. Under the same reclaim pressure, A has
> managed to activate most of its pages whereas B has not. That means A
> is hotter and B provides the better reclaim candidates.
> 
> If you apply this decision locally, on the other hand, you are no
> longer aging the groups at the same rate. And then the LRU orders
> between groups will no longer be comparable, and you won't be
> reclaiming the coldest memory in the system anymore.
> 

I really don't see any how global check will make any difference in this example.
In both cases, we reclaim only from B and don't touch A. And this what we actually want.

