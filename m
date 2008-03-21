Message-Id: <20080321061724.956843984@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:07 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [04/14] vcompound: Core piece
Content-Disposition: inline; filename=newcore
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add support functions to allow the creation and destruction of virtual compound
pages. Virtual compound pages are similar to compound pages in that if
PageTail(page) is true then page->first points to the first page.

	vcompound_head_page(address)

(similar to virt_to_head_page) can be used to determine the head page from an
address.

Another similarity to compound pages is that page[1].lru.next contains the
order of the virtual compound page. However, the page structs of virtual
compound pages are not in order. So page[1] means the second page belonging
to the virtual compound mapping which is not necessarily the page following
the head page.

Freeing of virtual compound pages is support both from preemptible and
non preemptible context (freeing requires a preemptible context, we simply
defer free if we are not in a preemptible context).

However, allocation of virtual compound pages must at this stage be done from
preemptible contexts only (there are patches to implement allocations from
atomic context but those are unecessary at this early stage).

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmalloc.h |   14 +++
 mm/vmalloc.c            |  197 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 211 insertions(+)

Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-20 23:03:14.600588151 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-20 23:03:14.612588010 -0700
@@ -86,6 +86,20 @@ extern struct vm_struct *alloc_vm_area(s
 extern void free_vm_area(struct vm_struct *area);
 
 /*
+ * Support for virtual compound pages.
+ *
+ * Calls to vcompound alloc will result in the allocation of normal compound
+ * pages unless memory is fragmented.  If insufficient physical linear memory
+ * is available then a virtually contiguous area of memory will be created
+ * using the vmalloc functionality.
+ */
+struct page *alloc_vcompound_alloc(gfp_t flags, int order);
+void free_vcompound(struct page *);
+void *__alloc_vcompound(gfp_t flags, int order);
+void __free_vcompound(void *addr);
+struct page *vcompound_head_page(const void *x);
+
+/*
  *	Internals.  Dont't use..
  */
 extern rwlock_t vmlist_lock;
Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-20 23:03:14.600588151 -0700
+++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-20 23:06:43.703428350 -0700
@@ -989,3 +989,200 @@ const struct seq_operations vmalloc_op =
 };
 #endif
 
+/*
+ * Virtual Compound Page support.
+ *
+ * Virtual Compound Pages are used to fall back to order 0 allocations if large
+ * linear mappings are not available. They are formatted according to compound
+ * page conventions. I.e. following page->first_page if PageTail(page) is set
+ * can be used to determine the head page.
+ */
+
+/*
+ * Determine the appropriate page struct given a virtual address
+ * (including vmalloced areas).
+ *
+ * Return the head page if this is a compound page.
+ *
+ * Cannot be inlined since VMALLOC_START and VMALLOC_END may contain
+ * complex calculations that depend on multiple arch includes or
+ * even variables.
+ */
+struct page *vcompound_head_page(const void *x)
+{
+	unsigned long addr = (unsigned long)x;
+	struct page *page;
+
+	if (unlikely(is_vmalloc_addr(x)))
+		page = vmalloc_to_page(x);
+	else
+		page = virt_to_page(addr);
+
+	return compound_head(page);
+}
+
+static void __vcompound_free(void *addr)
+{
+
+	struct page **pages;
+	int i;
+	int order;
+
+	pages = vunmap(addr);
+	order = (unsigned long)pages[1]->lru.prev;
+
+	/*
+	 * First page will have zero refcount since it maintains state
+	 * for the compound and was decremented before we got here.
+	 */
+	set_page_address(pages[0], NULL);
+	__ClearPageVcompound(pages[0]);
+	free_hot_page(pages[0]);
+
+	for (i = 1; i < (1 << order); i++) {
+		struct page *page = pages[i];
+		BUG_ON(!PageTail(page) || !PageVcompound(page));
+		set_page_address(page, NULL);
+		__ClearPageVcompound(page);
+		__free_page(page);
+	}
+	kfree(pages);
+}
+
+static void vcompound_free_work(struct work_struct *w)
+{
+	__vcompound_free((void *)w);
+}
+
+static void vcompound_free(void *addr, struct page *page)
+{
+	struct work_struct *w = addr;
+
+	BUG_ON((!PageVcompound(page) || !PageHead(page)));
+
+	if (!put_page_testzero(page))
+		return;
+
+	if (!preemptible()) {
+		/*
+		 * Need to defer the free until we are in
+		 * a preemptible context.
+		 */
+		INIT_WORK(w, vcompound_free_work);
+		schedule_work(w);
+	} else
+		__vcompound_free(addr);
+}
+
+
+void __free_vcompound(void *addr)
+{
+	struct page *page;
+
+	if (unlikely(is_vmalloc_addr(addr)))
+		vcompound_free(addr, vmalloc_to_page(addr));
+	else {
+		page = virt_to_page(addr);
+		free_pages((unsigned long)addr, compound_order(page));
+	}
+}
+
+void free_vcompound(struct page *page)
+{
+	if (unlikely(PageVcompound(page)))
+		vcompound_free(page_address(page), page);
+	else
+		__free_pages(page, compound_order(page));
+}
+
+static struct vm_struct *____alloc_vcompound(gfp_t gfp_mask, unsigned long order,
+								void *caller)
+{
+	struct page *page;
+	int i;
+	struct vm_struct *vm;
+	int nr_pages = 1 << order;
+	struct page **pages = kmalloc(nr_pages * sizeof(struct page *),
+						gfp_mask & GFP_RECLAIM_MASK);
+	struct page **pages2;
+
+	if (!pages)
+		return NULL;
+
+	for (i = 0; i < nr_pages; i++) {
+		page = alloc_page(gfp_mask);
+		if (!page)
+			goto abort;
+
+		/* Sets PageCompound which makes PageHead(page) true */
+		__SetPageVcompound(page);
+		pages[i] = page;
+	}
+
+	vm = __get_vm_area_node(nr_pages << PAGE_SHIFT, VM_VCOMPOUND,
+		VMALLOC_START, VMALLOC_END, -1, gfp_mask, caller);
+
+	if (!vm)
+		goto abort;
+
+	vm->caller = caller;
+	pages2 = pages;
+	if (map_vm_area(vm, PAGE_KERNEL, &pages2))
+		goto abort;
+
+	pages[1]->lru.prev = (void *)order;
+
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page = pages[i];
+
+		__SetPageTail(page);
+		page->first_page = pages[0];
+		set_page_address(page, vm->addr + (i << PAGE_SHIFT));
+	}
+	return vm;
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
+struct page *alloc_vcompound(gfp_t flags, int order)
+{
+	struct vm_struct *vm;
+	struct page *page;
+
+	page = alloc_pages(flags | __GFP_NORETRY | __GFP_NOWARN, order);
+	if (page || !order)
+		return page;
+
+	vm = ____alloc_vcompound(flags, order, __builtin_return_address(0));
+	if (vm)
+		return vm->pages[0];
+
+	return NULL;
+}
+
+void *__alloc_vcompound(gfp_t flags, int order)
+{
+	struct vm_struct *vm;
+	void *addr;
+
+	addr = (void *)__get_free_pages(flags | __GFP_NORETRY | __GFP_NOWARN,
+								order);
+	if (addr || !order)
+		return addr;
+
+	vm = ____alloc_vcompound(flags, order, __builtin_return_address(0));
+	if (vm)
+		return vm->addr;
+
+	return NULL;
+}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
