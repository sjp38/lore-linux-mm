Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 45A6382F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:22:34 -0500 (EST)
Received: by wmll128 with SMTP id l128so3665467wml.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:22:33 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 75si9535978wmm.5.2015.11.04.14.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 14:22:33 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/8] mm: memcontrol: account socket memory in unified hierarchy v2
Date: Wed,  4 Nov 2015 17:22:06 -0500
Message-Id: <1446675734-25671-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi,

this is version 2 of the patches to add socket memory accounting to
the unified hierarchy memory controller. Changes from v1 include:

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

---

This series begins with a rework of the existing tcp memory controller
that simplifies and cleans up the code while allowing us to have only
one set of networking hooks for both memory controller versions. The
original behavior of the existing tcp controller should be preserved.

It then adds socket accounting to the v2 memory controller, including
the use of the per-cpu charge cache and async memory.high enforcement
from socket memory charges.

Lastly, vmpressure is hooked up to the socket code so that it stops
growing transmit windows when the VM has trouble reclaiming memory.

 include/linux/memcontrol.h   |  98 ++++++++-------
 include/linux/page_counter.h |   6 +-
 include/net/sock.h           | 137 ++-------------------
 include/net/tcp.h            |   5 +-
 include/net/tcp_memcontrol.h |   7 --
 mm/backing-dev.c             |   2 +-
 mm/hugetlb_cgroup.c          |   3 +-
 mm/memcontrol.c              | 262 +++++++++++++++++++++++++----------------
 mm/page_counter.c            |  14 +--
 mm/vmpressure.c              |  25 +++-
 mm/vmscan.c                  |  31 ++---
 net/core/sock.c              |  78 +++---------
 net/ipv4/sysctl_net_ipv4.c   |   1 -
 net/ipv4/tcp.c               |   3 +-
 net/ipv4/tcp_ipv4.c          |   9 +-
 net/ipv4/tcp_memcontrol.c    | 147 ++++-------------------
 net/ipv4/tcp_output.c        |   6 +-
 net/ipv6/tcp_ipv6.c          |   3 -
 18 files changed, 328 insertions(+), 509 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
