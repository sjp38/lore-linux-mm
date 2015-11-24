Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE4E6B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 16:52:23 -0500 (EST)
Received: by wmvv187 with SMTP id v187so230362231wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 13:52:23 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 132si959056wmj.99.2015.11.24.13.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 13:52:22 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 00/13] mm: memcontrol: account socket memory in unified hierarchy v4
Date: Tue, 24 Nov 2015 16:51:52 -0500
Message-Id: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this is version 4 of the patches to add socket memory accounting to
the unified hierarchy memory controller.

Andrew, absent any new showstoppers, please consider merging this
series for v4.5. Thanks!

Changes since v3 include:

- Restored the local vmpressure reporting while preserving the
  hierarchical pressure semantics of the user interface, such that
  networking is throttled also for global memory shortage, and not
  just when encountering configured cgroup limits. As per Vladimir,
  this will make fully provisioned systems perform more smoothly.

- Make packet submission paths enter direct reclaim when memory is
  tight, and reserve the background balancing worklet for receiving
  packets in softirq context.

- Dropped a buggy shrinker cleanup, spotted by Vladimir.

- Fixed a missing return statement, spotted by Eric.

- Documented cgroup.memory=nosocket, as per Michal.

- Rebased onto latest mmots and added ack tags.

Changes since v2 include:

- Fixed an underflow bug in the mem+swap counter that came through the
  design of the per-cpu charge cache. To fix that, the unused mem+swap
  counter is now fully patched out on unified hierarchy. Double whammy.

- Restored the counting jump label such that the networking callbacks
  get patched out again when the last memory-controlled cgroup goes
  away. The code was already there, so we might as well keep it.

- Broke down the massive tcp_memcontrol rewrite patch into smaller
  logical pieces to (hopefully) make it easier to review and verify.

Changes since v1 include:

- No accounting overhead unless a dedicated cgroup is created and the
  memory controller instructed to track that group's memory footprint.
  Distribution kernels enable CONFIG_MEMCG, and users (incl. systemd)
  might create cgroups only for process control or resources other
  than memory. As noted by David and Michal, these setups shouldn't
  pay any overhead for this.

- Continue to enter the socket pressure state when hitting the memory
  controller's hard limit. Vladimir noted that there is at least some
  value in telling other sockets in the cgroup to not increase their
  transmit windows when one of them is already dropping packets.

- Drop the controversial vmpressure rework. Instead of changing the
  level where pressure is noted, keep noting pressure in its origin
  and then make the pressure check hierarchical. As noted by Michal
  and Vladimir, we shouldn't risk changing user-visible behavior.

---

Socket buffer memory can make up a significant share of a workload's
memory footprint that can be directly linked to userspace activity,
and so it needs to be part of the memory controller to provide proper
resource isolation/containment.

Historically, socket buffers were accounted in a separate counter,
without any pressure equalization between anonymous memory, page
cache, and the socket buffers. When the socket buffer pool was
exhausted, buffer allocations would fail hard and cause network
performance to tank, regardless of whether there was still memory
available to the group or not. Likewise, struggling anonymous or cache
workingsets could not dip into an idle socket memory pool. Because of
this, the feature was not usable for many real life applications.

To not repeat this mistake, the new memory controller will account all
types of memory pages it is tracking on behalf of a cgroup in a single
pool. Upon pressure, the VM reclaims and shrinks and puts pressure on
whatever memory consumer in that pool is within its reach.

For socket memory, pressure feedback is provided through vmpressure
events. When the VM has trouble freeing memory, the network code is
instructed to stop growing the cgroup's transmit windows.

This series begins with a rework of the existing tcp memory controller
that simplifies and cleans up the code while allowing us to have only
one set of networking hooks for both memory controller versions. The
original behavior of the existing tcp controller should be preserved.

It then adds socket accounting to the v2 memory controller, including
the use of the per-cpu charge cache and async memory.high enforcement
from socket memory charges.

Lastly, vmpressure is hooked up to the socket code so that it stops
growing transmit windows when the VM has trouble reclaiming memory.

 Documentation/kernel-parameters.txt |   4 +
 include/linux/memcontrol.h          |  71 ++++----
 include/linux/vmpressure.h          |   5 +-
 include/net/sock.h                  | 149 ++---------------
 include/net/tcp.h                   |   5 +-
 include/net/tcp_memcontrol.h        |   1 -
 mm/backing-dev.c                    |   2 +-
 mm/memcontrol.c                     | 296 ++++++++++++++++++++++------------
 mm/vmpressure.c                     |  78 ++++++---
 mm/vmscan.c                         |  10 +-
 net/core/sock.c                     |  78 +++------
 net/ipv4/tcp.c                      |   3 +-
 net/ipv4/tcp_ipv4.c                 |   9 +-
 net/ipv4/tcp_memcontrol.c           |  82 ++++------
 net/ipv4/tcp_output.c               |   7 +-
 net/ipv6/tcp_ipv6.c                 |   3 -
 16 files changed, 383 insertions(+), 420 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
