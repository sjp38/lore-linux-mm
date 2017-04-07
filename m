Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 971396B0390
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 20:36:06 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r129so53495073pgr.18
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 17:36:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 31si3151535pgx.220.2017.04.06.17.36.04
        for <linux-mm@kvack.org>;
        Thu, 06 Apr 2017 17:36:05 -0700 (PDT)
Date: Fri, 7 Apr 2017 09:38:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 7/8] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
Message-ID: <20170407003851.GA17231@js1304-P5Q-DELUXE>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-8-vbabka@suse.cz>
 <20170316021403.GC14063@js1304-P5Q-DELUXE>
 <a7dd63a2-edd2-2699-91c4-d48960d34a3d@suse.cz>
MIME-Version: 1.0
In-Reply-To: <a7dd63a2-edd2-2699-91c4-d48960d34a3d@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On Wed, Mar 29, 2017 at 06:06:41PM +0200, Vlastimil Babka wrote:
> On 03/16/2017 03:14 AM, Joonsoo Kim wrote:
> > On Tue, Mar 07, 2017 at 02:15:44PM +0100, Vlastimil Babka wrote:
> >> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
> >> pageblocks. This is a heuristic intended to reduce latency, based on the
> >> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
> >> 
> >> However, with the exception of THP's, most high-order allocations are not
> >> movable. Should the async compaction succeed, this increases the chance that
> >> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
> >> long-term fragmentation worse.
> > 
> > I agree with this idea but have some concerns on this change.
> > 
> > *ASYNC* compaction is designed for reducing latency and this change
> > doesn't fit it. If everything works fine, there is a few movable pages
> > in non-MOVABLE pageblocks as you noted above. Moreover, there is quite
> > less the number of non-MOVABLE pageblock than MOVABLE one so finding
> > non-MOVABLE pageblock takes long time. These two factors will increase
> > the latency of *ASYNC* compaction.
> 
> Right. I lately started to doubt the whole idea of async compaction (for
> non-movable allocations). Seems it's one of the compaction heuristics tuned
> towards the THP usecase. But for non-movable allocations, we just can't have
> both the low latency and long-term fragmentation avoidance. I see now even my
> own skip_on_failure mode in isolate_migratepages_block() as a mistake for
> non-movable allocations.

Why do you think that skip_on_failure mode is a mistake? I think that
it would lead to reduce the latency and it fits the goal of async
compaction.

> 
> Ideally I'd like to make async compaction redundant by kcompactd, and direct
> compaction would mean a serious situation which should warrant sync compaction.
> Meanwhile I see several options to modify this patch
> - async compaction for non-movable allocations will stop doing the
> skip_on_failure mode, and won't restrict the pageblock at all. patch 8/8 will
> make sure that also this kind of compaction finishes the whole pageblock
> - non-movable allocations will skip async compaction completely and go for sync
> compaction immediately

IMO, concept of async compaction is also important for non-movable allocation.
Non-movable allocation is essential for some workload and they hope
the low latency.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
