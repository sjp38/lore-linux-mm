Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id B93996B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 07:30:22 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l68so190435061wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 04:30:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w76si10356359wmd.81.2016.03.09.04.30.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Mar 2016 04:30:21 -0800 (PST)
Subject: Re: [PATCH 02/27] mm, vmscan: Check if cpusets are enabled during
 direct reclaim
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-3-git-send-email-mgorman@techsingularity.net>
 <56D8209C.5020103@suse.cz> <20160309115909.GA31585@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E01759.5090203@suse.cz>
Date: Wed, 9 Mar 2016 13:30:17 +0100
MIME-Version: 1.0
In-Reply-To: <20160309115909.GA31585@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Li Zefan <lizefan@huawei.com>, cgroups@vger.kernel.org

On 03/09/2016 12:59 PM, Mel Gorman wrote:
> On Thu, Mar 03, 2016 at 12:31:40PM +0100, Vlastimil Babka wrote:
>> On 02/23/2016 04:04 PM, Mel Gorman wrote:
>>> Direct reclaim obeys cpusets but misses the cpusets_enabled() check.
>>> The overhead is unlikely to be measurable in the direct reclaim
>>> path which is expensive but there is no harm is doing it.
>>>
>>> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>>> ---
>>>  mm/vmscan.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index 86eb21491867..de8d6226e026 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -2566,7 +2566,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>>>  		 * to global LRU.
>>>  		 */
>>>  		if (global_reclaim(sc)) {
>>> -			if (!cpuset_zone_allowed(zone,
>>> +			if (cpusets_enabled() && !cpuset_zone_allowed(zone,
>>>  						 GFP_KERNEL | __GFP_HARDWALL))
>>>  				continue;
>>
>> Hmm, wouldn't it be nicer if cpuset_zone_allowed() itself did the right
>> thing, and not each caller?
>>
>> How about the patch below? (+CC)
>>
> 
> The patch appears to be layer upon the entire series but that in itself

It could be also completely separate, witch your 02/27 dropped as it's
not tied to the rework anyway? Or did I miss something else cpuset
related in later patches?

> is ok. This part is a problem
> 
>> An important function for cpusets is cpuset_node_allowed(), which acknowledges
>> that if there's a single root CPU set, it must be trivially allowed. But the
>> check "nr_cpusets() <= 1" doesn't use the cpusets_enabled_key static key in a
>> proper way where static keys can reduce the overhead.
> 
> 
> There is one check for the static key and a second for the count to see
> if it's likely a valid cpuset that matters has been configured.

The point is that these should be equivalent, as the static key becomes
enabled only when there's more than one (root) cpuset. So checking
"nr_cpusets() <= 1" does the same as "!cpusets_enabled()", but without
taking advantage of the static key code patching.

> The
> point of that check was that it was lighter than __cpuset_zone_allowed
> in the case where no cpuset is configured.

But shrink_zones() (which you were patching) uses cpuset_zone_allowed(),
not __cpuset_zone_allowed(). The latter is provided only for
get_page_from_freelist(), which inserts extra fast check between
cpusets_enabled() and the slow cpuset allowed checking.

> The patches are not equivalent.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
