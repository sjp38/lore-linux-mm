Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D41D280280
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:05 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q1so12202734pgv.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y12si1607836pgq.380.2018.01.17.12.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:03 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 78/99] sh: intc: Convert to XArray
Date: Wed, 17 Jan 2018 12:21:42 -0800
Message-Id: <20180117202203.19756-79-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The radix tree was being protected by a raw spinlock.  I believe that
was not necessary, and the new internal regular spinlock will be
adequate for this array.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 drivers/sh/intc/core.c      |  9 ++----
 drivers/sh/intc/internals.h |  5 ++--
 drivers/sh/intc/virq.c      | 72 +++++++++++++--------------------------------
 3 files changed, 25 insertions(+), 61 deletions(-)

diff --git a/drivers/sh/intc/core.c b/drivers/sh/intc/core.c
index 8e72bcbd3d6d..356a423d9dcb 100644
--- a/drivers/sh/intc/core.c
+++ b/drivers/sh/intc/core.c
@@ -30,7 +30,6 @@
 #include <linux/syscore_ops.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
-#include <linux/radix-tree.h>
 #include <linux/export.h>
 #include <linux/sort.h>
 #include "internals.h"
@@ -78,11 +77,8 @@ static void __init intc_register_irq(struct intc_desc *desc,
 	struct intc_handle_int *hp;
 	struct irq_data *irq_data;
 	unsigned int data[2], primary;
-	unsigned long flags;
 
-	raw_spin_lock_irqsave(&intc_big_lock, flags);
-	radix_tree_insert(&d->tree, enum_id, intc_irq_xlate_get(irq));
-	raw_spin_unlock_irqrestore(&intc_big_lock, flags);
+	xa_store(&d->array, enum_id, intc_irq_xlate_get(irq), GFP_ATOMIC);
 
 	/*
 	 * Prefer single interrupt source bitmap over other combinations:
@@ -196,8 +192,7 @@ int __init register_intc_controller(struct intc_desc *desc)
 	INIT_LIST_HEAD(&d->list);
 	list_add_tail(&d->list, &intc_list);
 
-	raw_spin_lock_init(&d->lock);
-	INIT_RADIX_TREE(&d->tree, GFP_ATOMIC);
+	xa_init(&d->array);
 
 	d->index = nr_intc_controllers;
 
diff --git a/drivers/sh/intc/internals.h b/drivers/sh/intc/internals.h
index fa73c173b56a..9b6fd07e99a6 100644
--- a/drivers/sh/intc/internals.h
+++ b/drivers/sh/intc/internals.h
@@ -5,7 +5,7 @@
 #include <linux/list.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 #include <linux/device.h>
 
 #define _INTC_MK(fn, mode, addr_e, addr_d, width, shift) \
@@ -54,8 +54,7 @@ struct intc_subgroup_entry {
 struct intc_desc_int {
 	struct list_head list;
 	struct device dev;
-	struct radix_tree_root tree;
-	raw_spinlock_t lock;
+	struct xarray array;
 	unsigned int index;
 	unsigned long *reg;
 #ifdef CONFIG_SMP
diff --git a/drivers/sh/intc/virq.c b/drivers/sh/intc/virq.c
index a638c3048207..801c9c8b7556 100644
--- a/drivers/sh/intc/virq.c
+++ b/drivers/sh/intc/virq.c
@@ -12,7 +12,6 @@
 #include <linux/slab.h>
 #include <linux/irq.h>
 #include <linux/list.h>
-#include <linux/radix-tree.h>
 #include <linux/spinlock.h>
 #include <linux/export.h>
 #include "internals.h"
@@ -27,10 +26,7 @@ struct intc_virq_list {
 #define for_each_virq(entry, head) \
 	for (entry = head; entry; entry = entry->next)
 
-/*
- * Tags for the radix tree
- */
-#define INTC_TAG_VIRQ_NEEDS_ALLOC	0
+#define INTC_TAG_VIRQ_NEEDS_ALLOC	XA_TAG_0
 
 void intc_irq_xlate_set(unsigned int irq, intc_enum id, struct intc_desc_int *d)
 {
@@ -54,23 +50,18 @@ int intc_irq_lookup(const char *chipname, intc_enum enum_id)
 	int irq = -1;
 
 	list_for_each_entry(d, &intc_list, list) {
-		int tagged;
-
 		if (strcmp(d->chip.name, chipname) != 0)
 			continue;
 
 		/*
 		 * Catch early lookups for subgroup VIRQs that have not
-		 * yet been allocated an IRQ. This already includes a
-		 * fast-path out if the tree is untagged, so there is no
-		 * need to explicitly test the root tree.
+		 * yet been allocated an IRQ.
 		 */
-		tagged = radix_tree_tag_get(&d->tree, enum_id,
-					    INTC_TAG_VIRQ_NEEDS_ALLOC);
-		if (unlikely(tagged))
+		if (unlikely(xa_get_tag(&d->array, enum_id,
+						INTC_TAG_VIRQ_NEEDS_ALLOC)))
 			break;
 
-		ptr = radix_tree_lookup(&d->tree, enum_id);
+		ptr = xa_load(&d->array, enum_id);
 		if (ptr) {
 			irq = ptr - intc_irq_xlate;
 			break;
@@ -148,22 +139,16 @@ static void __init intc_subgroup_init_one(struct intc_desc *desc,
 {
 	struct intc_map_entry *mapped;
 	unsigned int pirq;
-	unsigned long flags;
 	int i;
 
-	mapped = radix_tree_lookup(&d->tree, subgroup->parent_id);
-	if (!mapped) {
-		WARN_ON(1);
+	mapped = xa_load(&d->array, subgroup->parent_id);
+	if (WARN_ON(!mapped))
 		return;
-	}
 
 	pirq = mapped - intc_irq_xlate;
 
-	raw_spin_lock_irqsave(&d->lock, flags);
-
 	for (i = 0; i < ARRAY_SIZE(subgroup->enum_ids); i++) {
 		struct intc_subgroup_entry *entry;
-		int err;
 
 		if (!subgroup->enum_ids[i])
 			continue;
@@ -176,15 +161,14 @@ static void __init intc_subgroup_init_one(struct intc_desc *desc,
 		entry->enum_id = subgroup->enum_ids[i];
 		entry->handle = intc_subgroup_data(subgroup, d, i);
 
-		err = radix_tree_insert(&d->tree, entry->enum_id, entry);
-		if (unlikely(err < 0))
+		if (xa_err(xa_store(&d->array, entry->enum_id, entry,
+						GFP_NOWAIT))) {
+			kfree(entry);
 			break;
-
-		radix_tree_tag_set(&d->tree, entry->enum_id,
+		}
+		xa_set_tag(&d->array, entry->enum_id,
 				   INTC_TAG_VIRQ_NEEDS_ALLOC);
 	}
-
-	raw_spin_unlock_irqrestore(&d->lock, flags);
 }
 
 void __init intc_subgroup_init(struct intc_desc *desc, struct intc_desc_int *d)
@@ -201,28 +185,16 @@ void __init intc_subgroup_init(struct intc_desc *desc, struct intc_desc_int *d)
 static void __init intc_subgroup_map(struct intc_desc_int *d)
 {
 	struct intc_subgroup_entry *entries[32];
-	unsigned long flags;
 	unsigned int nr_found;
 	int i;
 
-	raw_spin_lock_irqsave(&d->lock, flags);
-
-restart:
-	nr_found = radix_tree_gang_lookup_tag_slot(&d->tree,
-			(void ***)entries, 0, ARRAY_SIZE(entries),
-			INTC_TAG_VIRQ_NEEDS_ALLOC);
+	nr_found = xa_extract(&d->array, (void **)entries, 0, ULONG_MAX,
+			ARRAY_SIZE(entries), INTC_TAG_VIRQ_NEEDS_ALLOC);
 
 	for (i = 0; i < nr_found; i++) {
-		struct intc_subgroup_entry *entry;
-		int irq;
+		struct intc_subgroup_entry *entry = entries[i];
+		int irq = irq_alloc_desc(numa_node_id());
 
-		entry = radix_tree_deref_slot((void **)entries[i]);
-		if (unlikely(!entry))
-			continue;
-		if (radix_tree_deref_retry(entry))
-			goto restart;
-
-		irq = irq_alloc_desc(numa_node_id());
 		if (unlikely(irq < 0)) {
 			pr_err("no more free IRQs, bailing..\n");
 			break;
@@ -250,13 +222,11 @@ static void __init intc_subgroup_map(struct intc_desc_int *d)
 		add_virq_to_pirq(entry->pirq, irq);
 		irq_set_chained_handler(entry->pirq, intc_virq_handler);
 
-		radix_tree_tag_clear(&d->tree, entry->enum_id,
-				     INTC_TAG_VIRQ_NEEDS_ALLOC);
-		radix_tree_replace_slot(&d->tree, (void **)entries[i],
-					&intc_irq_xlate[irq]);
+		xa_store(&d->array, entry->enum_id, &intc_irq_xlate[irq],
+				GFP_NOWAIT);
+		xa_clear_tag(&d->array, entry->enum_id,
+				INTC_TAG_VIRQ_NEEDS_ALLOC);
 	}
-
-	raw_spin_unlock_irqrestore(&d->lock, flags);
 }
 
 void __init intc_finalize(void)
@@ -264,6 +234,6 @@ void __init intc_finalize(void)
 	struct intc_desc_int *d;
 
 	list_for_each_entry(d, &intc_list, list)
-		if (radix_tree_tagged(&d->tree, INTC_TAG_VIRQ_NEEDS_ALLOC))
+		if (xa_tagged(&d->array, INTC_TAG_VIRQ_NEEDS_ALLOC))
 			intc_subgroup_map(d);
 }
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
