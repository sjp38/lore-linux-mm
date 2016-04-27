Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 213986B0253
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 03:47:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so67139017pfy.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 00:47:15 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 12si2815254pfl.3.2016.04.27.00.47.12
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 00:47:13 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 00/13] Support non-lru page migration
Date: Wed, 27 Apr 2016 16:48:13 +0900
Message-Id: <1461743305-19970-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

Recently, I got many reports about perfermance degradation in embedded
system(Android mobile phone, webOS TV and so on) and easy fork fail.

The problem was fragmentation caused by zram and GPU driver mainly.
With memory pressure, their pages were spread out all of pageblock and
it cannot be migrated with current compaction algorithm which supports
only LRU pages. In the end, compaction cannot work well so reclaimer
shrinks all of working set pages. It made system very slow and even to
fail to fork easily which requires order-[2 or 3] allocations.

Other pain point is that they cannot use CMA memory space so when OOM
kill happens, I can see many free pages in CMA area, which is not
memory efficient. In our product which has big CMA memory, it reclaims
zones too exccessively to allocate GPU and zram page although there are
lots of free space in CMA so system becomes very slow easily.

To solve these problem, this patch tries to add facility to migrate
non-lru pages via introducing new functions and page flags to help
migration.


struct address_space_operations {
	..
	..
	bool (*isolate_page)(struct page *, isolate_mode_t);
	void (*putback_page)(struct page *);
	..
}

new page flags

	PG_movable
	PG_isolated

For details, please read description in "mm: migrate: support non-lru
movable page migration".

Originally, Gioh Kim had tried to support this feature but he moved so
I took over the work. I took many code from his work and changed a little
bit and Konstantin Khlebnikov helped Gioh a lot so he should deserve to have
many credit, too.

Thanks, Gioh and Konstantin!

This patchset consists of five parts.

1. clean up migration
  mm: use put_page to free page instead of putback_lru_page

2. add non-lru page migration feature
  mm: migrate: support non-lru movable page migration

3. rework KVM memory-ballooning
  mm: balloon: use general non-lru movable page feature

4. zsmalloc refactoring for preparing page migration
  zsmalloc: keep max_object in size_class
  zsmalloc: use bit_spin_lock
  zsmalloc: use accessor
  zsmalloc: factor page chain functionality out
  zsmalloc: introduce zspage structure
  zsmalloc: separate free_zspage from putback_zspage
  zsmalloc: use freeobj for index

5. zsmalloc page migration
  zsmalloc: page migration support
  zram: use __GFP_MOVABLE for memory allocation

* From v3
  * rebase on mmotm-2016-04-06-20-40
  * fix swap_info deadlock - Chulmin
  * race without page_lock - Vlastimil
  * no use page._mapcount for potential user-mapped page driver - Vlastimil
  * fix and enhance doc/description - Vlastimil
  * use page->mapping lower bits to represent PG_movable
  * make driver side's rule simple.

* From v2
  * rebase on mmotm-2016-03-29-15-54-16
  * check PageMovable before lock_page - Joonsoo
  * check PageMovable before PageIsolated checking - Joonsoo
  * add more description about rule

* From v1
  * rebase on v4.5-mmotm-2016-03-17-15-04
  * reordering patches to merge clean-up patches first
  * add Acked-by/Reviewed-by from Vlastimil and Sergey
  * use each own mount model instead of reusing anon_inode_fs - Al Viro
  * small changes - YiPing, Gioh

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: dri-devel@lists.freedesktop.org
Cc: Hugh Dickins <hughd@google.com>
Cc: John Einar Reitan <john.reitan@foss.arm.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Rafael Aquini <aquini@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: virtualization@lists.linux-foundation.org
Cc: Gioh Kim <gi-oh.kim@profitbricks.com>
Cc: Chan Gyun Jeong <chan.jeong@lge.com>
Cc: Sangseok Lee <sangseok.lee@lge.com>
Cc: Kyeongdon Kim <kyeongdon.kim@lge.com>
Cc: Chulmin Kim <cmlaika.kim@samsung.com>

Minchan Kim (12):
  mm: use put_page to free page instead of  putback_lru_page
  mm: migrate: support non-lru movable page migration
  mm: balloon: use general non-lru movable page feature
  zsmalloc: keep max_object in size_class
  zsmalloc: use bit_spin_lock
  zsmalloc: use accessor
  zsmalloc: factor page chain functionality out
  zsmalloc: introduce zspage structure
  zsmalloc: separate free_zspage from putback_zspage
  zsmalloc: use freeobj for index
  zsmalloc: page migration support
  zram: use __GFP_MOVABLE for memory allocation

 Documentation/filesystems/Locking  |    4 +
 Documentation/filesystems/vfs.txt  |   11 +
 Documentation/vm/page_migration    |  107 +++-
 drivers/block/zram/zram_drv.c      |    3 +-
 drivers/virtio/virtio_balloon.c    |   52 +-
 include/linux/balloon_compaction.h |   51 +-
 include/linux/fs.h                 |    2 +
 include/linux/ksm.h                |    3 +-
 include/linux/migrate.h            |    5 +
 include/linux/mm.h                 |    1 +
 include/linux/page-flags.h         |   23 +-
 include/uapi/linux/magic.h         |    2 +
 mm/balloon_compaction.c            |   94 +--
 mm/compaction.c                    |   40 +-
 mm/ksm.c                           |    4 +-
 mm/migrate.c                       |  287 +++++++--
 mm/page_alloc.c                    |    4 +-
 mm/util.c                          |    6 +-
 mm/vmscan.c                        |    2 +-
 mm/zsmalloc.c                      | 1147 ++++++++++++++++++++++++------------
 20 files changed, 1283 insertions(+), 565 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
