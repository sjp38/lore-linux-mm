Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id F07606B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:37 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so34873160pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:37 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id by10si4350370pab.168.2016.03.30.00.10.36
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:36 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 00/16] Support non-lru page migration
Date: Wed, 30 Mar 2016 16:11:59 +0900
Message-Id: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>

Recently, I got many reports about perfermance degradation
in embedded system(Android mobile phone, webOS TV and so on)
and failed to fork easily.

The problem was fragmentation caused by zram and GPU driver
pages. Their pages cannot be migrated so compaction cannot
work well, either so reclaimer ends up shrinking all of working
set pages. It made system very slow and even to fail to fork
easily.

Other pain point is that they cannot work with CMA.
Most of CMA memory space could be idle(ie, it could be used
for movable pages unless driver is using) but if driver(i.e.,
zram) cannot migrate his page, that memory space could be
wasted. In our product which has big CMA memory, it reclaims
zones too exccessively although there are lots of free space
in CMA so system was very slow easily.

To solve these problem, this patch try to add facility to
migrate non-lru pages via introducing new friend functions
of migratepage in address_space_operation and new page flags.

	(isolate_page, putback_page)
	(PG_movable, PG_isolated)

For details, please read description in
"mm/compaction: support non-lru movable page migration".

Originally, Gioh Kim tried to support this feature but he moved
so I took over the work. But I took many code from his work and
changed a little bit.
Thanks, Gioh!

And I should mention Konstantin Khlebnikov. He really heped Gioh
at that time so he should deserve to have many credit, too.
Thanks, Konstantin!

This patchset consists of five parts.

1. clean up migration
  mm: use put_page to free page instead of putback_lru_page

2. add non-lru page migration feature
  mm/compaction: support non-lru movable page migration
  mm: add non-lru movable page support document

3. rework KVM memory-ballooning
  mm/balloon: use general movable page feature into balloon

4. zsmalloc clean-up for preparing page migration
  zsmalloc: keep max_object in size_class
  zsmalloc: squeeze inuse into page->mapping
  zsmalloc: remove page_mapcount_reset
  zsmalloc: squeeze freelist into page->mapping
  zsmalloc: move struct zs_meta from mapping to freelist
  zsmalloc: factor page chain functionality out
  zsmalloc: separate free_zspage from putback_zspage
  zsmalloc: zs_compact refactoring

5. add zsmalloc page migration
  zsmalloc: migrate head page of zspage
  zsmalloc: use single linked list for page chain
  zsmalloc: migrate tail pages in zspage
  zram: use __GFP_MOVABLE for memory allocation

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


Minchan Kim (16):
  mm: use put_page to free page instead of putback_lru_page
  mm/compaction: support non-lru movable page migration
  mm: add non-lru movable page support document
  mm/balloon: use general movable page feature into balloon
  zsmalloc: keep max_object in size_class
  zsmalloc: squeeze inuse into page->mapping
  zsmalloc: remove page_mapcount_reset
  zsmalloc: squeeze freelist into page->mapping
  zsmalloc: move struct zs_meta from mapping to freelist
  zsmalloc: factor page chain functionality out
  zsmalloc: separate free_zspage from putback_zspage
  zsmalloc: zs_compact refactoring
  zsmalloc: migrate head page of zspage
  zsmalloc: use single linked list for page chain
  zsmalloc: migrate tail pages in zspage
  zram: use __GFP_MOVABLE for memory allocation

 Documentation/filesystems/Locking      |    4 +
 Documentation/filesystems/vfs.txt      |   16 +-
 Documentation/vm/page_migration        |   69 +-
 drivers/block/zram/zram_drv.c          |    3 +-
 drivers/virtio/virtio_balloon.c        |   53 +-
 fs/proc/page.c                         |    3 +
 include/linux/balloon_compaction.h     |   49 +-
 include/linux/fs.h                     |    2 +
 include/linux/migrate.h                |    2 +
 include/linux/page-flags.h             |   47 +-
 include/uapi/linux/kernel-page-flags.h |    1 +
 include/uapi/linux/magic.h             |    2 +
 mm/balloon_compaction.c                |  101 +--
 mm/compaction.c                        |   15 +-
 mm/migrate.c                           |  238 ++++--
 mm/vmscan.c                            |    2 +-
 mm/zsmalloc.c                          | 1253 ++++++++++++++++++++++++--------
 17 files changed, 1368 insertions(+), 492 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
