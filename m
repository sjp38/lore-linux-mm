Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id DCC2A6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 00:18:11 -0500 (EST)
Received: by qcsd17 with SMTP id d17so5155640qcs.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 21:18:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] vmalloc: remove #ifdef in function body
Date: Wed, 21 Dec 2011 14:17:59 +0900
Message-Id: <1324444679-9247-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>

We don't like function body which include #ifdef.
If we can, define null function to go out compile time.
It's trivial, no functional change.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmalloc.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0aca3ce..e1fa5a6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -505,6 +505,7 @@ static void unmap_vmap_area(struct vmap_area *va)
 	vunmap_page_range(va->va_start, va->va_end);
 }
 
+#ifdef CONFIG_DEBUG_PAGEALLOC
 static void vmap_debug_free_range(unsigned long start, unsigned long end)
 {
 	/*
@@ -520,11 +521,15 @@ static void vmap_debug_free_range(unsigned long start, unsigned long end)
 	 * debugging doesn't do a broadcast TLB flush so it is a lot
 	 * faster).
 	 */
-#ifdef CONFIG_DEBUG_PAGEALLOC
 	vunmap_page_range(start, end);
 	flush_tlb_kernel_range(start, end);
-#endif
 }
+#else
+static inline void vmap_debug_free_range(unsigned long start,
+					unsigned long end)
+{
+}
+#endif
 
 /*
  * lazy_max_pages is the maximum amount of virtual address space we gather up
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
