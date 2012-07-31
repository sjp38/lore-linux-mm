Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 1D22B6B0074
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 06:42:08 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so4882724lbj.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 03:42:07 -0700 (PDT)
Subject: [PATCH v3 02/10] x86,
 pat: separate the pfn attribute tracking for remap_pfn_range and
 vm_insert_pfn
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 31 Jul 2012 14:42:04 +0400
Message-ID: <20120731104204.20515.18670.stgit@zurg>
In-Reply-To: <20120731103724.20515.60334.stgit@zurg>
References: <20120731103724.20515.60334.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Venkatesh Pallipadi <venki@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

From: Suresh Siddha <suresh.b.siddha@intel.com>

With PAT enabled, vm_insert_pfn() looks up the existing pfn memory attribute
and uses it. Expectation is that the driver reserves the memory attributes
for the pfn before calling vm_insert_pfn().

remap_pfn_range() (when called for the whole vma) will setup a
new attribute (based on the prot argument) for the specified pfn range. This
addresses the legacy usage which typically calls remap_pfn_range() with
a desired memory attribute. For ranges smaller than the vma size (which
is typically not the case), remap_pfn_range() will use the
existing memory attribute for the pfn range.

Expose two different API's for these different behaviors.
track_pfn_insert() for tracking the pfn attribute set by
vm_insert_pfn() and track_pfn_remap() for the remap_pfn_range().

This cleanup also prepares the ground for the track/untrack pfn vma routines
to take over the ownership of setting PAT specific vm_flag in the 'vma'.

[khlebnikov@openvz.org: Clear checks in track_pfn_remap()]

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Venkatesh Pallipadi <venki@google.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Ingo Molnar <mingo@redhat.com>
---
 arch/x86/mm/pat.c             |   49 ++++++++++++++++++++++++++++---------
 include/asm-generic/pgtable.h |   55 ++++++++++++++++++++++++-----------------
 mm/memory.c                   |   13 ++++------
 3 files changed, 75 insertions(+), 42 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index de36c88..4ad8316 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -664,13 +664,13 @@ static void free_pfn_range(u64 paddr, unsigned long size)
 }
 
 /*
- * track_pfn_vma_copy is called when vma that is covering the pfnmap gets
+ * track_pfn_copy is called when vma that is covering the pfnmap gets
  * copied through copy_page_range().
  *
  * If the vma has a linear pfn mapping for the entire range, we get the prot
  * from pte and reserve the entire vma range with single reserve_pfn_range call.
  */
-int track_pfn_vma_copy(struct vm_area_struct *vma)
+int track_pfn_copy(struct vm_area_struct *vma)
 {
 	resource_size_t paddr;
 	unsigned long prot;
@@ -694,15 +694,12 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
 }
 
 /*
- * track_pfn_vma_new is called when a _new_ pfn mapping is being established
- * for physical range indicated by pfn and size.
- *
  * prot is passed in as a parameter for the new mapping. If the vma has a
  * linear pfn mapping for the entire range reserve the entire vma range with
  * single reserve_pfn_range call.
  */
-int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-			unsigned long pfn, unsigned long size)
+int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
+		    unsigned long pfn, unsigned long size)
 {
 	resource_size_t paddr = (resource_size_t)pfn << PAGE_SHIFT;
 	unsigned long flags;
@@ -714,8 +711,38 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
 	if (!pat_enabled)
 		return 0;
 
-	/* for vm_insert_pfn and friends, we set prot based on lookup */
+	/*
+	 * for anything smaller than the vma size,
+	 * we set prot based on the lookup.
+	 */
 	flags = lookup_memtype(paddr);
+
+	/*
+	 * Check memtype for the rest pages
+	 */
+	while (size > PAGE_SIZE) {
+		size -= PAGE_SIZE;
+		paddr += PAGE_SIZE;
+		if (flags != lookup_memtype(paddr))
+			return -EINVAL;
+	}
+
+	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
+			 flags);
+
+	return 0;
+}
+
+int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
+		     unsigned long pfn)
+{
+	unsigned long flags;
+
+	if (!pat_enabled)
+		return 0;
+
+	/* we set prot based on lookup */
+	flags = lookup_memtype((resource_size_t)pfn << PAGE_SHIFT);
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
 			 flags);
 
@@ -723,12 +750,12 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
 }
 
 /*
- * untrack_pfn_vma is called while unmapping a pfnmap for a region.
+ * untrack_pfn is called while unmapping a pfnmap for a region.
  * untrack can be called for a specific region indicated by pfn and size or
  * can be for the entire vma (in which case pfn, size are zero).
  */
-void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
-			unsigned long size)
+void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
+		 unsigned long size)
 {
 	resource_size_t paddr;
 	unsigned long prot;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index ff4947b..d4d4592 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -381,48 +381,57 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
 
 #ifndef __HAVE_PFNMAP_TRACKING
 /*
- * Interface that can be used by architecture code to keep track of
- * memory type of pfn mappings (remap_pfn_range, vm_insert_pfn)
- *
- * track_pfn_vma_new is called when a _new_ pfn mapping is being established
- * for physical range indicated by pfn and size.
+ * Interfaces that can be used by architecture code to keep track of
+ * memory type of pfn mappings specified by the remap_pfn_range,
+ * vm_insert_pfn.
+ */
+
+/*
+ * track_pfn_remap is called when a _new_ pfn mapping is being established
+ * by remap_pfn_range() for physical range indicated by pfn and size.
  */
-static inline int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-					unsigned long pfn, unsigned long size)
+static inline int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
+				  unsigned long pfn, unsigned long size)
 {
 	return 0;
 }
 
 /*
- * Interface that can be used by architecture code to keep track of
- * memory type of pfn mappings (remap_pfn_range, vm_insert_pfn)
- *
- * track_pfn_vma_copy is called when vma that is covering the pfnmap gets
+ * track_pfn_insert is called when a _new_ single pfn is established
+ * by vm_insert_pfn().
+ */
+static inline int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
+				   unsigned long pfn)
+{
+	return 0;
+}
+
+/*
+ * track_pfn_copy is called when vma that is covering the pfnmap gets
  * copied through copy_page_range().
  */
-static inline int track_pfn_vma_copy(struct vm_area_struct *vma)
+static inline int track_pfn_copy(struct vm_area_struct *vma)
 {
 	return 0;
 }
 
 /*
- * Interface that can be used by architecture code to keep track of
- * memory type of pfn mappings (remap_pfn_range, vm_insert_pfn)
- *
  * untrack_pfn_vma is called while unmapping a pfnmap for a region.
  * untrack can be called for a specific region indicated by pfn and size or
- * can be for the entire vma (in which case size can be zero).
+ * can be for the entire vma (in which case pfn, size are zero).
  */
-static inline void untrack_pfn_vma(struct vm_area_struct *vma,
-					unsigned long pfn, unsigned long size)
+static inline void untrack_pfn(struct vm_area_struct *vma,
+			       unsigned long pfn, unsigned long size)
 {
 }
 #else
-extern int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-				unsigned long pfn, unsigned long size);
-extern int track_pfn_vma_copy(struct vm_area_struct *vma);
-extern void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
-				unsigned long size);
+extern int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
+			   unsigned long pfn, unsigned long size);
+extern int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
+			    unsigned long pfn);
+extern int track_pfn_copy(struct vm_area_struct *vma);
+extern void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
+			unsigned long size);
 #endif
 
 #ifdef CONFIG_MMU
diff --git a/mm/memory.c b/mm/memory.c
index 91f6945..57148fc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1060,7 +1060,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		 * We do not free on error cases below as remove_vma
 		 * gets called on error from higher level routine
 		 */
-		ret = track_pfn_vma_copy(vma);
+		ret = track_pfn_copy(vma);
 		if (ret)
 			return ret;
 	}
@@ -1328,7 +1328,7 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 		uprobe_munmap(vma, start, end);
 
 	if (unlikely(is_pfn_mapping(vma)))
-		untrack_pfn_vma(vma, 0, 0);
+		untrack_pfn(vma, 0, 0);
 
 	if (start != end) {
 		if (unlikely(is_vm_hugetlb_page(vma))) {
@@ -2159,14 +2159,11 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_vma_new(vma, &pgprot, pfn, PAGE_SIZE))
+	if (track_pfn_insert(vma, &pgprot, pfn))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, pfn, pgprot);
 
-	if (ret)
-		untrack_pfn_vma(vma, pfn, PAGE_SIZE);
-
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn);
@@ -2308,7 +2305,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
-	err = track_pfn_vma_new(vma, &prot, pfn, PAGE_ALIGN(size));
+	err = track_pfn_remap(vma, &prot, pfn, PAGE_ALIGN(size));
 	if (err) {
 		/*
 		 * To indicate that track_pfn related cleanup is not
@@ -2332,7 +2329,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	} while (pgd++, addr = next, addr != end);
 
 	if (err)
-		untrack_pfn_vma(vma, pfn, PAGE_ALIGN(size));
+		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
 
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
