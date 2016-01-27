Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 14B0A6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:18:01 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id uo6so10941389pac.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:18:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 78si11759567pfr.69.2016.01.27.13.18.00
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 13:18:00 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/5] Fix races & improve the radix tree iterator patterns
Date: Wed, 27 Jan 2016 16:17:47 -0500
Message-Id: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

The first two patches here are bugfixes, and I would like to see them
make their way into stable ASAP since they can lead to data corruption
(very low probabilty).

The last three patches do not qualify as bugfixes.  They simply improve
the standard pattern used to do radix tree iterations by removing the
'goto restart' part.  Partially this is because this is an ugly &
confusing goto, and partially because with multi-order entries in the
tree, it'll be more likely that we'll see an indirect_ptr bit, and
it's more efficient to kep going from the point of the iteration we're
currently in than restart from the beginning each time.

Matthew Wilcox (5):
  radix-tree: Fix race in gang lookup
  hwspinlock: Fix race between radix tree insertion and lookup
  btrfs: Use radix_tree_iter_retry()
  mm: Use radix_tree_iter_retry()
  radix-tree,shmem: Introduce radix_tree_iter_next()

 drivers/hwspinlock/hwspinlock_core.c |  4 +++
 fs/btrfs/tests/btrfs-tests.c         |  3 +-
 include/linux/radix-tree.h           | 31 +++++++++++++++++++++
 lib/radix-tree.c                     | 12 ++++++--
 mm/filemap.c                         | 53 ++++++++++++------------------------
 mm/shmem.c                           | 30 ++++++++++----------
 6 files changed, 78 insertions(+), 55 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
