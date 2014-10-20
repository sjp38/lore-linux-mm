Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3D23A6B0070
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:41:55 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so22588pab.10
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 15:41:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id og2si9098441pbc.104.2014.10.20.15.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Oct 2014 15:41:52 -0700 (PDT)
Message-Id: <20141020215633.717315139@infradead.org>
Date: Mon, 20 Oct 2014 23:56:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 0/6] Another go at speculative page faults
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Hi,

I figured I'd give my 2010 speculative fault series another spin:

  https://lkml.org/lkml/2010/1/4/257

Since then I think many of the outstanding issues have changed sufficiently to
warrant another go. In particular Al Viro's delayed fput seems to have made it
entirely 'normal' to delay fput(). Lai Jiangshan's SRCU rewrite provided us
with call_srcu() and my preemptible mmu_gather removed the TLB flushes from
under the PTL.

The code needs way more attention but builds a kernel and runs the
micro-benchmark so I figured I'd post it before sinking more time into it.

I realize the micro-bench is about as good as it gets for this series and not
very realistic otherwise, but I think it does show the potential benefit the
approach has.

(patches go against .18-rc1+)

---

Using Kamezawa's multi-fault micro-bench from: https://lkml.org/lkml/2010/1/6/28

My Ivy Bridge EP (2*10*2) has a ~58% improvement in pagefault throughput:

PRE:

root@ivb-ep:~# perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault 20

 Performance counter stats for './multi-fault 20' (5 runs):

       149,441,555      page-faults                  ( +-  1.25% )
     2,153,651,828      cache-misses                 ( +-  1.09% )

      60.003082014 seconds time elapsed              ( +-  0.00% )

POST:

root@ivb-ep:~# perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault 20

 Performance counter stats for './multi-fault 20' (5 runs):

       236,442,626      page-faults                  ( +-  0.08% )
     2,796,353,939      cache-misses                 ( +-  1.01% )

      60.002792431 seconds time elapsed              ( +-  0.00% )


My Ivy Bridge EX (4*15*2) has a ~78% improvement in pagefault throughput:

PRE:

root@ivb-ex:~# perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault 60

 Performance counter stats for './multi-fault 60' (5 runs):

       105,789,078      page-faults                 ( +-  2.24% )
     1,314,072,090      cache-misses                ( +-  1.17% )

      60.009243533 seconds time elapsed             ( +-  0.00% )

POST:

root@ivb-ex:~# perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault 60

 Performance counter stats for './multi-fault 60' (5 runs):

       187,751,767      page-faults                 ( +-  2.24% )
     1,792,758,664      cache-misses                ( +-  2.30% )

      60.011611579 seconds time elapsed             ( +-  0.00% )

(I've not yet looked at why the EX sucks chunks compared to the EP box, I
 suspect we contend on other locks, but it could be anything.)

---

 arch/x86/mm/fault.c      |  35 ++-
 include/linux/mm.h       |  19 +-
 include/linux/mm_types.h |   5 +
 kernel/fork.c            |   1 +
 mm/init-mm.c             |   1 +
 mm/internal.h            |  18 ++
 mm/memory.c              | 672 ++++++++++++++++++++++++++++-------------------
 mm/mmap.c                | 101 +++++--
 8 files changed, 544 insertions(+), 308 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
