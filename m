Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA799000BD
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 06:20:11 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v4 0/8]  per-cgroup tcp buffer pressure settings
Date: Mon,  3 Oct 2011 14:18:35 +0400
Message-Id: <1317637123-18306-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

[[ v3: merge Kirill's suggestions, + a destroy-related bugfix ]]
[[ v4: Fix a bug with non-mounted cgroups + disallow task movement ]]

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
that will suppress allocation when reached. For each non-root cgroup, however,
the file kmem.tcp_maxmem will be used to cap those values.

The usage I have in mind here is containers. Each container will
define its own values for soft and hard limits, but none of them will
be possibly bigger than the value the box' sysadmin specified from
the outside.

To test for any performance impacts of this patch, I used netperf's
TCP_RR benchmark on localhost, so we can have both recv and snd in action.
For this iteration, I am using the 1% confidence interval as suggested by Rick.

Command line used was ./src/netperf -t TCP_RR -H localhost -i 30,3 -I 99,1 and the
results:

Without the patch
=================

Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    35356.22
16384  87380


With the patch
==============

Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    35399.12 
16384  87380

The difference is less than 0.5 %

A simple test with a 1000 level nesting yields more or less the same
difference:

1000 level nesting
==================

Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    35304.35   
16384  87380 

Glauber Costa (8):
  Basic kernel memory functionality for the Memory Controller
  socket: initial cgroup code.
  foundations of per-cgroup memory pressure controlling.
  per-cgroup tcp buffers control
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Disable task moving when using kernel memory accounting

 Documentation/cgroups/memory.txt |   32 +++-
 crypto/af_alg.c                  |    7 +-
 include/linux/memcontrol.h       |   56 ++++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  127 +++++++++++++-
 include/net/tcp.h                |   29 +++-
 include/net/udp.h                |    3 +-
 include/trace/events/sock.h      |   10 +-
 init/Kconfig                     |   11 ++
 mm/memcontrol.c                  |  360 ++++++++++++++++++++++++++++++++++++--
 net/core/sock.c                  |  104 ++++++++---
 net/decnet/af_decnet.c           |   21 ++-
 net/ipv4/proc.c                  |    7 +-
 net/ipv4/sysctl_net_ipv4.c       |   71 +++++++-
 net/ipv4/tcp.c                   |   58 ++++---
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   24 ++-
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv4/udp.c                   |   20 ++-
 net/ipv6/tcp_ipv6.c              |   20 ++-
 net/ipv6/udp.c                   |    4 +-
 net/sctp/socket.c                |   35 +++-
 23 files changed, 883 insertions(+), 133 deletions(-)

-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
