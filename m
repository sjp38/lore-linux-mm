Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 366136B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:15:29 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id x12so2019506qac.18
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:15:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u49si5031953qgd.101.2014.12.10.06.15.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:15:27 -0800 (PST)
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
	(backed by alf_queue)
Date: Wed, 10 Dec 2014 15:15:07 +0100
Message-ID: <20141210141332.31779.56391.stgit@dragon>
In-Reply-To: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

The network stack have some use-cases that puts some extreme demands
on the memory allocator.  One use-case, 10Gbit/s wirespeed at smallest
packet size[1], requires handling a packet every 67.2 ns (nanosec).

Micro benchmarking[2] the SLUB allocator (with skb size 256bytes
elements), show "fast-path" instant reuse only costs 19 ns, but a
closer to network usage pattern show the cost rise to 45 ns.

This patchset introduce a quick mempool (qmempool), which when used
in-front of the SKB (sk_buff) kmem_cache, saves 12 ns on "fast-path"
drop in iptables "raw" table, but more importantly saves 40 ns with
IP-forwarding, which were hitting the slower SLUB use-case.


One of the building blocks for achieving this speedup is a cmpxchg
based Lock-Free queue that supports bulking, named alf_queue for
Array-based Lock-Free queue.  By bulking elements (pointers) from the
queue, the cost of the cmpxchg (approx 8 ns) is amortized over several
elements.

 Patch1: alf_queue (Lock-Free queue)

 Patch2: qmempool using alf_queue

 Patch3: usage of qmempool for SKB caching


Notice, this patchset depend on introduction of napi_alloc_skb(),
which is part of Alexander Duyck's work patchset [3].

Different correctness tests and micro benchmarks are avail via my
github repo "prototype-kernel"[4], where the alf_queue and qmempool is
also kept in sync with this patchset.

Links:
 [1]: http://netoptimizer.blogspot.dk/2014/05/the-calculations-10gbits-wirespeed.html
 [2]: https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/qmempool_bench.c
 [3]: http://thread.gmane.org/gmane.linux.network/342347
 [4]: https://github.com/netoptimizer/prototype-kernel

---

Jesper Dangaard Brouer (3):
      net: use qmempool in-front of sk_buff kmem_cache
      mm: qmempool - quick queue based memory pool
      lib: adding an Array-based Lock-Free (ALF) queue


 include/linux/alf_queue.h |  303 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/qmempool.h  |  205 +++++++++++++++++++++++++++++
 include/linux/skbuff.h    |    4 -
 lib/Kconfig               |   13 ++
 lib/Makefile              |    2 
 lib/alf_queue.c           |   47 +++++++
 mm/Kconfig                |   12 ++
 mm/Makefile               |    1 
 mm/qmempool.c             |  322 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |    5 +
 net/core/skbuff.c         |   43 +++++-
 11 files changed, 950 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/alf_queue.h
 create mode 100644 include/linux/qmempool.h
 create mode 100644 lib/alf_queue.c
 create mode 100644 mm/qmempool.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
