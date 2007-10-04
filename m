Message-Id: <20071004040003.556122828@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:43 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [08/18] GFP_VFALLBACK: Allow fallback of compound pages to virtual mappings
Content-Disposition: inline; filename=vcompound_core
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a new gfp flag

	__GFP_VFALLBACK

If specified during a higher order allocation then the system will fall
back to vmap if no physically contiguous pages can be found. This will
create a virtually contiguous area instead of a physically contiguous area.
In many cases the virtually contiguous area can stand in for the physically
contiguous area (with some loss of performance).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/gfp.h |    5 +
 mm/page_alloc.c     |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 139 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-10-03 19:44:07.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-10-03 19:44:08.000000000 -0700
@@ -60,6 +60,9 @@ long nr_swap_pages;
 int percpu_pagelist_fraction;
 
 static void __free_pages_ok(struct page *page, unsigned int order);
+static struct page *alloc_vcompound(gfp_t, int,
+					struct zonelist *, unsigned long);
+static void destroy_compound_page(struct page *page, unsigned long order);
 
 /*
  * results with 256, 32 in the lowmem_reserve sysctl:
@@ -260,9 +263,51 @@ static void bad_page(struct page *page)
  * This usage means that zero-order pages may not be compound.
  */
 
+static void __free_vcompound(void *addr)
+{
+	struct page **pages;
+	int i;
+	struct page *page = vmalloc_to_page(addr);
+	int order = compound_order(page);
+	int nr_pages = 1 << order;
+
+	if (!PageVcompound(page) || !PageHead(page)) {
+		bad_page(page);
+		return;
+	}
+	destroy_compound_page(page, order);
+	pages = vunmap(addr);
+	/*
+	 * First page will have zero refcount since it maintains state
+	 * for the compound and was decremented before we got here.
+	 */
+	set_page_address(page, NULL);
+	__ClearPageVcompound(page);
+	free_hot_page(page);
+
+	for (i = 1; i < nr_pages; i++) {
+		page = pages[i];
+		set_page_address(page, NULL);
+		__ClearPageVcompound(page);
+		__free_page(page);
+	}
+	kfree(pages);
+}
+
+
+static void free_vcompound(void *addr)
+{
+	__free_vcompound(addr);
+}
+
 static void free_compound_page(struct page *page)
 {
-	__free_pages_ok(page, compound_order(page));
+	if (PageVcompound(page))
+		free_vcompound(page_address(page));
+	else {
+		destroy_compound_page(page, compound_order(page));
+		__free_pages_ok(page, compound_order(page));
+	}
 }
 
 static void prep_compound_page(struct page *page, unsigned long order)
@@ -1259,6 +1304,67 @@ try_next_zone:
 }
 
 /*
+ * Virtual Compound Page support.
+ *
+ * Virtual Compound Pages are used to fall back to order 0 allocations if large
+ * linear mappings are not available and __GFP_VFALLBACK is set. They are
+ * formatted according to compound page conventions. I.e. following
+ * page->first_page if PageTail(page) is set can be used to determine the
+ * head page.
+ */
+static noinline struct page *alloc_vcompound(gfp_t gfp_mask, int order,
+		struct zonelist *zonelist, unsigned long alloc_flags)
+{
+	struct page *page;
+	int i;
+	struct vm_struct *vm;
+	int nr_pages = 1 << order;
+	struct page **pages = kmalloc(nr_pages * sizeof(struct page *),
+						gfp_mask & GFP_LEVEL_MASK);
+	struct page **pages2;
+
+	if (!pages)
+		return NULL;
+
+	gfp_mask &= ~(__GFP_COMP | __GFP_VFALLBACK);
+	for (i = 0; i < nr_pages; i++) {
+		page = get_page_from_freelist(gfp_mask, 0, zonelist,
+							alloc_flags);
+		if (!page)
+			goto abort;
+
+		/* Sets PageCompound which makes PageHead(page) true */
+		__SetPageVcompound(page);
+		pages[i] = page;
+	}
+
+	vm = get_vm_area_node(nr_pages << PAGE_SHIFT, VM_MAP,
+			zone_to_nid(zonelist->zones[0]), gfp_mask);
+	pages2 = pages;
+	if (map_vm_area(vm, PAGE_KERNEL, &pages2))
+		goto abort;
+
+	prep_compound_page(pages[0], order);
+
+	for (i = 0; i < nr_pages; i++)
+		set_page_address(pages[0], vm->addr + (i << PAGE_SHIFT));
+
+	return pages[0];
+
+abort:
+	while (i-- > 0) {
+		page = pages[i];
+		if (!page)
+			continue;
+		set_page_address(page, NULL);
+		__ClearPageVcompound(page);
+		__free_page(page);
+	}
+	kfree(pages);
+	return NULL;
+}
+
+/*
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page * fastcall
@@ -1353,12 +1459,12 @@ nofail_alloc:
 				goto nofail_alloc;
 			}
 		}
-		goto nopage;
+		goto try_vcompound;
 	}
 
 	/* Atomic allocations - we can't balance anything */
 	if (!wait)
-		goto nopage;
+		goto try_vcompound;
 
 	cond_resched();
 
@@ -1389,6 +1495,11 @@ nofail_alloc:
 		 */
 		page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_HIGH|ALLOC_CPUSET);
+
+		if (!page && order && (gfp_mask & __GFP_VFALLBACK))
+			page = alloc_vcompound(gfp_mask, order,
+					zonelist, alloc_flags);
+
 		if (page)
 			goto got_pg;
 
@@ -1420,6 +1531,14 @@ nofail_alloc:
 		goto rebalance;
 	}
 
+try_vcompound:
+	/* Last chance before failing the allocation */
+	if (order && (gfp_mask & __GFP_VFALLBACK)) {
+		page = alloc_vcompound(gfp_mask, order,
+					zonelist, alloc_flags);
+		if (page)
+			goto got_pg;
+	}
 nopage:
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit()) {
 		printk(KERN_WARNING "%s: page allocation failure."
@@ -1480,6 +1599,9 @@ fastcall void __free_pages(struct page *
 		if (order == 0)
 			free_hot_page(page);
 		else
+		if (unlikely(PageHead(page)))
+			free_compound_page(page);
+		else
 			__free_pages_ok(page, order);
 	}
 }
@@ -1489,8 +1611,15 @@ EXPORT_SYMBOL(__free_pages);
 fastcall void free_pages(unsigned long addr, unsigned int order)
 {
 	if (addr != 0) {
-		VM_BUG_ON(!virt_addr_valid((void *)addr));
-		__free_pages(virt_to_page((void *)addr), order);
+		struct page *page;
+
+		if (unlikely(addr >= VMALLOC_START && addr < VMALLOC_END))
+			page = vmalloc_to_page((void *)addr);
+		else {
+			VM_BUG_ON(!virt_addr_valid(addr));
+			page  = virt_to_page(addr);
+		};
+		__free_pages(page, order);
 	}
 }
 
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2007-10-03 19:44:07.000000000 -0700
+++ linux-2.6/include/linux/gfp.h	2007-10-03 19:44:08.000000000 -0700
@@ -43,6 +43,7 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
+#define __GFP_VFALLBACK	((__force gfp_t)0x2000u)/* Permit fallback to vmalloc */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
@@ -86,6 +87,10 @@ struct vm_area_struct;
 #define GFP_THISNODE	((__force gfp_t)0)
 #endif
 
+/*
+ * Allocate large page but allow fallback to a virtually mapped page
+ */
+#define GFP_VFALLBACK	(GFP_KERNEL | __GFP_VFALLBACK)
 
 /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
    platforms, used as appropriate on others */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
