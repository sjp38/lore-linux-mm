Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78132280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 11:12:17 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 99so46417535qku.9
        for <linux-mm@kvack.org>; Sun, 21 May 2017 08:12:17 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id v34si15187023qtv.325.2017.05.21.08.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 May 2017 08:12:15 -0700 (PDT)
Received: from mr6.cc.vt.edu (mr6.cc.vt.edu [IPv6:2607:b400:92:8500:0:af:2d00:4488])
	by omr1.cc.vt.edu (8.14.4/8.14.4) with ESMTP id v4LFCFDX025047
	for <linux-mm@kvack.org>; Sun, 21 May 2017 11:12:15 -0400
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by mr6.cc.vt.edu (8.14.7/8.14.7) with ESMTP id v4LFCAPq021165
	for <linux-mm@kvack.org>; Sun, 21 May 2017 11:12:15 -0400
Received: by mail-qk0-f197.google.com with SMTP id 36so46368872qkz.10
        for <linux-mm@kvack.org>; Sun, 21 May 2017 08:12:15 -0700 (PDT)
From: Sarunya Pumma <sarunya@vt.edu>
Subject: [PATCH] Patch for remapping pages around the fault page
Date: Sun, 21 May 2017 11:12:00 -0400
Message-Id: <1495379520-23752-1-git-send-email-sarunya@vt.edu>
In-Reply-To: <rppt@linux.vnet.ibm.com>
References: <rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com, lstoakes@gmail.com, dave.jiang@intel.com, Sarunya Pumma <sarunya@vt.edu>

After the fault handler performs the __do_fault function to read a fault
page when a page fault occurs, it does not map other pages that have been
read together with the fault page. This can cause a number of minor page
faults to be large. Therefore, this patch is developed to remap pages
around the fault page by aiming to map the pages that have been read
synchronously or asynchronously with the fault page.

The major function of this patch is the redo_fault_around function. This
function computes the start and end offsets of the pages to be mapped,
determines whether to do the page remapping, remaps pages using the
map_pages function, and returns. In the redo_fault_around function, the
start and end offsets are computed the same way as the do_fault_around
function. To determine whether to do the remapping, we determine if the
pages around the fault page are already mapped. If they are, the remapping
will not be performed.

As checking every page can be inefficient if a number of pages to be mapped
is large, we have added a threshold called "vm_nr_rempping" to consider
whether to check the status of every page around the fault page or just
some pages. Note that the vm_nr_rempping parameter can be adjusted via the
Sysctl interface. In the case that a number of pages to be mapped is
smaller than the vm_nr_rempping threshold, we check all pages around the
fault page (within the start and end offsets). Otherwise, we check only the
adjacent pages (left and right).

The page remapping is beneficial when performing the "almost sequential"
page accesses, where pages are accessed in order but some pages are
skipped.

The following is one example scenario that we can reduce one page fault
every 16 page:

Assume that we want to access pages sequentially and skip every page that
marked as PG_readahead. Assume that the read-ahead size is 32 pages and the
number of pages to be mapped each time (fault_around_pages) is 16.

When accessing a page at offset 0, a major page fault occurs, so pages from
page 0 to page 31 is read from the disk to the page cache. With this, page
24 is marked as a read-ahead page (PG_readahead). Then only page 0 is
mapped to the virtual memory space.

When accessing a page at offset 1, a minor page fault occurs, pages from
page 0 to page 15 will be mapped.

We keep accessing pages until page 31. Note that we skip page 24.

When accessing a page at offset 32, a major page fault occurs.  The same
process will be repeated. The other 32 pages will be read from the disk.
Only page 32 is mapped. Then a minor page fault at the next page (page
33) will occur.

>From this example, two page faults occur every 16 page. With this patch, we
can eliminate the minor page fault in every 16 page.

Thank you very much for your time for reviewing the patch.

Signed-off-by: Sarunya Pumma <sarunya@vt.edu>
---
 include/linux/mm.h |  2 ++
 kernel/sysctl.c    |  8 +++++
 mm/memory.c        | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7cb17c6..2d533a3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -34,6 +34,8 @@ struct bdi_writeback;
 
 void init_mm_internals(void);
 
+extern unsigned long vm_nr_remapping;
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 4dfba1a..16c7efe 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1332,6 +1332,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.procname	= "nr_remapping",
+		.data		= &vm_nr_remapping,
+		.maxlen		= sizeof(vm_nr_remapping),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+		.extra1		= &zero,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	= "nr_hugepages",
diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d72..3d0dca9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -83,6 +83,9 @@
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
 
+/* A preset threshold for considering page remapping */
+unsigned long vm_nr_remapping = 32;
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -3374,6 +3377,82 @@ static int do_fault_around(struct vm_fault *vmf)
 	return ret;
 }
 
+static int redo_fault_around(struct vm_fault *vmf)
+{
+	unsigned long address = vmf->address, nr_pages, mask;
+	pgoff_t start_pgoff = vmf->pgoff;
+	pgoff_t end_pgoff;
+	pte_t *lpte, *rpte;
+	int off, ret = 0, is_mapped = 0;
+
+	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
+	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
+
+	vmf->address = max(address & mask, vmf->vma->vm_start);
+	off = ((address - vmf->address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
+	start_pgoff -= off;
+
+	/*
+	 *  end_pgoff is either end of page table or end of vma
+	 *  or fault_around_pages() from start_pgoff, depending what is nearest.
+	 */
+	end_pgoff = start_pgoff -
+		((vmf->address >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
+		PTRS_PER_PTE - 1;
+	end_pgoff = min3(end_pgoff, vma_pages(vmf->vma) + vmf->vma->vm_pgoff - 1,
+			start_pgoff + nr_pages - 1);
+
+	if (nr_pages < vm_nr_remapping) {
+		int i, start_off = 0, end_off = 0;
+
+		lpte = vmf->pte - off;
+		for (i = 0; i < nr_pages; i++) {
+			if (!pte_none(*lpte)) {
+				is_mapped++;
+			} else {
+				if (!start_off)
+					start_off = i;
+				end_off = i;
+			}
+			lpte++;
+		}
+		if (is_mapped != nr_pages) {
+			is_mapped = 0;
+			end_pgoff = start_pgoff + end_off;
+			start_pgoff += start_off;
+			vmf->pte += start_off;
+		}
+		lpte = NULL;
+	} else {
+		lpte = vmf->pte - 1;
+		rpte = vmf->pte + 1;
+		if (!pte_none(*lpte) && !pte_none(*rpte))
+			is_mapped = 1;
+		lpte = NULL;
+		rpte = NULL;
+	}
+
+	if (!is_mapped) {
+		vmf->pte -= off;
+		vmf->vma->vm_ops->map_pages(vmf, start_pgoff, end_pgoff);
+		vmf->pte -= (vmf->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
+	}
+
+	/* Huge page is mapped? Page fault is solved */
+	if (pmd_trans_huge(*vmf->pmd)) {
+		ret = VM_FAULT_NOPAGE;
+		goto out;
+	}
+
+	if (vmf->pte)
+		pte_unmap_unlock(vmf->pte, vmf->ptl);
+
+out:
+	vmf->address = address;
+	vmf->pte = NULL;
+	return ret;
+}
+
 static int do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -3394,6 +3473,17 @@ static int do_read_fault(struct vm_fault *vmf)
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 
+	/*
+	 * Remap pages after read
+	 */
+	if (!(vma->vm_flags & VM_RAND_READ) && vma->vm_ops->map_pages
+			&& fault_around_bytes >> PAGE_SHIFT > 1) {
+		ret |= alloc_set_pte(vmf, vmf->memcg, vmf->page);
+		unlock_page(vmf->page);
+		redo_fault_around(vmf);
+		return ret;
+	}
+
 	ret |= finish_fault(vmf);
 	unlock_page(vmf->page);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
