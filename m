Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA816B0003
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 20:57:36 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so97960oiw.13
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 17:57:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17-v6sor4699728oix.191.2018.07.01.17.57.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Jul 2018 17:57:35 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 0/6] mm/fs: gup: don't unmap or drop filesystem buffers
Date: Sun,  1 Jul 2018 17:56:48 -0700
Message-Id: <20180702005654.20369-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

This fixes a few problems that came up when using devices (NICs, GPUs,
for example) that want to have direct access to a chunk of system (CPU)
memory, so that they can DMA to/from that memory. Problems [1] come up
if that memory is backed by persistence storage; for example, an ext4
file system. I've been working on several customer bugs that are hitting
this, and this patchset fixes those bugs.

The bugs happen via:

-- get_user_pages() on some ext4-backed pages
-- device does DMA for a while to/from those pages

    -- Somewhere in here, some of the pages get disconnected from the
       file system, via try_to_unmap() and eventually drop_buffers()

-- device is all done, device driver calls set_page_dirty_locked, then
   put_page()

And then at some point, we see a this BUG():

    kernel BUG at /build/linux-fQ94TU/linux-4.4.0/fs/ext4/inode.c:1899!
    backtrace:
        ext4_writepage
        __writepage
        write_cache_pages
        ext4_writepages
        do_writepages
        __writeback_single_inode
        writeback_sb_inodes
        __writeback_inodes_wb
        wb_writeback
        wb_workfn
        process_one_work
        worker_thread
        kthread
        ret_from_fork

...which is due to the file system asserting that there are still buffer
heads attached:

        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

How to fix this:

If a page is pinned by any of the get_user_page("gup", here) variants, then
there is no need for that page to be on an LRU. So, this patchset removes
such pages from their LRU, thus leaving the page->lru fields *mostly*
available for tracking gup pages. (The lowest bit of page->lru.next is used
as PageTail, and these flags have to be checked when we don't know if it
really is a tail page or not, so avoid that bit.)

After that, the page is reference-counted via page->dma_pinned_count, and
flagged via page->dma_pinned_flags. The PageDmaPinned flag is cleared when
the reference count hits zero, and the reference count is only used when
the flag is set.

All of the above provides a reliable PageDmaPinned flag, which is then used
to decide when to abort or wait for operations such as:

    try_to_unmap()
    page_mkclean()

In order to handle page_mkclean(), new information had to be plumbed down
from the filesystems, so that page_mkclean can decide whether to skip
dma-pinned pages, or to wait for them.

Thanks to Matthew Wilcox for suggesting re-using page->lru fields for a
new refcount and flag, and to Jan Kara for explaining the rest of the
design details (how to deal with page_mkclean() and try_to_unmap(),
especially). Also thanks to Dan Williams for design advice and DAX,
long-term pinning, and page flag thoughts.

References:

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

Changes since v1:

 -- Use page->lru and full reference counting, instead of a single page flag.
 -- Proper handling of page_mkclean().

John Hubbard (6):
  mm: get_user_pages: consolidate error handling
  mm: introduce page->dma_pinned_flags, _count
  mm: introduce zone_gup_lock, for dma-pinned pages
  mm/fs: add a sync_mode param for clear_page_dirty_for_io()
  mm: track gup pages with page->dma_pinned_* fields
  mm: page_mkclean, ttu: handle pinned pages

 drivers/video/fbdev/core/fb_defio.c |  3 +-
 fs/9p/vfs_addr.c                    |  2 +-
 fs/afs/write.c                      |  6 +-
 fs/btrfs/extent_io.c                | 14 ++---
 fs/btrfs/file.c                     |  2 +-
 fs/btrfs/free-space-cache.c         |  2 +-
 fs/btrfs/ioctl.c                    |  2 +-
 fs/ceph/addr.c                      |  4 +-
 fs/cifs/cifssmb.c                   |  3 +-
 fs/cifs/file.c                      |  5 +-
 fs/ext4/inode.c                     |  5 +-
 fs/f2fs/checkpoint.c                |  4 +-
 fs/f2fs/data.c                      |  2 +-
 fs/f2fs/dir.c                       |  2 +-
 fs/f2fs/gc.c                        |  4 +-
 fs/f2fs/inline.c                    |  2 +-
 fs/f2fs/node.c                      | 10 ++--
 fs/f2fs/segment.c                   |  3 +-
 fs/fuse/file.c                      |  2 +-
 fs/gfs2/aops.c                      |  2 +-
 fs/nfs/write.c                      |  2 +-
 fs/nilfs2/page.c                    |  2 +-
 fs/nilfs2/segment.c                 | 10 ++--
 fs/ubifs/file.c                     |  2 +-
 fs/xfs/xfs_aops.c                   |  2 +-
 include/linux/mm.h                  | 22 ++++++-
 include/linux/mm_types.h            | 22 +++++--
 include/linux/mmzone.h              |  7 +++
 include/linux/page-flags.h          | 50 ++++++++++++++++
 include/linux/rmap.h                |  4 +-
 mm/gup.c                            | 93 +++++++++++++++++++++++------
 mm/memcontrol.c                     |  7 +++
 mm/memory-failure.c                 |  3 +-
 mm/migrate.c                        |  2 +-
 mm/page-writeback.c                 | 14 +++--
 mm/page_alloc.c                     |  1 +
 mm/rmap.c                           | 71 ++++++++++++++++++++--
 mm/swap.c                           | 48 +++++++++++++++
 mm/truncate.c                       |  3 +-
 mm/vmscan.c                         |  2 +-
 40 files changed, 361 insertions(+), 85 deletions(-)

-- 
2.18.0
