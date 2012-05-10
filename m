Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8D5CA6B00EB
	for <linux-mm@kvack.org>; Thu, 10 May 2012 09:54:29 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/12] Swap-over-NFS without deadlocking V4
Date: Thu, 10 May 2012 14:54:13 +0100
Message-Id: <1336658065-24851-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Mel Gorman <mgorman@suse.de>

Changelog since V3
  o Rebase to 3.4-rc5
  o kmap pages for writing to swap				(akpm)
  o Move forward declaration to reduce chance of duplication	(akpm)

Changelog since V2
  o Nothing significant, just rebases. A radix tree lookup is replaced with
    a linear search would be the biggest rebase artifact

This patch series is based on top of "Swap-over-NBD without deadlocking v9"
as it depends on the same reservation of PF_MEMALLOC reserves logic.

When a user or administrator requires swap for their application, they
create a swap partition and file, format it with mkswap and activate it with
swapon. In diskless systems this is not an option so if swap if required
then swapping over the network is considered.  The two likely scenarios
are when blade servers are used as part of a cluster where the form factor
or maintenance costs do not allow the use of disks and thin clients.

The Linux Terminal Server Project recommends the use of the Network
Block Device (NBD) for swap but this is not always an option.  There is
no guarantee that the network attached storage (NAS) device is running
Linux or supports NBD. However, it is likely that it supports NFS so there
are users that want support for swapping over NFS despite any performance
concern. Some distributions currently carry patches that support swapping
over NFS but it would be preferable to support it in the mainline kernel.

Patch 1 avoids a stream-specific deadlock that potentially affects TCP.

Patch 2 is a small modification to SELinux to avoid using PFMEMALLOC
	reserves.

Patch 3 adds three helpers for filesystems to handle swap cache pages.
	For example, page_file_mapping() returns page->mapping for
	file-backed pages and the address_space of the underlying
	swap file for swap cache pages.

Patch 4 adds two address_space_operations to allow a filesystem
	to pin all metadata relevant to a swapfile in memory. Upon
	successful activation, the swapfile is marked SWP_FILE and
	the address space operation ->direct_IO is used for writing
	and ->readpage for reading in swap pages.

Patch 5 notes that patch 3 is bolting
	filesystem-specific-swapfile-support onto the side and that
	the default handlers have different information to what
	is available to the filesystem. This patch refactors the
	code so that there are generic handlers for each of the new
	address_space operations.

Patch 6 adds an API to allow a vector of kernel addresses to be
	translated to struct pages and pinned for IO.

Patch 7 adds support for using highmem pages for swap by kmapping
	the pages before calling the direct_IO handler.

Patch 8 updates NFS to use the helpers from patch 3 where necessary.

Patch 9 avoids setting PF_private on PG_swapcache pages within NFS.

Patch 10 implements the new swapfile-related address_space operations
	for NFS and teaches the direct IO handler how to manage
	kernel addresses.

Patch 11 prevents page allocator recursions in NFS by using GFP_NOIO
	where appropriate.

Patch 12 fixes a NULL pointer dereference that occurs when using
	swap-over-NFS.

With the patches applied, it is possible to mount a swapfile that is on an
NFS filesystem. Swap performance is not great with a swap stress test taking
roughly twice as long to complete than if the swap device was backed by NBD.

 Documentation/filesystems/Locking |   13 ++++
 Documentation/filesystems/vfs.txt |   12 +++
 fs/nfs/Kconfig                    |    8 ++
 fs/nfs/direct.c                   |   94 ++++++++++++++++--------
 fs/nfs/file.c                     |   28 +++++--
 fs/nfs/inode.c                    |    6 ++
 fs/nfs/internal.h                 |    7 +-
 fs/nfs/pagelist.c                 |    6 +-
 fs/nfs/read.c                     |    6 +-
 fs/nfs/write.c                    |   96 +++++++++++++++---------
 include/linux/blk_types.h         |    2 +
 include/linux/fs.h                |    8 ++
 include/linux/highmem.h           |    7 ++
 include/linux/mm.h                |   29 ++++++++
 include/linux/nfs_fs.h            |    4 +-
 include/linux/pagemap.h           |    5 ++
 include/linux/sunrpc/xprt.h       |    3 +
 include/linux/swap.h              |    8 ++
 include/net/sock.h                |    7 +-
 mm/highmem.c                      |   12 +++
 mm/memory.c                       |   52 +++++++++++++
 mm/page_io.c                      |  145 +++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    2 +-
 mm/swapfile.c                     |  141 ++++++++++++++----------------------
 net/caif/caif_socket.c            |    2 +-
 net/core/sock.c                   |    2 +-
 net/ipv4/tcp_input.c              |   12 +--
 net/sctp/ulpevent.c               |    2 +-
 net/sunrpc/Kconfig                |    5 ++
 net/sunrpc/clnt.c                 |    2 +
 net/sunrpc/sched.c                |    7 +-
 net/sunrpc/xprtsock.c             |   53 ++++++++++++++
 security/selinux/avc.c            |    2 +-
 33 files changed, 601 insertions(+), 187 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
