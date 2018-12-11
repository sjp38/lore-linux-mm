Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB4A8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:36:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d41so6871931eda.12
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:36:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o21-v6sor4054180ejh.52.2018.12.11.06.36.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 06:36:51 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, thp, proc: report THP eligibility for each vma
Date: Tue, 11 Dec 2018 15:36:40 +0100
Message-Id: <20181211143641.3503-3-mhocko@kernel.org>
In-Reply-To: <20181211143641.3503-1-mhocko@kernel.org>
References: <20181211143641.3503-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

Userspace falls short when trying to find out whether a specific memory
range is eligible for THP. There are usecases that would like to know
that
http://lkml.kernel.org/r/alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com
: This is used to identify heap mappings that should be able to fault thp
: but do not, and they normally point to a low-on-memory or fragmentation
: issue.

The only way to deduce this now is to query for hg resp. nh flags and
confronting the state with the global setting. Except that there is
also PR_SET_THP_DISABLE that might change the picture. So the final
logic is not trivial. Moreover the eligibility of the vma depends on
the type of VMA as well. In the past we have supported only anononymous
memory VMAs but things have changed and shmem based vmas are supported
as well these days and the query logic gets even more complicated
because the eligibility depends on the mount option and another global
configuration knob.

Simplify the current state and report the THP eligibility in
/proc/<pid>/smaps for each existing vma. Reuse transparent_hugepage_enabled
for this purpose. The original implementation of this function assumes
that the caller knows that the vma itself is supported for THP so make
the core checks into __transparent_hugepage_enabled and use it for
existing callers. __show_smap just use the new transparent_hugepage_enabled
which also checks the vma support status (please note that this one has
to be out of line due to include dependency issues).

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/filesystems/proc.txt |  3 +++
 fs/proc/task_mmu.c                 |  2 ++
 include/linux/huge_mm.h            | 13 ++++++++++++-
 mm/huge_memory.c                   | 12 +++++++++++-
 mm/memory.c                        |  4 ++--
 5 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 2a4e63f5122c..cd465304bec4 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -425,6 +425,7 @@ SwapPss:               0 kB
 KernelPageSize:        4 kB
 MMUPageSize:           4 kB
 Locked:                0 kB
+THPeligible:           0
 VmFlags: rd ex mr mw me dw
 
 the first of these lines shows the same information as is displayed for the
@@ -462,6 +463,8 @@ replaced by copy-on-write) part of the underlying shmem object out on swap.
 "SwapPss" shows proportional swap share of this mapping. Unlike "Swap", this
 does not take into account swapped out page of underlying shmem objects.
 "Locked" indicates whether the mapping is locked in memory or not.
+"THPeligible" indicates whether the mapping is eligible for THP pages - 1 if
+true, 0 otherwise.
 
 "VmFlags" field deserves a separate description. This member represents the kernel
 flags associated with the particular virtual memory area in two letter encoded
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 47c3764c469b..c9f160eb9fbc 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -790,6 +790,8 @@ static int show_smap(struct seq_file *m, void *v)
 
 	__show_smap(m, &mss);
 
+	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
+
 	if (arch_pkeys_enabled())
 		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
 	show_smap_vma_flags(m, vma);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4663ee96cf59..381e872bfde0 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -93,7 +93,11 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 extern unsigned long transparent_hugepage_flags;
 
-static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
+/*
+ * to be used on vmas which are known to support THP.
+ * Use transparent_hugepage_enabled otherwise
+ */
+static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
 	if (vma->vm_flags & VM_NOHUGEPAGE)
 		return false;
@@ -117,6 +121,8 @@ static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 	return false;
 }
 
+bool transparent_hugepage_enabled(struct vm_area_struct *vma);
+
 #define transparent_hugepage_use_zero_page()				\
 	(transparent_hugepage_flags &					\
 	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
@@ -257,6 +263,11 @@ static inline bool thp_migration_supported(void)
 
 #define hpage_nr_pages(x) 1
 
+static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	return false;
+}
+
 static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
 {
 	return false;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 55478ab3c83b..f64733c23067 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -62,6 +62,16 @@ static struct shrinker deferred_split_shrinker;
 static atomic_t huge_zero_refcount;
 struct page *huge_zero_page __read_mostly;
 
+bool transparent_hugepage_enabled(struct vm_area_struct *vma)
+{
+	if (vma_is_anonymous(vma))
+		return __transparent_hugepage_enabled(vma);
+	if (shmem_mapping(vma->vm_file->f_mapping) && shmem_huge_enabled(vma))
+		return __transparent_hugepage_enabled(vma);
+
+	return false;
+}
+
 static struct page *get_huge_zero_page(void)
 {
 	struct page *zero_page;
@@ -1303,7 +1313,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	get_page(page);
 	spin_unlock(vmf->ptl);
 alloc:
-	if (transparent_hugepage_enabled(vma) &&
+	if (__transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
 		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
 		new_page = alloc_pages_vma(huge_gfp, HPAGE_PMD_ORDER, vma,
diff --git a/mm/memory.c b/mm/memory.c
index 4ad2d293ddc2..3c2716ec7fbd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3830,7 +3830,7 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 	vmf.pud = pud_alloc(mm, p4d, address);
 	if (!vmf.pud)
 		return VM_FAULT_OOM;
-	if (pud_none(*vmf.pud) && transparent_hugepage_enabled(vma)) {
+	if (pud_none(*vmf.pud) && __transparent_hugepage_enabled(vma)) {
 		ret = create_huge_pud(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
@@ -3856,7 +3856,7 @@ static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
 	vmf.pmd = pmd_alloc(mm, vmf.pud, address);
 	if (!vmf.pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*vmf.pmd) && transparent_hugepage_enabled(vma)) {
+	if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
 		ret = create_huge_pmd(&vmf);
 		if (!(ret & VM_FAULT_FALLBACK))
 			return ret;
-- 
2.19.2
