Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 862446B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:32 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 00/25] shrinkers rework: per-numa, generic lists, etc
Date: Fri,  7 Jun 2013 00:34:33 +0400
Message-Id: <1370550898-26711-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com

Andrew,

I believe I have addressed most of your comments, while attempting to address
all of them. If there is anything I have missed after this long day, let me
know and I will go over it promptly.

As per your request, the memcg parts are out. Let us first sort out the
infrastructure first, while giving the rest of the memcg crew to review the
other part of the series.

I have also included one of my follow-up-patches-to-be, one that dynamically
allocates memory for the list_lru's instead of statically declaring the array,
since it ended up being such a hot topic during the last submission.

I have also improved the documentation a lot (by my standards =p).

For newcomers, here is the link that detail the work that has been
done so far:

http://www.spinics.net/lists/linux-fsdevel/msg65706.html

Dave Chinner (18):
  dcache: convert dentry_stat.nr_unused to per-cpu counters
  dentry: move to per-sb LRU locks
  dcache: remove dentries from LRU before putting on dispose list
  mm: new shrinker API
  shrinker: convert superblock shrinkers to new API
  list: add a new LRU list type
  inode: convert inode lru list to generic lru list code.
  dcache: convert to use new lru list infrastructure
  list_lru: per-node list infrastructure
  shrinker: add node awareness
  fs: convert inode and dentry shrinking to be node aware
  xfs: convert buftarg LRU to generic code
  xfs: rework buffer dispose list tracking
  xfs: convert dquot cache lru to list_lru
  fs: convert fs shrinkers to new scan/count API
  drivers: convert shrinkers to new count/scan API
  shrinker: convert remaining shrinkers to count/scan API
  shrinker: Kill old ->shrink API.

Glauber Costa (7):
  fs: bump inode and dentry counters to long
  super: fix calculation of shrinkable objects for small numbers
  list_lru: per-node API
  vmscan: per-node deferred work
  i915: bail out earlier when shrinker cannot acquire mutex
  hugepage: convert huge zero page shrinker to new shrinker API
  list_lru: dynamically adjust node arrays

 arch/x86/kvm/mmu.c                        |  24 ++-
 drivers/gpu/drm/i915/i915_dma.c           |   4 +-
 drivers/gpu/drm/i915/i915_gem.c           |  71 +++++---
 drivers/gpu/drm/ttm/ttm_page_alloc.c      |  44 +++--
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c  |  51 ++++--
 drivers/md/bcache/btree.c                 |  43 +++--
 drivers/md/bcache/sysfs.c                 |   2 +-
 drivers/md/dm-bufio.c                     |  61 ++++---
 drivers/staging/android/ashmem.c          |  44 +++--
 drivers/staging/android/lowmemorykiller.c |  40 +++--
 drivers/staging/zcache/zcache-main.c      |  29 +--
 fs/dcache.c                               | 270 +++++++++++++++++-----------
 fs/drop_caches.c                          |   1 +
 fs/ext4/extents_status.c                  |  30 ++--
 fs/gfs2/glock.c                           |  30 ++--
 fs/gfs2/main.c                            |   3 +-
 fs/gfs2/quota.c                           |  16 +-
 fs/gfs2/quota.h                           |   4 +-
 fs/inode.c                                | 193 +++++++++-----------
 fs/internal.h                             |   6 +-
 fs/mbcache.c                              |  49 ++---
 fs/nfs/dir.c                              |  16 +-
 fs/nfs/internal.h                         |   4 +-
 fs/nfs/super.c                            |   3 +-
 fs/nfsd/nfscache.c                        |  31 +++-
 fs/quota/dquot.c                          |  34 ++--
 fs/super.c                                | 106 ++++++-----
 fs/ubifs/shrinker.c                       |  22 ++-
 fs/ubifs/super.c                          |   3 +-
 fs/ubifs/ubifs.h                          |   3 +-
 fs/xfs/xfs_buf.c                          | 253 +++++++++++++-------------
 fs/xfs/xfs_buf.h                          |  17 +-
 fs/xfs/xfs_dquot.c                        |   7 +-
 fs/xfs/xfs_icache.c                       |   4 +-
 fs/xfs/xfs_icache.h                       |   2 +-
 fs/xfs/xfs_qm.c                           | 285 ++++++++++++++++--------------
 fs/xfs/xfs_qm.h                           |   4 +-
 fs/xfs/xfs_super.c                        |  12 +-
 include/linux/dcache.h                    |  14 +-
 include/linux/fs.h                        |  25 ++-
 include/linux/list_lru.h                  | 148 ++++++++++++++++
 include/linux/shrinker.h                  |  54 ++++--
 include/trace/events/vmscan.h             |   4 +-
 include/uapi/linux/fs.h                   |   6 +-
 kernel/sysctl.c                           |   6 +-
 mm/Makefile                               |   2 +-
 mm/huge_memory.c                          |  17 +-
 mm/list_lru.c                             | 186 +++++++++++++++++++
 mm/memory-failure.c                       |   2 +
 mm/vmscan.c                               | 242 ++++++++++++++-----------
 net/sunrpc/auth.c                         |  41 +++--
 51 files changed, 1620 insertions(+), 948 deletions(-)
 create mode 100644 include/linux/list_lru.h
 create mode 100644 mm/list_lru.c

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
