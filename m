Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 683406B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 00:24:09 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 0/9] per-cgroup tcp buffers limitation
Date: Wed,  7 Sep 2011 01:23:10 -0300
Message-Id: <1315369399-3073-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, Glauber Costa <glommer@parallels.com>

This patch introduces per-cgroup tcp buffers limitation. This allows
sysadmins to specify a maximum amount of kernel memory that
tcp connections can use at any point in time. TCP is the main interest
in this work, but extending it to other protocols would be easy.

For this to work, I am introducing kmem_cgroup, a cgroup targetted
at tracking and controlling objects in kernel memory. Since they
are usually not found in page granularity, and are fundamentally
different from userspace memory (not swappable, can't overcommit),
I am proposing those objects live in its own cgroup rather than
in the memory controller.

It piggybacks in the memory control mechanism already present in
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

Glauber Costa (9):
  per-netns ipv4 sysctl_tcp_mem
  Kernel Memory cgroup
  socket: initial cgroup code.
  function wrappers for upcoming socket
  foundations of per-cgroup memory pressure controlling.
  per-cgroup tcp buffers control
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Add documentation about kmem_cgroup

 Documentation/cgroups/kmem_cgroups.txt |   27 +++++
 crypto/af_alg.c                        |    7 +-
 include/linux/cgroup_subsys.h          |    4 +
 include/linux/kmem_cgroup.h            |  194 ++++++++++++++++++++++++++++++++
 include/net/netns/ipv4.h               |    1 +
 include/net/sock.h                     |   37 +++++-
 include/net/tcp.h                      |   13 ++-
 include/net/udp.h                      |    3 +-
 include/trace/events/sock.h            |   10 +-
 init/Kconfig                           |   11 ++
 mm/Makefile                            |    1 +
 mm/kmem_cgroup.c                       |   61 ++++++++++
 net/core/sock.c                        |   88 ++++++++++-----
 net/decnet/af_decnet.c                 |   21 +++-
 net/ipv4/proc.c                        |    7 +-
 net/ipv4/sysctl_net_ipv4.c             |   59 +++++++++-
 net/ipv4/tcp.c                         |  181 ++++++++++++++++++++++++++----
 net/ipv4/tcp_input.c                   |   12 +-
 net/ipv4/tcp_ipv4.c                    |   15 ++-
 net/ipv4/tcp_output.c                  |    2 +-
 net/ipv4/tcp_timer.c                   |    2 +-
 net/ipv4/udp.c                         |   20 +++-
 net/ipv6/tcp_ipv6.c                    |   10 +-
 net/ipv6/udp.c                         |    4 +-
 net/sctp/socket.c                      |   35 +++++--
 25 files changed, 710 insertions(+), 115 deletions(-)
 create mode 100644 Documentation/cgroups/kmem_cgroups.txt
 create mode 100644 include/linux/kmem_cgroup.h
 create mode 100644 mm/kmem_cgroup.c

-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
