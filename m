Message-Id: <20071004040004.482614498@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:47 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [12/18] Wait: Allow bit_waitqueue to wait on a bit in a virtual compound page
Content-Disposition: inline; filename=vcompound_wait_on_virtually_mapped_object
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

If bit waitqueue is passed a virtual address then it must use
virt_to_head_page instead of virt_to_page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 kernel/wait.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/kernel/wait.c
===================================================================
--- linux-2.6.orig/kernel/wait.c	2007-10-03 17:44:21.000000000 -0700
+++ linux-2.6/kernel/wait.c	2007-10-03 17:53:07.000000000 -0700
@@ -245,7 +245,7 @@ EXPORT_SYMBOL(wake_up_bit);
 fastcall wait_queue_head_t *bit_waitqueue(void *word, int bit)
 {
 	const int shift = BITS_PER_LONG == 32 ? 5 : 6;
-	const struct zone *zone = page_zone(virt_to_page(word));
+	const struct zone *zone = page_zone(virt_to_head_page(word));
 	unsigned long val = (unsigned long)word << shift | bit;
 
 	return &zone->wait_table[hash_long(val, zone->wait_table_bits)];

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
