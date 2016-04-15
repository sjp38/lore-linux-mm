Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8778A6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 08:44:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id t184so76555559qkh.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:44:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e46si20000343qgd.31.2016.04.15.05.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 05:44:09 -0700 (PDT)
Date: Fri, 15 Apr 2016 14:44:02 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 00/28] Optimise page alloc/free fast paths v3
Message-ID: <20160415144402.5fbe7a1e@redhat.com>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, brouer@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Fri, 15 Apr 2016 09:58:52 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> There were no further responses to the last series but I kept going and
> added a few more small bits. Most are basic micro-optimisations.  The last
> two patches weaken debugging checks to improve performance at the cost of
> delayed detection of some use-after-free and memory corruption bugs. If
> they make people uncomfortable, they can be dropped and the rest of the
> series stands on its own.
> 
> Changelog since v2
> o Add more micro-optimisations
> o Weak debugging checks in favor of speed
> 
[...]
> 
> The overall impact on a page allocator microbenchmark for a range of orders

I also micro benchmarked this patchset.  Avail via Mel Gorman's kernel tree:
 http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git
tested branch mm-vmscan-node-lru-v5r9 which also contain the node-lru series.

Tool:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench01.c
Run as:
 modprobe page_bench01; rmmod page_bench01 ; dmesg | tail -n40 | grep 'alloc_pages order'

Results kernel 4.6.0-rc1 :

 alloc_pages order:0(4096B/x1) 272 cycles per-4096B 272 cycles
 alloc_pages order:1(8192B/x2) 395 cycles per-4096B 197 cycles
 alloc_pages order:2(16384B/x4) 433 cycles per-4096B 108 cycles
 alloc_pages order:3(32768B/x8) 503 cycles per-4096B 62 cycles
 alloc_pages order:4(65536B/x16) 682 cycles per-4096B 42 cycles
 alloc_pages order:5(131072B/x32) 910 cycles per-4096B 28 cycles
 alloc_pages order:6(262144B/x64) 1384 cycles per-4096B 21 cycles
 alloc_pages order:7(524288B/x128) 2335 cycles per-4096B 18 cycles
 alloc_pages order:8(1048576B/x256) 4108 cycles per-4096B 16 cycles
 alloc_pages order:9(2097152B/x512) 8398 cycles per-4096B 16 cycles

After Mel Gorman's optimizations, results from mm-vmscan-node-lru-v5r::

 alloc_pages order:0(4096B/x1) 231 cycles per-4096B 231 cycles
 alloc_pages order:1(8192B/x2) 351 cycles per-4096B 175 cycles
 alloc_pages order:2(16384B/x4) 357 cycles per-4096B 89 cycles
 alloc_pages order:3(32768B/x8) 397 cycles per-4096B 49 cycles
 alloc_pages order:4(65536B/x16) 481 cycles per-4096B 30 cycles
 alloc_pages order:5(131072B/x32) 652 cycles per-4096B 20 cycles
 alloc_pages order:6(262144B/x64) 1054 cycles per-4096B 16 cycles
 alloc_pages order:7(524288B/x128) 1852 cycles per-4096B 14 cycles
 alloc_pages order:8(1048576B/x256) 3156 cycles per-4096B 12 cycles
 alloc_pages order:9(2097152B/x512) 6790 cycles per-4096B 13 cycles



I've also started doing some parallel concurrency testing workloads[1]
 [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench03.c

Order-0 pages scale nicely:

Results kernel 4.6.0-rc1 :
 Parallel-CPUs:1 page order:0(4096B/x1) ave 274 cycles per-4096B 274 cycles
 Parallel-CPUs:2 page order:0(4096B/x1) ave 283 cycles per-4096B 283 cycles
 Parallel-CPUs:3 page order:0(4096B/x1) ave 284 cycles per-4096B 284 cycles
 Parallel-CPUs:4 page order:0(4096B/x1) ave 288 cycles per-4096B 288 cycles
 Parallel-CPUs:5 page order:0(4096B/x1) ave 417 cycles per-4096B 417 cycles
 Parallel-CPUs:6 page order:0(4096B/x1) ave 503 cycles per-4096B 503 cycles
 Parallel-CPUs:7 page order:0(4096B/x1) ave 567 cycles per-4096B 567 cycles
 Parallel-CPUs:8 page order:0(4096B/x1) ave 620 cycles per-4096B 620 cycles

And even better with you changes! :-))) This is great work!

Results from mm-vmscan-node-lru-v5r:
 Parallel-CPUs:1 page order:0(4096B/x1) ave 246 cycles per-4096B 246 cycles
 Parallel-CPUs:2 page order:0(4096B/x1) ave 251 cycles per-4096B 251 cycles
 Parallel-CPUs:3 page order:0(4096B/x1) ave 254 cycles per-4096B 254 cycles
 Parallel-CPUs:4 page order:0(4096B/x1) ave 258 cycles per-4096B 258 cycles
 Parallel-CPUs:5 page order:0(4096B/x1) ave 313 cycles per-4096B 313 cycles
 Parallel-CPUs:6 page order:0(4096B/x1) ave 369 cycles per-4096B 369 cycles
 Parallel-CPUs:7 page order:0(4096B/x1) ave 379 cycles per-4096B 379 cycles
 Parallel-CPUs:8 page order:0(4096B/x1) ave 399 cycles per-4096B 399 cycles


It does not seem that higher order page scale... and your patches does
not change this pattern.

Example order-3 pages, which is often used in the network stack:

Results kernel 4.6.0-rc1 ::
 Parallel-CPUs:1 page order:3(32768B/x8) ave 524 cycles per-4096B 65 cycles
 Parallel-CPUs:2 page order:3(32768B/x8) ave 2131 cycles per-4096B 266 cycles
 Parallel-CPUs:3 page order:3(32768B/x8) ave 3885 cycles per-4096B 485 cycles
 Parallel-CPUs:4 page order:3(32768B/x8) ave 4520 cycles per-4096B 565 cycles
 Parallel-CPUs:5 page order:3(32768B/x8) ave 5604 cycles per-4096B 700 cycles
 Parallel-CPUs:6 page order:3(32768B/x8) ave 7125 cycles per-4096B 890 cycles
 Parallel-CPUs:7 page order:3(32768B/x8) ave 7883 cycles per-4096B 985 cycles
 Parallel-CPUs:8 page order:3(32768B/x8) ave 9364 cycles per-4096B 1170 cycles

Results from mm-vmscan-node-lru-v5r:
 Parallel-CPUs:1 page order:3(32768B/x8) ave 421 cycles per-4096B 52 cycles
 Parallel-CPUs:2 page order:3(32768B/x8) ave 2236 cycles per-4096B 279 cycles
 Parallel-CPUs:3 page order:3(32768B/x8) ave 3408 cycles per-4096B 426 cycles
 Parallel-CPUs:4 page order:3(32768B/x8) ave 4687 cycles per-4096B 585 cycles
 Parallel-CPUs:5 page order:3(32768B/x8) ave 5972 cycles per-4096B 746 cycles
 Parallel-CPUs:6 page order:3(32768B/x8) ave 7349 cycles per-4096B 918 cycles
 Parallel-CPUs:7 page order:3(32768B/x8) ave 8436 cycles per-4096B 1054 cycles
 Parallel-CPUs:8 page order:3(32768B/x8) ave 9589 cycles per-4096B 1198 cycles

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/bench/page_bench03.c

 for ORDER in $(seq 0 5) ; do \
    for X in $(seq 1 8) ; do \
       modprobe page_bench03 page_order=$ORDER parallel_cpus=$X run_flags=$((2#100)); \
       rmmod page_bench03 ; dmesg | tail -n 3 | grep Parallel-CPUs ; \
    done; \
 done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
