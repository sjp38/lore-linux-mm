Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB396B0276
	for <linux-mm@kvack.org>; Mon, 10 May 2010 06:57:34 -0400 (EDT)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 19/25] lmb: Add array resizing support
Date: Mon, 10 May 2010 19:38:53 +1000
Message-Id: <1273484339-28911-20-git-send-email-benh@kernel.crashing.org>
In-Reply-To: <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
References: <1273484339-28911-1-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-2-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-3-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-4-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-5-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-6-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-7-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-8-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-9-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-10-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-11-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-12-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-13-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-14-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-15-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-16-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-17-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-18-git-send-email-benh@kernel.crashing.org>
 <1273484339-28911-19-git-send-email-benh@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linuxtronix.de, mingo@elte.hu, davem@davemloft.net, lethal@linux-sh.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

When one of the array gets full, we resize it. After much thinking and
a few iterations of that code, I went back to on-demand resizing using
the (new) internal lmb_find_base() function, which is pretty much what
Yinghai initially proposed, though there some differences in the details.

To work this relies on the default alloc limit being set sensibly by
the architecture.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 lib/lmb.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 92 insertions(+), 1 deletions(-)

diff --git a/lib/lmb.c b/lib/lmb.c
index 4977888..2602683 100644
--- a/lib/lmb.c
+++ b/lib/lmb.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
 #include <linux/poison.h>
@@ -24,6 +25,17 @@ static struct lmb_region lmb_reserved_init_regions[INIT_LMB_REGIONS + 1];
 
 #define LMB_ERROR	(~(phys_addr_t)0)
 
+/* inline so we don't get a warning when pr_debug is compiled out */
+static inline const char *lmb_type_name(struct lmb_type *type)
+{
+	if (type == &lmb.memory)
+		return "memory";
+	else if (type == &lmb.reserved)
+		return "reserved";
+	else
+		return "unknown";
+}
+
 /*
  * Address comparison utilities
  */
@@ -156,6 +168,73 @@ static void lmb_coalesce_regions(struct lmb_type *type,
 	lmb_remove_region(type, r2);
 }
 
+/* Defined below but needed now */
+static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size);
+
+static int lmb_double_array(struct lmb_type *type)
+{
+	struct lmb_region *new_array, *old_array;
+	phys_addr_t old_size, new_size, addr;
+	int use_slab = slab_is_available();
+
+	pr_debug("lmb: %s array full, doubling...", lmb_type_name(type));
+
+	/* Calculate new doubled size */
+	old_size = type->max * sizeof(struct lmb_region);
+	new_size = old_size << 1;
+
+	/* Try to find some space for it.
+	 *
+	 * WARNING: We assume that either slab_is_available() and we use it or
+	 * we use LMB for allocations. That means that this is unsafe to use
+	 * when bootmem is currently active (unless bootmem itself is implemented
+	 * on top of LMB which isn't the case yet)
+	 *
+	 * This should however not be an issue for now, as we currently only
+	 * call into LMB while it's still active, or much later when slab is
+	 * active for memory hotplug operations
+	 */
+	if (use_slab) {
+		new_array = kmalloc(new_size, GFP_KERNEL);
+		addr = new_array == NULL ? LMB_ERROR : __pa(new_array);
+	} else
+		addr = lmb_find_base(new_size, sizeof(phys_addr_t), LMB_ALLOC_ACCESSIBLE);
+	if (addr == LMB_ERROR) {
+		pr_err("lmb: Failed to double %s array from %ld to %ld entries !\n",
+		       lmb_type_name(type), type->max, type->max * 2);
+		return -1;
+	}
+	new_array = __va(addr);
+
+	/* Found space, we now need to move the array over before
+	 * we add the reserved region since it may be our reserved
+	 * array itself that is full.
+	 */
+	memcpy(new_array, type->regions, old_size);
+	memset(new_array + type->max, 0, old_size);
+	old_array = type->regions;
+	type->regions = new_array;
+	type->max <<= 1;
+
+	/* If we use SLAB that's it, we are done */
+	if (use_slab)
+		return 0;
+
+	/* Add the new reserved region now. Should not fail ! */
+	BUG_ON(lmb_add_region(&lmb.reserved, addr, new_size) < 0);
+
+	/* If the array wasn't our static init one, then free it. We only do
+	 * that before SLAB is available as later on, we don't know whether
+	 * to use kfree or free_bootmem_pages(). Shouldn't be a big deal
+	 * anyways
+	 */
+	if (old_array != lmb_memory_init_regions &&
+	    old_array != lmb_reserved_init_regions)
+		lmb_free(__pa(old_array), old_size);
+
+	return 0;
+}
+
 static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t size)
 {
 	unsigned long coalesced = 0;
@@ -196,7 +275,11 @@ static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t
 
 	if (coalesced)
 		return coalesced;
-	if (type->cnt >= type->max)
+
+	/* If we are out of space, we fail. It's too late to resize the array
+	 * but then this shouldn't have happened in the first place.
+	 */
+	if (WARN_ON(type->cnt >= type->max))
 		return -1;
 
 	/* Couldn't coalesce the LMB, so add it to the sorted table. */
@@ -217,6 +300,14 @@ static long lmb_add_region(struct lmb_type *type, phys_addr_t base, phys_addr_t
 	}
 	type->cnt++;
 
+	/* The array is full ? Try to resize it. If that fails, we undo
+	 * our allocation and return an error
+	 */
+	if (type->cnt == type->max && lmb_double_array(type)) {
+		type->cnt--;
+		return -1;
+	}
+
 	return 0;
 }
 
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
