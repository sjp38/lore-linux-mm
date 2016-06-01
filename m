Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C16C96B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 06:01:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f75so8855016wmf.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 03:01:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b80si14051074wmf.119.2016.06.01.03.01.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 03:01:27 -0700 (PDT)
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net> <574E05B8.3060009@suse.cz>
 <20160601091921.GT2527@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <574EB274.4030408@suse.cz>
Date: Wed, 1 Jun 2016 12:01:24 +0200
MIME-Version: 1.0
In-Reply-To: <20160601091921.GT2527@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On 06/01/2016 11:19 AM, Mel Gorman wrote:
> On Tue, May 31, 2016 at 11:44:24PM +0200, Vlastimil Babka wrote:
>> On 05/30/2016 05:56 PM, Mel Gorman wrote:
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index dba8cfd0b2d6..f2c1e47adc11 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -3232,6 +3232,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>>  		 * allocations are system rather than user orientated
>>>  		 */
>>>  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>>> +		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
>>> +					ac->high_zoneidx, ac->nodemask);
>>> +		ac->classzone_idx = zonelist_zone_idx(ac->preferred_zoneref);
>>>  		page = get_page_from_freelist(gfp_mask, order,
>>>  						ALLOC_NO_WATERMARKS, ac);
>>>  		if (page)
>>>
>>
>> Even if that didn't help for this report, I think it's needed too
>> (except the classzone_idx which doesn't exist anymore?).

But you agree that the hunk above should be merged?

>> And I think the following as well. (the changed comment could be also
>> just deleted).
>>
> 
> Why?
> 
> The comment is fine but I do not see why the recalculation would occur.
> 
> In the original code, the preferred_zoneref for statistics is calculated
> based on either the supplied nodemask or cpuset_current_mems_allowed during
> the initial attempt. It then relies on the cpuset checks in the slowpath
> to encorce mems_allowed but the preferred zone doesn't change.
> 
> With your proposed change, it's possible that the
> preferred_zoneref recalculation points to a zoneref disallowed by
> cpuset_current_mems_sllowed. While it'll be skipped during allocation,
> the statistics will still be against a zone that is potentially outside
> what is allowed.

Hmm that's true and I was ready to agree. But then I noticed  that
gfp_to_alloc_flags() can mask out ALLOC_CPUSET for GFP_ATOMIC. So it's
like a lighter version of the ALLOC_NO_WATERMARKS situation. In that
case it's wrong if we leave ac->preferred_zoneref at a position that has
skipped some zones due to mempolicies?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
