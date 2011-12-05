Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 540BA6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 16:36:28 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v8 0/9] per-cgroup tcp memory pressure controls
Date: Mon,  5 Dec 2011 19:34:54 -0200
Message-Id: <1323120903-2831-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz

Hi,

This is my new attempt to fix all the concerns that were raised during
the last iteration.

I should highlight:
1) proc information is kept intact. (although I kept the wrapper functions)
   it will be submitted as a follow up patch so it can get the attention it
   deserves
2) sockets now hold a reference to memcg. sockets can be alive even after the
   task is gone, so we don't bother with between cgroups movements.
   To be able to release resources more easily in this cenario, the parent
   pointer in struct cg_proto was replaced by a memcg object. We then iterate
   through its pointer (which is cleaner anyway)

The rest should be mostly the same except for small fixes and style changes.

Glauber Costa (9):
  Basic kernel memory functionality for the Memory Controller
  foundations of per-cgroup memory pressure controlling.
  socket: initial cgroup code.
  tcp memory pressure controls
  per-netns ipv4 sysctl_tcp_mem
  tcp buffer limitation: per-cgroup limit
  Display current tcp memory allocation in kmem cgroup
  Display current tcp failcnt in kmem cgroup
  Display maximum tcp memory allocation in kmem cgroup

 Documentation/cgroups/memory.txt |   46 ++++++-
 include/linux/memcontrol.h       |   23 ++++
 include/net/netns/ipv4.h         |    1 +
 include/net/sock.h               |  239 +++++++++++++++++++++++++++++++++-
 include/net/tcp.h                |    4 +-
 include/net/tcp_memcontrol.h     |   19 +++
 init/Kconfig                     |   11 ++
 mm/memcontrol.c                  |  189 +++++++++++++++++++++++++-
 net/core/sock.c                  |  118 ++++++++++++-----
 net/ipv4/Makefile                |    1 +
 net/ipv4/af_inet.c               |    2 +
 net/ipv4/proc.c                  |    6 +-
 net/ipv4/sysctl_net_ipv4.c       |   65 ++++++++-
 net/ipv4/tcp.c                   |   11 +--
 net/ipv4/tcp_input.c             |   12 +-
 net/ipv4/tcp_ipv4.c              |   14 ++-
 net/ipv4/tcp_memcontrol.c        |  272 ++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c            |    2 +-
 net/ipv4/tcp_timer.c             |    2 +-
 net/ipv6/af_inet6.c              |    2 +
 net/ipv6/tcp_ipv6.c              |    8 +-
 21 files changed, 968 insertions(+), 79 deletions(-)
 create mode 100644 include/net/tcp_memcontrol.h
 create mode 100644 net/ipv4/tcp_memcontrol.c

-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
