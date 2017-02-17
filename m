Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE7D4440602
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 10:25:00 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id jb1so1835723wjb.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 07:25:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n19si2055641wmg.126.2017.02.17.07.24.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 07:24:59 -0800 (PST)
Subject: Re: [PATCH v2 00/10] try to reduce fragmenting fallbacks
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170213110701.vb4e6zrwhwliwm7k@techsingularity.net>
 <37f46f4c-4006-a76a-bf0a-5a4e3b0d68e6@suse.cz>
 <ac941e43-9a5c-13fa-756e-c12c08513c9b@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6faad9e5-7bad-bdd7-96a0-8a04d57f4a57@suse.cz>
Date: Fri, 17 Feb 2017 16:24:53 +0100
MIME-Version: 1.0
In-Reply-To: <ac941e43-9a5c-13fa-756e-c12c08513c9b@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/16/2017 04:12 PM, Vlastimil Babka wrote:
> On 02/15/2017 03:29 PM, Vlastimil Babka wrote:
>> On 02/13/2017 12:07 PM, Mel Gorman wrote:
>>> On Fri, Feb 10, 2017 at 06:23:33PM +0100, Vlastimil Babka wrote:
>>>
>>> By and large, I like the series, particularly patches 7 and 8. I cannot
>>> make up my mind about the RFC patches 9 and 10 yet. Conceptually they
>>> seem sound but they are much more far reaching than the rest of the
>>> series.
>>>
>>> It would be nice if patches 1-8 could be treated in isolation with data
>>> on the number of extfrag events triggered, time spent in compaction and
>>> the success rate. Patches 9 and 10 are tricy enough that they would need
>>> data per patch where as patches 1-8 should be ok with data gathered for
>>> the whole series.
>> 
>> I've got the results with mmtests stress-highalloc modified to do
>> GFP_KERNEL order-4 allocations, on 4.9 with "mm, vmscan: fix zone
>> balance check in prepare_kswapd_sleep" (without that, kcompactd indeed
>> wasn't woken up) on UMA machine with 4GB memory. There were 5 repeats of
>> each run, as the extfrag stats are quite volatile (note the stats below
>> are sums, not averages, as it was less perl hacking for me).
>> 
>> Success rate are the same, already high due to the low order. THP and
>> compaction stats also roughly the same. The extfrag stats (a bit
>> modified/expanded wrt. vanilla mmtests):
>> 
>> (the patches are stacked, and I haven't measured the non-functional-changes
>> patches separately)
>> 							   base     patch 2     patch 3     patch 4     patch 7     patch 8
>> Page alloc extfrag event                               11734984    11769620    11485185    13029676    13312786    13939417
>> Extfrag fragmenting                                    11729231    11763921    11479301    13024101    13307281    13933978
>> Extfrag fragmenting for unmovable                         87848       84906       76328       78613       66025       59261
>> Extfrag fragmenting unmovable placed with movable          8298        7367        5865        8479        6440        5928
>> Extfrag fragmenting for reclaimable                    11636074    11673657    11397642    12940253    13236444    13869509
>> Extfrag fragmenting reclaimable placed with movable      389283      362396      330855      374292      390700      415478
>> Extfrag fragmenting for movable                            5309        5358        5331        5235        4812        5208
> 
> OK, so turns out the trace postprocessing script had mixed up movable
> and reclaimable, because the tracepoint prints only the numeric value
> from the enum. Commit 016c13daa5c9 ("mm, page_alloc: use masks and
> shifts when converting GFP flags to migrate types") swapped movable and
> reclaimable in the enum, and the script wasn't updated.
> 
> Here are the results again, after fixing the script:
> 
>  							   base     patch 2     patch 3     patch 4     patch 7     patch 8
> Page alloc extfrag event                               11734984    11769620    11485185    13029676    13312786    13939417
> Extfrag fragmenting                                    11729231    11763921    11479301    13024101    13307281    13933978
> Extfrag fragmenting for unmovable                         87848       84906       76328       78613       66025       59261
> Extfrag fragmenting unmovable placed with movable         79550       77539       70463       70134       59585       53333
> Extfrag fragmenting unmovable placed with reclaim.         8298        7367        5865        8479        6440        5928
> Extfrag fragmenting for reclaimable                        5309        5358        5331        5235        4812        5208
> Extfrag fragmenting reclaimable placed with movable        1757        1728        1703        1750        1647        1715
> Extfrag fragmenting reclaimable placed with unmov.         3552        3630        3628        3485        3165        3493
> Extfrag fragmenting for movable                        11636074    11673657    11397642    12940253    13236444    13869509


And the disaster of evaluation continues. I have now realised that my automation
got broken by grub2 changes, and long story short, iterations 2+ of each kernel
actually used the "patch 8" kernel, which made all the differences relatively
smaller. So only the first iteration is usable, with results below for
illustration. I'll hopefully collect the proper data with 5 iterations over
weekend - the series should have more impact than it looked like.

    	                                                      base     patch 2     patch 3     patch 4     patch 7     patch 8
Page alloc extfrag event                                   1528823     1444798     1514653     2702564     2643290     3024168
Extfrag fragmenting                                        1527537     1443567     1513410     2701466     2642117     3023164
Extfrag fragmenting for unmovable                            39908       37186       32646       23214       13942       13994
Extfrag fragmenting unmovable placed with movable            36703       36093       31344       21312       12628       12267
Extfrag fragmenting unmovable placed with reclaim.            3205        1093        1302        1902        1314        1727
Extfrag fragmenting for reclaimable                           1038        1025        1048        1039        1023        1132
Extfrag fragmenting reclaimable placed with movable            370         319         326         373         317         320
Extfrag fragmenting reclaimable placed with unmov.             668         706         722         666         706         812
Extfrag fragmenting for movable                            1486591     1405356     1479716     2677213     2627152     3008038

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
