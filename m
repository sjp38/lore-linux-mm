Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 18C306B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 18:42:23 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Make vb_alloc() more foolproof
Date: Wed,  6 Jun 2012 00:40:56 +0200
Message-Id: <1338936056-4092-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>

If someone calls vb_alloc() (or vm_map_ram() for that matter) to allocate
0 bytes (0 pages), get_order() returns BITS_PER_LONG - PAGE_CACHE_SHIFT
and interesting stuff happens. So make debugging such problems easier and
warn about 0-size allocation.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/vmalloc.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2aad499..bebee70 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -904,6 +904,15 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 
 	BUG_ON(size & ~PAGE_MASK);
 	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
+	if (size == 0) {
+		/*
+		 * Allocating 0 bytes isn't what caller wants since
+		 * get_order(0) returns funny result. Just warn and terminate
+		 * early.
+		 */
+		WARN_ON(1);
+		return NULL;
+	}
 	order = get_order(size);
 
 again:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
