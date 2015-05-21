Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCF982966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:34:12 -0400 (EDT)
Received: by qget53 with SMTP id t53so47122944qge.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:12 -0700 (PDT)
Received: from mail-qk0-x22a.google.com (mail-qk0-x22a.google.com. [2607:f8b0:400d:c09::22a])
        by mx.google.com with ESMTPS id z105si17540679qgz.67.2015.05.21.12.34.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:34:11 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so64214989qkg.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:34:11 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 16/36] HMM: add special swap filetype for memory migrated to HMM device memory.
Date: Thu, 21 May 2015 15:31:25 -0400
Message-Id: <1432236705-4209-17-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Jerome Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>

From: Jerome Glisse <jglisse@redhat.com>

When migrating anonymous memory from system memory to device memory
CPU pte are replaced with special HMM swap entry so that page fault,
get user page (gup), fork, ... are properly redirected to HMM helpers.

This patch only add the new swap type entry and hooks HMM helpers
functions inside the page fault and fork code path.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
---
 include/linux/hmm.h     | 34 ++++++++++++++++++++++++++++++++++
 include/linux/swap.h    | 12 +++++++++++-
 include/linux/swapops.h | 43 ++++++++++++++++++++++++++++++++++++++++++-
 mm/hmm.c                | 21 +++++++++++++++++++++
 mm/memory.c             | 22 ++++++++++++++++++++++
 5 files changed, 130 insertions(+), 2 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 186f497..f243eb5 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -257,6 +257,40 @@ void hmm_mirror_range_dirty(struct hmm_mirror *mirror,
 			    unsigned long start,
 			    unsigned long end);
 
+int hmm_handle_cpu_fault(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmdp, unsigned long addr,
+			unsigned flags, pte_t orig_pte);
+
+int hmm_mm_fork(struct mm_struct *src_mm,
+		struct mm_struct *dst_mm,
+		struct vm_area_struct *dst_vma,
+		pmd_t *dst_pmd,
+		unsigned long start,
+		unsigned long end);
+
+#else /* CONFIG_HMM */
+
+static inline int hmm_handle_mm_fault(struct mm_struct *mm,
+				      struct vm_area_struct *vma,
+				      pmd_t *pmdp, unsigned long addr,
+				      unsigned flags, pte_t orig_pte)
+{
+	return VM_FAULT_SIGBUS;
+}
+
+static inline int hmm_mm_fork(struct mm_struct *src_mm,
+			      struct mm_struct *dst_mm,
+			      struct vm_area_struct *dst_vma,
+			      pmd_t *dst_pmd,
+			      unsigned long start,
+			      unsigned long end)
+{
+	BUG();
+	return -ENOMEM;
+}
 
 #endif /* CONFIG_HMM */
+
+
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 0428e4c..89b9dda 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -70,8 +70,18 @@ static inline int current_is_kswapd(void)
 #define SWP_HWPOISON_NUM 0
 #endif
 
+/*
+ * HMM (heterogeneous memory management) used when data is in remote memory.
+ */
+#ifdef CONFIG_HMM
+#define SWP_HMM_NUM 1
+#define SWP_HMM			(MAX_SWAPFILES + SWP_MIGRATION_NUM + SWP_HWPOISON_NUM)
+#else
+#define SWP_HMM_NUM 0
+#endif
+
 #define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
+	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM - SWP_HMM_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index cedf3d3..934359f 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -190,7 +190,7 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
 }
 #endif
 
-#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
+#if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION) || defined(CONFIG_HMM)
 static inline int non_swap_entry(swp_entry_t entry)
 {
 	return swp_type(entry) >= MAX_SWAPFILES;
@@ -202,4 +202,45 @@ static inline int non_swap_entry(swp_entry_t entry)
 }
 #endif
 
+#ifdef CONFIG_HMM
+static inline swp_entry_t make_hmm_entry(void)
+{
+	/* We do not store anything inside the CPU page table entry (pte). */
+	return swp_entry(SWP_HMM, 0);
+}
+
+static inline swp_entry_t make_hmm_entry_locked(void)
+{
+	/* We do not store anything inside the CPU page table entry (pte). */
+	return swp_entry(SWP_HMM, 1);
+}
+
+static inline swp_entry_t make_hmm_entry_poisonous(void)
+{
+	/* We do not store anything inside the CPU page table entry (pte). */
+	return swp_entry(SWP_HMM, 2);
+}
+
+static inline int is_hmm_entry(swp_entry_t entry)
+{
+	return (swp_type(entry) == SWP_HMM);
+}
+
+static inline int is_hmm_entry_locked(swp_entry_t entry)
+{
+	return (swp_type(entry) == SWP_HMM) && (swp_offset(entry) == 1);
+}
+
+static inline int is_hmm_entry_poisonous(swp_entry_t entry)
+{
+	return (swp_type(entry) == SWP_HMM) && (swp_offset(entry) == 2);
+}
+#else /* CONFIG_HMM */
+static inline int is_hmm_entry(swp_entry_t swp)
+{
+	return 0;
+}
+#endif /* CONFIG_HMM */
+
+
 #endif /* _LINUX_SWAPOPS_H */
diff --git a/mm/hmm.c b/mm/hmm.c
index 1533223..2143a58 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -423,6 +423,27 @@ static struct mmu_notifier_ops hmm_notifier_ops = {
 };
 
 
+int hmm_handle_cpu_fault(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			pmd_t *pmdp, unsigned long addr,
+			unsigned flags, pte_t orig_pte)
+{
+	return VM_FAULT_SIGBUS;
+}
+EXPORT_SYMBOL(hmm_handle_cpu_fault);
+
+int hmm_mm_fork(struct mm_struct *src_mm,
+		struct mm_struct *dst_mm,
+		struct vm_area_struct *dst_vma,
+		pmd_t *dst_pmd,
+		unsigned long start,
+		unsigned long end)
+{
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(hmm_mm_fork);
+
+
 struct mm_pt_iter {
 	struct mm_struct	*mm;
 	pte_t			*ptep;
diff --git a/mm/memory.c b/mm/memory.c
index 6497009..b6840fb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -53,6 +53,7 @@
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
+#include <linux/hmm.h>
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
@@ -893,9 +894,11 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	pte_t *orig_src_pte, *orig_dst_pte;
 	pte_t *src_pte, *dst_pte;
 	spinlock_t *src_ptl, *dst_ptl;
+	unsigned cnt_hmm_entry = 0;
 	int progress = 0;
 	int rss[NR_MM_COUNTERS];
 	swp_entry_t entry = (swp_entry_t){0};
+	unsigned long start;
 
 again:
 	init_rss_vec(rss);
@@ -909,6 +912,7 @@ again:
 	orig_src_pte = src_pte;
 	orig_dst_pte = dst_pte;
 	arch_enter_lazy_mmu_mode();
+	start = addr;
 
 	do {
 		/*
@@ -925,6 +929,12 @@ again:
 			progress++;
 			continue;
 		}
+		if (unlikely(!pte_present(*src_pte))) {
+			entry = pte_to_swp_entry(*src_pte);
+
+			if (is_hmm_entry(entry))
+				cnt_hmm_entry++;
+		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
 							vma, addr, rss);
 		if (entry.val)
@@ -939,6 +949,15 @@ again:
 	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
+	if (cnt_hmm_entry) {
+		int ret;
+
+		ret = hmm_mm_fork(src_mm, dst_mm, dst_vma,
+				  dst_pmd, start, end);
+		if (ret)
+			return ret;
+	}
+
 	if (entry.val) {
 		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
 			return -ENOMEM;
@@ -2487,6 +2506,9 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			migration_entry_wait(mm, pmd, address);
 		} else if (is_hwpoison_entry(entry)) {
 			ret = VM_FAULT_HWPOISON;
+		} else if (is_hmm_entry(entry)) {
+			ret = hmm_handle_cpu_fault(mm, vma, pmd, address,
+						   flags, orig_pte);
 		} else {
 			print_bad_pte(vma, address, orig_pte, NULL);
 			ret = VM_FAULT_SIGBUS;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
