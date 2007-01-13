From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:49:43 +1100
Message-Id: <20070113024943.29682.62446.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 12/12] Alternate page table implementation cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 12
 * Adds iterator implementations necessary to boot GPT, run LTP and lmbench
 without bringing down the machine (providing you have plenty of memory :))
   * There are problems freeing the GPT at the moment so I have commented
   it out :(

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-gpt-core.c |  210 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 205 insertions(+), 5 deletions(-)
Index: linux-2.6.20-rc4/mm/pt-gpt-core.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-gpt-core.c	2007-01-11 19:00:49.115823000 +1100
+++ linux-2.6.20-rc4/mm/pt-gpt-core.c	2007-01-11 19:13:08.783823000 +1100
@@ -573,14 +573,14 @@
 	/* Process node once children have been processed. */
 	// DEBUG [
 	if(iterator_u->depth == 0) {
-		printk("Root");
+//		printk("Root"); //pauld
 	}
 	gpt_iterator_return(*iterator_u, &key, &node_temp_p);
 	guard = gpt_node_read_guard(gpt_node_get(node_temp_p));
-	printk("\tinternal node (0x%lx, %d) guard (0x%lx, %d)",
-		   gpt_key_read_value(key), gpt_key_read_length(key),
-		   gpt_key_read_value(guard), gpt_key_read_length(guard));
-	printk((iterator_u->finished) ? "U\n" : "D\n");
+//	printk("\tinternal node (0x%lx, %d) guard (0x%lx, %d)", //pauld
+//		   gpt_key_read_value(key), gpt_key_read_length(key),
+//		   gpt_key_read_value(guard), gpt_key_read_length(guard));
+//	printk((iterator_u->finished) ? "U\n" : "D\n");
 	// DEBUG ]
 	if(iterator_u->finished) {
 		// gpt_iterator_return(*iterator_u, &key, node_p_r);
@@ -1024,3 +1024,203 @@
 	}
 	return GPT_OK;
 }
+
+/*
+ * This function frees user-level page tables of a process.
+ *
+ * Must be called with pagetable lock held.
+ */
+void free_pt_range(struct mmu_gather **tlb,
+			unsigned long addr, unsigned long end,
+			unsigned long floor, unsigned long ceiling)
+{
+	gpt_iterator_t iterator;
+	gpt_node_t* node_p;
+	/* buggy somewhere - so turned off temporarily */
+	//gpt_iterator_inspect_init_range(&iterator, &(((*tlb)->mm)->page_table),
+    //                                                 addr, end);
+	//gpt_iterator_free_pgtables(&iterator, &node_p, floor, ceiling);
+}
+
+int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+                       unsigned long addr, unsigned long end,
+                       struct vm_area_struct *vma)
+{
+	unsigned long i;
+	pte_t* src_pte_p;
+	pte_t* dst_pte_p;
+	int rss[2];
+	gpt_key_t key;
+	gpt_node_t* node_p;
+	gpt_iterator_t iterator;
+
+	gpt_iterator_inspect_init_range(&iterator, &(src_mm->page_table),
+                                                     addr, end);
+	spin_lock(&src_mm->page_table_lock);
+	while(gpt_iterator_inspect_leaves_range(&iterator, &key, &node_p)) {
+		BUG_ON(gpt_key_read_length(key) != GPT_KEY_LENGTH_MAX);
+		i = get_real_address(gpt_key_read_value(key));
+		src_pte_p = gpt_node_leaf_read_ptep(node_p);
+		spin_lock(&dst_mm->page_table_lock);
+		dst_pte_p = build_page_table(dst_mm, i, NULL);
+		BUG_ON(!dst_pte_p); // Need to fix this with clean failure.
+		spin_unlock(&dst_mm->page_table_lock);
+		copy_one_pte(dst_mm, src_mm, dst_pte_p, src_pte_p, vma, addr,
+					 rss);
+		add_mm_rss(dst_mm, rss[0], rss[1]);
+	}
+	spin_unlock(&src_mm->page_table_lock);
+	return 0;
+}
+
+unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long addr, unsigned long end,
+		long *zap_work, struct zap_details *details)
+{
+    gpt_key_t key; // DEBUG!
+	pte_t* pte_p;
+	int file_rss, anon_rss = 0;
+    gpt_node_t* node_p;
+    gpt_iterator_t iterator;
+	struct mm_struct *mm = vma->vm_mm;
+
+    gpt_iterator_inspect_init_range(&iterator, &(mm->page_table),
+                                        addr, end);
+    spin_lock(&mm->page_table_lock);
+    while(gpt_iterator_inspect_leaves_range(&iterator, &key, &node_p)) {
+        pte_p = gpt_node_leaf_read_ptep(node_p);
+        node_p->raw.guard = 0; // zap doesn't clear gpt guard field.
+        zap_one_pte(pte_p, mm, addr, vma, zap_work, details, tlb,
+                    &anon_rss, &file_rss);
+        add_mm_rss(mm, file_rss, anon_rss);
+    }
+    spin_unlock(&mm->page_table_lock);
+ 	return end;
+}
+
+int zeromap_build_iterator(struct mm_struct *mm,
+			unsigned long addr, unsigned long end, pgprot_t prot)
+{
+	unsigned long i;
+	pte_t *pte;
+	int err;
+
+	spin_lock(&mm->page_table_lock);
+	for(i=addr; i<end;) {
+		if((pte = build_page_table(&init_mm,i, NULL))) {
+			zeromap_one_pte(mm, pte, addr, prot);
+		}
+		i+=PAGE_SIZE;
+	}
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
+int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot)
+{
+	panic("TODO rebuild iterator\n");
+	return 0;
+}
+
+void change_protection_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable)
+{
+	unsigned long i;
+	pte_t* pte_p;
+	gpt_key_t key;
+	gpt_node_t* node_p;
+	gpt_iterator_t iterator;
+	struct mm_struct* mm = vma->vm_mm;
+
+	gpt_iterator_inspect_init_range(&iterator, &(mm->page_table),
+                                        addr, end);
+	spin_lock(&mm->page_table_lock);
+	while(gpt_iterator_inspect_leaves_range(&iterator, &key, &node_p)) {
+		BUG_ON(gpt_key_read_length(key) != GPT_KEY_LENGTH_MAX);
+		i = get_real_address(gpt_key_read_value(key));
+		pte_p = gpt_node_leaf_read_ptep(node_p);
+		change_prot_pte(mm, pte_p, i, newprot, dirty_accountable);
+	}
+	spin_unlock(&mm->page_table_lock);
+}
+
+void vunmap_read_iterator(unsigned long addr, unsigned long end)
+{
+	unsigned long i;
+	pte_t* pte_p;
+    gpt_key_t key;
+    gpt_node_t* node_p;
+    gpt_iterator_t iterator;
+
+    gpt_iterator_inspect_init_range(&iterator, &(init_mm.page_table),
+                                                     addr, end);
+    while(gpt_iterator_inspect_leaves_range(&iterator, &key, &node_p)) {
+         pte_p = gpt_node_leaf_read_ptep(node_p);
+         BUG_ON(gpt_key_read_length(key) != GPT_KEY_LENGTH_MAX);
+         i = get_real_address(gpt_key_read_value(key));
+         vunmap_one_pte(pte_p, i);
+    }
+}
+
+int vmap_build_iterator(unsigned long addr,
+			unsigned long end, pgprot_t prot, struct page ***pages)
+{
+	unsigned long i;
+	pte_t *pte;
+	int err;
+
+	for(i=addr; i<end;) {
+		if((pte = build_page_table(&init_mm,i, NULL))) {
+				err = vmap_one_pte(pte, addr, pages, prot);
+				if(err)
+				return err;
+		}
+		i+=PAGE_SIZE;
+	}
+	return 0;
+}
+
+int unuse_vma_read_iterator(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end, swp_entry_t entry,
+				struct page *page)
+{
+	panic("TODO: unuse vma iterator\n");
+	return 0;
+}
+
+void smaps_read_iterator(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	panic("TODO: smaps read iterator\n");
+}
+
+#ifdef CONFIG_NUMA
+
+int check_policy_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private)
+{
+	panic("TODO: check policy iterator");
+	return 0;
+}
+#endif
+
+int ioremap_page_range(unsigned long addr,
+		       unsigned long end, unsigned long phys_addr, pgprot_t prot)
+{
+	panic("TODO: ioremap iterator");
+	return 0;
+}
+
+unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len)
+{
+	panic("TODO: move page tables\n");
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
