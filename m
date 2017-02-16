Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01233680FEA
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:12:33 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c4so3573401wrd.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:12:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 124si848707wmc.141.2017.02.16.07.12.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:12:30 -0800 (PST)
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
 <37f46f4c-4006-a76a-bf0a-5a4e3b0d68e6@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ac941e43-9a5c-13fa-756e-c12c08513c9b@suse.cz>
Date: Thu, 16 Feb 2017 16:12:27 +0100
MIME-Version: 1.0
In-Reply-To: <37f46f4c-4006-a76a-bf0a-5a4e3b0d68e6@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/15/2017 03:29 PM, Vlastimil Babka wrote:
> On 02/13/2017 12:07 PM, Mel Gorman wrote:
>> On Fri, Feb 10, 2017 at 06:23:33PM +0100, Vlastimil Babka wrote:
>>
>> By and large, I like the series, particularly patches 7 and 8. I cannot
>> make up my mind about the RFC patches 9 and 10 yet. Conceptually they
>> seem sound but they are much more far reaching than the rest of the
>> series.
>>
>> It would be nice if patches 1-8 could be treated in isolation with data
>> on the number of extfrag events triggered, time spent in compaction and
>> the success rate. Patches 9 and 10 are tricy enough that they would need
>> data per patch where as patches 1-8 should be ok with data gathered for
>> the whole series.
> 
> I've got the results with mmtests stress-highalloc modified to do
> GFP_KERNEL order-4 allocations, on 4.9 with "mm, vmscan: fix zone
> balance check in prepare_kswapd_sleep" (without that, kcompactd indeed
> wasn't woken up) on UMA machine with 4GB memory. There were 5 repeats of
> each run, as the extfrag stats are quite volatile (note the stats below
> are sums, not averages, as it was less perl hacking for me).
> 
> Success rate are the same, already high due to the low order. THP and
> compaction stats also roughly the same. The extfrag stats (a bit
> modified/expanded wrt. vanilla mmtests):
> 
> (the patches are stacked, and I haven't measured the non-functional-changes
> patches separately)
> 							   base     patch 2     patch 3     patch 4     patch 7     patch 8
> Page alloc extfrag event                               11734984    11769620    11485185    13029676    13312786    13939417
> Extfrag fragmenting                                    11729231    11763921    11479301    13024101    13307281    13933978
> Extfrag fragmenting for unmovable                         87848       84906       76328       78613       66025       59261
> Extfrag fragmenting unmovable placed with movable          8298        7367        5865        8479        6440        5928
> Extfrag fragmenting for reclaimable                    11636074    11673657    11397642    12940253    13236444    13869509
> Extfrag fragmenting reclaimable placed with movable      389283      362396      330855      374292      390700      415478
> Extfrag fragmenting for movable                            5309        5358        5331        5235        4812        5208

OK, so turns out the trace postprocessing script had mixed up movable
and reclaimable, because the tracepoint prints only the numeric value
from the enum. Commit 016c13daa5c9 ("mm, page_alloc: use masks and
shifts when converting GFP flags to migrate types") swapped movable and
reclaimable in the enum, and the script wasn't updated.

Here are the results again, after fixing the script:

 							   base     patch 2     patch 3     patch 4     patch 7     patch 8
Page alloc extfrag event                               11734984    11769620    11485185    13029676    13312786    13939417
Extfrag fragmenting                                    11729231    11763921    11479301    13024101    13307281    13933978
Extfrag fragmenting for unmovable                         87848       84906       76328       78613       66025       59261
Extfrag fragmenting unmovable placed with movable         79550       77539       70463       70134       59585       53333
Extfrag fragmenting unmovable placed with reclaim.         8298        7367        5865        8479        6440        5928
Extfrag fragmenting for reclaimable                        5309        5358        5331        5235        4812        5208
Extfrag fragmenting reclaimable placed with movable        1757        1728        1703        1750        1647        1715
Extfrag fragmenting reclaimable placed with unmov.         3552        3630        3628        3485        3165        3493
Extfrag fragmenting for movable                        11636074    11673657    11397642    12940253    13236444    13869509

Most of the original evaluation is still applicable, and it's nice to
see even more stronger trend of "unmovable placed with movable"
decreasing throughout the series.
The mystery of patch 4 increasing fragmenting events actually applies to
movable allocations (and not reclaimable), which is not permanent
fragmentation. But it's still significant, so I'll investigate.
It's unfortunately possible that the optimistic stats are just a result
of having more pageblocks on average marked as UNMOVABLE. That would be
fine if they were really occupied by such allocations, but not so great
otherwise. I do hope that the extra insight about existing pages coming
from Patch 4 is improving things here, not making them worse. But the
extfrag events themselves won't tell us that...

> Going in order, patch 3 might be some improvement wrt polluting
> (movable) pageblocks with unmovable, hopefully not noise.
> 
> Results for patch 4 ("count movable pages when stealing from pageblock")
> are really puzzling me, as it increases the number of fragmenting events
> for reclaimable allocations, implicating "reclaimable placed with (i.e.
> falling back to) unmovable" (which is not listed separately above, but
> follows logically from "reclaimable placed with movable" not changing
> that much). I really wonder why is that. The patch effectively only
> changes the decision to change migratetype of a pageblock, it doesn't
> affect the actual stealing decision (which is always true for
> RECLAIMABLE anyway, see can_steal_fallback()). Moreover, since we can't
> distinguish UNMOVABLE from RECLAIMABLE when counting, good_pages is 0
> and thus even the decision to change pageblock migratetype shouldn't be
> changed by the patch for this case. I must recheck the implementation...
> 
> Patch 7 could be cautiously labeled as improvement for reduction of
> "Fragmenting for unmovable" events, which would be perfect as that was
> the intention. For reclaimable it looks worse, but probably just within
> noise. Same goes for Patch 8, although the apparent regression for
> reclaimable looks even worse there.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
