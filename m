Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f45.google.com (mail-lf0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 56F2482F64
	for <linux-mm@kvack.org>; Sat,  7 Nov 2015 15:07:26 -0500 (EST)
Received: by lfgh9 with SMTP id h9so84585450lfg.1
        for <linux-mm@kvack.org>; Sat, 07 Nov 2015 12:07:25 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a195si4498044lfe.143.2015.11.07.12.07.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Nov 2015 12:07:24 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 0/5] memcg/kmem: switch to white list policy
Date: Sat, 7 Nov 2015 23:07:04 +0300
Message-ID: <cover.1446924358.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

Currently, all kmem allocations (namely every kmem_cache_alloc, kmalloc,
alloc_kmem_pages call) are accounted to memory cgroup automatically.
Callers have to explicitly opt out if they don't want/need accounting
for some reason. Such a design decision leads to several problems:

 - kmalloc users are highly sensitive to failures, many of them
   implicitly rely on the fact that kmalloc never fails, while memcg
   makes failures quite plausible.

 - A lot of objects are shared among different containers by design.
   Accounting such objects to one of containers is just unfair.
   Moreover, it might lead to pinning a dead memcg along with its kmem
   caches, which aren't tiny, which might result in noticeable increase
   in memory consumption for no apparent reason in the long run.

 - There are tons of short-lived objects. Accounting them to memcg will
   only result in slight noise and won't change the overall picture, but
   we still have to pay accounting overhead.

For more info, see

 - https://lkml.org/lkml/2015/11/5/365
 - https://lkml.org/lkml/2015/11/6/122

Therefore this patch switches to the white list policy. Now kmalloc
users have to explicitly opt in by passing __GFP_ACCOUNT flag.

Currently, the list of accounted objects is quite limited and only
includes those allocations that (1) are known to be easily triggered
from userspace and (2) can fail gracefully (for the full list see patch
no. 5) and it still misses many object types. However, accounting only
those objects should be a satisfactory approximation of the behavior we
used to have for most sane workloads.

Thanks,

Vladimir Davydov (5):
  Revert "kernfs: do not account ino_ida allocations to memcg"
  Revert "gfp: add __GFP_NOACCOUNT"
  memcg: only account kmem allocations marked as __GFP_ACCOUNT
  vmalloc: allow to account vmalloc to memcg
  Account certain kmem allocations to memcg

 arch/powerpc/platforms/cell/spufs/inode.c     |  2 +-
 drivers/staging/lustre/lustre/llite/super25.c |  3 ++-
 fs/9p/vfs_inode.c                             |  2 +-
 fs/adfs/super.c                               |  2 +-
 fs/affs/super.c                               |  2 +-
 fs/afs/super.c                                |  2 +-
 fs/befs/linuxvfs.c                            |  2 +-
 fs/bfs/inode.c                                |  2 +-
 fs/block_dev.c                                |  3 ++-
 fs/btrfs/inode.c                              |  2 +-
 fs/ceph/inode.c                               |  2 +-
 fs/cifs/cifsfs.c                              |  2 +-
 fs/coda/inode.c                               |  2 +-
 fs/dcache.c                                   |  5 +++--
 fs/ecryptfs/super.c                           |  3 ++-
 fs/efs/super.c                                |  2 +-
 fs/exec.c                                     |  5 +++--
 fs/exofs/super.c                              |  2 +-
 fs/ext2/super.c                               |  2 +-
 fs/ext4/super.c                               |  2 +-
 fs/f2fs/super.c                               |  2 +-
 fs/fat/inode.c                                |  2 +-
 fs/file.c                                     |  9 +++++----
 fs/fs_struct.c                                |  2 +-
 fs/fuse/inode.c                               |  4 ++--
 fs/gfs2/super.c                               |  2 +-
 fs/hfs/super.c                                |  2 +-
 fs/hfsplus/super.c                            |  2 +-
 fs/hostfs/hostfs_kern.c                       |  2 +-
 fs/hpfs/super.c                               |  2 +-
 fs/hugetlbfs/inode.c                          |  2 +-
 fs/inode.c                                    |  2 +-
 fs/isofs/inode.c                              |  2 +-
 fs/jffs2/super.c                              |  2 +-
 fs/jfs/super.c                                |  3 ++-
 fs/kernfs/dir.c                               |  9 +--------
 fs/logfs/inode.c                              |  2 +-
 fs/minix/inode.c                              |  2 +-
 fs/ncpfs/inode.c                              |  3 ++-
 fs/nfs/inode.c                                |  2 +-
 fs/nilfs2/super.c                             |  2 +-
 fs/ntfs/inode.c                               |  2 +-
 fs/ocfs2/dlmfs/dlmfs.c                        |  2 +-
 fs/ocfs2/super.c                              |  2 +-
 fs/openpromfs/inode.c                         |  2 +-
 fs/proc/inode.c                               |  3 ++-
 fs/qnx4/inode.c                               |  2 +-
 fs/qnx6/inode.c                               |  2 +-
 fs/reiserfs/super.c                           |  2 +-
 fs/romfs/super.c                              |  2 +-
 fs/squashfs/super.c                           |  2 +-
 fs/sysv/inode.c                               |  2 +-
 fs/ubifs/super.c                              |  2 +-
 fs/udf/super.c                                |  2 +-
 fs/ufs/super.c                                |  2 +-
 fs/xfs/kmem.h                                 |  7 ++++++-
 fs/xfs/xfs_icache.c                           |  2 +-
 include/linux/gfp.h                           |  6 ++++--
 include/linux/memcontrol.h                    |  2 +-
 include/linux/thread_info.h                   |  5 +++--
 ipc/mqueue.c                                  |  2 +-
 kernel/cred.c                                 |  4 ++--
 kernel/delayacct.c                            |  2 +-
 kernel/fork.c                                 | 11 ++++++-----
 kernel/pid.c                                  |  2 +-
 mm/kmemleak.c                                 |  3 +--
 mm/mmap.c                                     | 10 +++++-----
 mm/nommu.c                                    |  8 ++++----
 mm/page_alloc.c                               |  3 ++-
 mm/rmap.c                                     |  4 ++--
 mm/shmem.c                                    |  2 +-
 mm/vmalloc.c                                  |  6 +++---
 net/socket.c                                  |  4 ++--
 net/sunrpc/rpc_pipe.c                         |  2 +-
 74 files changed, 117 insertions(+), 106 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
