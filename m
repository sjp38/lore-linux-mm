Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD0D56B025E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 01:44:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so57559157pac.0
        for <linux-mm@kvack.org>; Tue, 03 May 2016 22:44:36 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id cz6si2801844pad.230.2016.05.03.22.44.34
        for <linux-mm@kvack.org>;
        Tue, 03 May 2016 22:44:35 -0700 (PDT)
Date: Wed, 4 May 2016 14:45:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0.14] oom detection rework v6
Message-ID: <20160504054502.GA10899@js1304-P5Q-DELUXE>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 20, 2016 at 03:47:13PM -0400, Michal Hocko wrote:
> Hi,
> 
> This is v6 of the series. The previous version was posted [1]. The
> code hasn't changed much since then. I have found one old standing
> bug (patch 1) which just got much more severe and visible with this
> series. Other than that I have reorganized the series and put the
> compaction feedback abstraction to the front just in case we find out
> that parts of the series would have to be reverted later on for some
> reason. The premature oom killer invocation reported by Hugh [2] seems
> to be addressed.
> 
> We have discussed this series at LSF/MM summit in Raleigh and there
> didn't seem to be any concerns/objections to go on with the patch set
> and target it for the next merge window. 

I still don't agree with some part of this patchset that deal with
!costly order. As you know, there was two regression reports from Hugh
and Aaron and you fixed them by ensuring to trigger compaction. I
think that these show the problem of this patchset. Previous kernel
doesn't need to ensure to trigger compaction and just works fine in
any case. Your series make compaction necessary for all. OOM handling
is essential part in MM but compaction isn't. OOM handling should not
depend on compaction. I tested my own benchmark without
CONFIG_COMPACTION and found that premature OOM happens.

I hope that you try to test something without CONFIG_COMPACTION.

Thanks.

> 
> Motivation:
> As pointed by Linus [3][4] relying on zone_reclaimable as a way to
> communicate the reclaim progress is rater dubious. I tend to agree,
> not only it is really obscure, it is not hard to imagine cases where a
> single page freed in the loop keeps all the reclaimers looping without
> getting any progress because their gfp_mask wouldn't allow to get that
> page anyway (e.g. single GFP_ATOMIC alloc and free loop). This is rather
> rare so it doesn't happen in the practice but the current logic which we
> have is rather obscure and hard to follow a also non-deterministic.
> 
> This is an attempt to make the OOM detection more deterministic and
> easier to follow because each reclaimer basically tracks its own
> progress which is implemented at the page allocator layer rather spread
> out between the allocator and the reclaim. The more on the implementation
> is described in the first patch.
> 
> I have tested several different scenarios but it should be clear that
> testing OOM killer is quite hard to be representative. There is usually
> a tiny gap between almost OOM and full blown OOM which is often time
> sensitive. Anyway, I have tested the following 2 scenarios and I would
> appreciate if there are more to test.
> 
> Testing environment: a virtual machine with 2G of RAM and 2CPUs without
> any swap to make the OOM more deterministic.
> 
> 1) 2 writers (each doing dd with 4M blocks to an xfs partition with 1G
>    file size, removes the files and starts over again) running in
>    parallel for 10s to build up a lot of dirty pages when 100 parallel
>    mem_eaters (anon private populated mmap which waits until it gets
>    signal) with 80M each.
> 
>    This causes an OOM flood of course and I have compared both patched
>    and unpatched kernels. The test is considered finished after there
>    are no OOM conditions detected. This should tell us whether there are
>    any excessive kills or some of them premature (e.g. due to dirty pages):
> 
> I have performed two runs this time each after a fresh boot.
> 
> * base kernel
> $ grep "Out of memory:" base-oom-run1.log | wc -l
> 78
> $ grep "Out of memory:" base-oom-run2.log | wc -l
> 78
> 
> $ grep "Kill process" base-oom-run1.log | tail -n1
> [   91.391203] Out of memory: Kill process 3061 (mem_eater) score 39 or sacrifice child
> $ grep "Kill process" base-oom-run2.log | tail -n1
> [   82.141919] Out of memory: Kill process 3086 (mem_eater) score 39 or sacrifice child
> 
> $ grep "DMA32 free:" base-oom-run1.log | sed 's@.*free:\([0-9]*\)kB.*@\1@' | calc_min_max.awk 
> min: 5376.00 max: 6776.00 avg: 5530.75 std: 166.50 nr: 61
> $ grep "DMA32 free:" base-oom-run2.log | sed 's@.*free:\([0-9]*\)kB.*@\1@' | calc_min_max.awk 
> min: 5416.00 max: 5608.00 avg: 5514.15 std: 42.94 nr: 52
> 
> $ grep "DMA32.*all_unreclaimable? no" base-oom-run1.log | wc -l
> 1
> $ grep "DMA32.*all_unreclaimable? no" base-oom-run2.log | wc -l
> 3
> 
> * patched kernel
> $ grep "Out of memory:" patched-oom-run1.log | wc -l
> 78
> miso@tiehlicka /mnt/share/devel/miso/kvm $ grep "Out of memory:" patched-oom-run2.log | wc -l
> 77
> 
> e grep "Kill process" patched-oom-run1.log | tail -n1
> [  497.317732] Out of memory: Kill process 3108 (mem_eater) score 39 or sacrifice child
> $ grep "Kill process" patched-oom-run2.log | tail -n1
> [  316.169920] Out of memory: Kill process 3093 (mem_eater) score 39 or sacrifice child
> 
> $ grep "DMA32 free:" patched-oom-run1.log | sed 's@.*free:\([0-9]*\)kB.*@\1@' | calc_min_max.awk 
> min: 5420.00 max: 5808.00 avg: 5513.90 std: 60.45 nr: 78
> $ grep "DMA32 free:" patched-oom-run2.log | sed 's@.*free:\([0-9]*\)kB.*@\1@' | calc_min_max.awk 
> min: 5380.00 max: 6384.00 avg: 5520.94 std: 136.84 nr: 77
> 
> e grep "DMA32.*all_unreclaimable? no" patched-oom-run1.log | wc -l
> 2
> $ grep "DMA32.*all_unreclaimable? no" patched-oom-run2.log | wc -l
> 3
> 
> The patched kernel run noticeably longer while invoking OOM killer same
> number of times. This means that the original implementation is much
> more aggressive and triggers the OOM killer sooner. free pages stats
> show that neither kernels went OOM too early most of the time, though. I
> guess the difference is in the backoff when retries without any progress
> do sleep for a while if there is memory under writeback or dirty which
> is highly likely considering the parallel IO.
> Both kernels have seen races where zone wasn't marked unreclaimable
> and we still hit the OOM killer. This is most likely a race where
> a task managed to exit between the last allocation attempt and the oom
> killer invocation.
> 
> 2) 2 writers again with 10s of run and then 10 mem_eaters to consume as much
>    memory as possible without triggering the OOM killer. This required a lot
>    of tuning but I've considered 3 consecutive runs in three different boots
>    without OOM as a success.
> 
> * base kernel
> size=$(awk '/MemFree/{printf "%dK", ($2/10)-(16*1024)}' /proc/meminfo)
> 
> * patched kernel
> size=$(awk '/MemFree/{printf "%dK", ($2/10)-(12*1024)}' /proc/meminfo)
> 
> That means 40M more memory was usable without triggering OOM killer. The
> base kernel sometimes managed to handle the same as patched but it
> wasn't consistent and failed in at least on of the 3 runs. This seems
> like a minor improvement.
> 
> I was testing also GPF_REPEAT costly requests (hughetlb) with fragmented
> memory and under memory pressure. The results are in patch 11 where the
> logic is implemented. In short I can see huge improvement there.
> 
> I am certainly interested in other usecases as well as well as any
> feedback. Especially those which require higher order requests.
> 
> * Changes since v5
> - added "vmscan: consider classzone_idx in compaction_ready"
> - added "mm, oom, compaction: prevent from should_compact_retry looping
>   for ever for costly orders"
> - acked-bys from Vlastimil
> - integrated feedback from review
> * Changes since v4
> - dropped __GFP_REPEAT for costly allocation as it is now replaced by
>   the compaction based feedback logic
> - !costly high order requests are retried based on the compaction feedback
> - compaction feedback has been tweaked to give us an useful information
>   to make decisions in the page allocator
> - rebased on the current mmotm-2016-04-01-16-24 with the previous version
>   of the rework reverted
> 
> * Changes since v3
> - factor out the new heuristic into its own function as suggested by
>   Johannes (no functional changes)
> 
> * Changes since v2
> - rebased on top of mmotm-2015-11-25-17-08 which includes
>   wait_iff_congested related changes which needed refresh in
>   patch#1 and patch#2
> - use zone_page_state_snapshot for NR_FREE_PAGES per David
> - shrink_zones doesn't need to return anything per David
> - retested because the major kernel version has changed since
>   the last time (4.2 -> 4.3 based kernel + mmotm patches)
> 
> * Changes since v1
> - backoff calculation was de-obfuscated by using DIV_ROUND_UP
> - __GFP_NOFAIL high order migh fail fixed - theoretical bug
> 
> [1] http://lkml.kernel.org/r/1459855533-4600-1-git-send-email-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/alpine.LSU.2.11.1602241832160.15564@eggly.anvils
> [3] http://lkml.kernel.org/r/CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com
> [4] http://lkml.kernel.org/r/CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com
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
