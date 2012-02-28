Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id CD5396B00EB
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:32 -0500 (EST)
Message-Id: <20120228144747.360548589@intel.com>
Date: Tue, 28 Feb 2012 22:00:29 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 7/9] mm: pass __GFP_WRITE to memcg charge and reclaim routines
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=memcg-pass-__GFP_WRITE-to-reclaim.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

__GFP_WRITE will be tested in vmscan to find out the write tasks.

For good interactive performance, we try to focus dirty reclaim waits on
them and avoid blocking unrelated tasks.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 include/linux/gfp.h |    2 +-
 mm/filemap.c        |   13 +++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

--- linux.orig/include/linux/gfp.h	2012-02-28 10:22:24.000000000 +0800
+++ linux/include/linux/gfp.h	2012-02-28 10:22:42.936316697 +0800
@@ -129,7 +129,7 @@ struct vm_area_struct;
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_NOMEMALLOC|__GFP_WRITE)
 
 /* Control slab gfp mask during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
--- linux.orig/mm/filemap.c	2012-02-28 10:22:25.000000000 +0800
+++ linux/mm/filemap.c	2012-02-28 10:24:12.320318821 +0800
@@ -2340,21 +2340,22 @@ struct page *grab_cache_page_write_begin
 	int status;
 	gfp_t gfp_mask;
 	struct page *page;
-	gfp_t gfp_notmask = 0;
+	gfp_t lru_gfp_mask = GFP_KERNEL | __GFP_WRITE;
 
 	gfp_mask = mapping_gfp_mask(mapping) | __GFP_WRITE;
-	if (flags & AOP_FLAG_NOFS)
-		gfp_notmask = __GFP_FS;
+	if (flags & AOP_FLAG_NOFS) {
+		gfp_mask &= ~__GFP_FS;
+		lru_gfp_mask &= ~__GFP_FS;
+	}
 repeat:
 	page = find_lock_page(mapping, index);
 	if (page)
 		goto found;
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	page = __page_cache_alloc(gfp_mask);
 	if (!page)
 		return NULL;
-	status = add_to_page_cache_lru(page, mapping, index,
-						GFP_KERNEL & ~gfp_notmask);
+	status = add_to_page_cache_lru(page, mapping, index, lru_gfp_mask);
 	if (unlikely(status)) {
 		page_cache_release(page);
 		if (status == -EEXIST)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
