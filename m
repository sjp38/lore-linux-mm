Message-Id: <20080430044319.806574846@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:55 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [04/11] vcompound: Core piece for virtualizable compound page allocation
Content-Disposition: inline; filename=vcp_core
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add support functions to allow the creation and destruction of virtualizable
compound pages. A virtualizable compound page is either allocated as a compound
page (using physically contiguous memory) or as a virtualized compound page
(using virtually contiguous memory).

Virtualized compound pages are in many ways similar to regular compound pages

1. If PageTail(page) is true then page->first points to the first page.
   compound_head(page) works also for virtualized compound pages.

2. page[1].lru.next contains the order of the virtualized compound page.
   However, the page structs of virtual compound pages are not in order.
   So page[1] means the second page belonging to the virtual compound mapping
   which is not necessarily the page following the head page physically.

There is a special function:

	vcompound_head_page(address)

(similar to virt_to_head_page) that can be used to determine the head page
from a virtual address.

Freeing of virtualized compound pages is supported both from preemptible and
non preemptible context (freeing requires a preemptible context, we simply
defer free if we are not in a preemptible context).

However, allocation of virtualized compound pages must at this stage be done
from preemptible contexts only.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/vmalloc.h |   19 +++
 mm/vmalloc.c            |  238 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 257 insertions(+)

Index: linux-2.6/include/linux/vmalloc.h
===================================================================
--- linux-2.6.orig/include/linux/vmalloc.h	2008-04-29 20:23:50.016939945 -0700
+++ linux-2.6/include/linux/vmalloc.h	2008-04-29 20:23:50.685509617 -0700
@@ -86,6 +86,25 @@ extern struct vm_struct *alloc_vm_area(s
 extern void free_vm_area(struct vm_struct *area);
 
 /*
+ * Support for virtualizable compound pages.
+ *
+ * Calls to vcompound_alloc will result in the allocation of normal compound
+ * pages unless memory is fragmented.  If insufficient physical linear memory
+ * is available then a virtual contiguous area of memory will be created
+ * using the vmalloc functionality to allocate a virtualized compound page.
+ */
+struct page *alloc_vcompound_node(int node, gfp_t flags, int order);
+static inline struct page *alloc_vcompound(gfp_t flags, int order)
+{
+	return alloc_vcompound_node(-1, flags, order);
+};
+
+void free_vcompound(struct page *);
+void *__alloc_vcompound(gfp_t flags, int order);
+void __free_vcompound(void *addr);
+struct page *vcompound_head_page(const void *x);
+
+/*
  *	Internals.  Dont't use..
  */
 extern rwlock_t vmlist_lock;
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2008-04-29 20:23:50.016939945 -0700
+++ linux-2.6/mm/vmalloc.c	2008-04-29 21:27:32.237026026 -0700
@@ -986,3 +986,241 @@ const struct seq_operations vmalloc_op =
 };
 #endif
 
+/*
+ * Virtualized Compound Pages are used to fall back to order 0 allocations if
+ * large linear mappings are not available. A virtualized compound page is
+ * provided using a series of order 0 allocations that have been stringed
+ * together using vmap().
+ *
+ * Virtualized Compound Pages are formatted according to compound page
+ * conventions. I.e. following page->first_page (if PageTail(page) is set)
+ * can be used to determine the head page.
+ *
+ * The order of the allocation is stored in page[1].lru.next. However, the
+ * pages are not in sequence. In order to determine the second page the
+ * vmstruct structure needs to be located. Then the page array can be
+ * used to find the remaining pages.
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
+EXPORT_SYMBOL(vcompound_head_page);
+
+static void __vcompound_free(void *addr)
+{
+
+	struct page **pages;
+	int i;
+	int order;
+	struct page *head;
+
+	pages = vunmap(addr);
+	order = (unsigned long)pages[1]->lru.prev;
+
+	/*
+	 * The first page will have zero refcount since it maintains state
+	 * for the virtualized compound.
+	 */
+	head = pages[0];
+	set_page_address(head, NULL);
+	__ClearPageVcompound(head);
+	__ClearPageHead(head);
+	free_hot_page(head);
+
+	for (i = 1; i < (1 << order); i++) {
+		struct page *page = pages[i];
+
+		BUG_ON(!PageTail(page));
+		set_page_address(page, NULL);
+		__ClearPageTail(page);
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
+EXPORT_SYMBOL(__free_vcompound);
+
+void free_vcompound(struct page *page)
+{
+	if (unlikely(PageVcompound(page)))
+		vcompound_free(page_address(page), page);
+	else
+		__free_pages(page, compound_order(page));
+}
+EXPORT_SYMBOL(free_vcompound);
+
+static struct vm_struct *____alloc_vcompound(int node, gfp_t gfp_mask,
+					unsigned long order, void *caller)
+{
+	int i;
+	struct vm_struct *vm;
+	int nr_pages = 1 << order;
+	struct page **pages = kmalloc(nr_pages * sizeof(struct page *),
+						gfp_mask & GFP_RECLAIM_MASK);
+	struct page **pages2;
+	struct page *head;
+
+	BUG_ON(!order || order >= MAX_ORDER);
+	if (!pages)
+		return NULL;
+
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page;
+
+		if (node == -1)
+			page = alloc_page(gfp_mask);
+		else
+			page = alloc_pages_node(node, gfp_mask, 0);
+
+		if (!page)
+			goto abort;
+
+		pages[i] = page;
+	}
+
+	vm = __get_vm_area_node(nr_pages << PAGE_SHIFT, VM_VCOMPOUND,
+		VMALLOC_START, VMALLOC_END, node, gfp_mask, caller);
+
+	if (!vm)
+		goto abort;
+
+	vm->caller = caller;
+	vm->pages = pages;
+	vm->nr_pages = nr_pages;
+	pages2 = pages;
+	if (map_vm_area(vm, PAGE_KERNEL, &pages2))
+		goto abort;
+
+	/* Setup head page */
+	head = pages[0];
+	__SetPageHead(head);
+	__SetPageVcompound(head);
+	set_page_address(head, vm->addr);
+	pages[1]->lru.prev = (void *)order;
+
+	/* Setup tail pages */
+	for (i = 1; i < nr_pages; i++) {
+		struct page *page = pages[i];
+
+		__SetPageTail(page);
+		page->first_page = head;
+		set_page_address(page, vm->addr + (i << PAGE_SHIFT));
+	}
+	return vm;
+
+abort:
+	while (i-- > 0) {
+		struct page *page = pages[i];
+
+		if (!page)
+			continue;
+
+		set_page_address(page, NULL);
+		__ClearPageTail(page);
+		__ClearPageHead(page);
+		__ClearPageVcompound(page);
+		__free_page(page);
+	}
+	kfree(pages);
+	return NULL;
+}
+
+struct page *alloc_vcompound_node(int node, gfp_t flags, int order)
+{
+	struct vm_struct *vm;
+	struct page *page;
+	gfp_t alloc_flags = flags | __GFP_NORETRY | __GFP_NOWARN;
+
+	if (order)
+		alloc_flags |= __GFP_COMP;
+
+	if (node == -1) {
+		page = alloc_pages(alloc_flags, order);
+	} else
+		page = alloc_pages_node(node, alloc_flags, order);
+
+	if (page || !order)
+		return page;
+
+	vm = ____alloc_vcompound(node, flags, order, __builtin_return_address(0));
+	if (vm)
+		return vm->pages[0];
+
+	return NULL;
+}
+EXPORT_SYMBOL(alloc_vcompound);
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
+	vm = ____alloc_vcompound(-1, flags, order, __builtin_return_address(0));
+	if (vm)
+		return vm->addr;
+
+	return NULL;
+}
+EXPORT_SYMBOL(__alloc_vcompound);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
