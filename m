Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 675B9600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:24:09 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 00/31] Swap over NFS -v20
Date: Thu,  1 Oct 2009 19:34:18 +0530
Message-Id: <1254405858-15651-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi,

Here's the latest version of swap over NFS series since -v19 last October by
Peter Zijlstra. Peter does not have time to pursue this further (though he has
not lost interest) and that led me to take over this patchset and try merging
upstream.

The patches are against the current mmotm. It does not support SLQB, yet.
These patches can also be found online here:
	http://www.suse.de/~sjayaraman/patches/swap-over-nfs/

The swap over NFS patches are being shipped with openSUSE 11.1 and SLE 11 (with
CONFIG_NFS_SWAP enabled by default) for several months now. There have been
no bugs reported so far due to these patches and it has been found stable.

Changes since -v19:
 - rebased patches against current -mm
 - adapted changes pertaining to using zone->watermarks array
 - dropped cleanup patches/fixes that have already made to upstream
 - dropped the patch that remove nfs mempools
 - fixed racy nature of sync_page in swap_sync_page (NeilBrown)
 - fixed use of uninitialized variable in cache_grow() (Miklos Szeredi)
 - fixed a bug in bnx2 driver (Jiri Bohac)
 - fixed null-pointer dereferences in swapfile code path when s_bdev is NULL

Thanks,
Suresh Jayaraman

--

Peter Zijlstra (26)
 mm: serialize access to min_free_kbytes
 mm: expose gfp_to_alloc_flags()
 mm: tag reseve pages
 mm: sl[au]b: add knowledge of reserve pages
 mm: kmem_alloc_estimate()
 mm: allow PF_MEMALLOC from softirq context
 mm: emergency pool
 mm: system wide ALLOC_NO_WATERMARK
 mm: __GFP_MEMALLOC
 mm: memory reserve management
 mm: add support for non block device backed swap files
 mm: methods for teaching filesystems about PG_swapcache pages
 net: packet split receive api
 net: sk_allocation() - concentrate socket related allocations
 selinux: tag avc cache alloc as non-critical
 netvm: network reserve infrastructure
 netvm: INET reserves
 netvm: hook skb allocation to reserves
 netvm: filter emergency skbs
 netvm: prevent a stream specific deadlock
 netvm: skb processing
 netfilter: NF_QUEUE vs emergency skbs
 nfs: teach the NFS client how to treat PG_swapcache pages
 nfs: disable data cache revalidation for swapfiles
 nfs: enable swap on NFS
 nfs: fix various memory recursions possible with swap over NFS

Jeff Mahoney (1)
 Fix initialization of ipv4_route_lock

Neil Brown (2)
 swap over network documentation
 Cope with racy nature of sync_page in swap_sync_page

Miklos Szeredi (1)
 Fix use of uninitialized variable in cache_grow()

Suresh Jayaraman (1)
 swapfile: avoid NULL pointer dereference in swapon when s_bdev is NULL


 fs/nfs/file.c                           |   18 
 fs/nfs/pagelist.c                       |    2 
 fs/nfs/write.c                          |   99 ++++
 include/linux/mm_types.h                |    1 
 include/linux/skbuff.h                  |   28 +
 include/linux/slab.h                    |   19 
 include/net/sock.h                      |   55 ++
 mm/page_alloc.c                         |  120 ++++--
 mm/page_io.c                            |    2 
 mm/slab.c                               |   80 +++-
 mm/slob.c                               |   67 +++
 mm/slub.c                               |   89 ++++
 mm/swapfile.c                           |   53 ++
 Documentation/filesystems/Locking	 |   22 +
 Documentation/filesystems/vfs.txt	 |   18 
 Documentation/network-swap.txt		 |  270 +++++++++++++
 drivers/net/bnx2.c               	 |    9 
 drivers/net/e1000e/netdev.c      	 |    7 
 drivers/net/igb/igb_main.c        	 |    9 
 drivers/net/ixgbe/ixgbe_main.c    	 |   14 
 drivers/net/sky2.c                	 |   16 
 fs/nfs/Kconfig                    	 |   10 
 fs/nfs/file.c                     	 |    6 
 fs/nfs/inode.c                    	 |    6 
 fs/nfs/internal.h                  	 |    7 
 fs/nfs/pagelist.c                 	 |    6 
 fs/nfs/read.c                     	 |    6 
 fs/nfs/write.c                    	 |   53 +-
 include/linux/buffer_head.h       	 |    1 
 include/linux/fs.h                	 |    9 
 include/linux/gfp.h               	 |    3 
 include/linux/mm.h                	 |   25 +
 include/linux/mm_types.h          	 |    1 
 include/linux/mmzone.h            	 |    3 
 include/linux/nfs_fs.h            	 |    2 
 include/linux/pagemap.h           	 |    5 
 include/linux/reserve.h           	 |  198 +++++++++
 include/linux/sched.h             	 |    7 
 include/linux/skbuff.h            	 |    3 
 include/linux/slab.h              	 |    4 
 include/linux/slub_def.h          	 |    1 
 include/linux/sunrpc/xprt.h       	 |    5 
 include/linux/swap.h              	 |    4 
 include/net/inet_frag.h           	 |    7 
 include/net/netns/ipv6.h          	 |    4 
 include/net/sock.h                	 |    5 
 kernel/softirq.c                  	 |    3 
 mm/Makefile                       	 |    2 
 mm/internal.h                     	 |   15 
 mm/page_alloc.c                   	 |   16 
 mm/page_io.c                      	 |   51 ++
 mm/reserve.c                      	 |  637 ++++++++++++++++++++++++++++++++
 mm/slab.c                         	 |   61 ++-
 mm/slob.c                         	 |   16 
 mm/slub.c                          	 |   43 +-
 mm/swap_state.c                   	 |    4 
 mm/swapfile.c                     	 |   30 +
 mm/vmstat.c                       	 |    6 
 net/Kconfig                       	 |    3 
 net/core/dev.c                    	 |   57 ++
 net/core/filter.c                 	 |    3 
 net/core/skbuff.c                 	 |  137 +++++-
 net/core/sock.c                   	 |  107 +++++
 net/ipv4/inet_fragment.c          	 |    3 
 net/ipv4/ip_fragment.c            	 |   86 ++++
 net/ipv4/route.c                  	 |   70 +++
 net/ipv4/tcp.c                    	 |    3 
 net/ipv4/tcp_input.c              	 |   12 
 net/ipv4/tcp_output.c             	 |   12 
 net/ipv6/reassembly.c             	 |   85 ++++
 net/ipv6/route.c                  	 |   77 +++
 net/ipv6/tcp_ipv6.c               	 |   15 
 net/netfilter/core.c              	 |    3 
 net/sctp/ulpevent.c               	 |    2 
 net/sunrpc/Kconfig                	 |    5 
 net/sunrpc/sched.c                	 |    9 
 net/sunrpc/xprtsock.c             	 |   68 +++
 security/selinux/avc.c            	 |    2 
 net/core/sock.c                         |   18 
 net/ipv4/route.c                        |    2 

 80 files changed, 2797 insertions(+), 245 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
