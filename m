Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id AA1616B029D
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:06:09 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id i77so3933263ybg.21
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:06:09 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v73si1454555ywa.108.2017.12.15.14.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:06:08 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 00/78] XArray v5
Date: Fri, 15 Dec 2017 14:03:32 -0800
Message-Id: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Again, this patch set does not apply to any particular tree
because it depends on things which are purely noise, and I'm trying
to keep the patch count down [1].  If you want it in a git tree, try
http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2017-12-11
(note change of date from last posting)

I've been getting progressively fewer bug reports from 0day.  I might
almost consider booting this on one of my test machines soon.  The only
bug report I don't believe I've addressed yet is a compile failure
on ia64.  I've resurrected my old McKinley and I'm building gcc 6.4 on
it to see if I can reproduce it (Debian only has 4.8 for ia64).

I'd really like an ACK from Darrick on patch 1 (and then I'll stop
posting it).  I'd like ACKs from the other maintainers whose radix
trees I'm converting:

  mm-cgroup-writeback
  vmalloc
  brd
  xfs (again, Dave's feedback has been invaluable)
  xhci-mem 
  raid5-cache
  irqdomain
  fscache

I don't imagine anybody has the stomach to review the entire pagecache
conversion, but you don't have to do all 44 patches at once.  Please don't
make me beg for reviewers in Park City.

[1] 78 patches.  Haha.  I can squash a bunch of them together for
posting in future if you like, but the diffstat is still intense:
162 files changed, 6305 insertions(+), 4595 deletions(-).

In case the +/- worries you, each user of the xarray has, so far, lost
lines of code, and deleting the radix tree code once all the users are
converted will net us back 2270 lines.  And there's way more documentation
of the XArray than there was of the radix tree.

Bug fixes:
 - Fixed bisectability bug (thanks, 0day!)
 - Fixed builds with !CONFIG_RADIX_TREE_MULTIORDER
 - Fixed shmem_add_to_page_cache() and add_to_swap_cache().  Just a typo.
 - Changed xa_ functions which return an error to use xa_err instead of ERR_PTR.
 - Fixed a bug which could cause xas_for_each_tag() to terminate early.
 - Removed spurious VM_BUG_ON_PAGE in page_cache_delete_batch
 - Clear tags before erasing an entry

Cleanup:
 - Renamed node->root to ->array.
 - Renamed node->exceptional to ->nr_values.
 - Improved debug output.
 - Removed xa_lock_held.  The few users opencode lockdep_is_held().
 - Made xas_error use unlikely().  Errors are always unlikely.
 - Changed xas errors to be the same as xa errors.
 - Changed xa_set_tag(), xa_clear_tag(), __xa_set_tag() and __xa_get_tag() to
   return void.  The functionality is not being used.
 - Rewrote xa_to_node() to be more efficient.
 - Replaced license text with SPDX tags
 - Pulled some boilerplate out of __xa_erase, xa_store and xa_cmpxchg into
   the new xas_result()
 - Applied several of Randy's suggestions to the documentation.  Also lots
   of tweaking.

New features:
 - Added xa_count()
 - Added xa_store_empty() as a convenience function.
 - Changed xarray to not use irqsafe locks by default.  The IDR continues to
   use irqsafe locks for now.
 - Added __xa_store and __xa_cmpxchg variations so users can do their own
   locking.
 - Exposed & documented the xa_lock member of struct xarray.
 - Converted fscache to XArray
 - Converted irqdomain to XArray
 - Converted raid5-cache to XArray


Matthew Wilcox (78):
  xfs: Rename xa_ elements to ail_
  fscache: Use appropriate radix tree accessors
  xarray: Add the xa_lock to the radix_tree_root
  page cache: Use xa_lock
  xarray: Replace exceptional entries
  xarray: Change definition of sibling entries
  xarray: Add definition of struct xarray
  xarray: Define struct xa_node
  xarray: Add documentation
  xarray: Add xa_load
  xarray: Add xa_get_tag, xa_set_tag and xa_clear_tag
  xarray: Add xa_store
  xarray: Add xa_cmpxchg
  xarray: Add xa_for_each
  xarray: Add xas_for_each_tag
  xarray: Add xa_get_entries, xa_get_tagged and xa_get_maybe_tag
  xarray: Add xa_destroy
  xarray: Add xas_next and xas_prev
  xarray: Add xas_create_range
  xarray: Add MAINTAINERS entry
  xarray: Add ability to store errno values
  idr: Convert to XArray
  ida: Convert to XArray
  page cache: Convert hole search to XArray
  page cache: Add page_cache_range_empty function
  page cache: Add and replace pages using the XArray
  page cache: Convert page deletion to XArray
  page cache: Convert page cache lookups to XArray
  page cache: Convert delete_batch to XArray
  page cache: Remove stray radix comment
  mm: Convert page-writeback to XArray
  mm: Convert workingset to XArray
  mm: Convert truncate to XArray
  mm: Convert add_to_swap_cache to XArray
  mm: Convert delete_from_swap_cache to XArray
  mm: Convert __do_page_cache_readahead to XArray
  mm: Convert page migration to XArray
  mm: Convert huge_memory to XArray
  mm: Convert collapse_shmem to XArray
  mm: Convert khugepaged_scan_shmem to XArray
  pagevec: Use xa_tag_t
  shmem: Convert replace to XArray
  shmem: Convert shmem_confirm_swap to XArray
  shmem: Convert find_swap_entry to XArray
  shmem: Convert shmem_tag_pins to XArray
  shmem: Convert shmem_wait_for_pins to XArray
  shmem: Convert shmem_add_to_page_cache to XArray
  shmem: Convert shmem_alloc_hugepage to XArray
  shmem: Convert shmem_free_swap to XArray
  shmem: Convert shmem_partial_swap_usage to XArray
  shmem: Comment fixups
  btrfs: Convert page cache to XArray
  fs: Convert buffer to XArray
  fs: Convert writeback to XArray
  nilfs2: Convert to XArray
  f2fs: Convert to XArray
  lustre: Convert to XArray
  dax: Convert dax_unlock_mapping_entry to XArray
  dax: Convert lock_slot to XArray
  dax: More XArray conversion
  dax: Convert __dax_invalidate_mapping_entry to XArray
  dax: Convert dax_writeback_one to XArray
  dax: Convert dax_insert_pfn_mkwrite to XArray
  dax: Convert dax_insert_mapping_entry to XArray
  dax: Convert grab_mapping_entry to XArray
  dax: Fix sparse warning
  page cache: Finish XArray conversion
  mm: Convert cgroup writeback to XArray
  vmalloc: Convert to XArray
  brd: Convert to XArray
  xfs: Convert m_perag_tree to XArray
  xfs: Convert pag_ici_root to XArray
  xfs: Convert xfs dquot to XArray
  xfs: Convert mru cache to XArray
  usb: Convert xhci-mem to XArray
  md: Convert raid5-cache to XArray
  irqdomain: Convert to XArray
  fscache: Convert to XArray

 Documentation/cgroup-v1/memory.txt              |    2 +-
 Documentation/core-api/index.rst                |    1 +
 Documentation/core-api/xarray.rst               |  347 +++++
 Documentation/vm/page_migration                 |   14 +-
 MAINTAINERS                                     |   12 +
 arch/arm/include/asm/cacheflush.h               |    6 +-
 arch/nios2/include/asm/cacheflush.h             |    6 +-
 arch/parisc/include/asm/cacheflush.h            |    6 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h    |    4 +-
 arch/powerpc/include/asm/nohash/64/pgtable.h    |    4 +-
 drivers/block/brd.c                             |   93 +-
 drivers/gpu/drm/i915/i915_gem.c                 |   17 +-
 drivers/md/raid5-cache.c                        |  119 +-
 drivers/staging/lustre/lustre/llite/glimpse.c   |   12 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   16 +-
 drivers/usb/host/xhci-mem.c                     |   68 +-
 drivers/usb/host/xhci.h                         |    6 +-
 fs/afs/write.c                                  |    9 +-
 fs/btrfs/btrfs_inode.h                          |    7 +-
 fs/btrfs/compression.c                          |    6 +-
 fs/btrfs/extent_io.c                            |   24 +-
 fs/btrfs/inode.c                                |   70 -
 fs/buffer.c                                     |   25 +-
 fs/cifs/file.c                                  |    9 +-
 fs/dax.c                                        |  384 +++---
 fs/ext4/inode.c                                 |    2 +-
 fs/f2fs/data.c                                  |    9 +-
 fs/f2fs/dir.c                                   |    5 +-
 fs/f2fs/gc.c                                    |    2 +-
 fs/f2fs/inline.c                                |    6 +-
 fs/f2fs/node.c                                  |   10 +-
 fs/fs-writeback.c                               |   37 +-
 fs/fscache/cookie.c                             |    6 +-
 fs/fscache/internal.h                           |    2 +-
 fs/fscache/object.c                             |    2 +-
 fs/fscache/page.c                               |  152 +--
 fs/fscache/stats.c                              |    6 +-
 fs/gfs2/aops.c                                  |    2 +-
 fs/inode.c                                      |   11 +-
 fs/nfs/blocklayout/blocklayout.c                |    2 +-
 fs/nilfs2/btnode.c                              |   41 +-
 fs/nilfs2/page.c                                |   78 +-
 fs/proc/task_mmu.c                              |    2 +-
 fs/xfs/libxfs/xfs_sb.c                          |   11 +-
 fs/xfs/libxfs/xfs_sb.h                          |    2 +-
 fs/xfs/xfs_buf_item.c                           |   10 +-
 fs/xfs/xfs_dquot.c                              |   42 +-
 fs/xfs/xfs_dquot_item.c                         |   11 +-
 fs/xfs/xfs_icache.c                             |  146 +-
 fs/xfs/xfs_icache.h                             |   10 +-
 fs/xfs/xfs_inode.c                              |   24 +-
 fs/xfs/xfs_inode_item.c                         |   22 +-
 fs/xfs/xfs_log.c                                |    6 +-
 fs/xfs/xfs_log_recover.c                        |   80 +-
 fs/xfs/xfs_mount.c                              |   22 +-
 fs/xfs/xfs_mount.h                              |    6 +-
 fs/xfs/xfs_mru_cache.c                          |   72 +-
 fs/xfs/xfs_qm.c                                 |   32 +-
 fs/xfs/xfs_qm.h                                 |   18 +-
 fs/xfs/xfs_trans.c                              |   18 +-
 fs/xfs/xfs_trans_ail.c                          |  152 +--
 fs/xfs/xfs_trans_buf.c                          |    4 +-
 fs/xfs/xfs_trans_priv.h                         |   42 +-
 include/linux/backing-dev-defs.h                |    2 +-
 include/linux/backing-dev.h                     |   14 +-
 include/linux/fs.h                              |   68 +-
 include/linux/fscache.h                         |    8 +-
 include/linux/idr.h                             |  166 ++-
 include/linux/irqdomain.h                       |   10 +-
 include/linux/mm.h                              |    2 +-
 include/linux/pagemap.h                         |   16 +-
 include/linux/pagevec.h                         |    8 +-
 include/linux/radix-tree.h                      |   95 +-
 include/linux/swap.h                            |    5 +-
 include/linux/swapops.h                         |   19 +-
 include/linux/xarray.h                          | 1026 ++++++++++++++
 kernel/irq/irqdomain.c                          |   39 +-
 kernel/pid.c                                    |    2 +-
 lib/Makefile                                    |    2 +-
 lib/idr.c                                       |  633 +++++----
 lib/radix-tree.c                                |  451 ++-----
 lib/xarray.c                                    | 1646 +++++++++++++++++++++++
 mm/backing-dev.c                                |   23 +-
 mm/filemap.c                                    |  748 ++++------
 mm/huge_memory.c                                |   23 +-
 mm/khugepaged.c                                 |  182 +--
 mm/madvise.c                                    |    2 +-
 mm/memcontrol.c                                 |    6 +-
 mm/migrate.c                                    |   41 +-
 mm/mincore.c                                    |    2 +-
 mm/page-writeback.c                             |   78 +-
 mm/readahead.c                                  |   10 +-
 mm/rmap.c                                       |    4 +-
 mm/shmem.c                                      |  311 ++---
 mm/swap.c                                       |    6 +-
 mm/swap_state.c                                 |  124 +-
 mm/truncate.c                                   |   45 +-
 mm/vmalloc.c                                    |   39 +-
 mm/vmscan.c                                     |   14 +-
 mm/workingset.c                                 |   87 +-
 tools/include/linux/spinlock.h                  |   10 +-
 tools/testing/radix-tree/.gitignore             |    2 +
 tools/testing/radix-tree/Makefile               |   15 +-
 tools/testing/radix-tree/idr-test.c             |   29 +-
 tools/testing/radix-tree/linux/bug.h            |    1 +
 tools/testing/radix-tree/linux/kconfig.h        |    1 +
 tools/testing/radix-tree/linux/kernel.h         |    4 +
 tools/testing/radix-tree/linux/rcupdate.h       |    2 +
 tools/testing/radix-tree/linux/xarray.h         |    3 +
 tools/testing/radix-tree/multiorder.c           |   83 +-
 tools/testing/radix-tree/regression1.c          |   68 +-
 tools/testing/radix-tree/test.c                 |    8 +-
 tools/testing/radix-tree/xarray-test.c          |  512 +++++++
 113 files changed, 5889 insertions(+), 3178 deletions(-)
 create mode 100644 Documentation/core-api/xarray.rst
 create mode 100644 include/linux/xarray.h
 create mode 100644 lib/xarray.c
 create mode 100644 tools/testing/radix-tree/linux/kconfig.h
 create mode 100644 tools/testing/radix-tree/linux/xarray.h
 create mode 100644 tools/testing/radix-tree/xarray-test.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
