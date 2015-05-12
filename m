Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id BA5E06B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:01:51 -0400 (EDT)
Received: by widdi4 with SMTP id di4so142625209wid.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:01:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o3si26361412wjz.169.2015.05.12.02.01.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:01:50 -0700 (PDT)
Message-ID: <5551C17C.4050002@suse.cz>
Date: Tue, 12 May 2015 11:01:48 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/3] mm: support active anti-fragmentation algorithm
References: <1430119421-13536-1-git-send-email-iamjoonsoo.kim@lge.com> <1430119421-13536-3-git-send-email-iamjoonsoo.kim@lge.com> <20150427082923.GG2449@suse.de> <20150428074540.GA18647@js1304-P5Q-DELUXE>
In-Reply-To: <20150428074540.GA18647@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On 04/28/2015 09:45 AM, Joonsoo Kim wrote:
> On Mon, Apr 27, 2015 at 09:29:23AM +0100, Mel Gorman wrote:
>> On Mon, Apr 27, 2015 at 04:23:41PM +0900, Joonsoo Kim wrote:
>>> We already have antifragmentation policy in page allocator. It works well
>>> when system memory is sufficient, but, it doesn't works well when system
>>> memory isn't sufficient because memory is already highly fragmented and
>>> fallback/steal mechanism cannot get whole pageblock. If there is severe
>>> unmovable allocation requestor like zram, problem could get worse.
>>>
>>> CPU: 8
>>> RAM: 512 MB with zram swap
>>> WORKLOAD: kernel build with -j12
>>> OPTION: page owner is enabled to measure fragmentation
>>> After finishing the build, check fragmentation by 'cat /proc/pagetypeinfo'
>>>
>>> * Before
>>> Number of blocks type (movable)
>>> DMA32: 207
>>>
>>> Number of mixed blocks (movable)
>>> DMA32: 111.2
>>>
>>> Mixed blocks means that there is one or more allocated page for
>>> unmovable/reclaimable allocation in movable pageblock. Results shows that
>>> more than half of movable pageblock is tainted by other migratetype
>>> allocation.
>>>
>>> To mitigate this fragmentation, this patch implements active
>>> anti-fragmentation algorithm. Idea is really simple. When some
>>> unmovable/reclaimable steal happens from movable pageblock, we try to
>>> migrate out other pages that can be migratable in this pageblock are and
>>> use these generated freepage for further allocation request of
>>> corresponding migratetype.
>>>
>>> Once unmovable allocation taints movable pageblock, it cannot easily
>>> recover. Instead of praying that it gets restored, making it unmovable
>>> pageblock as much as possible and using it further unmovable request
>>> would be more reasonable approach.
>>>
>>> Below is result of this idea.
>>>
>>> * After
>>> Number of blocks type (movable)
>>> DMA32: 208.2
>>>
>>> Number of mixed blocks (movable)
>>> DMA32: 55.8
>>>
>>> Result shows that non-mixed block increase by 59% in this case.

Interesting. I tested a patch prototype like this too (although the work 
wasn't offloaded to a kthread, I wanted to see benefits first) and it 
yielded no significant difference. But admittedly I was using 
stress-highalloc for huge page sized allocations and a 4GB memory system...

So with these results it seems definitely worth pursuing, taking Mel's 
comments into account. We should think about coordination with 
khugepaged, which is another source of compaction. See my patchset from 
yesterday "Outsourcing page fault THP allocations to khugepaged" (sorry 
I didn't CC you). I think ideally this "antifrag" or maybe "kcompactd" 
thread would be one per NUMA node and serve both for the pageblock 
antifragmentation requests (with higher priority) and then THP 
allocation requests. Then khugepaged would do just the scanning for 
collapses, which might be later moved to task_work context and 
khugepaged killed. We could also remove compaction from kswapd balancing 
and let it wake up kcompactd instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
