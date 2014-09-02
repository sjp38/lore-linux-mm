Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 292A16B003C
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 10:02:13 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so8708669pdj.31
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 07:02:12 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id o2si6228747pdh.86.2014.09.02.07.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 07:02:11 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 79D743EE181
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 23:02:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 7F349AC0242
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 23:02:08 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 139041DB803A
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 23:02:08 +0900 (JST)
Message-ID: <5405CDB7.8040808@jp.fujitsu.com>
Date: Tue, 02 Sep 2014 23:01:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: page_alloc: Default to node-ordering on 64-bit NUMA
 machines
References: <20140901125551.GI12424@suse.de> <20140902135120.GC29501@cmpxchg.org>
In-Reply-To: <20140902135120.GC29501@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2014/09/02 22:51), Johannes Weiner wrote:
> On Mon, Sep 01, 2014 at 01:55:51PM +0100, Mel Gorman wrote:
>> Zones are allocated by the page allocator in either node or zone order.
>> Node ordering is preferred in terms of locality and is applied automatically
>> in one of three cases.
>>
>>    1. If a node has only low memory
>>
>>    2. If DMA/DMA32 is a high percentage of memory
>>
>>    3. If low memory on a single node is greater than 70% of the node size
>>
>> Otherwise zone ordering is used to preserve low memory. Unfortunately
>> a consequence of this is that a machine with balanced NUMA nodes will
>> experience different performance characteristics depending on which node
>> they happen to start from.
>>
>> The point of zone ordering is to protect lower nodes for devices that require
>> DMA/DMA32 memory. When NUMA was first introduced, this was critical as 32-bit
>> NUMA machines commonly suffered from low memory exhaustion problems. On
>> 64-bit machines the primary concern is devices that are 32-bit only which
>> is less severe than the low memory exhaustion problem on 32-bit NUMA. It
>> seems there are really few devices that depends on it.
>>
>> AGP -- I assume this is getting more rare but even then I think the allocations
>> 	happen early in boot time where lowmem pressure is less of a problem
>>
>> DRM -- If the device is 32-bit only then there may be low pressure. I didn't
>> 	evaluate these in detail but it looks like some of these are mobile
>> 	graphics card. Not many NUMA laptops out there. DRM folk should know
>> 	better though.
>>
>> Some TV cards -- Much demand for 32-bit capable TV cards on NUMA machines?
>>
>> B43 wireless card -- again not really a NUMA thing.
>>
>> I cannot find a good reason to incur a performance penalty on all 64-bit NUMA
>> machines in case someone throws a brain damanged TV or graphics card in there.
>> This patch defaults to node-ordering on 64-bit NUMA machines. I was tempted
>> to make it default everywhere but I understand that some embedded arches may
>> be using 32-bit NUMA where I cannot predict the consequences.
>
> This patch is a step in the right direction, but I'm not too fond of
> further fragmenting this code and where it applies, while leaving all
> the complexity from the heuristics and the zonelist building in, just
> on spec.  Could we at least remove the heuristics too?  If anybody is
> affected by this, they can always override the default on the cmdline.
>
I'm okay with removing heuristics. There were a request to add "automatic detection"
at the time this feature was developped. But I'm not sure whether the logic is
still required. i.e. at that age, node-0 memory was small and default node order
can cause OOM easily.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
