Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9356B020B
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:00 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/10] Swap-over-NFS without deadlocking v1
Date: Fri,  9 Sep 2011 12:00:44 +0100
Message-Id: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

This patch series is based on top of "Swap-over-NBD without deadlocking
v6" as it depends on the same reservation of PF_MEMALLOC reserves
logic.

When a user or administrator requires swap for their application,
they create a swap partition and file, format it with mkswap and
activate it with swapon. In diskless systems this is not an option
so if swap if required then swapping over the network is considered.
The two likely scenarios are when blade servers are used as part of
a cluster where the form factor or maintenance costs do not allow
the use of disks and thin clients.

The Linux Terminal Server Project recommends the use of the Network
Block Device (NBD) for swap but this is not always an option.  There is
no guarantee that the network attached storage (NAS) device is running
Linux or supports NBD. However, it is likely that it supports NFS so
there are users that want support for swapping over NFS despite any
performance concern. Some distributions currently carry patches that
support swapping over NFS but it would be preferable to support it
in the mainline kernel.

Patch 1 avoids a stream-specific deadlock that potentially affects TCP.

Patch 2 is a small modification to SELinux to avoid using PFMEMALLOC
	reserves.

Patch 3 adds four address_space_operations to allow a filesystem
	to optionally control a swapfile. The news handlers are
	expected to map requests to the swapspace operations to
	the underlying file mapping.

Patch 4 notes that patch 3 is bolting
	filesystem-specific-swapfile-support onto the side and that
	the default handlers have different information to what
	is available to the filesystem. This patch refactors the
	code so that there are generic handlers for each of the new
	address_space operations.

Patch 5 adds some helpers for filesystems to handle swap cache pages.

Patch 6 updates NFS to use the helpers from patch 5 where necessary.

Patch 7 avoids setting PF_private on PG_swapcache pages within NFS.

Patch 8 implements the new swapfile-related address_space operations
	for NFS.

Patch 9 prevents page allocator recursions in NFS by using GFP_NOIO
	where appropriate.

Patch 10 fixes a NULL pointer dereference that occurs when using
	swap-over-NFS.

 Documentation/filesystems/Locking |   23 +++++
 Documentation/filesystems/vfs.txt |   21 +++++
 fs/nfs/Kconfig                    |    8 ++
 fs/nfs/file.c                     |   26 +++++-
 fs/nfs/inode.c                    |    6 ++
 fs/nfs/internal.h                 |    7 +-
 fs/nfs/pagelist.c                 |    8 +-
 fs/nfs/read.c                     |    6 +-
 fs/nfs/write.c                    |  163 +++++++++++++++++++++++++--------
 include/linux/fs.h                |   10 ++
 include/linux/mm.h                |   25 +++++
 include/linux/nfs_fs.h            |    2 +
 include/linux/pagemap.h           |    5 +
 include/linux/sunrpc/xprt.h       |    3 +
 include/linux/swap.h              |    7 ++
 include/net/sock.h                |    7 +-
 mm/page_io.c                      |  181 ++++++++++++++++++++++++++++++++-----
 mm/swap_state.c                   |    2 +-
 mm/swapfile.c                     |  138 ++++++++++------------------
 net/caif/caif_socket.c            |    2 +-
 net/core/sock.c                   |    2 +-
 net/ipv4/tcp_input.c              |   12 ++--
 net/sctp/ulpevent.c               |    2 +-
 net/sunrpc/Kconfig                |    5 +
 net/sunrpc/clnt.c                 |    2 +
 net/sunrpc/sched.c                |    7 +-
 net/sunrpc/xprtsock.c             |   57 ++++++++++++
 security/selinux/avc.c            |    2 +-
 28 files changed, 561 insertions(+), 178 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
