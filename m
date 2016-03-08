Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7688D6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 11:05:06 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so156330325wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 08:05:06 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id h8si5259758wmh.59.2016.03.08.08.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 08:05:05 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id l68so4938713wml.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 08:05:05 -0800 (PST)
Date: Tue, 8 Mar 2016 17:05:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more (was: Re:
 [PATCH 0/3] OOM detection rework v4)
Message-ID: <20160308160503.GL13542@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <CAAmzW4P2SPwW6F7X61QdAW8HTO_HUnZ_a9rbtei51SEuWXFvPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4P2SPwW6F7X61QdAW8HTO_HUnZ_a9rbtei51SEuWXFvPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Wed 09-03-16 00:19:03, Joonsoo Kim wrote:
> 2016-03-08 1:08 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > On Mon 29-02-16 22:02:13, Michal Hocko wrote:
> >> Andrew,
> >> could you queue this one as well, please? This is more a band aid than a
> >> real solution which I will be working on as soon as I am able to
> >> reproduce the issue but the patch should help to some degree at least.
> >
> > Joonsoo wasn't very happy about this approach so let me try a different
> > way. What do you think about the following? Hugh, Sergey does it help
> 
> I'm still not happy. Just ensuring one compaction run doesn't mean our
> best.

OK, let me think about it some more.

> What's your purpose of OOM rework? From my understanding,
> you'd like to trigger OOM kill deterministic and *not prematurely*.
> This makes sense.

Well this is a bit awkward because we do not have any proper definition
of what prematurely actually means. We do not know whether something
changes and decides to free some memory right after we made the decision.
We also do not know whether reclaiming some more memory would help
because we might be trashing over few remaining pages so there would be
still some progress, albeit small, progress. The system would be
basically unusable and the OOM killer would be a large relief. What I
want to achieve is to have a clear definition of _when_ we fire and do
not fire _often_ to be impractical. There are loads where the new
implementation behaved slightly better (see the cover for my tests) and
there surely be some where this will be worse. I want this to be
reasonably good. I am not claiming we are there yet and the interaction
with the compaction seems like it needs some work, no question about
that.

> But, what you did in case of high order allocation is completely different
> with original purpose. It may be deterministic but *completely premature*.
> There is no way to prevent premature OOM kill. So, I want to ask one more
> time. Why OOM kill is better than retry reclaiming when there is reclaimable
> page? Deterministic is for what? It ensures something more?

yes, If we keep reclaiming we can soon start trashing or over reclaim
too much which would hurt more processes. If you invoke the OOM killer
instead then chances are that you will release a lot of memory at once
and that would help to reconcile the memory pressure as well as free
some page blocks which couldn't have been compacted before and not
affect potentially many processes. The effect would be reduced to a
single process. If we had a proper trashing detection feedback we could
do much more clever decisions of course.

But back to the !costly OOMs. Once your system is fragmented so heavily
that there are no free blocks that would satisfy !costly request then
something has gone terribly wrong and we should fix it. To me it sounds
like we do not care about those requests early enough and only start
carying after we hit the wall. Maybe kcompactd can help us in this
regards.

> Please see Hugh's latest vmstat. There are plenty of anon pages when
> OOM kill happens and it may have enough swap space. Even if
> compaction runs and fails, why do we need to kill something
> in this case? OOM kill should be a last resort.

Well this would be the case even if we were trashing over swap.
Refaulting the swapped out memory all over again...

> Please see Hugh's previous report and OOM dump.
> 
> [  796.540791] Mem-Info:
> [  796.557378] active_anon:150198 inactive_anon:46022 isolated_anon:32
>  active_file:5107 inactive_file:1664 isolated_file:57
>  unevictable:3067 dirty:4 writeback:75 unstable:0
>  slab_reclaimable:13907 slab_unreclaimable:23236
>  mapped:8889 shmem:3171 pagetables:2176 bounce:0
>  free:1637 free_pcp:54 free_cma:0
> [  796.630465] Node 0 DMA32 free:13904kB min:3940kB low:4944kB
> high:5948kB active_anon:588776kB inactive_anon:188816kB
> active_file:20432kB inactive_file:6928kB unevictable:12268kB
> isolated(anon):128kB isolated(file):8kB present:1046128kB
> managed:1004892kB mlocked:12268kB dirty:16kB writeback:1400kB
> mapped:35556kB shmem:12684kB slab_reclaimable:55628kB
> slab_unreclaimable:92944kB kernel_stack:4448kB pagetables:8604kB
> unstable:0kB bounce:0kB free_pcp:296kB local_pcp:164kB free_cma:0kB
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> [  796.685815] lowmem_reserve[]: 0 0 0
> [  796.687390] Node 0 DMA32: 969*4kB (UE) 184*8kB (UME) 167*16kB (UM)
> 19*32kB (UM) 3*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB
> 0*4096kB = 8820kB
> [  796.729696] Node 0 hugepages_total=0 hugepages_free=0
> hugepages_surp=0 hugepages_size=2048kB
> 
> See [  796.557378] and [  796.630465].
> In this 100 ms time interval, freepage increase a lot and
> there are enough high order pages. OOM kill happen later
> so freepage would come from reclaim. This shows
> that your previous implementation which uses static retry number
> causes premature OOM.

Or simply one of the gcc simply exitted and freed up a memory which is
more likely. As I've tried to explain in other email, we cannot prevent
from those races. We simply do not have a crystal ball. All we know is
that at the time we checked the watermarks the last time there were
simply no eligible high order pages available.

> This attempt using compaction result looks not different to me.
> It would also cause premature OOM kill.
> 
> I don't insist endless retry. I just want a more scientific criteria
> that prevents premature OOM kill.

That is exactly what I try to achive here. Right now we are relying on
zone_reclaimable heuristic. That relies that some pages are freed (and
reset NR_PAGES_SCANNED) while we are scanning. With a stream of order-0
pages this is basically unbounded. What I am trying to achieve here
is to base the decision on the feedback. The first attempt was to use
the reclaim feedback. This turned out to be not sufficient for higher
orders because compaction can deffer and skip if we are close to
watermarks which is really surprising to me. So now I've tried to make
sure that we do not hit this path. I agree we can do better but there
always will be a moment to simply give up. Whatever that moment will
be we can still find loads which could theoretically go on for little
more and survive.

> I'm really tire to say same thing again and again.
> Am I missing something? This is the situation that I totally misunderstand
> something? Please let me know.
> 
> Note: your current implementation doesn't consider which zone is compacted.
> If DMA zone which easily fail to make high order page is compacted,
> your implementation will not do retry. It also looks not our best.

Why are we even consider DMA zone when we cannot ever allocate from this
zone?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
