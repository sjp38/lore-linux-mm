Received: from e31.co.us.ibm.com (e31.esmtp.ibm.com [9.14.4.129])
	by pokfb.esmtp.ibm.com (8.12.9/8.12.2) with ESMTP id h7EN4MNw517910
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=OK)
	for <linux-mm@kvack.org>; Thu, 14 Aug 2003 19:05:27 -0400
Subject: Re: [RFC] prefault optimization
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20030807183744.5eb19ba9.akpm@osdl.org>
References: <3F32ECE0.1000102@us.ibm.com>
	<20030807183744.5eb19ba9.akpm@osdl.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 14 Aug 2003 14:47:40 -0700
Message-Id: <1060897660.9347.49.camel@dyn318198.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Here is the latest on the pre-fault code I posted last week.  I fixed it
up some in response to comments I received.  There is still a bug which
causes some programs to segfault (ie. gcc).  Interestingly, man fails
the first time it is run, but subsequent runs are successful.  Please
take a look and let me know what you think.  Any ideas about that bug?

On Thu, 2003-08-07 at 18:37, Andrew Morton wrote:
> I'd like to see it using find_get_pages() though.

This implementation is simple but somewhat wasteful.  My basic testing
shows around 30% of pages returned from find_get_pages() aren't used.
 
> And find a way to hold the pte page's atomic kmap across the whole pte page

I allocate the page once at the beginning but have to drop it when I
need to allocate a pte_chain.  Perhaps it could be done a better way.

> Perhaps it can use install_page() as well, rather than open-coding it?

It seems that install_page does too much for what I need.  For starters
it zaps the pte.  There is also no need to do the pgd lookup stuff every
time because I already know the correct pte entry to use.

> Cannot do a sleeping allocation while holding the atomic kmap from
> pte_offset_map().  

I took a dirty approach to this one.  Is it ok to hold the
page_table_lock throughout this function?
 
> And the pte_chain handling can be optimised:

I think I am pretty close here.  In my brief test 10% of mapped pages
required a call to pte_chain_alloc.

--Adam

diff -urN linux-2.5.73-virgin/include/asm-i386/pgtable.h
linux-2.5.73-vm/include/asm-i386/pgtable.h
--- linux-2.5.73-virgin/include/asm-i386/pgtable.h	2003-06-22
11:33:04.000000000 -0700
+++ linux-2.5.73-vm/include/asm-i386/pgtable.h	2003-08-13
07:08:18.000000000 -0700
@@ -299,12 +299,15 @@
 	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0) + pte_index(address))
 #define pte_offset_map_nested(dir, address) \
 	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE1) + pte_index(address))
+#define pte_base_map(dir) \
+	((pte_t *)kmap_atomic(pmd_page(*(dir)),KM_PTE0)
 #define pte_unmap(pte) kunmap_atomic(pte, KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic(pte, KM_PTE1)
 #else
 #define pte_offset_map(dir, address) \
 	((pte_t *)page_address(pmd_page(*(dir))) + pte_index(address))
 #define pte_offset_map_nested(dir, address) pte_offset_map(dir,
address)
+#define pte_base_map(dir) ((pte_t *)page_address(pmd_page(*(dir))))
 #define pte_unmap(pte) do { } while (0)
 #define pte_unmap_nested(pte) do { } while (0)
 #endif
diff -urN linux-2.5.73-virgin/mm/memory.c linux-2.5.73-vm/mm/memory.c
--- linux-2.5.73-virgin/mm/memory.c	2003-06-22 11:32:43.000000000 -0700
+++ linux-2.5.73-vm/mm/memory.c	2003-08-14 07:57:54.000000000 -0700
@@ -1328,6 +1328,74 @@
 	return ret;
 }
 
+#define vma_nr_pages(vma) \
+	((vma->vm_end - vma->vm_start) >> PAGE_SHIFT)
+
+/* Try to reduce overhead from page faults by grabbing pages from the
page
+ * cache and instantiating the page table entries for this vma
+ */
+
+unsigned long prefault_entered = 0;
+unsigned long prefault_pages_mapped = 0;
+unsigned long prefault_pte_alloc = 0;
+unsigned long prefault_unused_pages = 0;
+
+static void
+do_pre_fault(struct mm_struct *mm, struct vm_area_struct *vma, pmd_t
*pmd)
+{
+	unsigned long offset, address;
+	struct address_space *mapping;
+	struct page *new_page;
+	pte_t *pte, *pte_base;
+	struct pte_chain *pte_chain;
+	unsigned int i, num_pages;
+	struct page **pages; 
+	
+	/* debug */ ++prefault_entered;
+	pages = kmalloc(PTRS_PER_PTE * sizeof(struct page*), GFP_KERNEL);
+	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
+	num_pages = find_get_pages(mapping, vma->vm_pgoff, PTRS_PER_PTE,
pages);
+
+	pte_chain = pte_chain_alloc(GFP_KERNEL);
+	pte_base = pte_base_map(pmd);
+
+	/* Iterate through all pages managed by this vma */
+	for (i = 0; i < num_pages; ++i)
+	{
+		new_page = pages[i];
+		if (new_page->index >= (vma->vm_pgoff + vma_nr_pages(vma)))
+			break; /* The rest of the pages are not in this vma */
+		offset = new_page->index - vma->vm_pgoff;
+		address = vma->vm_start + (offset << PAGE_SHIFT);
+		pte = pte_base + pte_index(address);
+		if (pte_none(*pte)) {
+			mm->rss++;
+			flush_icache_page(vma, new_page);
+			set_pte(pte, mk_pte(new_page, vma->vm_page_prot));
+			if (pte_chain == NULL) {
+				pte_unmap(pte_base);
+				/* debug */ ++prefault_pte_alloc;
+				pte_chain = pte_chain_alloc(GFP_KERNEL);
+				pte_base = pte_base_map(pmd);
+			}
+			pte_chain = page_add_rmap(new_page, pte, pte_chain);
+			update_mmu_cache(vma, address, *pte);
+			/* debug */ ++prefault_pages_mapped;
+			pages[i] = NULL;
+		}
+	}
+	pte_unmap(pte_base);
+	pte_chain_free(pte_chain);
+
+	/* Release the pages we did not sucessfully add */
+	for (i = 0; i < num_pages; ++i)
+		if (pages[i]) {
+			/* debug */ ++prefault_unused_pages;
+			page_cache_release(pages[i]);
+		}
+	kfree(pages);
+}
+
 /*
  * do_no_page() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -1416,6 +1484,8 @@
 
 	/* no need to invalidate: a not-present page shouldn't be cached */
 	update_mmu_cache(vma, address, entry);
+
+	do_pre_fault(mm, vma, pmd);
 	spin_unlock(&mm->page_table_lock);
 	ret = VM_FAULT_MAJOR;
 	goto out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
