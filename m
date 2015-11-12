Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9616B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:42:06 -0500 (EST)
Received: by wmdw130 with SMTP id w130so8342298wmd.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 15:42:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n65si1480316wma.13.2015.11.12.15.42.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 15:42:05 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 00/14] mm: memcontrol: account socket memory in unified hierarchy
Date: Thu, 12 Nov 2015 18:41:19 -0500
Message-Id: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this is version 3 of the patches to add socket memory accounting to
the unified hierarchy memory controller. Changes since v2 include:

- Fixed an underflow bug in the mem+swap counter that came through the
  design of the per-cpu charge cache. To fix that, the unused mem+swap
  counter is now fully patched out on unified hierarchy. Double whammy.

- Restored the counting jump label such that the networking callbacks
  get patched out again when the last memory-controlled cgroup goes
  away. The code was already there, so we might as well keep it.

- Broke down the massive tcp_memcontrol rewrite patch into smaller
  logical pieces to (hopefully) make it easier to review and verify.

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

 include/linux/memcontrol.h   |  71 ++++++----
 include/net/sock.h           | 149 ++------------------
 include/net/tcp.h            |   5 +-
 include/net/tcp_memcontrol.h |   1 -
 mm/backing-dev.c             |   2 +-
 mm/memcontrol.c              | 303 +++++++++++++++++++++++++++--------------
 mm/vmpressure.c              |  25 +++-
 mm/vmscan.c                  |  31 +++--
 net/core/sock.c              |  78 +++--------
 net/ipv4/tcp.c               |   3 +-
 net/ipv4/tcp_ipv4.c          |   9 +-
 net/ipv4/tcp_memcontrol.c    |  85 ++++--------
 net/ipv4/tcp_output.c        |   7 +-
 net/ipv6/tcp_ipv6.c          |   3 -
 14 files changed, 353 insertions(+), 419 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
