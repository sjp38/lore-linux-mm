Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 4EC676B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:56:23 -0500 (EST)
Message-Id: <20120228144747.440418051@intel.com>
Date: Tue, 28 Feb 2012 22:00:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH 8/9] mm: dont set __GFP_WRITE on ramfs/sysfs writes
References: <20120228140022.614718843@intel.com>
Content-Disposition: inline; filename=mm-__GFP_WRITE-cap_account_dirty.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Try to avoid page reclaim waits when writing to ramfs/sysfs etc.

Maybe not a big deal...

CC: Johannes Weiner <jweiner@redhat.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/filemap.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

--- linux.orig/mm/filemap.c	2012-02-28 10:24:12.000000000 +0800
+++ linux/mm/filemap.c	2012-02-28 10:25:55.568321275 +0800
@@ -2340,9 +2340,13 @@ struct page *grab_cache_page_write_begin
 	int status;
 	gfp_t gfp_mask;
 	struct page *page;
-	gfp_t lru_gfp_mask = GFP_KERNEL | __GFP_WRITE;
+	gfp_t lru_gfp_mask = GFP_KERNEL;
 
-	gfp_mask = mapping_gfp_mask(mapping) | __GFP_WRITE;
+	gfp_mask = mapping_gfp_mask(mapping);
+	if (mapping_cap_account_dirty(mapping)) {
+		gfp_mask |= __GFP_WRITE;
+		lru_gfp_mask |= __GFP_WRITE;
+	}
 	if (flags & AOP_FLAG_NOFS) {
 		gfp_mask &= ~__GFP_FS;
 		lru_gfp_mask &= ~__GFP_FS;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
