Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACB06B0287
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:04:17 -0500 (EST)
Received: by wmvv187 with SMTP id v187so277156575wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:04:16 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id f199si4619252wme.123.2015.11.18.05.04.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 05:04:15 -0800 (PST)
Received: by wmdw130 with SMTP id w130so197638087wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:04:13 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 0/3] OOM detection rework v2
Date: Wed, 18 Nov 2015 14:03:57 +0100
Message-Id: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi,
this is a second version of the the patchset. The previous version was
posted here [1]. Changes since the last time are not really huge. The
backoff calculation was de-obfuscated by using DIV_ROUND_UP and one
theoretical bug for __GFP_NOFAIL and costly requests was fixed.

As pointed by Linus [2][3] relying on zone_reclaimable as a way to
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

* base kernel
$ grep "Killed process" base-oom-run.log | tail -n1
[  836.589319] Killed process 3035 (mem_eater) total-vm:85852kB, anon-rss:81996kB, file-rss:344kB
$ grep "invoked oom-killer" base-oom-run.log | wc -l
78
$ grep "DMA32.*all_unreclaimable? no" base-oom-run.log | wc -l
0

* patched kernel
$ grep "Killed process" patched-oom-run.log | tail -n1
[  843.281009] Killed process 2998 (mem_eater) total-vm:85852kB, anon-rss:82000kB, file-rss:4kB
$ grep "invoked oom-killer" patched-oom-run.log | wc -l
77
$ grep "DMA32.*all_unreclaimable? no" patched-oom-run.log | wc -l
0

So they have finished in a comparable time and killed the very similar number
of processes and there doesn't seem to be any case where the patched kernel
would have DMA32 zone considered reclaimable.

2) 2 writers again with 10s of run and then 10 mem_eaters to consume as much
   memory as possible without triggering the OOM killer. This required a lot
   of tuning but I've considered 3 consecutive runs without OOM as a success.

* base kernel
size=$(awk '/MemFree/{printf "%dK", ($2/10)-(14*1024)}' /proc/meminfo)

* patched kernel
size=$(awk '/MemFree/{printf "%dK", ($2/10)-(7500)}' /proc/meminfo)

So it seems that the patched kernel handled the low mem conditions better and
fired OOM killer later.

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
      1 66
     19 67
     20 Trying to allocate 74

* patched kernel
$ sort patched-hugepages.log | uniq -c
      1 66
     19 67
     20 Trying to allocate 74

This also doesn't look very bad but this particular test is quite timing
sensitive.

The above results do seem optimistic but more loads should be tested
obviously. I would really appreciate a feedback on the approach I have
chosen before I go into more tuning. Is this viable way to go?

[1] http://lkml.kernel.org/r/1446131835-3263-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/CA+55aFwapaED7JV6zm-NVkP-jKie+eQ1vDXWrKD=SkbshZSgmw@mail.gmail.com
[3] http://lkml.kernel.org/r/CA+55aFxwg=vS2nrXsQhAUzPQDGb8aQpZi0M7UUh21ftBo-z46Q@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
