Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id E83126B00C0
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 15:49:47 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id p61so4980730wes.39
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 12:49:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xm2si5955993wib.82.2014.03.17.12.49.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 12:49:44 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 9/9] staging: tidspbridge: Convert to get_vaddr_pfns()
Date: Mon, 17 Mar 2014 20:49:36 +0100
Message-Id: <1395085776-8626-10-git-send-email-jack@suse.cz>
In-Reply-To: <1395085776-8626-1-git-send-email-jack@suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-media@vger.kernel.org, Jan Kara <jack@suse.cz>

Convert the driver to use get_vaddr_pfns() instead of get_user_pages()
or a hand made page table walk. This removes knowledge about vmas
and mmap_sem locking from the driver.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 drivers/staging/tidspbridge/core/tiomap3430.c      | 261 ++++-----------------
 .../staging/tidspbridge/include/dspbridge/drv.h    |   3 +-
 .../tidspbridge/include/dspbridge/dspdefs.h        |   9 +-
 drivers/staging/tidspbridge/rmgr/proc.c            |  66 ++++--
 4 files changed, 91 insertions(+), 248 deletions(-)

diff --git a/drivers/staging/tidspbridge/core/tiomap3430.c b/drivers/staging/tidspbridge/core/tiomap3430.c
index b770b2281ce8..a7cbc2f90b60 100644
--- a/drivers/staging/tidspbridge/core/tiomap3430.c
+++ b/drivers/staging/tidspbridge/core/tiomap3430.c
@@ -100,9 +100,10 @@ static int bridge_brd_mem_write(struct bridge_dev_context *dev_ctxt,
 static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
 				  u32 ul_mpu_addr, u32 virt_addr,
 				  u32 ul_num_bytes, u32 ul_map_attr,
-				  struct page **mapped_pages);
+				  struct pinned_pfns *pfns);
 static int bridge_brd_mem_un_map(struct bridge_dev_context *dev_ctxt,
-				     u32 virt_addr, u32 ul_num_bytes);
+				     u32 virt_addr, u32 ul_num_bytes,
+				     struct pinned_pfns *pfns);
 static int bridge_dev_create(struct bridge_dev_context
 					**dev_cntxt,
 					struct dev_object *hdev_obj,
@@ -1122,24 +1123,18 @@ static int bridge_brd_mem_write(struct bridge_dev_context *dev_ctxt,
  *  TODO: Disable MMU while updating the page tables (but that'll stall DSP)
  */
 static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
-				  u32 ul_mpu_addr, u32 virt_addr,
-				  u32 ul_num_bytes, u32 ul_map_attr,
-				  struct page **mapped_pages)
+			      u32 ul_mpu_addr, u32 virt_addr, u32 ul_num_bytes,
+			      u32 ul_map_attr, struct pinned_pfns *pfns)
 {
 	u32 attrs;
 	int status = 0;
 	struct bridge_dev_context *dev_context = dev_ctxt;
 	struct hw_mmu_map_attrs_t hw_attrs;
-	struct vm_area_struct *vma;
-	struct mm_struct *mm = current->mm;
 	u32 write = 0;
-	u32 num_usr_pgs = 0;
-	struct page *mapped_page, *pg;
-	s32 pg_num;
+	int num_usr_pgs, i;
 	u32 va = virt_addr;
-	struct task_struct *curr_task = current;
-	u32 pg_i = 0;
-	u32 mpu_addr, pa;
+	u32 pa;
+	struct page **pages;
 
 	dev_dbg(bridge,
 		"%s hDevCtxt %p, pa %x, va %x, size %x, ul_map_attr %x\n",
@@ -1201,128 +1196,36 @@ static int bridge_brd_mem_map(struct bridge_dev_context *dev_ctxt,
 	if ((attrs & DSP_MAPPHYSICALADDR)) {
 		status = pte_update(dev_context, ul_mpu_addr, virt_addr,
 				    ul_num_bytes, &hw_attrs);
-		goto func_cont;
+		goto out;
 	}
 
-	/*
-	 * Important Note: ul_mpu_addr is mapped from user application process
-	 * to current process - it must lie completely within the current
-	 * virtual memory address space in order to be of use to us here!
-	 */
-	down_read(&mm->mmap_sem);
-	vma = find_vma(mm, ul_mpu_addr);
-	if (vma)
-		dev_dbg(bridge,
-			"VMAfor UserBuf: ul_mpu_addr=%x, ul_num_bytes=%x, "
-			"vm_start=%lx, vm_end=%lx, vm_flags=%lx\n", ul_mpu_addr,
-			ul_num_bytes, vma->vm_start, vma->vm_end,
-			vma->vm_flags);
-
-	/*
-	 * It is observed that under some circumstances, the user buffer is
-	 * spread across several VMAs. So loop through and check if the entire
-	 * user buffer is covered
-	 */
-	while ((vma) && (ul_mpu_addr + ul_num_bytes > vma->vm_end)) {
-		/* jump to the next VMA region */
-		vma = find_vma(mm, vma->vm_end + 1);
-		dev_dbg(bridge,
-			"VMA for UserBuf ul_mpu_addr=%x ul_num_bytes=%x, "
-			"vm_start=%lx, vm_end=%lx, vm_flags=%lx\n", ul_mpu_addr,
-			ul_num_bytes, vma->vm_start, vma->vm_end,
-			vma->vm_flags);
-	}
-	if (!vma) {
-		pr_err("%s: Failed to get VMA region for 0x%x (%d)\n",
-		       __func__, ul_mpu_addr, ul_num_bytes);
-		status = -EINVAL;
-		up_read(&mm->mmap_sem);
-		goto func_cont;
+	BUG_ON(!pfns);
+	num_usr_pgs = ul_num_bytes / PG_SIZE4K;
+	status = get_vaddr_pfns(ul_mpu_addr, num_usr_pgs, write, 1, pfns);
+	if (status < 0)
+		goto out;
+	if (status != num_usr_pgs) {
+		status = -EFAULT;
+		goto put_pfns;
 	}
 
-	if (vma->vm_flags & VM_IO) {
-		num_usr_pgs = ul_num_bytes / PG_SIZE4K;
-		mpu_addr = ul_mpu_addr;
-
-		/* Get the physical addresses for user buffer */
-		for (pg_i = 0; pg_i < num_usr_pgs; pg_i++) {
-			pa = user_va2_pa(mm, mpu_addr);
-			if (!pa) {
-				status = -EPERM;
-				pr_err("DSPBRIDGE: VM_IO mapping physical"
-				       "address is invalid\n");
-				break;
-			}
-			if (pfn_valid(__phys_to_pfn(pa))) {
-				pg = PHYS_TO_PAGE(pa);
-				get_page(pg);
-				if (page_count(pg) < 1) {
-					pr_err("Bad page in VM_IO buffer\n");
-					bad_page_dump(pa, pg);
-				}
-			}
-			status = pte_set(dev_context->pt_attrs, pa,
-					 va, HW_PAGE_SIZE4KB, &hw_attrs);
-			if (status)
-				break;
-
-			va += HW_PAGE_SIZE4KB;
-			mpu_addr += HW_PAGE_SIZE4KB;
-			pa += HW_PAGE_SIZE4KB;
-		}
-	} else {
-		num_usr_pgs = ul_num_bytes / PG_SIZE4K;
-		if (vma->vm_flags & (VM_WRITE | VM_MAYWRITE))
-			write = 1;
-
-		for (pg_i = 0; pg_i < num_usr_pgs; pg_i++) {
-			pg_num = get_user_pages(curr_task, mm, ul_mpu_addr, 1,
-						write, 1, &mapped_page, NULL);
-			if (pg_num > 0) {
-				if (page_count(mapped_page) < 1) {
-					pr_err("Bad page count after doing"
-					       "get_user_pages on"
-					       "user buffer\n");
-					bad_page_dump(page_to_phys(mapped_page),
-						      mapped_page);
-				}
-				status = pte_set(dev_context->pt_attrs,
-						 page_to_phys(mapped_page), va,
-						 HW_PAGE_SIZE4KB, &hw_attrs);
-				if (status)
-					break;
-
-				if (mapped_pages)
-					mapped_pages[pg_i] = mapped_page;
-
-				va += HW_PAGE_SIZE4KB;
-				ul_mpu_addr += HW_PAGE_SIZE4KB;
-			} else {
-				pr_err("DSPBRIDGE: get_user_pages FAILED,"
-				       "MPU addr = 0x%x,"
-				       "vma->vm_flags = 0x%lx,"
-				       "get_user_pages Err"
-				       "Value = %d, Buffer"
-				       "size=0x%x\n", ul_mpu_addr,
-				       vma->vm_flags, pg_num, ul_num_bytes);
-				status = -EPERM;
-				break;
-			}
-		}
-	}
-	up_read(&mm->mmap_sem);
-func_cont:
-	if (status) {
-		/*
-		 * Roll out the mapped pages incase it failed in middle of
-		 * mapping
-		 */
-		if (pg_i) {
-			bridge_brd_mem_un_map(dev_context, virt_addr,
-					   (pg_i * PG_SIZE4K));
-		}
-		status = -EPERM;
+	status = pfns_vector_to_pages(pfns);
+	if (status < 0)
+		goto put_pfns;
+
+	pages = pfns_vector_pages(pfns);
+	for (i = 0; i < num_usr_pgs; i++) {
+		status = pte_set(dev_context->pt_attrs, page_to_phys(pages[i]),
+				 va, HW_PAGE_SIZE4KB, &hw_attrs);
+		if (status)
+			goto put_pfns;
+		va += HW_PAGE_SIZE4KB;
 	}
+	status = 0;
+	goto out;
+put_pfns:
+	put_vaddr_pfns(pfns);
+out:
 	/*
 	 * In any case, flush the TLB
 	 * This is called from here instead from pte_update to avoid unnecessary
@@ -1343,7 +1246,8 @@ func_cont:
  *      we clear consecutive PTEs until we unmap all the bytes
  */
 static int bridge_brd_mem_un_map(struct bridge_dev_context *dev_ctxt,
-				     u32 virt_addr, u32 ul_num_bytes)
+				 u32 virt_addr, u32 ul_num_bytes,
+				 struct pinned_pfns *pfns)
 {
 	u32 l1_base_va;
 	u32 l2_base_va;
@@ -1357,13 +1261,10 @@ static int bridge_brd_mem_un_map(struct bridge_dev_context *dev_ctxt,
 	u32 rem_bytes;
 	u32 rem_bytes_l2;
 	u32 va_curr;
-	struct page *pg = NULL;
 	int status = 0;
 	struct bridge_dev_context *dev_context = dev_ctxt;
 	struct pg_table_attrs *pt = dev_context->pt_attrs;
-	u32 temp;
-	u32 paddr;
-	u32 numof4k_pages = 0;
+	struct page **pages;
 
 	va_curr = virt_addr;
 	rem_bytes = ul_num_bytes;
@@ -1423,30 +1324,6 @@ static int bridge_brd_mem_un_map(struct bridge_dev_context *dev_ctxt,
 				break;
 			}
 
-			/* Collect Physical addresses from VA */
-			paddr = (pte_val & ~(pte_size - 1));
-			if (pte_size == HW_PAGE_SIZE64KB)
-				numof4k_pages = 16;
-			else
-				numof4k_pages = 1;
-			temp = 0;
-			while (temp++ < numof4k_pages) {
-				if (!pfn_valid(__phys_to_pfn(paddr))) {
-					paddr += HW_PAGE_SIZE4KB;
-					continue;
-				}
-				pg = PHYS_TO_PAGE(paddr);
-				if (page_count(pg) < 1) {
-					pr_info("DSPBRIDGE: UNMAP function: "
-						"COUNT 0 FOR PA 0x%x, size = "
-						"0x%x\n", paddr, ul_num_bytes);
-					bad_page_dump(paddr, pg);
-				} else {
-					set_page_dirty(pg);
-					page_cache_release(pg);
-				}
-				paddr += HW_PAGE_SIZE4KB;
-			}
 			if (hw_mmu_pte_clear(pte_addr_l2, va_curr, pte_size)) {
 				status = -EPERM;
 				goto EXIT_LOOP;
@@ -1488,28 +1365,6 @@ skip_coarse_page:
 			break;
 		}
 
-		if (pte_size == HW_PAGE_SIZE1MB)
-			numof4k_pages = 256;
-		else
-			numof4k_pages = 4096;
-		temp = 0;
-		/* Collect Physical addresses from VA */
-		paddr = (pte_val & ~(pte_size - 1));
-		while (temp++ < numof4k_pages) {
-			if (pfn_valid(__phys_to_pfn(paddr))) {
-				pg = PHYS_TO_PAGE(paddr);
-				if (page_count(pg) < 1) {
-					pr_info("DSPBRIDGE: UNMAP function: "
-						"COUNT 0 FOR PA 0x%x, size = "
-						"0x%x\n", paddr, ul_num_bytes);
-					bad_page_dump(paddr, pg);
-				} else {
-					set_page_dirty(pg);
-					page_cache_release(pg);
-				}
-			}
-			paddr += HW_PAGE_SIZE4KB;
-		}
 		if (!hw_mmu_pte_clear(l1_base_va, va_curr, pte_size)) {
 			status = 0;
 			rem_bytes -= pte_size;
@@ -1519,6 +1374,15 @@ skip_coarse_page:
 			goto EXIT_LOOP;
 		}
 	}
+
+	pages = pfns_vector_pages(pfns);
+	if (pages) {
+		int i;
+
+		for (i = 0; i < pfns_vector_count(pfns); i++)
+			set_page_dirty(pages[i]);
+	}
+	put_vaddr_pfns(pfns);
 	/*
 	 * It is better to flush the TLB here, so that any stale old entries
 	 * get flushed
@@ -1533,41 +1397,6 @@ EXIT_LOOP:
 }
 
 /*
- *  ======== user_va2_pa ========
- *  Purpose:
- *      This function walks through the page tables to convert a userland
- *      virtual address to physical address
- */
-static u32 user_va2_pa(struct mm_struct *mm, u32 address)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
-
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || pgd_bad(*pgd))
-		return 0;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || pud_bad(*pud))
-		return 0;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return 0;
-
-	ptep = pte_offset_map(pmd, address);
-	if (ptep) {
-		pte = *ptep;
-		if (pte_present(pte))
-			return pte & PAGE_MASK;
-	}
-
-	return 0;
-}
-
-/*
  *  ======== pte_update ========
  *      This function calculates the optimum page-aligned addresses and sizes
  *      Caller must pass page-aligned values
diff --git a/drivers/staging/tidspbridge/include/dspbridge/drv.h b/drivers/staging/tidspbridge/include/dspbridge/drv.h
index b0c7708321b2..e8640e223e9c 100644
--- a/drivers/staging/tidspbridge/include/dspbridge/drv.h
+++ b/drivers/staging/tidspbridge/include/dspbridge/drv.h
@@ -87,8 +87,7 @@ struct dmm_map_object {
 	u32 dsp_addr;
 	u32 mpu_addr;
 	u32 size;
-	u32 num_usr_pgs;
-	struct page **pages;
+	struct pinned_pfns *pfns;
 	struct bridge_dma_map_info dma_info;
 };
 
diff --git a/drivers/staging/tidspbridge/include/dspbridge/dspdefs.h b/drivers/staging/tidspbridge/include/dspbridge/dspdefs.h
index ed32bf383132..f1108413827c 100644
--- a/drivers/staging/tidspbridge/include/dspbridge/dspdefs.h
+++ b/drivers/staging/tidspbridge/include/dspbridge/dspdefs.h
@@ -166,17 +166,16 @@ typedef int(*fxn_brd_memwrite) (struct bridge_dev_context
  *      ul_num_bytes:     Number of bytes to map.
  *      map_attrs:       Mapping attributes (e.g. endianness).
  *  Returns:
- *      0:        Success.
- *      -EPERM:      Other, unspecified error.
+ *      Pointer to pinned pages / NULL:   Success.
+ *      ERR_PTR(-EPERM):                  Other, unspecified error.
  *  Requires:
  *      dev_ctxt != NULL;
  *  Ensures:
  */
-typedef int(*fxn_brd_memmap) (struct bridge_dev_context
+typedef struct pinned_pfns *(*fxn_brd_memmap) (struct bridge_dev_context
 				     * dev_ctxt, u32 ul_mpu_addr,
 				     u32 virt_addr, u32 ul_num_bytes,
-				     u32 map_attr,
-				     struct page **mapped_pages);
+				     u32 map_attr);
 
 /*
  *  ======== bridge_brd_mem_un_map ========
diff --git a/drivers/staging/tidspbridge/rmgr/proc.c b/drivers/staging/tidspbridge/rmgr/proc.c
index cd5235a4f77c..5d4426f75ba8 100644
--- a/drivers/staging/tidspbridge/rmgr/proc.c
+++ b/drivers/staging/tidspbridge/rmgr/proc.c
@@ -124,9 +124,8 @@ static struct dmm_map_object *add_mapping_info(struct process_context *pr_ctxt,
 
 	INIT_LIST_HEAD(&map_obj->link);
 
-	map_obj->pages = kcalloc(num_usr_pgs, sizeof(struct page *),
-				 GFP_KERNEL);
-	if (!map_obj->pages) {
+	map_obj->pfns = pfns_vector_create(num_usr_pgs);
+	if (!map_obj->pfns) {
 		kfree(map_obj);
 		return NULL;
 	}
@@ -134,7 +133,6 @@ static struct dmm_map_object *add_mapping_info(struct process_context *pr_ctxt,
 	map_obj->mpu_addr = mpu_addr;
 	map_obj->dsp_addr = dsp_addr;
 	map_obj->size = size;
-	map_obj->num_usr_pgs = num_usr_pgs;
 
 	spin_lock(&pr_ctxt->dmm_map_lock);
 	list_add(&map_obj->link, &pr_ctxt->dmm_map_list);
@@ -154,10 +152,11 @@ static int match_exact_map_obj(struct dmm_map_object *map_obj,
 		map_obj->size == size;
 }
 
-static void remove_mapping_information(struct process_context *pr_ctxt,
-						u32 dsp_addr, u32 size)
+static struct dmm_map_object *find_mapping_information(
+					struct process_context *pr_ctxt,
+					u32 dsp_addr, u32 size)
 {
-	struct dmm_map_object *map_obj;
+	struct dmm_map_object *map_obj = NULL;
 
 	pr_debug("%s: looking for virt 0x%x size 0x%x\n", __func__,
 							dsp_addr, size);
@@ -171,11 +170,7 @@ static void remove_mapping_information(struct process_context *pr_ctxt,
 							map_obj->size);
 
 		if (match_exact_map_obj(map_obj, dsp_addr, size)) {
-			pr_debug("%s: match, deleting map info\n", __func__);
-			list_del(&map_obj->link);
-			kfree(map_obj->dma_info.sg);
-			kfree(map_obj->pages);
-			kfree(map_obj);
+			pr_debug("%s: match map info\n", __func__);
 			goto out;
 		}
 		pr_debug("%s: candidate didn't match\n", __func__);
@@ -184,6 +179,19 @@ static void remove_mapping_information(struct process_context *pr_ctxt,
 	pr_err("%s: failed to find given map info\n", __func__);
 out:
 	spin_unlock(&pr_ctxt->dmm_map_lock);
+	return map_obj
+}
+
+static void remove_mapping_information(struct process_context *pr_ctxt,
+				       struct dmm_map_object *map_obj)
+{
+	spin_lock(&pr_ctxt->dmm_map_lock);
+	pr_debug("%s: deleting map info\n", __func__);
+	list_del(&map_obj->link);
+	kfree(map_obj->dma_info.sg);
+	pfns_vector_destroy(map_obj->pfns);
+	kfree(map_obj);
+	spin_unlock(&pr_ctxt->dmm_map_lock);
 }
 
 static int match_containing_map_obj(struct dmm_map_object *map_obj,
@@ -231,7 +239,7 @@ static int find_first_page_in_cache(struct dmm_map_object *map_obj,
 	u32 requested_base_page = mpu_addr >> PAGE_SHIFT;
 	int pg_index = requested_base_page - mapped_base_page;
 
-	if (pg_index < 0 || pg_index >= map_obj->num_usr_pgs) {
+	if (pg_index < 0 || pg_index >= pfns_vector_count(map_obj->pfns)) {
 		pr_err("%s: failed (got %d)\n", __func__, pg_index);
 		return -1;
 	}
@@ -243,16 +251,18 @@ static int find_first_page_in_cache(struct dmm_map_object *map_obj,
 static inline struct page *get_mapping_page(struct dmm_map_object *map_obj,
 								int pg_i)
 {
+	int num_usr_pgs = pfns_vector_count(map_obj->pfns);
+
 	pr_debug("%s: looking for pg_i %d, num_usr_pgs: %d\n", __func__,
-					pg_i, map_obj->num_usr_pgs);
+					pg_i, num_usr_pgs);
 
-	if (pg_i < 0 || pg_i >= map_obj->num_usr_pgs) {
+	if (pg_i < 0 || pg_i >= num_usr_pgs) {
 		pr_err("%s: requested pg_i %d is out of mapped range\n",
 				__func__, pg_i);
 		return NULL;
 	}
 
-	return map_obj->pages[pg_i];
+	return pfns_vector_pages(map_obj->pfns)[pg_i];
 }
 
 /*
@@ -1262,7 +1272,7 @@ int proc_map(void *hprocessor, void *pmpu_addr, u32 ul_size,
 	u32 size_align;
 	int status = 0;
 	struct proc_object *p_proc_object = (struct proc_object *)hprocessor;
-	struct dmm_map_object *map_obj;
+	struct dmm_map_object *map_obj = NULL;
 	u32 tmp_addr = 0;
 
 #ifdef CONFIG_TIDSPBRIDGE_CACHE_LINE_CHECK
@@ -1307,13 +1317,14 @@ int proc_map(void *hprocessor, void *pmpu_addr, u32 ul_size,
 		else
 			status = (*p_proc_object->intf_fxns->brd_mem_map)
 			    (p_proc_object->bridge_context, pa_align, va_align,
-			     size_align, ul_map_attr, map_obj->pages);
+			     size_align, ul_map_attr, map_obj->pfns);
 	}
 	if (!status) {
 		/* Mapped address = MSB of VA | LSB of PA */
 		*pp_map_addr = (void *) tmp_addr;
 	} else {
-		remove_mapping_information(pr_ctxt, tmp_addr, size_align);
+		if (map_obj)
+			remove_mapping_information(pr_ctxt, map_obj);
 		dmm_un_map_memory(dmm_mgr, va_align, &size_align);
 	}
 	mutex_unlock(&proc_lock);
@@ -1592,6 +1603,7 @@ int proc_un_map(void *hprocessor, void *map_addr,
 	struct dmm_object *dmm_mgr;
 	u32 va_align;
 	u32 size_align;
+	struct dmm_map_object *map_obj;
 
 	va_align = PG_ALIGN_LOW((u32) map_addr, PG_SIZE4K);
 	if (!p_proc_object) {
@@ -1607,17 +1619,21 @@ int proc_un_map(void *hprocessor, void *map_addr,
 
 	/* Critical section */
 	mutex_lock(&proc_lock);
+
 	/*
 	 * Update DMM structures. Get the size to unmap.
 	 * This function returns error if the VA is not mapped
 	 */
 	status = dmm_un_map_memory(dmm_mgr, (u32) va_align, &size_align);
+	if (status)
+		goto unmap_failed;
+	map_obj = find_mapping_information(pr_ctxt, (u32) map_addr, size_align);
+	if (!map_obj)
+		goto unmap_failed;
 	/* Remove mapping from the page tables. */
-	if (!status) {
-		status = (*p_proc_object->intf_fxns->brd_mem_un_map)
-		    (p_proc_object->bridge_context, va_align, size_align);
-	}
-
+	status = (*p_proc_object->intf_fxns->brd_mem_un_map)
+		    (p_proc_object->bridge_context, va_align, size_align,
+		     map_obj);
 	if (status)
 		goto unmap_failed;
 
@@ -1626,7 +1642,7 @@ int proc_un_map(void *hprocessor, void *map_addr,
 	 * from dmm_map_list, so that mapped memory resource tracking
 	 * remains uptodate
 	 */
-	remove_mapping_information(pr_ctxt, (u32) map_addr, size_align);
+	remove_mapping_information(pr_ctxt, map_obj);
 
 unmap_failed:
 	mutex_unlock(&proc_lock);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
