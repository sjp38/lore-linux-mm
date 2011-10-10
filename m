Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 320AC6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:25:54 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 0/8] per-cgroup tcp memory pressure handling
Date: Mon, 10 Oct 2011 14:24:20 +0400
Message-Id: <1318242268-2234-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

Hi Guys,

I hope we have it all sorted this time. Main differences from
v5:
 * using res_counters for tcp_memory_allocated
 * tried to get maximum consistency with the rest of memcg files
   Now files appear even in root memcg, but we can't set any limits
   on it. (comes more or less for free with re-use of the files)
 * softlimit and failcnt are not shown, but I intend to introduce them
   in a followup series (failcnt is easy, but softlimit may need some more
   network-side work, at least testing)

I will be happy to address any comments you may have.

Glauber Costa (8):
  Basic kernel memory functionality for the Memory Controller
  socket: initial cgroup code.
  foundations of per-cgroup memory pressure controlling.
  per-cgroup tcp buffers control
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Disable task moving when using kernel memory accounting

 Documentation/cgroups/memory.txt |   38 ++++-
 crypto/af_alg.c                  |    8 +-
 include/linux/memcontrol.h       |   49 +++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  130 +++++++++++++-
 include/net/tcp.h                |   30 +++-
 include/net/udp.h                |    4 +-
 include/trace/events/sock.h      |   10 +-
 init/Kconfig                     |   14 ++
 mm/memcontrol.c                  |  375 ++++++++++++++++++++++++++++++++++++--
 net/core/sock.c                  |  104 ++++++++---
 net/decnet/af_decnet.c           |   22 ++-
 net/ipv4/proc.c                  |    7 +-
 net/ipv4/sysctl_net_ipv4.c       |   71 +++++++-
 net/ipv4/tcp.c                   |   60 ++++---
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   23 ++-
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv4/udp.c                   |   21 ++-
 net/ipv6/tcp_ipv6.c              |   20 ++-
 net/ipv6/udp.c                   |    4 +-
 net/sctp/socket.c                |   37 +++-
 23 files changed, 912 insertions(+), 132 deletions(-)

-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
