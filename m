Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 430316B026A
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:38 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y200so16437432itc.7
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 67si5278054ioc.178.2017.12.15.14.05.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:36 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 77/78] irqdomain: Convert to XArray
Date: Fri, 15 Dec 2017 14:04:49 -0800
Message-Id: <20171215220450.7899-78-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

In a non-critical path, irqdomain wants to know how many entries are
stored in the xarray, so add xa_count().  This is a pretty straightforward
conversion; mostly just removing now-redundant locking.  The only thing
of note is just how much simpler irq_domain_fix_revmap() becomes.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/irqdomain.h | 10 ++++------
 include/linux/xarray.h    |  1 +
 kernel/irq/irqdomain.c    | 39 ++++++++++-----------------------------
 lib/xarray.c              | 25 +++++++++++++++++++++++++
 4 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/include/linux/irqdomain.h b/include/linux/irqdomain.h
index a34355d19546..0efccfb9e9f1 100644
--- a/include/linux/irqdomain.h
+++ b/include/linux/irqdomain.h
@@ -33,8 +33,7 @@
 #include <linux/types.h>
 #include <linux/irqhandler.h>
 #include <linux/of.h>
-#include <linux/mutex.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 
 struct device_node;
 struct irq_domain;
@@ -151,7 +150,7 @@ struct irq_domain_chip_generic;
  * @revmap_direct_max_irq: The largest hwirq that can be set for controllers that
  *                         support direct mapping
  * @revmap_size: Size of the linear map table @linear_revmap[]
- * @revmap_tree: Radix map tree for hwirqs that don't fit in the linear map
+ * @revmap_array: hwirqs that don't fit in the linear map
  * @linear_revmap: Linear table of hwirq->virq reverse mappings
  */
 struct irq_domain {
@@ -177,8 +176,7 @@ struct irq_domain {
 	irq_hw_number_t hwirq_max;
 	unsigned int revmap_direct_max_irq;
 	unsigned int revmap_size;
-	struct radix_tree_root revmap_tree;
-	struct mutex revmap_tree_mutex;
+	struct xarray revmap_array;
 	unsigned int linear_revmap[];
 };
 
@@ -378,7 +376,7 @@ extern void irq_dispose_mapping(unsigned int virq);
  * This is a fast path alternative to irq_find_mapping() that can be
  * called directly by irq controller code to save a handful of
  * instructions. It is always safe to call, but won't find irqs mapped
- * using the radix tree.
+ * using the xarray.
  */
 static inline unsigned int irq_linear_revmap(struct irq_domain *domain,
 					     irq_hw_number_t hwirq)
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index eba544f26b70..6af8b30a9310 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -145,6 +145,7 @@ int xa_get_entries(struct xarray *, void **dst, unsigned long start,
 			unsigned long max, unsigned int n);
 int xa_get_tagged(struct xarray *, void **dst, unsigned long start,
 			unsigned long max, unsigned int n, xa_tag_t);
+unsigned long xa_count(struct xarray *);
 
 /**
  * xa_get_maybe_tag() - Copy entries from the XArray into a normal array.
diff --git a/kernel/irq/irqdomain.c b/kernel/irq/irqdomain.c
index 4f4f60015e8a..8225fe042f8a 100644
--- a/kernel/irq/irqdomain.c
+++ b/kernel/irq/irqdomain.c
@@ -114,7 +114,7 @@ EXPORT_SYMBOL_GPL(irq_domain_free_fwnode);
 /**
  * __irq_domain_add() - Allocate a new irq_domain data structure
  * @fwnode: firmware node for the interrupt controller
- * @size: Size of linear map; 0 for radix mapping only
+ * @size: Size of linear map; 0 for xarray mapping only
  * @hwirq_max: Maximum number of interrupts supported by controller
  * @direct_max: Maximum value of direct maps; Use ~0 for no limit; 0 for no
  *              direct mapping
@@ -209,8 +209,7 @@ struct irq_domain *__irq_domain_add(struct fwnode_handle *fwnode, int size,
 	of_node_get(of_node);
 
 	/* Fill structure */
-	INIT_RADIX_TREE(&domain->revmap_tree, GFP_KERNEL);
-	mutex_init(&domain->revmap_tree_mutex);
+	xa_init(&domain->revmap_array);
 	domain->ops = ops;
 	domain->host_data = host_data;
 	domain->hwirq_max = hwirq_max;
@@ -241,7 +240,7 @@ void irq_domain_remove(struct irq_domain *domain)
 	mutex_lock(&irq_domain_mutex);
 	debugfs_remove_domain_dir(domain);
 
-	WARN_ON(!radix_tree_empty(&domain->revmap_tree));
+	WARN_ON(!xa_empty(&domain->revmap_array));
 
 	list_del(&domain->link);
 
@@ -462,9 +461,7 @@ static void irq_domain_clear_mapping(struct irq_domain *domain,
 	if (hwirq < domain->revmap_size) {
 		domain->linear_revmap[hwirq] = 0;
 	} else {
-		mutex_lock(&domain->revmap_tree_mutex);
-		radix_tree_delete(&domain->revmap_tree, hwirq);
-		mutex_unlock(&domain->revmap_tree_mutex);
+		xa_erase(&domain->revmap_array, hwirq);
 	}
 }
 
@@ -475,9 +472,7 @@ static void irq_domain_set_mapping(struct irq_domain *domain,
 	if (hwirq < domain->revmap_size) {
 		domain->linear_revmap[hwirq] = irq_data->irq;
 	} else {
-		mutex_lock(&domain->revmap_tree_mutex);
-		radix_tree_insert(&domain->revmap_tree, hwirq, irq_data);
-		mutex_unlock(&domain->revmap_tree_mutex);
+		xa_store(&domain->revmap_array, hwirq, irq_data, GFP_KERNEL);
 	}
 }
 
@@ -585,7 +580,7 @@ EXPORT_SYMBOL_GPL(irq_domain_associate_many);
  * This routine is used for irq controllers which can choose the hardware
  * interrupt numbers they generate. In such a case it's simplest to use
  * the linux irq as the hardware interrupt number. It still uses the linear
- * or radix tree to store the mapping, but the irq controller can optimize
+ * or xarray to store the mapping, but the irq controller can optimize
  * the revmap path by using the hwirq directly.
  */
 unsigned int irq_create_direct_mapping(struct irq_domain *domain)
@@ -890,9 +885,7 @@ unsigned int irq_find_mapping(struct irq_domain *domain,
 	if (hwirq < domain->revmap_size)
 		return domain->linear_revmap[hwirq];
 
-	rcu_read_lock();
-	data = radix_tree_lookup(&domain->revmap_tree, hwirq);
-	rcu_read_unlock();
+	data = xa_load(&domain->revmap_array, hwirq);
 	return data ? data->irq : 0;
 }
 EXPORT_SYMBOL_GPL(irq_find_mapping);
@@ -943,8 +936,6 @@ static int virq_debug_show(struct seq_file *m, void *private)
 	unsigned long flags;
 	struct irq_desc *desc;
 	struct irq_domain *domain;
-	struct radix_tree_iter iter;
-	void __rcu **slot;
 	int i;
 
 	seq_printf(m, " %-16s  %-6s  %-10s  %-10s  %s\n",
@@ -953,7 +944,6 @@ static int virq_debug_show(struct seq_file *m, void *private)
 	list_for_each_entry(domain, &irq_domain_list, link) {
 		struct device_node *of_node;
 		const char *name;
-
 		int count = 0;
 
 		of_node = irq_domain_get_of_node(domain);
@@ -965,8 +955,7 @@ static int virq_debug_show(struct seq_file *m, void *private)
 		else
 			name = "";
 
-		radix_tree_for_each_slot(slot, &domain->revmap_tree, &iter, 0)
-			count++;
+		count = xa_count(&domain->revmap_array);
 		seq_printf(m, "%c%-16s  %6u  %10u  %10u  %s\n",
 			   domain == irq_default_domain ? '*' : ' ', domain->name,
 			   domain->revmap_size + count, domain->revmap_size,
@@ -1452,17 +1441,9 @@ int __irq_domain_alloc_irqs(struct irq_domain *domain, int irq_base,
 /* The irq_data was moved, fix the revmap to refer to the new location */
 static void irq_domain_fix_revmap(struct irq_data *d)
 {
-	void __rcu **slot;
-
 	if (d->hwirq < d->domain->revmap_size)
-		return; /* Not using radix tree. */
-
-	/* Fix up the revmap. */
-	mutex_lock(&d->domain->revmap_tree_mutex);
-	slot = radix_tree_lookup_slot(&d->domain->revmap_tree, d->hwirq);
-	if (slot)
-		radix_tree_replace_slot(&d->domain->revmap_tree, slot, d);
-	mutex_unlock(&d->domain->revmap_tree_mutex);
+		return;
+	xa_store(&d->domain->revmap_array, d->hwirq, d, GFP_KERNEL);
 }
 
 /**
diff --git a/lib/xarray.c b/lib/xarray.c
index 013e81281465..b94f71e30007 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1518,6 +1518,31 @@ int xa_get_tagged(struct xarray *xa, void **dst, unsigned long start,
 }
 EXPORT_SYMBOL(xa_get_tagged);
 
+/**
+ * xa_count() - Count the number of present entries in the XArray
+ * @xa: XArray.
+ *
+ * This function walks the XArray counting how many entries are present.
+ * If every entry in the XArray is full, this function will return 0.  If
+ * this is a theoretical possibility, check xa_empty() first.
+ *
+ * This is a naive implementation; faster implementations are possible.
+ * If speed is important, consider maintaining a count variable in your
+ * own data structure.
+ */
+unsigned long xa_count(struct xarray *xa)
+{
+	XA_STATE(xas, xa, 0);
+	void *p;
+	unsigned long count = 0;
+
+	xas_for_each(&xas, p, ULONG_MAX)
+		count++;
+
+	return count;
+}
+EXPORT_SYMBOL(xa_count);
+
 /**
  * xa_destroy() - Free all internal data structures.
  * @xa: XArray.
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
