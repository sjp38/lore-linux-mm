Message-Id: <20080430044320.479850443@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:58 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [07/11] vcompound: bit waitqueue support
Content-Disposition: inline; filename=vcp_waitqueue_support
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If bit_waitqueue is passed a vmalloc address then it must use
vmalloc_head_page() to determine the page struct address.
vmalloc_head_page will fall back to virt_to_page() for physical
addresses. For virtual addresses it will perform a page table lookup
to find the page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 kernel/wait.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc8-mm2/kernel/wait.c
===================================================================
--- linux-2.6.25-rc8-mm2.orig/kernel/wait.c	2008-04-01 12:44:26.000000000 -0700
+++ linux-2.6.25-rc8-mm2/kernel/wait.c	2008-04-11 20:23:32.000000000 -0700
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/wait.h>
 #include <linux/hash.h>
+#include <linux/vmalloc.h>
 
 void init_waitqueue_head(wait_queue_head_t *q)
 {
@@ -245,7 +246,7 @@ EXPORT_SYMBOL(wake_up_bit);
 wait_queue_head_t *bit_waitqueue(void *word, int bit)
 {
 	const int shift = BITS_PER_LONG == 32 ? 5 : 6;
-	const struct zone *zone = page_zone(virt_to_page(word));
+	const struct zone *zone = page_zone(vcompound_head_page(word));
 	unsigned long val = (unsigned long)word << shift | bit;
 
 	return &zone->wait_table[hash_long(val, zone->wait_table_bits)];

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
