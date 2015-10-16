Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0935382F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 11:57:21 -0400 (EDT)
Received: by wijq8 with SMTP id q8so17604776wij.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:57:20 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id k9si11935612wif.3.2015.10.16.08.57.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 08:57:19 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so15100647wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:57:19 -0700 (PDT)
Date: Fri, 16 Oct 2015 17:57:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silent hang up caused by pages being not scanned?
Message-ID: <20151016155716.GF19597@dhcp22.suse.cz>
References: <201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
 <201510062351.JHJ57310.VFQLFHFOJtSMOO@I-love.SAKURA.ne.jp>
 <201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp>
 <201510130025.EJF21331.FFOQJtVOMLFHSO@I-love.SAKURA.ne.jp>
 <CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com>
 <201510132121.GDE13044.FOSHLJOMFOtQVF@I-love.SAKURA.ne.jp>
 <CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com>
 <20151015131409.GD2978@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151015131409.GD2978@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Thu 15-10-15 15:14:09, Michal Hocko wrote:
> On Tue 13-10-15 09:37:06, Linus Torvalds wrote:
[...]
> > Now, I realize the above suggestions are big changes, and they'll
> > likely break things and we'll still need to tweak things, but dammit,
> > wouldn't that be better than just randomly tweaking the insane
> > zone_reclaimable logic?
> 
> Yes zone_reclaimable is subtle and imho it is used even at the
> wrong level. We should decide whether we are really OOM at
> __alloc_pages_slowpath. We definitely need a big picture logic to tell
> us when it makes sense to drop the ball and trigger OOM killer or fail
> the allocation request.
> 
> E.g. free + reclaimable + writeback < min_wmark on all usable zones for
> more than X rounds of direct reclaim without any progress is
> a sufficient signal to go OOM. Costly/noretry allocations can fail earlier
> of course. This is obviously a half baked idea which needs much more
> consideration all I am trying to say is that we need a high level metric
> to tell OOM condition.

OK so here is what I am playing with currently. It is not complete
yet. Anyway I have tested it with 2 scenarios on a swapless system with
2G of RAM both do

$ cat writer.sh
#!/bin/sh
size=$((1<<30))
block=$((4<<10))

writer()
{
	(
        while true
        do
                dd if=/dev/zero of=/mnt/data/file.$1 bs=$block count=$(($size/$block))
                rm /mnt/data/file.$1
                sync
        done
	) &
}

writer 1
writer 2

sleep 10s # allow to accumulate enough dirty pages

1) massive OOM
start 100 memeaters each 80M run in parallel (anon private MAP_POPULATE
mapping). This will trigger many OOM killers and the overall count is
what I was interested in. The test is considered finished when we get
a steady state - writers can make progress and there is no more OOM
killing for some time.

$ grep "invoked oom-killer" base-run-oom.log | wc -l
78
$ grep "invoked oom-killer" test-run-oom.log | wc -l
63

So it looks like we have triggered less OOM killing with the patch
applied. I haven't checked those too closely but it seems like at least
two instances might not have triggered with the current implementation
because DMA32 zone is considered reclaimable. But this check is
inherently racy so we cannot be sure.
$ grep "DMA32.*all_unreclaimable? no" test2-run-oom.log | wc -l
2

2) almost OOM situation
invoke 10 memeaters in parallel and try to fill up all the memory
without triggering the OOM killer. This is quite hard and it required a
lot of tunning. I've ended up with:
#!/bin/sh
pkill mem_eater
sync
echo 3 > /proc/sys/vm/drop_caches
sync
size=$(awk '/MemFree/{printf "%dK", ($2/10)-(16*1024)}' /proc/meminfo)
sh writer.sh &
sleep 10s
for i in $(seq 10)
do
        memcg_test/tools/mem_eater $size &
done

wait

and this one doesn't hit the OOM killer with the original implementation
while it hits it with the patch applied:
[   32.727001] DMA32 free:5428kB min:5532kB low:6912kB high:8296kB active_anon:1802520kB inactive_anon:204kB active_file:6692kB inactive_file:137184k
B unevictable:0kB isolated(anon):136kB isolated(file):32kB present:2080640kB managed:1997880kB mlocked:0kB dirty:0kB writeback:137168kB mapped:6408kB
 shmem:204kB slab_reclaimable:20472kB slab_unreclaimable:13276kB kernel_stack:1456kB pagetables:4756kB unstable:0kB bounce:0kB free_pcp:120kB local_p
cp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:948764 all_unreclaimable? yes

There is a lot of memory in the writeback but all_unreclaimable is yes
so who knows maybe it is just a coincidence we haven't triggered OOM in
the original kernel.

Anyway the two implementation will be hard to compare because workloads
are very different but I think something like below should be more
readable and deterministic than what we have right now. It will need
some more tuning for sure and I will be playing with it some more. I
would just like to hear opinions whether this approach makes sense.
If yes I will post it separately in a new thread for a wider discussion.
This email thread seems to be full of detours already.
---
