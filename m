Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE21CC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7784F20851
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 10:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7784F20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8F808E0003; Fri,  1 Mar 2019 05:38:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3F528E0001; Fri,  1 Mar 2019 05:38:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D551F8E0003; Fri,  1 Mar 2019 05:38:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1828E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 05:38:24 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id c7so3953733ljj.12
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 02:38:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=ckrZQp0PZ2mpaKZo10KFPTYDS8LaJ0tANgFIQmuYBt8=;
        b=tIQcw6yGIRH3Q7uiTHjtYlKgr/CLjwmtnav1o7vLbtezvvfZ5Q25eybw/ZnVkGtDdL
         WZhDN+hCMx+NmV4u3T0WxeaPiw3lnoUhHHQiqOxcV2glj371jiTEZZHc2MtBgKPHsnJG
         mJwCZdm75CbriPmsbqHSXJr39QeqXohCXTUo5RCIPGuJr5jeAf/kW8AifbhWXteknnTw
         lqTFXUw3lBxZB9P8n2t/TETVnBXdhRqhikgaBrmyETP8v6I5NXKBdYdOR9FCFy5HA9dR
         sbp/XLJPAfn3kfOCd4Jl4hAph72XZIPrVzZdiWNt3HyytHhw1T2+8q3aiMg73mozqDXS
         o7Hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVAtzwjD2k79isH/XDE4tw6Pc+U3GGUzgLqw46WuPqCAn1warTW
	/lZc89/ukP0k78roefhOFr89Gf/ZDMCCIknw/G2afivN/wJHI4ZC6b5knH3RdmTqKKgY1Bbg2Tz
	1CKx2n0VSgC5P9RCmq01yJQ2Px+jShRzVKk9cOJFeSQDPd77hHnqkPn3oKYR5J9jNpQ==
X-Received: by 2002:a2e:9e03:: with SMTP id e3mr2278593ljk.92.1551436703592;
        Fri, 01 Mar 2019 02:38:23 -0800 (PST)
X-Google-Smtp-Source: APXvYqw2DRFQu/lvN5e8yOEmRp6LNoeC/jWL4op+XHaktwtuOOEAMZqurHpaTHXGHPO6XT1H7oll
X-Received: by 2002:a2e:9e03:: with SMTP id e3mr2278544ljk.92.1551436702339;
        Fri, 01 Mar 2019 02:38:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551436702; cv=none;
        d=google.com; s=arc-20160816;
        b=ZFmg69DGlZUs8lk2SHKbLWnLUxl3AjuT4N/59zsUEH1t6OqVaFUcREXTFLsx6HBUyP
         GoQteyyIG8C9GrzhN93e38XmZasqrZQ4LbBkzadPnbXRRMsiN1CeEWtTsrHCcntKRCDb
         PJ/nxcSwcrKsOn0M/qGxc31EYi20+rUhfX16I3JsLNu7CjRF4PWaSnI1TNz9L6bf/jev
         Z7HsX5zwcVJEBeak8vtPQa6PEyfbsF7fN402fXrVberY2cZSvc5fvHiIpe+SQ1xo6VK/
         yXUDNa0NKLRhf5cKKmpiRiv1C8LOXmZ8uWdzLlk1Pk+HsncN/63bEfkATT91/3nfY/DV
         b5DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=ckrZQp0PZ2mpaKZo10KFPTYDS8LaJ0tANgFIQmuYBt8=;
        b=UsBJdeKqMmuwTUkZ7wyVf3JK9QGfGq4B2LYPbuIGOyu16WpQAyCGTP+SexQVR3aVnq
         JH0MdNNqBXgo3dDMSnduud251Ws9xpHAXPgeunJPjA8gVAz/E5ZkB7ZZVgsIERM9INpA
         kDDRyfLV8zJIsLiLHGEuRKk7hsVfJ/FqumkA7AYLDN1stHUCT+/uxP5xxglI6GAj+VvM
         GCVEaTaoy5U+OOwZPeK7LD+cY2R2+k5U4GbHNsU7mvJ5qkY7nyt66Rl89d/BJLFmghGB
         A2OqYfe6jx9jhnTCFjk6hxdU1cwAXN4I9No23JgL2ZmffPwNcKIKr3M/24Bbu/ni8tWK
         6z2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j4si14511765lfk.30.2019.03.01.02.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 02:38:22 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gzfYO-000469-Ez; Fri, 01 Mar 2019 13:38:08 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
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
Message-ID: <7c915942-6f52-e7a4-b879-e4c99dd65968@virtuozzo.com>
Date: Fri, 1 Mar 2019 13:38:26 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <f752c208-599c-9b5a-bc42-e4282df43616@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/26/19 3:50 PM, Andrey Ryabinin wrote:
> 
> 
> On 2/22/19 10:15 PM, Johannes Weiner wrote:
>> On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
>>> In a presence of more than 1 memory cgroup in the system our reclaim
>>> logic is just suck. When we hit memory limit (global or a limit on
>>> cgroup with subgroups) we reclaim some memory from all cgroups.
>>> This is sucks because, the cgroup that allocates more often always wins.
>>> E.g. job that allocates a lot of clean rarely used page cache will push
>>> out of memory other jobs with active relatively small all in memory
>>> working set.
>>>
>>> To prevent such situations we have memcg controls like low/max, etc which
>>> are supposed to protect jobs or limit them so they to not hurt others.
>>> But memory cgroups are very hard to configure right because it requires
>>> precise knowledge of the workload which may vary during the execution.
>>> E.g. setting memory limit means that job won't be able to use all memory
>>> in the system for page cache even if the rest the system is idle.
>>> Basically our current scheme requires to configure every single cgroup
>>> in the system.
>>>
>>> I think we can do better. The idea proposed by this patch is to reclaim
>>> only inactive pages and only from cgroups that have big
>>> (!inactive_is_low()) inactive list. And go back to shrinking active lists
>>> only if all inactive lists are low.
>>
>> Yes, you are absolutely right.
>>
>> We shouldn't go after active pages as long as there are plenty of
>> inactive pages around. That's the global reclaim policy, and we
>> currently fail to translate that well to cgrouped systems.
>>
>> Setting group protections or limits would work around this problem,
>> but they're kind of a red herring. We shouldn't ever allow use-once
>> streams to push out hot workingsets, that's a bug.
>>
>>> @@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>>>  
>>>  		scan >>= sc->priority;
>>>  
>>> +		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
>>> +						file, memcg, sc, false))
>>> +			scan = 0;
>>> +
>>>  		/*
>>>  		 * If the cgroup's already been deleted, make sure to
>>>  		 * scrape out the remaining cache.
>>> @@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>  	struct reclaim_state *reclaim_state = current->reclaim_state;
>>>  	unsigned long nr_reclaimed, nr_scanned;
>>>  	bool reclaimable = false;
>>> +	bool retry;
>>>  
>>>  	do {
>>>  		struct mem_cgroup *root = sc->target_mem_cgroup;
>>> @@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>  		};
>>>  		struct mem_cgroup *memcg;
>>>  
>>> +		retry = false;
>>> +
>>>  		memset(&sc->nr, 0, sizeof(sc->nr));
>>>  
>>>  		nr_reclaimed = sc->nr_reclaimed;
>>> @@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>>  			}
>>>  		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
>>>  
>>> +		if ((sc->nr_scanned - nr_scanned) == 0 &&
>>> +		     !sc->may_shrink_active) {
>>> +			sc->may_shrink_active = 1;
>>> +			retry = true;
>>> +			continue;
>>> +		}
>>
>> Using !scanned as the gate could be a problem. There might be a cgroup
>> that has inactive pages on the local level, but when viewed from the
>> system level the total inactive pages in the system might still be low
>> compared to active ones. In that case we should go after active pages.
>>
>> Basically, during global reclaim, the answer for whether active pages
>> should be scanned or not should be the same regardless of whether the
>> memory is all global or whether it's spread out between cgroups.
>>
>> The reason this isn't the case is because we're checking the ratio at
>> the lruvec level - which is the highest level (and identical to the
>> node counters) when memory is global, but it's at the lowest level
>> when memory is cgrouped.
>>
>> So IMO what we should do is:
>>
>> - At the beginning of global reclaim, use node_page_state() to compare
>>   the INACTIVE_FILE:ACTIVE_FILE ratio and then decide whether reclaim
>>   can go after active pages or not. Regardless of what the ratio is in
>>   individual lruvecs.
>>
>> - And likewise at the beginning of cgroup limit reclaim, walk the
>>   subtree starting at sc->target_mem_cgroup, sum up the INACTIVE_FILE
>>   and ACTIVE_FILE counters, and make inactive_is_low() decision on
>>   those sums.
>>
> 
> Sounds reasonable.
> 

On the second thought it seems to be better to keep the decision on lru level.
There are couple reasons for this:

1) Using bare node_page_state() (or sc->targe_mem_cgroup's total_[in]active counters) would be wrong.
 Because some cgroups might have protection set (memory.low) and we must take it into account. Also different
cgroups have different available swap space/memory.swappiness and it must be taken into account as well to.

So it has to be yet another full memcg-tree iteration.

2) Let's consider simple case. Two cgroups, one with big 'active' set of pages the other allocates one-time used pages.
So the total inactive is low, thus checking inactive ratio on higher level will result in reclaiming pages.
While with check on lru-level only inactive will be reclaimed.

I've tried to come up with a scenario in which checking ratio on higher level would better but failed.

