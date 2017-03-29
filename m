Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833F46B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:06:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g7so4029456wrd.16
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:06:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si7727483wmj.152.2017.03.29.09.06.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 09:06:43 -0700 (PDT)
Subject: Re: [PATCH v3 7/8] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-8-vbabka@suse.cz>
 <20170316021403.GC14063@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a7dd63a2-edd2-2699-91c4-d48960d34a3d@suse.cz>
Date: Wed, 29 Mar 2017 18:06:41 +0200
MIME-Version: 1.0
In-Reply-To: <20170316021403.GC14063@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On 03/16/2017 03:14 AM, Joonsoo Kim wrote:
> On Tue, Mar 07, 2017 at 02:15:44PM +0100, Vlastimil Babka wrote:
>> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
>> pageblocks. This is a heuristic intended to reduce latency, based on the
>> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
>> 
>> However, with the exception of THP's, most high-order allocations are not
>> movable. Should the async compaction succeed, this increases the chance that
>> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
>> long-term fragmentation worse.
> 
> I agree with this idea but have some concerns on this change.
> 
> *ASYNC* compaction is designed for reducing latency and this change
> doesn't fit it. If everything works fine, there is a few movable pages
> in non-MOVABLE pageblocks as you noted above. Moreover, there is quite
> less the number of non-MOVABLE pageblock than MOVABLE one so finding
> non-MOVABLE pageblock takes long time. These two factors will increase
> the latency of *ASYNC* compaction.

Right. I lately started to doubt the whole idea of async compaction (for
non-movable allocations). Seems it's one of the compaction heuristics tuned
towards the THP usecase. But for non-movable allocations, we just can't have
both the low latency and long-term fragmentation avoidance. I see now even my
own skip_on_failure mode in isolate_migratepages_block() as a mistake for
non-movable allocations.

Ideally I'd like to make async compaction redundant by kcompactd, and direct
compaction would mean a serious situation which should warrant sync compaction.
Meanwhile I see several options to modify this patch
- async compaction for non-movable allocations will stop doing the
skip_on_failure mode, and won't restrict the pageblock at all. patch 8/8 will
make sure that also this kind of compaction finishes the whole pageblock
- non-movable allocations will skip async compaction completely and go for sync
compaction immediately

Both options mean we won't clean the unmovable/reclaimable pageblocks as
aggressively, but perhaps the tradeoff won't be bad. What do you think?
Johannes, would you be able/willing to test such modification?

Thanks

> And, there is a concern in implementaion side. With this change, there
> is much possibilty that compaction scanner's met by ASYNC compaction.
> It resets the scanner position and SYNC compaction would start the
> scan at the beginning of the zone every time. It would make cached
> position useless and inefficient.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
