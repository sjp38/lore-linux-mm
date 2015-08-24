Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3186B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 16:53:41 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so83001728wic.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 13:53:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cj8si34520451wjc.164.2015.08.24.13.53.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 13:53:39 -0700 (PDT)
Subject: Re: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists
 that can be mem-controlled
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
 <55DB1015.4080103@suse.cz> <20150824131616.GK12432@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB8451.4000102@suse.cz>
Date: Mon, 24 Aug 2015 22:53:37 +0200
MIME-Version: 1.0
In-Reply-To: <20150824131616.GK12432@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 24.8.2015 15:16, Mel Gorman wrote:
>>>
>>>  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
>>> @@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>>>
>>>  #else /* !CONFIG_CPUSETS */
>>>
>>> -static inline bool cpusets_enabled(void) { return false; }
>>> +static inline bool cpusets_mems_enabled(void) { return false; }
>>>
>>>  static inline int cpuset_init(void) { return 0; }
>>>  static inline void cpuset_init_smp(void) {}
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 62ae28d8ae8d..2c1c3bf54d15 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>>>  		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
>>>  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
>>>  				continue;
>>> -		if (cpusets_enabled() &&
>>> +		if (cpusets_mems_enabled() &&
>>>  			(alloc_flags & ALLOC_CPUSET) &&
>>>  			!cpuset_zone_allowed(zone, gfp_mask))
>>>  				continue;
>>
>> Here the benefits are less clear. I guess cpuset_zone_allowed() is
>> potentially costly...
>>
>> Heck, shouldn't we just start the static key on -1 (if possible), so that
>> it's enabled only when there's 2+ cpusets?

Hm wait a minute, that's what already happens:

static inline int nr_cpusets(void)
{
        /* jump label reference count + the top-level cpuset */
        return static_key_count(&cpusets_enabled_key) + 1;
}

I.e. if there's only the root cpuset, static key is disabled, so I think this
patch is moot after all?

> It's overkill for the amount of benefit.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
