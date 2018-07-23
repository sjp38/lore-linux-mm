Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B69B26B0007
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 18:34:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 66-v6so1317663plb.18
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 15:34:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s24-v6sor2837912pfm.12.2018.07.23.15.34.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Jul 2018 15:34:58 -0700 (PDT)
Date: Mon, 23 Jul 2018 15:34:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, vmacache: hash addresses based on pmd fix
Message-ID: <alpine.DEB.2.21.1807231532290.109445@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, lkp@intel.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

- use PMD_SHIFT only if CONFIG_MMU is used, otherwise there is only pgdir, 
per kbuild test robot

- fix vmacache_find_exact() for correct formal name, per me

- only check vma->vm_mm == mm for CONFIG_DEBUG_VM_VMACACHE, per akpm

Tested for {allnoconfig, defconfig} on alpha, arc, arm, arm64, c6x, h8300, 
i386, ia64, m68k, microblaze, mips, mips, nds32, nios2, parisc, powerpc, 
riscv, s390, sh, sparc, um, and xtensa.

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmacache.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/vmacache.c b/mm/vmacache.c
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -6,12 +6,18 @@
 #include <linux/sched/task.h>
 #include <linux/mm.h>
 #include <linux/vmacache.h>
+#include <asm/pgtable.h>
 
 /*
- * Hash based on the pmd of addr.  Provides a good hit rate for workloads with
- * spatial locality.
+ * Hash based on the pmd of addr if configured with MMU, which provides a good
+ * hit rate for workloads with spatial locality.  Otherwise, use pages.
  */
-#define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
+#ifdef CONFIG_MMU
+#define VMACACHE_SHIFT	PMD_SHIFT
+#else
+#define VMACACHE_SHIFT	PAGE_SHIFT
+#endif
+#define VMACACHE_HASH(addr) ((addr >> VMACACHE_SHIFT) & VMACACHE_MASK)
 
 /*
  * Flush vma caches for threads that share a given mm.
@@ -105,8 +111,10 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 		struct vm_area_struct *vma = current->vmacache.vmas[idx];
 
 		if (vma) {
+#ifdef CONFIG_DEBUG_VM_VMACACHE
 			if (WARN_ON_ONCE(vma->vm_mm != mm))
 				break;
+#endif
 			if (vma->vm_start <= addr && vma->vm_end > addr) {
 				count_vm_vmacache_event(VMACACHE_FIND_HITS);
 				return vma;
@@ -124,7 +132,7 @@ struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
 					   unsigned long start,
 					   unsigned long end)
 {
-	int idx = VMACACHE_HASH(addr);
+	int idx = VMACACHE_HASH(start);
 	int i;
 
 	count_vm_vmacache_event(VMACACHE_FIND_CALLS);
