Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79FBD28027C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:23:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z12so12213193pgv.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:23:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i135si4465714pgc.459.2018.01.17.12.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 12:23:02 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 82/99] s390: Convert gmap to XArray
Date: Wed, 17 Jan 2018 12:21:46 -0800
Message-Id: <20180117202203.19756-83-willy@infradead.org>
In-Reply-To: <20180117202203.19756-1-willy@infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The three radix trees in gmap are all converted to the XArray.
This is another case where the multiple locks held mandates the use
of the xa_reserve() API.  The gmap_insert_rmap() function is
considerably simplified by using the advanced API;
gmap_radix_tree_free() turns out to just be xa_destroy(), and
gmap_rmap_radix_tree_free() is a nice little iteration followed
by xa_destroy().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 arch/s390/include/asm/gmap.h |  12 ++--
 arch/s390/mm/gmap.c          | 133 +++++++++++++++----------------------------
 2 files changed, 51 insertions(+), 94 deletions(-)

diff --git a/arch/s390/include/asm/gmap.h b/arch/s390/include/asm/gmap.h
index e07cce88dfb0..7695a01d19d7 100644
--- a/arch/s390/include/asm/gmap.h
+++ b/arch/s390/include/asm/gmap.h
@@ -14,14 +14,14 @@
  * @list: list head for the mm->context gmap list
  * @crst_list: list of all crst tables used in the guest address space
  * @mm: pointer to the parent mm_struct
- * @guest_to_host: radix tree with guest to host address translation
- * @host_to_guest: radix tree with pointer to segment table entries
+ * @guest_to_host: guest to host address translation
+ * @host_to_guest: pointers to segment table entries
  * @guest_table_lock: spinlock to protect all entries in the guest page table
  * @ref_count: reference counter for the gmap structure
  * @table: pointer to the page directory
  * @asce: address space control element for gmap page table
  * @pfault_enabled: defines if pfaults are applicable for the guest
- * @host_to_rmap: radix tree with gmap_rmap lists
+ * @host_to_rmap: gmap_rmap lists
  * @children: list of shadow gmap structures
  * @pt_list: list of all page tables used in the shadow guest address space
  * @shadow_lock: spinlock to protect the shadow gmap list
@@ -35,8 +35,8 @@ struct gmap {
 	struct list_head list;
 	struct list_head crst_list;
 	struct mm_struct *mm;
-	struct radix_tree_root guest_to_host;
-	struct radix_tree_root host_to_guest;
+	struct xarray guest_to_host;
+	struct xarray host_to_guest;
 	spinlock_t guest_table_lock;
 	atomic_t ref_count;
 	unsigned long *table;
@@ -45,7 +45,7 @@ struct gmap {
 	void *private;
 	bool pfault_enabled;
 	/* Additional data for shadow guest address spaces */
-	struct radix_tree_root host_to_rmap;
+	struct xarray host_to_rmap;
 	struct list_head children;
 	struct list_head pt_list;
 	spinlock_t shadow_lock;
diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index 05d459b638f5..818a5e80914d 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -60,9 +60,9 @@ static struct gmap *gmap_alloc(unsigned long limit)
 	INIT_LIST_HEAD(&gmap->crst_list);
 	INIT_LIST_HEAD(&gmap->children);
 	INIT_LIST_HEAD(&gmap->pt_list);
-	INIT_RADIX_TREE(&gmap->guest_to_host, GFP_KERNEL);
-	INIT_RADIX_TREE(&gmap->host_to_guest, GFP_ATOMIC);
-	INIT_RADIX_TREE(&gmap->host_to_rmap, GFP_ATOMIC);
+	xa_init(&gmap->guest_to_host);
+	xa_init(&gmap->host_to_guest);
+	xa_init(&gmap->host_to_rmap);
 	spin_lock_init(&gmap->guest_table_lock);
 	spin_lock_init(&gmap->shadow_lock);
 	atomic_set(&gmap->ref_count, 1);
@@ -121,55 +121,16 @@ static void gmap_flush_tlb(struct gmap *gmap)
 		__tlb_flush_global();
 }
 
-static void gmap_radix_tree_free(struct radix_tree_root *root)
-{
-	struct radix_tree_iter iter;
-	unsigned long indices[16];
-	unsigned long index;
-	void __rcu **slot;
-	int i, nr;
-
-	/* A radix tree is freed by deleting all of its entries */
-	index = 0;
-	do {
-		nr = 0;
-		radix_tree_for_each_slot(slot, root, &iter, index) {
-			indices[nr] = iter.index;
-			if (++nr == 16)
-				break;
-		}
-		for (i = 0; i < nr; i++) {
-			index = indices[i];
-			radix_tree_delete(root, index);
-		}
-	} while (nr > 0);
-}
-
-static void gmap_rmap_radix_tree_free(struct radix_tree_root *root)
+static void gmap_rmap_free(struct xarray *xa)
 {
 	struct gmap_rmap *rmap, *rnext, *head;
-	struct radix_tree_iter iter;
-	unsigned long indices[16];
-	unsigned long index;
-	void __rcu **slot;
-	int i, nr;
-
-	/* A radix tree is freed by deleting all of its entries */
-	index = 0;
-	do {
-		nr = 0;
-		radix_tree_for_each_slot(slot, root, &iter, index) {
-			indices[nr] = iter.index;
-			if (++nr == 16)
-				break;
-		}
-		for (i = 0; i < nr; i++) {
-			index = indices[i];
-			head = radix_tree_delete(root, index);
-			gmap_for_each_rmap_safe(rmap, rnext, head)
-				kfree(rmap);
-		}
-	} while (nr > 0);
+	unsigned long index = 0;
+
+	xa_for_each(xa, head, index, ULONG_MAX, XA_PRESENT) {
+		gmap_for_each_rmap_safe(rmap, rnext, head)
+			kfree(rmap);
+	}
+	xa_destroy(xa);
 }
 
 /**
@@ -188,15 +149,15 @@ static void gmap_free(struct gmap *gmap)
 	/* Free all segment & region tables. */
 	list_for_each_entry_safe(page, next, &gmap->crst_list, lru)
 		__free_pages(page, CRST_ALLOC_ORDER);
-	gmap_radix_tree_free(&gmap->guest_to_host);
-	gmap_radix_tree_free(&gmap->host_to_guest);
+	xa_destroy(&gmap->guest_to_host);
+	xa_destroy(&gmap->host_to_guest);
 
 	/* Free additional data for a shadow gmap */
 	if (gmap_is_shadow(gmap)) {
 		/* Free all page tables. */
 		list_for_each_entry_safe(page, next, &gmap->pt_list, lru)
 			page_table_free_pgste(page);
-		gmap_rmap_radix_tree_free(&gmap->host_to_rmap);
+		gmap_rmap_free(&gmap->host_to_rmap);
 		/* Release reference to the parent */
 		gmap_put(gmap->parent);
 	}
@@ -358,7 +319,7 @@ static int __gmap_unlink_by_vmaddr(struct gmap *gmap, unsigned long vmaddr)
 
 	BUG_ON(gmap_is_shadow(gmap));
 	spin_lock(&gmap->guest_table_lock);
-	entry = radix_tree_delete(&gmap->host_to_guest, vmaddr >> PMD_SHIFT);
+	entry = xa_erase(&gmap->host_to_guest, vmaddr >> PMD_SHIFT);
 	if (entry) {
 		flush = (*entry != _SEGMENT_ENTRY_EMPTY);
 		*entry = _SEGMENT_ENTRY_EMPTY;
@@ -378,7 +339,7 @@ static int __gmap_unmap_by_gaddr(struct gmap *gmap, unsigned long gaddr)
 {
 	unsigned long vmaddr;
 
-	vmaddr = (unsigned long) radix_tree_delete(&gmap->guest_to_host,
+	vmaddr = (unsigned long) xa_erase(&gmap->guest_to_host,
 						   gaddr >> PMD_SHIFT);
 	return vmaddr ? __gmap_unlink_by_vmaddr(gmap, vmaddr) : 0;
 }
@@ -441,9 +402,9 @@ int gmap_map_segment(struct gmap *gmap, unsigned long from,
 		/* Remove old translation */
 		flush |= __gmap_unmap_by_gaddr(gmap, to + off);
 		/* Store new translation */
-		if (radix_tree_insert(&gmap->guest_to_host,
+		if (xa_is_err(xa_store(&gmap->guest_to_host,
 				      (to + off) >> PMD_SHIFT,
-				      (void *) from + off))
+				      (void *) from + off, GFP_KERNEL)))
 			break;
 	}
 	up_write(&gmap->mm->mmap_sem);
@@ -474,7 +435,7 @@ unsigned long __gmap_translate(struct gmap *gmap, unsigned long gaddr)
 	unsigned long vmaddr;
 
 	vmaddr = (unsigned long)
-		radix_tree_lookup(&gmap->guest_to_host, gaddr >> PMD_SHIFT);
+		xa_load(&gmap->guest_to_host, gaddr >> PMD_SHIFT);
 	/* Note: guest_to_host is empty for a shadow gmap */
 	return vmaddr ? (vmaddr | (gaddr & ~PMD_MASK)) : -EFAULT;
 }
@@ -588,21 +549,19 @@ int __gmap_link(struct gmap *gmap, unsigned long gaddr, unsigned long vmaddr)
 	if (pmd_large(*pmd))
 		return -EFAULT;
 	/* Link gmap segment table entry location to page table. */
-	rc = radix_tree_preload(GFP_KERNEL);
+	rc = xa_reserve(&gmap->host_to_guest, vmaddr >> PMD_SHIFT, GFP_KERNEL);
 	if (rc)
 		return rc;
 	ptl = pmd_lock(mm, pmd);
 	spin_lock(&gmap->guest_table_lock);
 	if (*table == _SEGMENT_ENTRY_EMPTY) {
-		rc = radix_tree_insert(&gmap->host_to_guest,
-				       vmaddr >> PMD_SHIFT, table);
+		rc = xa_err(xa_store(&gmap->host_to_guest, vmaddr >> PMD_SHIFT,
+				table, GFP_NOWAIT | __GFP_NOFAIL));
 		if (!rc)
 			*table = pmd_val(*pmd);
-	} else
-		rc = 0;
+	}
 	spin_unlock(&gmap->guest_table_lock);
 	spin_unlock(ptl);
-	radix_tree_preload_end();
 	return rc;
 }
 
@@ -660,7 +619,7 @@ void __gmap_zap(struct gmap *gmap, unsigned long gaddr)
 	pte_t *ptep;
 
 	/* Find the vm address for the guest address */
-	vmaddr = (unsigned long) radix_tree_lookup(&gmap->guest_to_host,
+	vmaddr = (unsigned long) xa_load(&gmap->guest_to_host,
 						   gaddr >> PMD_SHIFT);
 	if (vmaddr) {
 		vmaddr |= gaddr & ~PMD_MASK;
@@ -682,8 +641,7 @@ void gmap_discard(struct gmap *gmap, unsigned long from, unsigned long to)
 	for (gaddr = from; gaddr < to;
 	     gaddr = (gaddr + PMD_SIZE) & PMD_MASK) {
 		/* Find the vm address for the guest address */
-		vmaddr = (unsigned long)
-			radix_tree_lookup(&gmap->guest_to_host,
+		vmaddr = (unsigned long) xa_load(&gmap->guest_to_host,
 					  gaddr >> PMD_SHIFT);
 		if (!vmaddr)
 			continue;
@@ -1002,29 +960,24 @@ int gmap_read_table(struct gmap *gmap, unsigned long gaddr, unsigned long *val)
 EXPORT_SYMBOL_GPL(gmap_read_table);
 
 /**
- * gmap_insert_rmap - add a rmap to the host_to_rmap radix tree
+ * gmap_insert_rmap - add a rmap to the host_to_rmap
  * @sg: pointer to the shadow guest address space structure
  * @vmaddr: vm address associated with the rmap
  * @rmap: pointer to the rmap structure
  *
- * Called with the sg->guest_table_lock
+ * Called with the sg->guest_table_lock and page table lock held
  */
 static inline void gmap_insert_rmap(struct gmap *sg, unsigned long vmaddr,
 				    struct gmap_rmap *rmap)
 {
-	void __rcu **slot;
+	XA_STATE(xas, &sg->host_to_rmap, vmaddr >> PAGE_SHIFT);
 
 	BUG_ON(!gmap_is_shadow(sg));
-	slot = radix_tree_lookup_slot(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT);
-	if (slot) {
-		rmap->next = radix_tree_deref_slot_protected(slot,
-							&sg->guest_table_lock);
-		radix_tree_replace_slot(&sg->host_to_rmap, slot, rmap);
-	} else {
-		rmap->next = NULL;
-		radix_tree_insert(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT,
-				  rmap);
-	}
+
+	xas_lock(&xas);
+	rmap->next = xas_load(&xas);
+	xas_store(&xas, rmap);
+	xas_unlock(&xas);
 }
 
 /**
@@ -1058,7 +1011,8 @@ static int gmap_protect_rmap(struct gmap *sg, unsigned long raddr,
 		if (!rmap)
 			return -ENOMEM;
 		rmap->raddr = raddr;
-		rc = radix_tree_preload(GFP_KERNEL);
+		rc = xa_reserve(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT,
+				GFP_KERNEL);
 		if (rc) {
 			kfree(rmap);
 			return rc;
@@ -1074,7 +1028,7 @@ static int gmap_protect_rmap(struct gmap *sg, unsigned long raddr,
 			spin_unlock(&sg->guest_table_lock);
 			gmap_pte_op_end(ptl);
 		}
-		radix_tree_preload_end();
+		xa_release(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT);
 		if (rc) {
 			kfree(rmap);
 			rc = gmap_pte_op_fixup(parent, paddr, vmaddr, prot);
@@ -1962,7 +1916,8 @@ int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte)
 			rc = vmaddr;
 			break;
 		}
-		rc = radix_tree_preload(GFP_KERNEL);
+		rc = xa_reserve(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT,
+				GFP_KERNEL);
 		if (rc)
 			break;
 		rc = -EAGAIN;
@@ -1974,7 +1929,8 @@ int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte)
 			if (!tptep) {
 				spin_unlock(&sg->guest_table_lock);
 				gmap_pte_op_end(ptl);
-				radix_tree_preload_end();
+				xa_release(&sg->host_to_rmap,
+						vmaddr >> PAGE_SHIFT);
 				break;
 			}
 			rc = ptep_shadow_pte(sg->mm, saddr, sptep, tptep, pte);
@@ -1983,11 +1939,13 @@ int gmap_shadow_page(struct gmap *sg, unsigned long saddr, pte_t pte)
 				gmap_insert_rmap(sg, vmaddr, rmap);
 				rmap = NULL;
 				rc = 0;
+			} else {
+				xa_release(&sg->host_to_rmap,
+						vmaddr >> PAGE_SHIFT);
 			}
 			gmap_pte_op_end(ptl);
 			spin_unlock(&sg->guest_table_lock);
 		}
-		radix_tree_preload_end();
 		if (!rc)
 			break;
 		rc = gmap_pte_op_fixup(parent, paddr, vmaddr, prot);
@@ -2030,7 +1988,7 @@ static void gmap_shadow_notify(struct gmap *sg, unsigned long vmaddr,
 		return;
 	}
 	/* Remove the page table tree from on specific entry */
-	head = radix_tree_delete(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT);
+	head = xa_erase(&sg->host_to_rmap, vmaddr >> PAGE_SHIFT);
 	gmap_for_each_rmap_safe(rmap, rnext, head) {
 		bits = rmap->raddr & _SHADOW_RMAP_MASK;
 		raddr = rmap->raddr ^ bits;
@@ -2078,8 +2036,7 @@ void ptep_notify(struct mm_struct *mm, unsigned long vmaddr,
 	rcu_read_lock();
 	list_for_each_entry_rcu(gmap, &mm->context.gmap_list, list) {
 		spin_lock(&gmap->guest_table_lock);
-		table = radix_tree_lookup(&gmap->host_to_guest,
-					  vmaddr >> PMD_SHIFT);
+		table = xa_load(&gmap->host_to_guest, vmaddr >> PMD_SHIFT);
 		if (table)
 			gaddr = __gmap_segment_gaddr(table) + offset;
 		spin_unlock(&gmap->guest_table_lock);
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
