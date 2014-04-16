Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 27FF76B0031
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:17:48 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so8212982eek.7
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:17:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si28158190eea.89.2014.04.15.21.17.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:17:46 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:35 +1000
Subject: [PATCH/RFC 00/19] Support loop-back NFS mounts
Message-ID: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Ming Lei <ming.lei@canonical.com>, netdev@vger.kernel.org

Loop-back NFS mounts are when the NFS client and server run on the
same host.

The use-case for this is a high availability cluster with shared
storage.  The shared filesystem is mounted on any one machine and
NFS-mounted on the others.
If the nfs server fails, some other node will take over that service,
and then it will have a loop-back NFS mount which needs to keep
working.

This patch set addresses the "keep working" bit and specifically
addresses deadlocks and livelocks.
Allowing the fail-over itself to be deadlock free is a separate
challenge for another day.

The short description of how this works is:

deadlocks:
  - Elevate PF_FSTRANS to apply globally instead of just in NFS and XFS.
    PF_FSTRANS disables __GFP_NS in the same way that PF_MEMALLOC_NOIO
    disables __GFP_IO.
  - Set PF_FSTRANS in nfsd when handling requests related to
    memory reclaim, or requests which could block requests related
    to memory reclaim.
  - Use lockdep to find all consequent deadlocks from some other
    thread allocating memory while holding a lock that nfsd might
    want.
  - Fix those other deadlocks by setting PF_FSTRANS or using GFP_NOFS
    as appropriate.

livelocks:
  - identify throttling during reclaim and bypass it when
    PF_LESS_THROTTLE is set
  - only set PF_LESS_THROTTLE for nfsd when handling write requests
    from the local host.

The last 12 patches address various deadlocks due to locking chains.
11 were found by lockdep, 2 by testing.  There is a reasonable chance
that there are more, I just need to exercise more code while
testing....

There is one issue that lockdep reports which I haven't fixed (I've
just hacked the code out for my testing).  That issue relates to
freeze_super().
I may not be interpreting the lockdep reports perfectly, but I think
they are basically saying that if I were to freeze a filesystem that
was exported to the local host, then we could end up deadlocking.
This is to be expected.  The NFS filesystem would need to be frozen
first.  I don't know how to tell lockdep that I know that is a problem
and I don't want to be warned about it.  Suggestions welcome.
Until this is addressed I cannot really ask others to test the code
with lockdep enabled.

There are more subsidiary places that I needed to add PF_FSTRANS than
I would have liked.  The thought keeps crossing my mind that maybe we
can get rid of __GFP_FS and require that memory reclaim never ever
block on a filesystem.  Then most of these patches go away.

Now that writeback doesn't happen from reclaim (but from kswapd) much
of the calls from reclaim to FS are gone.
The ->releasepage call is the only one that I *know* causes me
problems so I'd like to just say that that must never block.  I don't
really understand the consequences of that though.
There are a couple of other places where __GFP_FS is used and I'd need
to carefully analyze those.  But if someone just said "no, that is
impossible", I could be happy and stick with the current approach....

I've cc:ed Peter Zijlstra and Ingo Molnar only on the lockdep-related
patches, Ming Lei only on the PF_MEMALLOC_NOIO related patches,
and net-dev only on the network-related patches.
There are probably other people I should CC.  Apologies if I missed you.
I'll ensure better coverage if the nfs/mm/xfs people are reasonably happy.

Comments, criticisms, etc most welcome.

Thanks,
NeilBrown


---

NeilBrown (19):
      Promote current_{set,restore}_flags_nested from xfs to global.
      lockdep: lockdep_set_current_reclaim_state should save old value
      lockdep: improve scenario messages for RECLAIM_FS errors.
      Make effect of PF_FSTRANS to disable __GFP_FS universal.
      SUNRPC: track whether a request is coming from a loop-back interface.
      nfsd: set PF_FSTRANS for nfsd threads.
      nfsd and VM: use PF_LESS_THROTTLE to avoid throttle in shrink_inactive_list.
      Set PF_FSTRANS while write_cache_pages calls ->writepage
      XFS: ensure xfs_file_*_read cannot deadlock in memory allocation.
      NET: set PF_FSTRANS while holding sk_lock
      FS: set PF_FSTRANS while holding mmap_sem in exec.c
      NET: set PF_FSTRANS while holding rtnl_lock
      MM: set PF_FSTRANS while allocating per-cpu memory to avoid deadlock.
      driver core: set PF_FSTRANS while holding gdp_mutex
      nfsd: set PF_FSTRANS when client_mutex is held.
      VFS: use GFP_NOFS rather than GFP_KERNEL in __d_alloc.
      VFS: set PF_FSTRANS while namespace_sem is held.
      nfsd: set PF_FSTRANS during nfsd4_do_callback_rpc.
      XFS: set PF_FSTRANS while ilock is held in xfs_free_eofblocks


 drivers/base/core.c             |    3 ++
 drivers/base/power/runtime.c    |    6 ++---
 drivers/block/nbd.c             |    6 ++---
 drivers/md/dm-bufio.c           |    6 ++---
 drivers/md/dm-ioctl.c           |    6 ++---
 drivers/mtd/nand/nandsim.c      |   28 ++++++---------------
 drivers/scsi/iscsi_tcp.c        |    6 ++---
 drivers/usb/core/hub.c          |    6 ++---
 fs/dcache.c                     |    4 ++-
 fs/exec.c                       |    6 +++++
 fs/fs-writeback.c               |    5 ++--
 fs/namespace.c                  |    4 +++
 fs/nfs/file.c                   |    3 +-
 fs/nfsd/nfs4callback.c          |    5 ++++
 fs/nfsd/nfs4state.c             |    3 ++
 fs/nfsd/nfssvc.c                |   24 ++++++++++++++----
 fs/nfsd/vfs.c                   |    6 +++++
 fs/xfs/kmem.h                   |    2 --
 fs/xfs/xfs_aops.c               |    7 -----
 fs/xfs/xfs_bmap_util.c          |    4 +++
 fs/xfs/xfs_file.c               |   12 +++++++++
 fs/xfs/xfs_linux.h              |    7 -----
 include/linux/lockdep.h         |    8 +++---
 include/linux/sched.h           |   32 +++++++++---------------
 include/linux/sunrpc/svc.h      |    2 ++
 include/linux/sunrpc/svc_xprt.h |    1 +
 include/net/sock.h              |    1 +
 kernel/locking/lockdep.c        |   51 ++++++++++++++++++++++++++++-----------
 kernel/softirq.c                |    6 ++---
 mm/migrate.c                    |    9 +++----
 mm/page-writeback.c             |    3 ++
 mm/page_alloc.c                 |   18 ++++++++------
 mm/percpu.c                     |    4 +++
 mm/slab.c                       |    2 ++
 mm/slob.c                       |    2 ++
 mm/slub.c                       |    1 +
 mm/vmscan.c                     |   31 +++++++++++++++---------
 net/core/dev.c                  |    6 ++---
 net/core/rtnetlink.c            |    9 ++++++-
 net/core/sock.c                 |    8 ++++--
 net/sunrpc/sched.c              |    5 ++--
 net/sunrpc/svc.c                |    6 +++++
 net/sunrpc/svcsock.c            |   10 ++++++++
 net/sunrpc/xprtrdma/transport.c |    5 ++--
 net/sunrpc/xprtsock.c           |   17 ++++++++-----
 45 files changed, 247 insertions(+), 149 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
