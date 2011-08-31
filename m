Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3FC06B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 21:44:31 -0400 (EDT)
Subject: [PATCH] mm: vmalloc - Report more vmalloc failures
From: Joe Perches <joe@perches.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Aug 2011 18:44:28 -0700
Message-ID: <1314755068.27632.12.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Some vmalloc failure paths do not report OOM conditions.

Add warn_alloc_failed, which also does a dump_stack,
to those failure paths.

This allows more site specific vmalloc failure
logging message printks to be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/vmalloc.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3122acc..5108e0b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1600,13 +1600,12 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
-		return NULL;
+		goto fail;
 
 	area = __get_vm_area_node(size, align, VM_ALLOC, start, end, node,
 				  gfp_mask, caller);
-
 	if (!area)
-		return NULL;
+		goto fail;
 
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
 
@@ -1618,6 +1617,12 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	kmemleak_alloc(addr, real_size, 3, gfp_mask);
 
 	return addr;
+
+fail:
+	warn_alloc_failed(gfp_mask, 0,
+			  "vmalloc: allocation failure: %lu bytes\n",
+			  real_size);
+	return NULL;
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
