Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id XAA26777
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 23:10:17 -0500
Subject: Update shared mappings
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 20 Nov 1998 05:10:01 +0100
Message-ID: <87btm3dmxy.fsf@atlas.CARNet.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


Should this patch be applied to kernel?

Index: 129.2/mm/filemap.c
--- 129.2/mm/filemap.c Thu, 19 Nov 1998 18:20:34 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.1.1.1 644)
+++ 129.3/mm/filemap.c Fri, 20 Nov 1998 05:07:24 +0100 zcalusic (linux-2.1/y/b/29_filemap.c 1.2.4.1.1.1.1.2 644)
@@ -5,6 +5,10 @@
  */
 
 /*
+ * update_shared_mappings(), 1998  Andrea Arcangeli
+ */
+
+/*
  * This file handles the generic file mmap semantics used by
  * most "normal" filesystems (but you don't /have/ to use this:
  * the NFS filesystem used to do this differently, for example)
@@ -1216,6 +1220,75 @@
 	return mk_pte(page,vma->vm_page_prot);
 }
 
+static void update_one_shared_mapping(struct vm_area_struct *shared,
+				      unsigned long address, pte_t orig_pte)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+	struct semaphore * mmap_sem = &shared->vm_mm->mmap_sem;
+
+	down(mmap_sem);
+
+	pgd = pgd_offset(shared->vm_mm, address);
+	if (pgd_none(*pgd))
+		goto out;
+	if (pgd_bad(*pgd)) {
+		printk(KERN_ERR "update_shared_mappings: bad pgd (%08lx)\n",
+		       pgd_val(*pgd));
+		pgd_clear(pgd);
+		goto out;
+	}
+
+	pmd = pmd_offset(pgd, address);
+	if (pmd_none(*pmd))
+		goto out;
+	if (pmd_bad(*pmd))
+	{
+		printk(KERN_ERR "update_shared_mappings: bad pmd (%08lx)\n",
+		       pmd_val(*pmd));
+		pmd_clear(pmd);
+		goto out;
+	}
+
+	pte = pte_offset(pmd, address);
+
+	if (pte_val(pte_mkclean(pte_mkyoung(*pte))) !=
+	    pte_val(pte_mkclean(pte_mkyoung(orig_pte))))
+		goto out;
+
+	flush_page_to_ram(page(pte));
+	flush_cache_page(shared, address);
+	set_pte(pte, pte_mkclean(*pte));
+	flush_tlb_page(shared, address);
+
+ out:
+	up(mmap_sem);
+}
+
+static void update_shared_mappings(struct vm_area_struct *this,
+				   unsigned long address,
+				   pte_t orig_pte)
+{
+	if (this->vm_flags & VM_SHARED)
+	{
+		struct file * filp = this->vm_file;
+		if (filp)
+		{
+			struct inode * inode = filp->f_dentry->d_inode;
+			struct vm_area_struct * shared;
+
+			for (shared = inode->i_mmap; shared;
+			     shared = shared->vm_next_share)
+			{
+				if (shared == this)
+					continue;
+				update_one_shared_mapping(shared, address,
+							  orig_pte);
+			}
+		}
+	}
+}
 
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
@@ -1233,6 +1306,7 @@
 		flush_cache_page(vma, address);
 		set_pte(ptep, pte_mkclean(pte));
 		flush_tlb_page(vma, address);
+		update_shared_mappings(vma, address, pte);
 		page = pte_page(pte);
 		atomic_inc(&mem_map[MAP_NR(page)].count);
 	} else {

-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	 If you're not confused, you're not paying attention.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
