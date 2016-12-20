Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D029E6B032C
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 09:49:39 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so53939715wjc.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 06:49:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d128si19276616wmf.100.2016.12.20.06.49.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Dec 2016 06:49:38 -0800 (PST)
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220091814.GC3769@dhcp22.suse.cz>
 <20161220131040.f5ga5426dduh3mhu@techsingularity.net>
 <20161220132643.GG3769@dhcp22.suse.cz>
 <20161220142845.drbedcibjcggdxk7@techsingularity.net>
 <20161220143501.GI3769@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c7c6239b-c521-b5b0-473a-187b9b04e931@suse.cz>
Date: Tue, 20 Dec 2016 15:49:34 +0100
MIME-Version: 1.0
In-Reply-To: <20161220143501.GI3769@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Andi Kleen <ak@linux.intel.com>

On 12/20/2016 03:35 PM, Michal Hocko wrote:
> On Tue 20-12-16 14:28:45, Mel Gorman wrote:
>> On Tue, Dec 20, 2016 at 02:26:43PM +0100, Michal Hocko wrote:
>>> On Tue 20-12-16 13:10:40, Mel Gorman wrote:
>>>> On Tue, Dec 20, 2016 at 10:18:14AM +0100, Michal Hocko wrote:
>>>>> On Mon 12-12-16 13:59:07, Jia He wrote:
>>>>>> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
>>>>>> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
>>>>>> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>>>>>>  z->node would not be equal to preferred_zone->node. That seems to be
>>>>>> incorrect.
>>>>>
>>>>> I am sorry but I have hard time following the changelog. It is clear
>>>>> that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
>>>>> but it is not really clear when such thing happens. You are adding
>>>>> preferred_zone->node check. preferred_zone is the first zone in the
>>>>> requested zonelist. So for the most allocations it is a node from the
>>>>> local node. But if something request an explicit numa node (without
>>>>> __GFP_OTHER_NODE which would be the majority I suspect) then we could
>>>>> indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
>>>>> referenced patch indeed caused an unintended change of accounting AFAIU.
>>>>>
>>>>
>>>> This is a similar concern to what I had. If the preferred zone, which is
>>>> the first valid usable zone, is not a "hit" for the statistics then I
>>>> don't know what "hit" is meant to mean.
>>>
>>> But the first valid usable zone is defined based on the requested numa
>>> node. Unless the requested node is memoryless then we should have a hit,
>>> no?
>>>
>>
>> Should be. If the local node is memoryless then there would be a difference
>> between hit and whether it's local or not but that to me is a little
>> useless. A local vs remote page allocated has a specific meaning and
>> consequence. It's hard to see how hit can be meaningfully interpreted if
>> there are memoryless nodes. I don't have a strong objection to the patch
>> so I didn't nak it, I'm just not convinced it matters.
> 
> So what do you think about
> http://lkml.kernel.org/r/20161220091814.GC3769@dhcp22.suse.cz
> 
> I think that we should get rid of __GFP_OTHER_NODE thingy. It is just
> one off thing and the gfp space it rather precious.

Let's CC Andi who introduced it by commit 78afd5612deb8.
Personally I agree that the reasoning provided by that commit does not
justify the troubles. We already have the HIT and MISS counters to
record if we allocated on the node we explicitly wanted/preferred (local
or remote). The LOCAL and OTHER should thus be true local/remote
statistics, why fake them in some rare cases such as khugepaged? The
only other case is do_huge_pmd_wp_page_fallback() where it perhaps makes
even less sense. No others were added in 5 years so I think the flag
really didn't catch on, let's get rid of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
