Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA23C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:49:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p64so15851168pfb.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 21:49:22 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x185si7293127pfx.31.2016.07.18.21.49.21
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 21:49:21 -0700 (PDT)
Date: Tue, 19 Jul 2016 13:53:30 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 12/17] mm, compaction: more reliably increase direct
 compaction priority
Message-ID: <20160719045330.GA17479@js1304-P5Q-DELUXE>
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-13-vbabka@suse.cz>
 <20160706053954.GE23627@js1304-P5Q-DELUXE>
 <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
 <20160718044112.GA9460@js1304-P5Q-DELUXE>
 <f5e07f1d-df29-24fb-a49d-9d436ad9b928@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5e07f1d-df29-24fb-a49d-9d436ad9b928@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Mon, Jul 18, 2016 at 02:21:02PM +0200, Vlastimil Babka wrote:
> On 07/18/2016 06:41 AM, Joonsoo Kim wrote:
> >On Fri, Jul 15, 2016 at 03:37:52PM +0200, Vlastimil Babka wrote:
> >>On 07/06/2016 07:39 AM, Joonsoo Kim wrote:
> >>>On Fri, Jun 24, 2016 at 11:54:32AM +0200, Vlastimil Babka wrote:
> >>>>During reclaim/compaction loop, compaction priority can be increased by the
> >>>>should_compact_retry() function, but the current code is not optimal. Priority
> >>>>is only increased when compaction_failed() is true, which means that compaction
> >>>>has scanned the whole zone. This may not happen even after multiple attempts
> >>>>with the lower priority due to parallel activity, so we might needlessly
> >>>>struggle on the lower priority and possibly run out of compaction retry
> >>>>attempts in the process.
> >>>>
> >>>>We can remove these corner cases by increasing compaction priority regardless
> >>>>of compaction_failed(). Examining further the compaction result can be
> >>>>postponed only after reaching the highest priority. This is a simple solution
> >>>>and we don't need to worry about reaching the highest priority "too soon" here,
> >>>>because hen should_compact_retry() is called it means that the system is
> >>>>already struggling and the allocation is supposed to either try as hard as
> >>>>possible, or it cannot fail at all. There's not much point staying at lower
> >>>>priorities with heuristics that may result in only partial compaction.
> >>>>Also we now count compaction retries only after reaching the highest priority.
> >>>
> >>>I'm not sure that this patch is safe. Deferring and skip-bit in
> >>>compaction is highly related to reclaim/compaction. Just ignoring them and (almost)
> >>>unconditionally increasing compaction priority will result in less
> >>>reclaim and less success rate on compaction.
> >>
> >>I don't see why less reclaim? Reclaim is always attempted before
> >>compaction and compaction priority doesn't affect it. And as long as
> >>reclaim wants to retry, should_compact_retry() isn't even called, so the
> >>priority stays. I wanted to change that in v1, but Michal suggested I
> >>shouldn't.
> >
> >I assume the situation that there is no !costly highorder freepage
> >because of fragmentation. In this case, should_reclaim_retry() would
> >return false since watermark cannot be met due to absence of high
> >order freepage. Now, please see should_compact_retry() with assumption
> >that there are enough order-0 free pages. Reclaim/compaction is only
> >retried two times (SYNC_LIGHT and SYNC_FULL) with your patchset since
> >compaction_withdrawn() return false with enough freepages and
> >!COMPACT_SKIPPED.
> >
> >But, before your patchset, COMPACT_PARTIAL_SKIPPED and
> >COMPACT_DEFERRED is considered as withdrawn so will retry
> >reclaim/compaction more times.
> 
> Perhaps, but it wouldn't guarantee to reach the highest priority.

Yes.

> 
> >As I said before, more reclaim (more freepage) increase migration
> >scanner's scan range and then increase compaction success probability.
> >Therefore, your patchset which makes reclaim/compaction retry less times
> >deterministically would not be safe.
> 
> After the patchset, we are guaranteed a full compaction has
> happened. If that doesn't help, yeah maybe we can try reclaiming
> more... but where to draw the line? Reclaim everything for an

To draw the line is a difficult problem. I know that. As I said before,
one of ideas is that reclaim/compaction continue until nr_reclaimed
reaches number of lru pages at beginning phase of reclaim/compaction
loop. It would not cause persistent thrashing, I guess.

> order-3 allocation just to avoid OOM, ignoring that the system might
> be thrashing heavily? Previously it also wasn't guaranteed to
> reclaim everything, but what is the optimal number of retries?

So, you say the similar logic in other thread we talked yesterday.
The fact that it wasn't guaranteed to reclaim every thing before
doesn't mean that we could relax guarantee more.

I'm not sure below is relevant to this series but just note.

I don't know the optimal number of retries. We are in a way to find
it and I hope this discussion would help. I don't think that we can
judge the point properly with simple checking on stat information at some
moment. It only has too limited knowledge about the system so it would
wrongly advise us to invoke OOM prematurely.

I think that using compaction result isn't a good way to determine if
further reclaim/compaction is useless or not because compaction result
can vary with further reclaim/compaction itself.

If we want to check more accurately if compaction is really impossible,
scanning whole range and checking arrangement of freepage and lru(movable)
pages would more help. Although there is some possibility to fail
the compaction even if this check is passed, it would give us more
information about the system state and we would invoke OOM less
prematurely. In this case that theoretically compaction success is possible,
we could keep reclaim/compaction more times even if full compaction fails
because we have a hope that more freepages would give us more compaction
success probability.

> >>
> >>>And, as a necessarily, it
> >>>would trigger OOM more frequently.
> >>
> >>OOM is only allowed for costly orders. If reclaim itself doesn't want to
> >>retry for non-costly orders anymore, and we finally start calling
> >>should_compact_retry(), then I guess the system is really struggling
> >>already and eventual OOM wouldn't be premature?
> >
> >Premature is really subjective so I don't know. Anyway, I tested
> >your patchset with simple test case and it causes a regression.
> >
> >My test setup is:
> >
> >Mem: 512 MB
> >vm.compact_unevictable_allowed = 0
> >Mlocked Mem: 225 MB by using mlock(). With some tricks, mlocked pages are
> >spread so memory is highly fragmented.
> 
> So this testcase isn't really about compaction, as that can't do
> anything even on the full priority. Actually

I missed that there are two parallel file readers. So, reclaim/compaction
actually can do something.

> compaction_zonelist_suitable() lies to us because it's not really
> suitable. Even with more memory freed by reclaim, it cannot increase
> the chances of compaction (your argument above). Reclaim can only
> free the non-mlocked pages, but compaction can also migrate those.
> 
> >fork 500
> 
> So the 500 forked processes all wait until the whole forking is done

Note that 500 isn't static value. Fragmentation ratio varies a lot
in every attempt so I should find proper value on each run.

Here is the way to find proper value.

1. make system fragmented
2. run two file readers in background.
3. set vm.highorder_retry = 1 which is my custom change to retry
reclaim/compaction endlessly for highorder allocation.
4. ./fork N
5. find proper N that doesn't invoke OOM.
6. set vm.highorder_retry = 0 to test your patchset.
7. ./fork N


js1304@ubuntu:~$ sudo sysctl -w vm.highorder_retry=1
vm.highorder_retry = 1
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m0.348s
user    0m0.000s
sys     0m0.252s
0
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m1.175s
user    0m0.000s
sys     0m0.576s
0
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m0.044s
user    0m0.000s
sys     0m0.036s
0
js1304@ubuntu:~$ sudo sysctl -w vm.highorder_retry=0
vm.highorder_retry = 0
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m0.470s
user    0m0.000s
sys     0m0.427s
18
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m0.710s
user    0m0.000s
sys     0m0.589s
14
js1304@ubuntu:~$ time ./fork 300 0; sudo dmesg -c | grep -i -e order -e killed > tmp.dat; grep -e Killed tmp.dat | wc -l; grep -v fork tmp.dat
real    0m0.944s
user    0m0.000s
sys     0m0.668s
27

Positive number at last line means that there are OOM killed processes
during the test.

> and only afterwards they all exit? Or they exit right after fork (or
> some delay?) I would assume the latter otherwise it would fail even

whole forked processes wait until the whole forking is done.

> before my patchset. If the non-mlocked areas don't have enough
> highorder pages for all 500 stacks, it will OOM regardless of how
> many reclaim and compaction retries. But if the processes exit
> shortly after fork, the extra retries might help making time for
> recycling the freed stacks of exited processes. But is it an useful
> workload for demonstrating the regression then?

I think so. This testcase greately pressures reclaim/compaction for
high order allocation because system memory is fragmented but there are
many reclaimable memory and many high order freepage candidates.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
