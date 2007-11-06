Received: from [99.236.101.138] (helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.68)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1IpPtN-00055I-BV
	for linux-mm@kvack.org; Tue, 06 Nov 2007 09:59:01 -0500
Date: Tue, 6 Nov 2007 09:57:16 -0500 (EST)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: [PATCH] MM: Use is_power_of_2() macro where appropriate.
Message-ID: <Pine.LNX.4.64.0711060955500.6006@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>

---

 mm/bootmem.c |    3 ++-
 mm/slab.c    |    3 ++-
 mm/slub.c    |    3 ++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 00a9697..47f9b59 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -12,6 +12,7 @@
 #include <linux/pfn.h>
 #include <linux/bootmem.h>
 #include <linux/module.h>
+#include <linux/log2.h>

 #include <asm/bug.h>
 #include <asm/io.h>
@@ -189,7 +190,7 @@ __alloc_bootmem_core(struct bootmem_data *bdata, unsigned long size,
 		printk("__alloc_bootmem_core(): zero-sized request\n");
 		BUG();
 	}
-	BUG_ON(align & (align-1));
+	BUG_ON(!is_power_of_2(align));

 	if (limit && bdata->node_boot_start >= limit)
 		return NULL;
diff --git a/mm/slab.c b/mm/slab.c
index cfa6be4..f13d46d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -110,6 +110,7 @@
 #include	<linux/fault-inject.h>
 #include	<linux/rtmutex.h>
 #include	<linux/reciprocal_div.h>
+#include	<linux/log2.h>

 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
@@ -1782,7 +1783,7 @@ static void dump_line(char *data, int offset, int limit)

 	if (bad_count == 1) {
 		error ^= POISON_FREE;
-		if (!(error & (error - 1))) {
+		if (is_power_of_2(error)) {
 			printk(KERN_ERR "Single bit error detected. Probably "
 					"bad RAM.\n");
 #ifdef CONFIG_X86
diff --git a/mm/slub.c b/mm/slub.c
index 84f59fd..413cdc6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -21,6 +21,7 @@
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include <linux/log2.h>

 /*
  * Lock order:
@@ -2851,7 +2852,7 @@ void __init kmem_cache_init(void)
 	 * around with ARCH_KMALLOC_MINALIGN
 	 */
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
-		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
+		!is_power_of_2(KMALLOC_MIN_SIZE));

 	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
 		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://crashcourse.ca
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
