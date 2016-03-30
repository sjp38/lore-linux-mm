Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id ECEF66B0253
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 03:10:40 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id 4so34906231pfd.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:10:40 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id lw9si4375063pab.89.2016.03.30.00.10.37
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 00:10:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v3 03/16] mm: add non-lru movable page support document
Date: Wed, 30 Mar 2016 16:12:02 +0900
Message-Id: <1459321935-3655-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1459321935-3655-1-git-send-email-minchan@kernel.org>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>, Minchan Kim <minchan@kernel.org>, Jonathan Corbet <corbet@lwn.net>

This patch describes what a subsystem should do for non-lru movable
page supporting.

Cc: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 Documentation/filesystems/vfs.txt | 11 ++++++-
 Documentation/vm/page_migration   | 69 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 4c1b6c3b4bc8..d63142f8ed7b 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -752,12 +752,21 @@ struct address_space_operations {
         and transfer data directly between the storage and the
         application's address space.
 
+  isolate_page: Called by the VM when isolating a movable non-lru page.
+	If page is successfully isolated, we should mark the page as
+	PG_isolated via __SetPageIsolated.
+
   migrate_page:  This is used to compact the physical memory usage.
         If the VM wants to relocate a page (maybe off a memory card
         that is signalling imminent failure) it will pass a new page
 	and an old page to this function.  migrate_page should
 	transfer any private data across and update any references
-        that it has to the page.
+	that it has to the page. If migrated page is non-lru page,
+	we should clear PG_isolated and PG_movable via __ClearPageIsolated
+	and __ClearPageMovable.
+
+  putback_page: Called by the VM when isolated page's migration fails.
+	We should clear PG_isolated marked in isolated_page function.
 
   launder_page: Called before freeing a page - it writes back the dirty page. To
   	prevent redirtying the page, it is kept locked during the whole
diff --git a/Documentation/vm/page_migration b/Documentation/vm/page_migration
index fea5c0864170..c4e7551a414e 100644
--- a/Documentation/vm/page_migration
+++ b/Documentation/vm/page_migration
@@ -142,5 +142,72 @@ is increased so that the page cannot be freed while page migration occurs.
 20. The new page is moved to the LRU and can be scanned by the swapper
     etc again.
 
-Christoph Lameter, May 8, 2006.
+C. Non-LRU Page migration
+-------------------------
+
+Although original migration aimed for reducing the latency of memory access
+for NUMA, compaction who want to create high-order page is also main customer.
+
+Ppage migration's disadvantage is that it was designed to migrate only
+*LRU* pages. However, there are potential non-lru movable pages which can be
+migrated in system, for example, zsmalloc, virtio-balloon pages.
+For virtio-balloon pages, some parts of migration code path was hooked up
+and added virtio-balloon specific functions to intercept logi.
+It's too specific to one subsystem so other subsystem who want to make
+their pages movable should add own specific hooks in migration path.
+
+To solve such problem, VM supports non-LRU page migration which provides
+generic functions for non-LRU movable pages without needing subsystem
+specific hook in mm/{migrate|compact}.c.
+
+If a subsystem want to make own pages movable, it should mark pages as
+PG_movable via __SetPageMovable. __SetPageMovable needs address_space for
+argument for register functions which will be called by VM.
+
+Three functions in address_space_operation related to non-lru movable page:
+
+	bool (*isolate_page) (struct page *, isolate_mode_t);
+	int (*migratepage) (struct address_space *,
+		struct page *, struct page *, enum migrate_mode);
+	void (*putback_page)(struct page *);
+
+1. Isolation
+
+What VM expected on isolate_page of subsystem is to set PG_isolated flags
+of the page if it was successful. With that, concurrent isolation among
+CPUs skips the isolated page by other CPU earlier. VM calls isolate_page
+under PG_lock of page. If a subsystem cannot isolate the page, it should
+return false.
 
+2. Migration
+
+After successful isolation, VM calls migratepage. The migratepage's goal is
+to move content of the old page to new page and set up struct page fields
+of new page. If migration is successful, subsystem should release old page's
+refcount to free. Keep in mind that subsystem should clear PG_movable and
+PG_isolated before releasing the refcount.  If everything are done, user
+should return MIGRATEPAGE_SUCCESS. If subsystem cannot migrate the page
+at the moment, migratepage can return -EAGAIN. On -EAGAIN, VM will retry page
+migration because VM interprets -EAGAIN as "temporal migration failure".
+
+3. Putback
+
+If migration was unsuccessful, VM calls putback_page. The subsystem should
+insert isolated page to own data structure again if it has. And subsystem
+should clear PG_isolated which was marked in isolation step.
+
+Note about releasing page:
+
+Subsystem can release pages whenever it want but if it releses the page
+which is already isolated, it should clear PG_isolated but doesn't touch
+PG_movable under PG_lock. Instead of it, VM will clear PG_movable after
+his job done. Otherweise, subsystem should clear both page flags before
+releasing the page.
+
+Note about PG_isolated:
+
+PG_isolated check on a page is valid only if the page's flag is already
+set to PG_movable.
+
+Christoph Lameter, May 8, 2006.
+Minchan Kim, Mar 28, 2016.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
