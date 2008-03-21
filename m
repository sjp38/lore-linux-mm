Message-Id: <20080321061725.701640800@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:10 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [07/14] vcompound: bit waitqueue support
Content-Disposition: inline; filename=0011-vcompound-bit-waitqueue-support.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If bit_waitqueue is passed a vmalloc address then it must use
vmalloc_head_page() instead of virt_to_page().

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 kernel/wait.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc5-mm1/kernel/wait.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/kernel/wait.c	2008-03-20 20:03:51.141901370 -0700
+++ linux-2.6.25-rc5-mm1/kernel/wait.c	2008-03-20 20:07:57.266856571 -0700
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
