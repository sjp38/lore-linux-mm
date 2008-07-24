Message-Id: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:00:42 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/30] Swap over NFS -v18
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Latest version of the swap over nfs work.

Patches are against: v2.6.26-rc8-mm1

I still need to write some more comments in the reservation code.

Pekka, it uses ksize(), please have a look.

This version also deals with network namespaces.
Two things where I could do with some suggestsion:

  - currently the sysctl code uses current->nrproxy.net_ns to obtain
    the current network namespace

  - the ipv6 route cache code has some initialization order issues

Thanks,

Peter - who hopes we can someday merge this - Zijlstra

--
 Documentation/filesystems/Locking |   22 +
 Documentation/filesystems/vfs.txt |   18 +
 Documentation/network-swap.txt    |  270 +++++++++++++++++
 drivers/net/bnx2.c                |    8
 drivers/net/e1000/e1000_main.c    |    8
 drivers/net/e1000e/netdev.c       |    7
 drivers/net/igb/igb_main.c        |    8
 drivers/net/ixgbe/ixgbe_main.c    |   10
 drivers/net/sky2.c                |   16 -
 fs/Kconfig                        |   17 +
 fs/nfs/file.c                     |   24 +
 fs/nfs/inode.c                    |    6
 fs/nfs/internal.h                 |    7
 fs/nfs/pagelist.c                 |    8
 fs/nfs/read.c                     |   21 -
 fs/nfs/write.c                    |  175 +++++++----
 include/linux/buffer_head.h       |    2
 include/linux/fs.h                |    9
 include/linux/gfp.h               |    3
 include/linux/mm.h                |   25 +
 include/linux/mm_types.h          |    2
 include/linux/mmzone.h            |    6
 include/linux/nfs_fs.h            |    2
 include/linux/pagemap.h           |    5
 include/linux/reserve.h           |  146 +++++++++
 include/linux/sched.h             |    7
 include/linux/skbuff.h            |   46 ++
 include/linux/slab.h              |   24 -
 include/linux/slub_def.h          |    8
 include/linux/sunrpc/xprt.h       |    5
 include/linux/swap.h              |    4
 include/net/inet_frag.h           |    7
 include/net/netns/ipv6.h          |    4
 include/net/sock.h                |   63 +++-
 include/net/tcp.h                 |    2
 kernel/softirq.c                  |    3
 mm/Makefile                       |    2
 mm/internal.h                     |   10
 mm/page_alloc.c                   |  207 +++++++++----
 mm/page_io.c                      |   52 +++
 mm/reserve.c                      |  594 ++++++++++++++++++++++++++++++++++++++
 mm/slab.c                         |  135 ++++++++
 mm/slub.c                         |  159 ++++++++--
 mm/swap_state.c                   |    4
 mm/swapfile.c                     |   51 +++
 mm/vmstat.c                       |    6
 net/Kconfig                       |    3
 net/core/dev.c                    |   59 +++
 net/core/filter.c                 |    3
 net/core/skbuff.c                 |  147 +++++++--
 net/core/sock.c                   |  129 ++++++++
 net/ipv4/inet_fragment.c          |    3
 net/ipv4/ip_fragment.c            |   89 +++++
 net/ipv4/route.c                  |   72 ++++
 net/ipv4/tcp.c                    |    5
 net/ipv4/tcp_input.c              |   12
 net/ipv4/tcp_output.c             |   12
 net/ipv4/tcp_timer.c              |    2
 net/ipv6/af_inet6.c               |   20 +
 net/ipv6/reassembly.c             |   88 +++++
 net/ipv6/route.c                  |   66 ++++
 net/ipv6/tcp_ipv6.c               |   17 -
 net/netfilter/core.c              |    3
 net/sctp/ulpevent.c               |    2
 net/sunrpc/sched.c                |    9
 net/sunrpc/xprtsock.c             |   73 ++++
 security/selinux/avc.c            |    2
 67 files changed, 2720 insertions(+), 314 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
