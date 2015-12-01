Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9762C6B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 07:56:57 -0500 (EST)
Received: by wmec201 with SMTP id c201so203916335wme.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 04:56:57 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id en5si71793130wjd.182.2015.12.01.04.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 04:56:55 -0800 (PST)
Received: by wmvv187 with SMTP id v187so205258110wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 04:56:54 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/3] OOM detection rework v3
Date: Tue,  1 Dec 2015 13:56:44 +0100
Message-Id: <1448974607-10208-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,

This is v3 of the RFC. The previous version was posted [1]
* Changes since v2
- rebased on top of mmotm-2015-11-25-17-08 which includes
  wait_iff_congested related changes which needed refresh in
  patch#1 and patch#2
- use zone_page_state_snapshot for NR_FREE_PAGES per David
- shrink_zones doesn't need to return anything per David
- retested because the major kernel version has changed since
  the last time (4.2 -> 4.3 based kernel + mmotm patches)

* Changes since v1
- backoff calculation was de-obfuscated by using DIV_ROUND_UP
- __GFP_NOFAIL high order migh fail fixed - theoretical bug

as pointed by Linus [2][3] relying on zone_reclaimable as a way to
communicate the reclaim progress is rater dubious. I tend to agree,
not only it is really obscure, it is not hard to imagine cases where a
single page freed in the loop keeps all the reclaimers looping without
getting any progress because their gfp_mask wouldn't allow to get that
page anyway (e.g. single GFP_ATOMIC alloc and free loop). This is rather
rare so it doesn't happen in the practice but the current logic which we
have is rather obscure and hard to follow a also non-deterministic.

This is an attempt to make the OOM detection more deterministic and
easier to follow because each reclaimer basically tracks its own
progress which is implemented at the page allocator layer rather spread
out between the allocator and the reclaim. The more on the implementation
is described in the first patch.

I have tested several different scenarios but it should be clear that
testing OOM killer is quite hard to be representative. There is usually
a tiny gap between almost OOM and full blown OOM which is often time
sensitive. Anyway, I have tested the following 3 scenarios and I would
appreciate if there are more to test.

Testing environment: a virtual machine with 2G of RAM and 2CPUs without
any swap to make the OOM more deterministic.

1) 2 writers (each doing dd with 4M blocks to an xfs partition with 1G size,
   removes the files and starts over again) running in parallel for 10s
   to build up a lot of dirty pages when 100 parallel mem_eaters (anon
   private populated mmap which waits until it gets signal) with 80M
   each.

   This causes an OOM flood of course and I have compared both patched
   and unpatched kernels. The test is considered finished after there
   are no OOM conditions detected. This should tell us whether there are
   any excessive kills or some of them premature:

I have performed two runs this time each after a fresh boot.

* base kernel
$ grep "Killed process" base-oom-run1.log | tail -n1
[  211.824379] Killed process 3086 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:332kB, shmem-rss:0kB
$ grep "Killed process" base-oom-run2.log | tail -n1
[  157.188326] Killed process 3094 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:368kB, shmem-rss:0kB

$ grep "invoked oom-killer" base-oom-run1.log | wc -l
78
$ grep "invoked oom-killer" base-oom-run2.log | wc -l
76

The number of OOM invocations is consistent with my last measurements
but the runtime is way too different (it took 800+s). One thing that
could have skewed results was that I was tail -f the serial log on the
host system to see the progress. I have stopped doing that. The results
are more consistent now but still too different from the last time.
This is really weird so I've retested with the last 4.2 mmotm again and
I am getting consistent ~220s which is really close to the above. If I
apply the WQ vmstat patch on top I am getting close to 160s so the stale
vmstat counters made a difference which is to be expected. I have a new
SSD in my laptop which migh have made a difference but I wouldn't expect
it to be that large.

$ grep "DMA32.*all_unreclaimable? no" base-oom-run1.log | wc -l
4
$ grep "DMA32.*all_unreclaimable? no" base-oom-run2.log | wc -l
1

* patched kernel
$ grep "Killed process" patched-oom-run1.log | tail -n1
[  341.164930] Killed process 3099 (mem_eater) total-vm:85852kB, anon-rss:82000kB, file-rss:336kB, shmem-rss:0kB
$ grep "Killed process" patched-oom-run2.log | tail -n1
[  349.111539] Killed process 3082 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:4kB, shmem-rss:0kB

$ grep "invoked oom-killer" patched-oom-run1.log | wc -l
78
$ grep "invoked oom-killer" patched-oom-run2.log | wc -l
77

$ grep "DMA32.*all_unreclaimable? no" patched-oom-run1.log | wc -l
1
$ grep "DMA32.*all_unreclaimable? no" patched-oom-run2.log | wc -l
0

So the number of OOM killer invocation is the same but the overall
runtime of the test was much longer with the patched kernel. This can be
attributed to more retries in general. The results from the base kernel
are quite inconsitent and I think that consistency is better here.


2) 2 writers again with 10s of run and then 10 mem_eaters to consume as much
   memory as possible without triggering the OOM killer. This required a lot
   of tuning but I've considered 3 consecutive runs without OOM as a success.

* base kernel
size=$(awk '/MemFree/{printf "%dK", ($2/10)-(15*1024)}' /proc/meminfo)

* patched kernel
size=$(awk '/MemFree/{printf "%dK", ($2/10)-(9*1024)}' /proc/meminfo)

It was -14M for the base 4.2 kernel and -7500M for the patched 4.2 kernel in
my last measurements.
The patched kernel handled the low mem conditions better and fired OOM
killer later.

3) Costly high-order allocations with a limited amount of memory.
   Start 10 memeaters in parallel each with
   size=$(awk '/MemTotal/{printf "%d\n", $2/10}' /proc/meminfo)
   This will cause an OOM killer which will kill one of them which will free up
   200M and then try to use all the remaining space for hugetlb pages. See how
   many of them will pass kill everything, wait 2s and try again.
   This tests whether we do not fail __GFP_REPEAT costly allocations too early
   now.
* base kernel
$ sort base-hugepages.log | uniq -c
      1 64
     13 65
      6 66
     20 Trying to allocate 73

* patched kernel
$ sort patched-hugepages.log | uniq -c
     17 65
      3 66
     20 Trying to allocate 73

This also doesn't look very bad but this particular test is quite timing
sensitive.

The above results do seem optimistic but more loads should be tested
obviously. I would really appreciate a feedback on the approach I have
chosen before I go into more tuning. Is this viable way to go?

[1] http://lkml.kernel.org/r/1447851840-15640-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com
[3] http://lkml.kernel.org/r/CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
