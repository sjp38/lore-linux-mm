Message-ID: <3F32ECE0.1000102@us.ibm.com>
Date: Thu, 07 Aug 2003 17:20:48 -0700
From: Adam Litke <agl@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC] prefault optimization
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: "Martin J. Bligh" <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

This patch attempts to reduce page fault overhead for mmap'd files.  All 
pages in the page cache that will be managed by the current vma are 
instantiated in the page table.  This boots, but some applications fail 
(eg. make).  I am probably missing a corner case somewhere.  Let me know 
what you think.

--Adam Litke

diff -urN linux-2.5.73-virgin/mm/memory.c linux-2.5.73-vm/mm/memory.c
--- linux-2.5.73-virgin/mm/memory.c	2003-06-22 11:32:43.000000000 -0700
+++ linux-2.5.73-vm/mm/memory.c	2003-08-07 13:01:48.000000000 -0700
@@ -1328,6 +1328,47 @@
  	return ret;
  }

+/* Try to reduce overhead from page faults by grabbing pages from the page
+ * cache and instantiating the page table entries for this vma
+ */
+static int
+do_pre_fault(struct mm_struct *mm, struct vm_area_struct *vma, pmd_t *pmd,
+		const pte_t *page_table)
+{
+	unsigned long vm_end_pgoff, offset, address;
+	struct address_space *mapping;
+	struct page *new_page;
+	pte_t *pte, entry;
+	struct pte_chain *pte_chain;
+	
+	/* the file offset corrssponding to end of this vma */
+	vm_end_pgoff = ((vma->vm_end - vma->vm_start) >> PAGE_SHIFT) + 
vma->vm_pgoff;
+	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
+
+	/* Itterate through all pages managed by this vma */
+	for(offset = vma->vm_pgoff; offset < vm_end_pgoff; ++offset)
+	{
+		address = vma->vm_start + ((offset - vma->vm_pgoff) << PAGE_SHIFT);
+		pte = pte_offset_map(pmd, address);
+		if(pte_none(*pte)) { /* don't touch instantiated ptes */
+			new_page = find_get_page(mapping, offset);
+			if(!new_page)
+				continue;
+			
+			/* This code taken directly from do_no_page() */
+			pte_chain = pte_chain_alloc(GFP_KERNEL);
+			++mm->rss;
+			flush_icache_page(vma, new_page);
+			entry = mk_pte(new_page, vma->vm_page_prot);
+			set_pte(pte, entry);
+			pte_chain = page_add_rmap(new_page, pte, pte_chain);
+			pte_unmap(page_table);
+			update_mmu_cache(vma, address, *pte);
+			pte_chain_free(pte_chain);
+		}
+	}
+}
+
  /*
   * do_no_page() tries to create a new page mapping. It aggressively
   * tries to share with existing pages, but makes a separate copy if
@@ -1405,6 +1446,8 @@
  		set_pte(page_table, entry);
  		pte_chain = page_add_rmap(new_page, page_table, pte_chain);
  		pte_unmap(page_table);
+		//if(!write_access)
+			do_pre_fault(mm, vma, pmd, page_table);
  	} else {
  		/* One of our sibling threads was faster, back out. */
  		pte_unmap(page_table);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
