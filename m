Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81DFF6B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:02:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p10-v6so2895493lfc.19
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 06:02:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor1893566ljc.5.2018.06.15.06.01.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 06:01:57 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC] mm/vmalloc: keep track of free blocks for allocation
Date: Fri, 15 Jun 2018 15:01:43 +0200
Message-Id: <20180615130143.12957-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello,

please RFC.

Initial discussion was here: https://patchwork.kernel.org/patch/10244733/

Currently an allocation of the new VA area is done over
busy list iteration until a suitable hole is found between
two busy areas. Therefore each new allocation causes the
list being grown. Due to long list and different permissive
parameters an allocation can take a long time on embedded
devices(milliseconds).

This patch organizes the vmalloc memory layout into free
areas of the VMALLOC_START-VMALLOC_END range. It uses a
red-black tree that keeps blocks sorted by their offsets
in pair with linked list keeping the free space in order
of increasing addresses.

Allocation: to allocate a new block a search is done over
free list areas until a suitable block is large enough to
encompass the requested size. If the block is bigger than
requested size - it is split.

De-allocation: red-black tree allows efficiently find a
spot in the tree whereas a linked list allows fast merge
of de-allocated memory chunks with existing free blocks
creating large coalesced areas.

model name: QEMU Virtual CPU version 2.5+

test_1:
<measure this loop time>
for (n = 0; n < 1000000; n++) {
    void *ptr_1 = vmalloc(3 * PAGE_SIZE);
    *((__u8 *)ptr_1) = 0; /* Pretend we used the mem */
    vfree(ptr_1);
}
<measure this loop time>

938007(us) vs 939222(us) +0.129%
932760(us) vs 932565(us) -0.020%
929691(us) vs 935795(us) +0.652%
932767(us) vs 932683(us) -0.009%
937520(us) vs 935457(us) -0.220%

test_2:
for (n = 0; n < 15000; n++)
    ptr[n] = vmalloc(1 * PAGE_SIZE);

<measure this loop time>
for (n = 0; n < 1000000; n++) {
    void *ptr_1 = vmalloc(100 * PAGE_SIZE);
    void *ptr_2 = vmalloc(1 * PAGE_SIZE);
    *((__u8 *)ptr_1) = 0; /* Pretend we used the mem */
    *((__u8 *)ptr_2) = 1; /* Pretend we used the mem */

    vfree(ptr_1);
    vfree(ptr_2);
}
<measure this loop time>

33590880(us) vs 11027121(us) -67.172%
34503307(us) vs 11696023(us) -66.101%
44198667(us) vs 11849005(us) -73.191%
19377377(us) vs 12026349(us) -37.936%
29511186(us) vs 11757217(us) -60.160%

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 420 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 393 insertions(+), 27 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729cc956..2ab7ec93b199 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -332,6 +332,29 @@ LIST_HEAD(vmap_area_list);
 static LLIST_HEAD(vmap_purge_list);
 static struct rb_root vmap_area_root = RB_ROOT;
 
+/*
+ * This linked list is used in pair with free_vmap_area_root.
+ * It makes it possible of fast accessing to next/prev nodes
+ * to perform coalescing.
+ */
+static LIST_HEAD(free_vmap_area_list);
+
+/*
+ * This red-black tree is used for storing address-sorted
+ * vmap areas during free operation. Sorting is done using
+ * va_start address. We make use of it to merge a VA with
+ * its prev/next neighbors.
+ */
+static struct rb_root free_vmap_area_root = RB_ROOT;
+
+/*
+ * For vmalloc specific area allocation.
+ */
+static struct vmap_area *last_free_va_chunk;
+static unsigned long last_alloc_vstart;
+static unsigned long last_alloc_align;
+static unsigned long free_va_max_size;
+
 /* The vmap cache globals are protected by vmap_area_lock */
 static struct rb_node *free_vmap_cache;
 static unsigned long cached_hole_size;
@@ -359,27 +382,53 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
 	return NULL;
 }
 
-static void __insert_vmap_area(struct vmap_area *va)
+static inline void __find_va_slot(struct vmap_area *va,
+	struct rb_root *root, struct rb_node **parent, struct rb_node ***link)
 {
-	struct rb_node **p = &vmap_area_root.rb_node;
-	struct rb_node *parent = NULL;
-	struct rb_node *tmp;
+	*link = &root->rb_node;
+	*parent = NULL;
 
-	while (*p) {
+	while (**link) {
 		struct vmap_area *tmp_va;
 
-		parent = *p;
-		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
+		*parent = **link;
+		tmp_va = rb_entry(*parent, struct vmap_area, rb_node);
 		if (va->va_start < tmp_va->va_end)
-			p = &(*p)->rb_left;
+			*link = &(**link)->rb_left;
 		else if (va->va_end > tmp_va->va_start)
-			p = &(*p)->rb_right;
+			*link = &(**link)->rb_right;
 		else
 			BUG();
 	}
+}
+
+static inline void __find_va_siblings(struct rb_node *p_rb_node,
+	struct rb_node **p_rb_link, struct list_head **next, struct list_head **prev)
+{
+	struct list_head *p_list_head;
+
+	if (likely(p_rb_node)) {
+		p_list_head = &rb_entry(p_rb_node, struct vmap_area, rb_node)->list;
+		if (&p_rb_node->rb_right == p_rb_link) {
+			*next = p_list_head->next;
+			*prev = p_list_head;
+		} else {
+			*prev = p_list_head->prev;
+			*next = p_list_head;
+		}
+	} else {
+		/* Suppose it may ever happen. */
+		*next = *prev = &free_vmap_area_list;
+	}
+}
 
-	rb_link_node(&va->rb_node, parent, p);
-	rb_insert_color(&va->rb_node, &vmap_area_root);
+static inline void __link_va(struct vmap_area *va, struct rb_root *root,
+	struct rb_node *parent, struct rb_node **p_link, struct list_head *head)
+{
+	struct rb_node *tmp;
+
+	rb_link_node(&va->rb_node, parent, p_link);
+	rb_insert_color(&va->rb_node, root);
 
 	/* address-sort this list */
 	tmp = rb_prev(&va->rb_node);
@@ -388,13 +437,239 @@ static void __insert_vmap_area(struct vmap_area *va)
 		prev = rb_entry(tmp, struct vmap_area, rb_node);
 		list_add_rcu(&va->list, &prev->list);
 	} else
-		list_add_rcu(&va->list, &vmap_area_list);
+		list_add_rcu(&va->list, head);
+}
+
+static void __insert_vmap_area(struct vmap_area *va,
+		struct rb_root *root, struct list_head *head)
+{
+	struct rb_node **p_link;
+	struct rb_node *parent;
+
+	__find_va_slot(va, root, &parent, &p_link);
+	__link_va(va, root, parent, p_link, head);
 }
 
 static void purge_vmap_area_lazy(void);
 
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 
+static inline unsigned long
+__va_size(struct vmap_area *va)
+{
+	return va->va_end - va->va_start;
+}
+
+static inline void
+__remove_free_va_area(struct vmap_area *va)
+{
+	/*
+	 * Remove VA from the address-sorted tree/list.
+	 * Do check if its rb_node is empty or not, since
+	 * we use this function as common interface to
+	 * destroy a vmap_area.
+	 */
+	if (!RB_EMPTY_NODE(&va->rb_node)) {
+		rb_erase(&va->rb_node, &free_vmap_area_root);
+		list_del_rcu(&va->list);
+	}
+
+	/*
+	 * Lazy free.
+	 */
+	kfree_rcu(va, rcu_head);
+}
+
+/*
+ * Merge de-allocated chunk of VA memory with previous
+ * and next free blocks. Either a pointer to the new
+ * merged area is returned if coalesce is done or VA
+ * area if inserting is done.
+ */
+static inline struct vmap_area *
+__merge_add_free_va_area(struct vmap_area *va,
+	struct rb_root *root, struct list_head *head)
+{
+	struct vmap_area *sibling;
+	struct list_head *next, *prev;
+	struct rb_node **p_link;
+	struct rb_node *parent;
+	bool merged = false;
+
+	/*
+	 * Find a place in the tree where VA potentially will be
+	 * inserted, unless it is merged with its sibling/siblings.
+	 */
+	__find_va_slot(va, root, &parent, &p_link);
+
+	/*
+	 * Get next/prev nodes of VA to check if merging can be done.
+	 */
+	__find_va_siblings(parent, p_link, &next, &prev);
+
+	/*
+	 * start            end
+	 * |                |
+	 * |<------VA------>|<-----Next----->|
+	 *                  |                |
+	 *                  start            end
+	 */
+	if (next != head) {
+		sibling = list_entry(next, struct vmap_area, list);
+		if (sibling->va_start == va->va_end) {
+			sibling->va_start = va->va_start;
+			__remove_free_va_area(va);
+
+			/* Point to the new merged area. */
+			va = sibling;
+			merged = true;
+		}
+	}
+
+	/*
+	 * start            end
+	 * |                |
+	 * |<-----Prev----->|<------VA------>|
+	 *                  |                |
+	 *                  start            end
+	 */
+	if (prev != head) {
+		sibling = list_entry(prev, struct vmap_area, list);
+		if (sibling->va_end == va->va_start) {
+			sibling->va_end = va->va_end;
+			__remove_free_va_area(va);
+
+			/* Point to the new merged area. */
+			va = sibling;
+			merged = true;
+		}
+	}
+
+	if (!merged)
+		__link_va(va, root, parent, p_link, head);
+
+	return va;
+}
+
+static inline unsigned long
+alloc_vmalloc_area(unsigned long size, unsigned long align,
+		unsigned long vstart, unsigned long vend,
+		int node, gfp_t gfp_mask)
+{
+	struct vmap_area *b_fit = NULL;  /* best fit */
+	struct vmap_area *le_fit = NULL; /* left-edge fit */
+	struct vmap_area *re_fit = NULL; /* right-edge fit */
+	struct vmap_area *ne_fit = NULL; /* no edge fit */
+	struct vmap_area *va = last_free_va_chunk;
+	unsigned long nva_start_addr;
+
+	if (!last_free_va_chunk || size <= free_va_max_size ||
+			vstart < last_alloc_vstart || align < last_alloc_align) {
+		va = list_first_entry(&free_vmap_area_list, struct vmap_area, list);
+		free_va_max_size = 0;
+		last_free_va_chunk = NULL;
+	}
+
+	nva_start_addr = ALIGN(vstart, align);
+	list_for_each_entry_from(va, &free_vmap_area_list, list) {
+		if (va->va_start > vstart)
+			nva_start_addr = ALIGN(va->va_start, align);
+
+		/* VA does not fit to requested parameters. */
+		if (nva_start_addr + size > va->va_end) {
+			free_va_max_size = max(free_va_max_size, __va_size(va));
+			continue;
+		}
+
+		/* Nothing has been found, give up. */
+		if (nva_start_addr + size > vend)
+			break;
+
+		/* Classify what we have found. */
+		if (va->va_start == nva_start_addr) {
+			if (va->va_end == nva_start_addr + size)
+				b_fit = va;
+			le_fit = va;
+		} else if (va->va_end == nva_start_addr + size) {
+			re_fit = va;
+		} else {
+			ne_fit = va;
+		}
+
+		last_free_va_chunk = va;
+		last_alloc_vstart = vstart;
+		last_alloc_align = align;
+		break;
+	}
+
+	if (b_fit) {
+		/*
+		 * No need to split VA, it fully fits.
+		 *
+		 * |               |
+		 * V      NVA      V
+		 * |---------------|
+		 */
+		if (b_fit->list.prev != &free_vmap_area_list)
+			last_free_va_chunk = list_prev_entry(b_fit, list);
+		else
+			last_free_va_chunk = NULL;
+
+		__remove_free_va_area(b_fit);
+	} else if (le_fit) {
+		/*
+		 * Split left edge fit VA.
+		 *
+		 * |       |
+		 * V  NVA  V
+		 * |-------|-------|
+		 */
+		le_fit->va_start += size;
+	} else if (re_fit) {
+		/*
+		 * Split right edge fit VA.
+		 *
+		 *         |       |
+		 *         V  NVA  V
+		 * |-------|-------|
+		 */
+		re_fit->va_end = nva_start_addr;
+	} else if (ne_fit) {
+		/*
+		 * Split no edge fit VA.
+		 *
+		 *     |       |
+		 *     V  NVA  V
+		 * |---|-------|---|
+		 */
+		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+		if (unlikely(!va))
+			return VMALLOC_END;
+
+		/*
+		 * Build right area of VA.
+		 */
+		va->va_start = nva_start_addr + size;
+		va->va_end = ne_fit->va_end;
+
+		/*
+		 * Build left area of VA.
+		 */
+		ne_fit->va_end = nva_start_addr;
+
+		/*
+		 * Add newly built right area to the address sorted list.
+		 */
+		__insert_vmap_area(va,
+			&free_vmap_area_root, &free_vmap_area_list);
+	} else {
+		/* Not found. */
+		nva_start_addr = VMALLOC_END;
+	}
+
+	return nva_start_addr;
+}
+
 /*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
@@ -409,6 +684,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	unsigned long addr;
 	int purged = 0;
 	struct vmap_area *first;
+	bool is_vmalloc_allocation;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
@@ -426,9 +702,22 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * to avoid false negatives.
 	 */
 	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
+	is_vmalloc_allocation = is_vmalloc_addr((void *)vstart);
 
 retry:
 	spin_lock(&vmap_area_lock);
+	if (is_vmalloc_allocation) {
+		addr = alloc_vmalloc_area(size, align,
+					vstart, vend, node, gfp_mask);
+
+		/*
+		 * If an allocation fails, the VMALLOC_END address is
+		 * returned. Therefore, an overflow path will be triggered
+		 * below.
+		 */
+		goto found;
+	}
+
 	/*
 	 * Invalidate cache if we have more permissive parameters.
 	 * cached_hole_size notes the largest hole noticed _below_
@@ -504,8 +793,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	va->va_start = addr;
 	va->va_end = addr + size;
 	va->flags = 0;
-	__insert_vmap_area(va);
-	free_vmap_cache = &va->rb_node;
+	__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+
+	if (!is_vmalloc_allocation)
+		free_vmap_cache = &va->rb_node;
+
 	spin_unlock(&vmap_area_lock);
 
 	BUG_ON(!IS_ALIGNED(va->va_start, align));
@@ -552,9 +844,14 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
+	unsigned long last_free_va_start = 0;
+	bool is_vmalloc_area;
+
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
+	is_vmalloc_area = (va->va_end > VMALLOC_START &&
+			va->va_end <= VMALLOC_END);
 
-	if (free_vmap_cache) {
+	if (!is_vmalloc_area && free_vmap_cache) {
 		if (va->va_end < cached_vstart) {
 			free_vmap_cache = NULL;
 		} else {
@@ -573,16 +870,39 @@ static void __free_vmap_area(struct vmap_area *va)
 	RB_CLEAR_NODE(&va->rb_node);
 	list_del_rcu(&va->list);
 
-	/*
-	 * Track the highest possible candidate for pcpu area
-	 * allocation.  Areas outside of vmalloc area can be returned
-	 * here too, consider only end addresses which fall inside
-	 * vmalloc area proper.
-	 */
-	if (va->va_end > VMALLOC_START && va->va_end <= VMALLOC_END)
+	if (is_vmalloc_area) {
+		/*
+		 * Track the highest possible candidate for pcpu area
+		 * allocation.  Areas outside of vmalloc area can be returned
+		 * here too, consider only end addresses which fall inside
+		 * vmalloc area proper.
+		 */
 		vmap_area_pcpu_hole = max(vmap_area_pcpu_hole, va->va_end);
 
-	kfree_rcu(va, rcu_head);
+		if (last_free_va_chunk)
+			last_free_va_start = last_free_va_chunk->va_start;
+
+		/*
+		 * Merge VA with its neighbors, otherwise add it.
+		 */
+		va = __merge_add_free_va_area(va,
+			&free_vmap_area_root, &free_vmap_area_list);
+
+		/*
+		 * Update a search criteria if merging/inserting is
+		 * done before last_free_va_chunk va_start address.
+		 */
+		if (last_free_va_start) {
+			if (va->va_start <= last_free_va_start) {
+				if (va->list.prev != &free_vmap_area_list)
+					last_free_va_chunk = list_prev_entry(va, list);
+				else
+					last_free_va_chunk = NULL;
+			}
+		}
+	} else {
+		kfree_rcu(va, rcu_head);
+	}
 }
 
 /*
@@ -1253,7 +1573,7 @@ void __init vm_area_register_early(struct vm_struct *vm, size_t align)
 
 void __init vmalloc_init(void)
 {
-	struct vmap_area *va;
+	struct vmap_area *va, *prev_va;
 	struct vm_struct *tmp;
 	int i;
 
@@ -1269,16 +1589,62 @@ void __init vmalloc_init(void)
 		INIT_WORK(&p->wq, free_work);
 	}
 
+	/*
+	 * Build free areas.
+	 */
+	va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+	va->va_start = (unsigned long) VMALLOC_START;
+
+	if (!vmlist)
+		va->va_end = (unsigned long) VMALLOC_END;
+	else
+		va->va_end = (unsigned long) vmlist->addr;
+
+	__insert_vmap_area(va,
+		&free_vmap_area_root, &free_vmap_area_list);
+
+	if (!vmlist)
+		goto build_free_area_done;
+
 	/* Import existing vmlist entries. */
-	for (tmp = vmlist; tmp; tmp = tmp->next) {
+	for (tmp = vmlist, prev_va = NULL; tmp; tmp = tmp->next) {
+		struct vmap_area *free_area;
+
 		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
 		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
-		__insert_vmap_area(va);
+		__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+
+		/*
+		 * Check if there is a padding between previous/current.
+		 */
+		if (prev_va && (va->va_start - prev_va->va_end) > 0) {
+			free_area = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+			free_area->va_start = prev_va->va_end;
+			free_area->va_end = va->va_start;
+
+			__insert_vmap_area(free_area,
+				&free_vmap_area_root, &free_vmap_area_list);
+		}
+
+		/*
+		 * Handle last case building the remaining space.
+		 */
+		if (!tmp->next) {
+			free_area = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+			free_area->va_start = va->va_end;
+			free_area->va_end = (unsigned long) VMALLOC_END;
+
+			__insert_vmap_area(free_area,
+				&free_vmap_area_root, &free_vmap_area_list);
+		}
+
+		prev_va = va;
 	}
 
+build_free_area_done:
 	vmap_area_pcpu_hole = VMALLOC_END;
 
 	vmap_initialized = true;
@@ -2604,7 +2970,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 
 		va->va_start = base + offsets[area];
 		va->va_end = va->va_start + sizes[area];
-		__insert_vmap_area(va);
+		__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 	}
 
 	vmap_area_pcpu_hole = base + offsets[last_area];
-- 
2.11.0
