Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id AE0436B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:31:11 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so898953wib.16
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 05:31:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pk8si17714544wjc.2.2014.07.25.05.31.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 05:31:10 -0700 (PDT)
Date: Fri, 25 Jul 2014 13:31:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V4 07/15] mm, compaction: khugepaged should not give up
 due to need_resched()
Message-ID: <20140725123106.GB10819@suse.de>
References: <1405518503-27687-1-git-send-email-vbabka@suse.cz>
 <1405518503-27687-8-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1405518503-27687-8-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On Wed, Jul 16, 2014 at 03:48:15PM +0200, Vlastimil Babka wrote:
> Async compaction aborts when it detects zone lock contention or need_resched()
> is true. David Rientjes has reported that in practice, most direct async
> compactions for THP allocation abort due to need_resched(). This means that a
> second direct compaction is never attempted, which might be OK for a page
> fault, but khugepaged is intended to attempt a sync compaction in such case and
> in these cases it won't.
> 
> This patch replaces "bool contended" in compact_control with an int that
> distinguieshes between aborting due to need_resched() and aborting due to lock
> contention. This allows propagating the abort through all compaction functions
> as before, but passing the abort reason up to __alloc_pages_slowpath() which
> decides when to continue with direct reclaim and another compaction attempt.
> 
> Another problem is that try_to_compact_pages() did not act upon the reported
> contention (both need_resched() or lock contention) immediately and would
> proceed with another zone from the zonelist. When need_resched() is true, that
> means initializing another zone compaction, only to check again need_resched()
> in isolate_migratepages() and aborting. For zone lock contention, the
> unintended consequence is that the lock contended status reported back to the
> allocator is detrmined from the last zone where compaction was attempted, which
> is rather arbitrary.
> 
> This patch fixes the problem in the following way:
> - async compaction of a zone aborting due to need_resched() or fatal signal
>   pending means that further zones should not be tried. We report
>   COMPACT_CONTENDED_SCHED to the allocator.
> - aborting zone compaction due to lock contention means we can still try
>   another zone, since it has different set of locks. We report back
>   COMPACT_CONTENDED_LOCK only if *all* zones where compaction was attempted,
>   it was aborted due to lock contention.
> 
> As a result of these fixes, khugepaged will proceed with second sync compaction
> as intended, when the preceding async compaction aborted due to need_resched().
> Page fault compactions aborting due to need_resched() will spare some cycles
> previously wasted by initializing another zone compaction only to abort again.
> Lock contention will be reported only when compaction in all zones aborted due
> to lock contention, and therefore it's not a good idea to try again after
> reclaim.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
