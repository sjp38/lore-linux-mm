Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 09D996B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:00 -0400 (EDT)
Received: by wikq8 with SMTP id q8so12979173wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:21:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lb9si15943577wjb.188.2015.10.21.21.21.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:21:58 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/8] mm: memcontrol: account socket memory in unified hierarchy
Date: Thu, 22 Oct 2015 00:21:28 -0400
Message-Id: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

this series adds socket buffer memory tracking and accounting to the
unified hierarchy memory cgroup controller.

[ Networking people, at this time please check the diffstat below to
  avoid going into convulsions. ]

Socket buffer memory can make up a significant share of a workload's
memory footprint, and so it needs to be accounted and tracked out of
the box, along with other types of memory that can be directly linked
to userspace activity, in order to provide useful resource isolation.

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
pool. And upon pressure, the VM reclaims and shrinks whatever memory
in that pool is within its reach.

These patches add accounting for memory consumed by sockets associated
with a cgroup to the existing pool of anonymous pages and page cache.

Patch #3 reworks the existing memcg socket infrastructure. It has many
provisions for future plans that won't materialize, and much of this
simply evaporates. The networking people should be happy about this.

Patch #5 adds accounting and tracking of socket memory to the unified
hierarchy memory controller, as described above. It uses the existing
per-cpu charge caches and triggers high limit reclaim asynchroneously.

Patch #8 uses the vmpressure extension to equalize pressure between
the pages tracked natively by the VM and socket buffer pages. As the
pool is shared, it makes sense that while natively tracked pages are
under duress the network transmit windows are also not increased.

As per above, this is an essential part of the new memory controller's
core functionality. With the unified hierarchy nearing release, please
consider this for 4.4.

 include/linux/memcontrol.h   |  90 +++++++++-------
 include/linux/page_counter.h |   6 +-
 include/net/sock.h           | 139 ++----------------------
 include/net/tcp.h            |   5 +-
 include/net/tcp_memcontrol.h |   7 --
 mm/backing-dev.c             |   2 +-
 mm/hugetlb_cgroup.c          |   3 +-
 mm/memcontrol.c              | 235 ++++++++++++++++++++++++++---------------
 mm/page_counter.c            |  14 +--
 mm/vmpressure.c              |  29 ++++-
 mm/vmscan.c                  |  41 +++----
 net/core/sock.c              |  78 ++++----------
 net/ipv4/sysctl_net_ipv4.c   |   1 -
 net/ipv4/tcp.c               |   3 +-
 net/ipv4/tcp_ipv4.c          |   9 +-
 net/ipv4/tcp_memcontrol.c    | 147 ++++----------------------
 net/ipv4/tcp_output.c        |   6 +-
 net/ipv6/tcp_ipv6.c          |   3 -
 18 files changed, 319 insertions(+), 499 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
