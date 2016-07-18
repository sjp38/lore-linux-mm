Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0BC6B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 00:37:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so352242997pfx.3
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 21:37:08 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i8si1270074pfk.43.2016.07.17.21.37.06
        for <linux-mm@kvack.org>;
        Sun, 17 Jul 2016 21:37:07 -0700 (PDT)
Date: Mon, 18 Jul 2016 13:41:13 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 12/17] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160718044112.GA9460@js1304-P5Q-DELUXE>
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-13-vbabka@suse.cz>
 <20160706053954.GE23627@js1304-P5Q-DELUXE>
 <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Fri, Jul 15, 2016 at 03:37:52PM +0200, Vlastimil Babka wrote:
> On 07/06/2016 07:39 AM, Joonsoo Kim wrote:
> > On Fri, Jun 24, 2016 at 11:54:32AM +0200, Vlastimil Babka wrote:
> >> During reclaim/compaction loop, compaction priority can be increased by the
> >> should_compact_retry() function, but the current code is not optimal. Priority
> >> is only increased when compaction_failed() is true, which means that compaction
> >> has scanned the whole zone. This may not happen even after multiple attempts
> >> with the lower priority due to parallel activity, so we might needlessly
> >> struggle on the lower priority and possibly run out of compaction retry
> >> attempts in the process.
> >>
> >> We can remove these corner cases by increasing compaction priority regardless
> >> of compaction_failed(). Examining further the compaction result can be
> >> postponed only after reaching the highest priority. This is a simple solution
> >> and we don't need to worry about reaching the highest priority "too soon" here,
> >> because hen should_compact_retry() is called it means that the system is
> >> already struggling and the allocation is supposed to either try as hard as
> >> possible, or it cannot fail at all. There's not much point staying at lower
> >> priorities with heuristics that may result in only partial compaction.
> >> Also we now count compaction retries only after reaching the highest priority.
> > 
> > I'm not sure that this patch is safe. Deferring and skip-bit in
> > compaction is highly related to reclaim/compaction. Just ignoring them and (almost)
> > unconditionally increasing compaction priority will result in less
> > reclaim and less success rate on compaction.
> 
> I don't see why less reclaim? Reclaim is always attempted before
> compaction and compaction priority doesn't affect it. And as long as
> reclaim wants to retry, should_compact_retry() isn't even called, so the
> priority stays. I wanted to change that in v1, but Michal suggested I
> shouldn't.

I assume the situation that there is no !costly highorder freepage
because of fragmentation. In this case, should_reclaim_retry() would
return false since watermark cannot be met due to absence of high
order freepage. Now, please see should_compact_retry() with assumption
that there are enough order-0 free pages. Reclaim/compaction is only
retried two times (SYNC_LIGHT and SYNC_FULL) with your patchset since
compaction_withdrawn() return false with enough freepages and
!COMPACT_SKIPPED.

But, before your patchset, COMPACT_PARTIAL_SKIPPED and
COMPACT_DEFERRED is considered as withdrawn so will retry
reclaim/compaction more times.

As I said before, more reclaim (more freepage) increase migration
scanner's scan range and then increase compaction success probability.
Therefore, your patchset which makes reclaim/compaction retry less times
deterministically would not be safe.

> 
> > And, as a necessarily, it
> > would trigger OOM more frequently.
> 
> OOM is only allowed for costly orders. If reclaim itself doesn't want to
> retry for non-costly orders anymore, and we finally start calling
> should_compact_retry(), then I guess the system is really struggling
> already and eventual OOM wouldn't be premature?

Premature is really subjective so I don't know. Anyway, I tested
your patchset with simple test case and it causes a regression.

My test setup is:

Mem: 512 MB
vm.compact_unevictable_allowed = 0
Mlocked Mem: 225 MB by using mlock(). With some tricks, mlocked pages are
spread so memory is highly fragmented.

fork 500

This test causes OOM with your patchset but not without your patchset.

Thanks.

> > It would not be your fault. This patch is reasonable in current
> > situation. It just makes current things more deterministic
> > although I dislike that current things and this patch would amplify
> > those problem.
> > 
> > Thanks.
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
