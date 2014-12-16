Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B4D696B006E
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 03:52:23 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so12914550wiv.2
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 00:52:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vf7si229660wjc.81.2014.12.16.00.52.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 00:52:22 -0800 (PST)
Message-ID: <548FF2BE.4060601@suse.cz>
Date: Tue, 16 Dec 2014 09:52:14 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] page stealing tweaks
References: <1418400085-3622-1-git-send-email-vbabka@suse.cz> <20141215075017.GB4898@js1304-P5Q-DELUXE> <548EA452.50706@suse.cz> <20141216025452.GC23270@js1304-P5Q-DELUXE>
In-Reply-To: <20141216025452.GC23270@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 12/16/2014 03:54 AM, Joonsoo Kim wrote:
> On Mon, Dec 15, 2014 at 10:05:22AM +0100, Vlastimil Babka wrote:
>> On 12/15/2014 08:50 AM, Joonsoo Kim wrote:
>>> On Fri, Dec 12, 2014 at 05:01:22PM +0100, Vlastimil Babka wrote:
>>>> Changes since v1:
>>>> o Reorder patch 2 and 3, Cc stable for patch 1
>>>> o Fix tracepoint in patch 1 (Joonsoo Kim)
>>>> o Cleanup in patch 2 (suggested by Minchan Kim)
>>>> o Improved comments and changelogs per Minchan and Mel.
>>>> o Considered /proc/pagetypeinfo in evaluation with 3.18 as baseline
>>>>
>>>> When studying page stealing, I noticed some weird looking decisions in
>>>> try_to_steal_freepages(). The first I assume is a bug (Patch 1), the following
>>>> two patches were driven by evaluation.
>>>>
>>>> Testing was done with stress-highalloc of mmtests, using the
>>>> mm_page_alloc_extfrag tracepoint and postprocessing to get counts of how often
>>>> page stealing occurs for individual migratetypes, and what migratetypes are
>>>> used for fallbacks. Arguably, the worst case of page stealing is when
>>>> UNMOVABLE allocation steals from MOVABLE pageblock. RECLAIMABLE allocation
>>>> stealing from MOVABLE allocation is also not ideal, so the goal is to minimize
>>>> these two cases.
>>>>
>>>> For some reason, the first patch increased the number of page stealing events
>>>> for MOVABLE allocations in the former evaluation with 3.17-rc7 + compaction
>>>> patches. In theory these events are not as bad, and the second patch does more
>>>> than just to correct this. In v2 evaluation based on 3.18, the weird result
>>>> was gone completely.
>>>>
>>>> In v2 I also checked if /proc/pagetypeinfo has shown an increase of the number
>>>> of unmovable/reclaimable pageblocks during and after the test, and it didn't.
>>>> The test was repeated 25 times with reboot only after each 5 to show
>>>> longer-term differences in the state of the system, which also wasn't the case.
>>>>
>>>> Extfrag events summed over first iteration after reboot (5 repeats)
>>>>                                                          3.18            3.18            3.18            3.18
>>>>                                                     0-nothp-1       1-nothp-1       2-nothp-1       3-nothp-1
>>>> Page alloc extfrag event                                4547160     4593415     2343438     2198189
>>>> Extfrag fragmenting                                     4546361     4592610     2342595     2196611
>>>> Extfrag fragmenting for unmovable                          5725        9196        5720        1093
>>>> Extfrag fragmenting unmovable placed with movable          3877        4091        1330         859
>>>> Extfrag fragmenting for reclaimable                         770         628         511         616
>>>> Extfrag fragmenting reclaimable placed with movable         679         520         407         492
>>>> Extfrag fragmenting for movable                         4539866     4582786     2336364     2194902
>>>>
>>>> Compared to v1 this looks like a regression for patch 1 wrt unmovable events,
>>>> but I blame noise and less repeats (it was 10 in v1). On the other hand, the
>>>> the mysterious increase in movable allocation events in v1 is gone (due to
>>>> different baseline?)
>>>
>>> Hmm... the result on patch 2 looks odd.
>>> Because you reorder patches, patch 2 have some effects on unmovable
>>> stealing and I expect that 'Extfrag fragmenting for unmovable' decreases.
>>> But, the result looks not. Is there any reason you think?
>>
>> Hm, I don't see any obvious reason.
>>
>>> And, could you share compaction success rate and allocation success
>>> rate on each iteration? In fact, reducing Extfrag event isn't our goal.
>>> It is natural result of this patchset because we steal pages more
>>> aggressively. Our utimate goal is to make the system less fragmented
>>> and to get more high order freepage, so I'd like to know this results.
>>
>> I don't think there's much significant difference. Could be a limitation
>> of the benchmark. But even if there's no difference, it means the reduction
>> of fragmenting events at least saves time on allocations.
>
> Hmm... Allocation success rate of 3-nothp-N on phase 1,2 shows minor degradation
> from 2-nothp-N and compaction success rate also decreases. Isn't it?
> I think that allocation success rate on phase 1 is important because
> workload in phase 1 mostly resemble real world scenario. Do you have
> any idea why this happens?

It could be just noise, keep in mind that each 3-nothp-N is averaged 
from just from 5 repeats. And the iterations without reboot (N) are not 
independent, so if there's some "bad luck" upon boot, it will carry to 
all N of 3-nothp-N.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
