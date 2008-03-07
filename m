Date: Fri, 7 Mar 2008 10:14:46 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Simple test case for the mask allocator
Message-ID: <20080307091446.GA14119@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Simple test case for the mask allocator

Can be added on top of the earlier mask allocator patchkit to give
a simple self test functionality.

Optional patch, but I find it useful for testing.

I haven't tried to clean it up too much (e.g. some checkpatch warnings left)

Signed-off-by: Andi Kleen <ak@suse.de>

---
 lib/Kconfig.debug    |    6 ++
 mm/Makefile          |    2 
 mm/mask-alloc-test.c |  124 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 132 insertions(+)

Index: linux/mm/mask-alloc-test.c
===================================================================
--- /dev/null
+++ linux/mm/mask-alloc-test.c
@@ -0,0 +1,124 @@
+/* Simple test for the mask allocator */
+#include <linux/gfp.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+enum {
+	MAX_LEN = PAGE_SIZE * 6,
+	NUMALLOC = 20,
+	MASK_BASE = 20,
+	MASK_MAX = 24,
+	MASKS = MASK_MAX-MASK_BASE,
+};
+
+static int next = 100;
+static unsigned my_rand(void)
+{
+	next = next * 1103515245 + 12345;
+	return next;
+}
+
+static void verify(int i, unsigned char *m, int length, u64 mask)
+{
+	int warned = 0;
+	int k;
+	for (k = 0; k < length; k++) {
+		if (m[k] != (i & 0xff) && warned++ < 5) {
+			printk("gpm verify %d offset %d expected %x got %x mask %Lx\n",
+				i, k, i & 0xff, m[k], mask);
+		}
+	}
+}
+
+int test_mask_alloc(void)
+{
+	int bits;
+	unsigned i, w;
+	int *all_lengths[MASKS + 1] = { 0 } ;
+	void **all_mem[MASKS + 1] = { 0 };
+	void **mem;
+	unsigned *lengths;
+
+	printk("testing mask alloc upto %d bits\n", MASK_MAX);
+
+	for (bits = MASK_BASE, w = 0; bits <= MASK_MAX; bits++, w++) {
+		unsigned total = 0;
+		u64 mask = (1 << bits) - 1;
+		all_lengths[w] = kmalloc(sizeof(unsigned) * NUMALLOC, GFP_KERNEL);
+		lengths = all_lengths[w];
+		all_mem[w] = kmalloc(sizeof(void *) * NUMALLOC, GFP_KERNEL);
+		mem = all_mem[w];
+		if (!mem || !lengths) {
+			kfree(lengths);
+			all_lengths[w] = NULL;
+			break;
+		}
+
+		for (i = 0; i < NUMALLOC; i++) {
+			lengths[i] = my_rand() % MAX_LEN;
+			mem[i] = get_pages_mask(GFP_NOWAIT|__GFP_NOWARN, lengths[i], mask);
+			if (!mem[i]) {
+				printk("gpm1 %d mask %Lx size %u total %uKB failed\n",
+					i, mask, lengths[i], total >> 10);
+				continue;
+			}
+			if ((u64)virt_to_phys(mem[i]) & ~mask)
+				printk("bad address mask %Lx: %p %u\n", mask, mem[i], lengths[i]);
+			total += lengths[i];
+			memset(mem[i], i & 0xff, lengths[i]);
+		}
+		/* free some again */
+		for (i = 0; i < NUMALLOC; i += my_rand()%4) {
+			if (!mem[i])
+				continue;
+			free_pages_mask(mem[i], lengths[i]);
+			mem[i] = NULL;
+		}
+		/* allocate some again */
+		for (i = 0; i < NUMALLOC; i++) {
+			if (mem[i])
+				continue;
+			lengths[i] = my_rand() % MAX_LEN;
+			mem[i] = get_pages_mask(GFP_NOWAIT|__GFP_NOWARN, lengths[i], mask);
+			if (!mem[i]) {
+				printk("gpm2 %d mask %Lx size %u failed\n",
+					i, mask, lengths[i]);
+				continue;
+			}
+			if ((u64)virt_to_phys(mem[i]) & ~mask)
+				printk("bad address mask %Lx: %p %u\n", mask, mem[i], lengths[i]);
+			memset(mem[i], i & 0xff, lengths[i]);
+		}
+	}
+
+	printk("verify & free\n");
+	for (bits = MASK_BASE, w = 0; bits <= MASK_MAX; bits++, w++) {
+		u64 mask = (1 << bits) - 1;
+		printk("mask %Lx\n", mask);
+		mem = all_mem[w];
+		lengths = all_lengths[w];
+		if (!mem || !lengths)
+			continue;
+		/* verify */
+		for (i = 0; i < NUMALLOC; i++) {
+			if (!mem[i])
+				continue;
+			verify(i, mem[i], lengths[i], mask);
+
+		}
+		/* free */
+		for (i = 0; i < NUMALLOC; i++) {
+			if (!mem[i])
+				continue;
+			free_pages_mask(mem[i], lengths[i]);
+		}
+		kfree(mem);
+		kfree(lengths);
+	}
+	printk("done\n");
+	return 0;
+}
+
+module_init(test_mask_alloc);
+
Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile
+++ linux/mm/Makefile
@@ -35,3 +35,5 @@ obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
 obj-$(CONFIG_MASK_ALLOC) += mask-alloc.o
 
+# should be somewhere else
+obj-$(CONFIG_TEST_MASK_ALLOC) += mask-alloc-test.o
Index: linux/lib/Kconfig.debug
===================================================================
--- linux.orig/lib/Kconfig.debug
+++ linux/lib/Kconfig.debug
@@ -621,4 +621,10 @@ config PROVIDE_OHCI1394_DMA_INIT
 
 	  See Documentation/debugging-via-ohci1394.txt for more information.
 
+config TEST_MASK_ALLOC
+	depends on MASK_ALLOC
+	bool "Boot time self test for mask allocator"
+	help
+	  Run a simple boot-time self test for the mask allocator.
+
 source "samples/Kconfig"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
