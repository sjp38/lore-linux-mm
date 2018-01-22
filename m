Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D79A800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 00:41:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o16so7835639pgv.3
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 21:41:12 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id q17si13066027pgt.50.2018.01.21.21.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 21:41:10 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v3] mm: make faultaround produce old ptes
Date: Mon, 22 Jan 2018 11:10:14 +0530
Message-Id: <1516599614-18546-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz, Vinayak Menon <vinmenon@codeaurora.org>

Based on Kirill's patch [1].

Currently, faultaround code produces young pte.  This can screw up
vmscan behaviour[2], as it makes vmscan think that these pages are hot
and not push them out on first round.

During sparse file access faultaround gets more pages mapped and all of
them are young. Under memory pressure, this makes vmscan swap out anon
pages instead, or to drop other page cache pages which otherwise stay
resident.

Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
is set, so they can easily be reclaimed under memory pressure.

This can to some extend defeat the purpose of faultaround on machines
without hardware accessed bit as it will not help us with reducing the
number of minor page faults.

Making the faultaround ptes old results in a unixbench regression for some
architectures [3][4]. But on some architectures like arm64 it is not found
to cause any regression.

unixbench shell8 scores on arm64 v8.2 hardware with CONFIG_ARM64_HW_AFDBM
enabled  (5 runs min, max, avg):
Base: (741,748,744)
With this patch: (739,748,743)

So by default produce young ptes and provide a sysctl option to make the
ptes old.

[1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
[2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
[3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
[4] https://marc.info/?l=linux-mm&m=146589376909424&w=2

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---

V3:
Fix the documentation (suggested by Kirill)

V2:
1. Removed the arch hook and want_old_faultaround_pte is made a sysctl
2. Renamed FAULT_FLAG_MKOLD to FAULT_FLAG_PREFAULT_OLD (suggested by Jan Kara)
3. Removed the saved fault address from vmf (suggested by Jan Kara)

 Documentation/sysctl/vm.txt | 22 ++++++++++++++++++++++
 include/linux/mm.h          |  3 +++
 kernel/sysctl.c             |  9 +++++++++
 mm/filemap.c                | 10 ++++++++++
 mm/memory.c                 |  4 ++++
 5 files changed, 48 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 17256f2..c3c9c6d 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -63,6 +63,7 @@ Currently, these files are in /proc/sys/vm:
 - vfs_cache_pressure
 - watermark_scale_factor
 - zone_reclaim_mode
+- want_old_faultaround_pte
 
 ==============================================================
 
@@ -887,4 +888,25 @@ Allowing regular swap effectively restricts allocations to the local
 node unless explicitly overridden by memory policies or cpuset
 configurations.
 
+=============================================================
+
+want_old_faultaround_pte:
+
+By default faultaround code produces young pte. When want_old_faultaround_pte is
+set to 1, faultaround produces old ptes.
+
+During sparse file access faultaround gets more pages mapped and when all of
+them are young (default), under memory pressure, this makes vmscan swap out anon
+pages instead, or to drop other page cache pages which otherwise stay resident.
+Setting want_old_faultaround_pte to 1 avoids this.
+
+Making the faultaround ptes old can result in performance regression on some
+architectures. This is due to cycles spent in micro-faults which would take page
+walk to set young bit in the pte. One such known test that shows a regression on
+x86 is unixbench shell8. Set want_old_faultaround_pte to 1 on architectures
+which does not show this regression or if the workload shows overall performance
+benefit with old faultaround ptes.
+
+The default value is 0.
+
 ============ End of Document =================================
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 63f7ba1..55b5667 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -302,6 +302,7 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
+#define FAULT_FLAG_PREFAULT_OLD	0x200	/* Make faultaround ptes old */
 
 #define FAULT_FLAG_TRACE \
 	{ FAULT_FLAG_WRITE,		"WRITE" }, \
@@ -2676,5 +2677,7 @@ static inline bool page_is_guard(struct page *page)
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int want_old_faultaround_pte;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f98f28c..2ab3a4e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1343,6 +1343,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.procname       = "want_old_faultaround_pte",
+		.data           = &want_old_faultaround_pte,
+		.maxlen         = sizeof(want_old_faultaround_pte),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+		.extra1         = &zero,
+		.extra2         = &one,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	{
 		.procname	= "nr_hugepages",
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f622..f58393d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -48,6 +48,8 @@
 
 #include <asm/mman.h>
 
+int want_old_faultaround_pte;
+
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
  * though.
@@ -2677,6 +2679,14 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (vmf->pte)
 			vmf->pte += iter.index - last_pgoff;
 		last_pgoff = iter.index;
+
+		if (want_old_faultaround_pte) {
+			if (iter.index == vmf->pgoff)
+				vmf->flags &= ~FAULT_FLAG_PREFAULT_OLD;
+			else
+				vmf->flags |= FAULT_FLAG_PREFAULT_OLD;
+		}
+
 		if (alloc_set_pte(vmf, NULL, page))
 			goto unlock;
 		unlock_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index c7f9a43..11412cc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3438,6 +3438,10 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+
+	if (vmf->flags & FAULT_FLAG_PREFAULT_OLD)
+		entry = pte_mkold(entry);
+
 	/* copy-on-write page */
 	if (write && !(vma->vm_flags & VM_SHARED)) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
