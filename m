Subject: [PATCH 1/2] remap file pages MAP_NONBLOCK fix
From: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>
Content-Type: text/plain
Message-Id: <1062786697.25345.253.camel@eecs-kilkenny.eecs.umich.edu>
Mime-Version: 1.0
Date: 05 Sep 2003 14:31:37 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew, Ingo,

The remap_file_pages system call with MAP_NONBLOCK flag does not
install file-ptes when the required pages are not found in the
page cache. Modify the populate functions to install file-ptes
if the mapping is non-linear and the required pages are not found
in the page cache.

Patch is for test4-mm6. Compiles and boots. Patch tested using the
programs at:

http://www-personal.engin.umich.edu/~vrajesh/linux/remap-file-pages/

Please apply if appropriate.

Thanks,
Rajesh



 include/linux/mm.h |    1 +
 mm/filemap.c       |   14 ++++++++++++++
 mm/fremap.c        |   39 +++++++++++++++++++++++++++++++++++++++
 mm/shmem.c         |   15 +++++++++++++++
 4 files changed, 69 insertions(+)

diff -puN mm/fremap.c~fremap-MAP_NONBLOCK mm/fremap.c
--- dev-2.6.0-test4/mm/fremap.c~fremap-MAP_NONBLOCK	Fri Sep  5 12:57:52 2003
+++ dev-2.6.0-test4-vrajesh/mm/fremap.c	Fri Sep  5 12:57:52 2003
@@ -100,6 +100,45 @@ err:
 EXPORT_SYMBOL(install_page);
 
 
+/*
+ * Install a file pte to a given virtual memory address, release any
+ * previously existing mapping.
+ */
+int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long pgoff, pgprot_t prot)
+{
+	int err = -ENOMEM, flush;
+	pte_t *pte;
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, addr);
+	spin_lock(&mm->page_table_lock);
+
+	pmd = pmd_alloc(mm, pgd, addr);
+	if (!pmd)
+		goto err_unlock;
+
+	pte = pte_alloc_map(mm, pmd, addr);
+	if (!pte)
+		goto err_unlock;
+
+	flush = zap_pte(mm, vma, addr, pte);
+
+	set_pte(pte, pgoff_to_pte(pgoff));
+	pte_unmap(pte);
+	if (flush)
+		flush_tlb_page(vma, addr);
+	update_mmu_cache(vma, addr, *pte);
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+
+err_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return err;
+}
+
+
 /***
  * sys_remap_file_pages - remap arbitrary pages of a shared backing store
  *                        file within an existing vma.
diff -puN include/linux/mm.h~fremap-MAP_NONBLOCK include/linux/mm.h
--- dev-2.6.0-test4/include/linux/mm.h~fremap-MAP_NONBLOCK	Fri Sep  5 12:57:52 2003
+++ dev-2.6.0-test4-vrajesh/include/linux/mm.h	Fri Sep  5 12:57:52 2003
@@ -431,6 +431,7 @@ extern pmd_t *FASTCALL(__pmd_alloc(struc
 extern pte_t *FASTCALL(pte_alloc_kernel(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern pte_t *FASTCALL(pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address));
 extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
+extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
 extern int handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma, unsigned long address, int write_access);
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
diff -puN mm/filemap.c~fremap-MAP_NONBLOCK mm/filemap.c
--- dev-2.6.0-test4/mm/filemap.c~fremap-MAP_NONBLOCK	Fri Sep  5 12:57:52 2003
+++ dev-2.6.0-test4-vrajesh/mm/filemap.c	Fri Sep  5 12:57:52 2003
@@ -1363,6 +1363,20 @@ repeat:
 			page_cache_release(page);
 			return err;
 		}
+	} else {
+	    	/*
+		 * If a nonlinear mapping then store the file page offset
+		 * in the pte.
+		 */
+	    	unsigned long pgidx;
+		pgidx = (addr - vma->vm_start) >> PAGE_SHIFT;
+		pgidx += vma->vm_pgoff;
+		pgidx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
+		if (pgoff != pgidx) {
+	    		err = install_file_pte(mm, vma, addr, pgoff, prot);
+			if (err)
+		    		return err;
+		}
 	}
 
 	len -= PAGE_SIZE;
diff -puN mm/shmem.c~fremap-MAP_NONBLOCK mm/shmem.c
--- dev-2.6.0-test4/mm/shmem.c~fremap-MAP_NONBLOCK	Fri Sep  5 12:57:52 2003
+++ dev-2.6.0-test4-vrajesh/mm/shmem.c	Fri Sep  5 12:57:52 2003
@@ -984,7 +984,22 @@ static int shmem_populate(struct vm_area
 				page_cache_release(page);
 				return err;
 			}
+		} else if (nonblock) {
+	    		/*
+		 	 * If a nonlinear mapping then store the file page 
+			 * offset in the pte.  
+			 */
+	    		unsigned long pgidx;
+			pgidx = (addr - vma->vm_start) >> PAGE_SHIFT;
+			pgidx += vma->vm_pgoff;
+			pgidx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT; 
+			if (pgoff != pgidx) {
+	    			err = install_file_pte(mm, vma, addr, pgoff, prot);
+				if (err)
+		    			return err;
+			}
 		}
+	
 		len -= PAGE_SIZE;
 		addr += PAGE_SIZE;
 		pgoff++;

_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
