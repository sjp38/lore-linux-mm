Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB586B0010
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 21:47:39 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/7] per-cgroup tcp buffer pressure settings
Date: Wed, 14 Sep 2011 22:46:08 -0300
Message-Id: <1316051175-17780-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

This patch introduces per-cgroup tcp buffers limitation. This allows
sysadmins to specify a maximum amount of kernel memory that
tcp connections can use at any point in time. TCP is the main interest
in this work, but extending it to other protocols would be easy.

For this to work, I am hooking it into memcg, after the introdution of
an extension for tracking and controlling objects in kernel memory.
Since they are usually not found in page granularity, and are fundamentally
different from userspace memory (not swappable, can't overcommit), they
need their special place inside the Memory Controller.

Right now, the kmem extension is quite basic, and just lays down the
basic infrastucture for the ongoing work. 

Although it does not account kernel memory allocated - I preferred to
keep this series simple and leave accounting to the slab allocations when
they arrive.

What it does is to piggyback in the memory control mechanism already present in
/proc/sys/net/ipv4/tcp_mem. There is a soft limit, and a hard limit,
that will suppress allocation when reached. For each cgroup, however,
the file kmem.tcp_maxmem will be used to cap those values. 

The usage I have in mind here is containers. Each container will
define its own values for soft and hard limits, but none of them will
be possibly bigger than the value the box' sysadmin specified from
the outside.

To test for any performance impacts of this patch, I used netperf's
TCP_RR benchmark on localhost, so we can have both recv and snd in action.

Command line used was ./src/netperf -t TCP_RR -H localhost, and the
results:

Without the patch
=================

Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    26996.35
16384  87380

With the patch
===============

Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    27291.86
16384  87380

The difference is within a one-percent range.

Nesting cgroups doesn't seem to be the dominating factor as well,
with nestings up to 10 levels not showing a significant performance
difference.


Glauber Costa (7):
  Basic kernel memory functionality for the Memory Controller
  socket: initial cgroup code.
  foundations of per-cgroup memory pressure controlling.
  per-cgroup tcp buffers control
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup

 Documentation/cgroups/memory.txt |   31 +++-
 crypto/af_alg.c                  |    7 +-
 include/linux/memcontrol.h       |   84 +++++++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  126 +++++++++++++-
 include/net/tcp.h                |   14 +-
 include/net/udp.h                |    3 +-
 include/trace/events/sock.h      |   10 +-
 init/Kconfig                     |   11 ++
 mm/memcontrol.c                  |  354 +++++++++++++++++++++++++++++++++++++-
 net/core/sock.c                  |   93 +++++++---
 net/decnet/af_decnet.c           |   21 ++-
 net/ipv4/proc.c                  |    7 +-
 net/ipv4/sysctl_net_ipv4.c       |   71 +++++++-
 net/ipv4/tcp.c                   |   58 ++++---
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   18 ++-
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv4/udp.c                   |   20 ++-
 net/ipv6/tcp_ipv6.c              |   16 +-
 net/ipv6/udp.c                   |    4 +-
 net/sctp/socket.c                |   35 +++-
 23 files changed, 876 insertions(+), 124 deletions(-)

-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
