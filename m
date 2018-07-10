Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF20E6B0005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 20:50:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f9-v6so11655586pfn.22
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 17:50:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f34-v6sor5123347ple.122.2018.07.09.17.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 17:50:05 -0700 (PDT)
Date: Mon, 9 Jul 2018 17:50:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmacache: hash addresses based on pmd
Message-ID: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When perf profiling a wide variety of different workloads, it was found
that vmacache_find() had higher than expected cost: up to 0.08% of cpu
utilization in some cases.  This was found to rival other core VM
functions such as alloc_pages_vma() with thp enabled and default
mempolicy, and the conditionals in __get_vma_policy().

VMACACHE_HASH() determines which of the four per-task_struct slots a vma
is cached for a particular address.  This currently depends on the pfn,
so pfn 5212 occupies a different vmacache slot than its neighboring
pfn 5213.

vmacache_find() iterates through all four of current's vmacache slots
when looking up an address.  Hashing based on pfn, an address has
~1/VMACACHE_SIZE chance of being cached in the first vmacache slot, or
about 25%, *if* the vma is cached.

This patch hashes an address by its pmd instead of pte to optimize for
workloads with good spatial locality.  This results in a higher
probability of vmas being cached in the first slot that is checked:
normally ~70% on the same workloads instead of 25%.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/vmacache.h |  6 ------
 mm/vmacache.c            | 32 ++++++++++++++++++++++----------
 2 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
--- a/include/linux/vmacache.h
+++ b/include/linux/vmacache.h
@@ -5,12 +5,6 @@
 #include <linux/sched.h>
 #include <linux/mm.h>
 
-/*
- * Hash based on the page number. Provides a good hit rate for
- * workloads with good locality and those with random accesses as well.
- */
-#define VMACACHE_HASH(addr) ((addr >> PAGE_SHIFT) & VMACACHE_MASK)
-
 static inline void vmacache_flush(struct task_struct *tsk)
 {
 	memset(tsk->vmacache.vmas, 0, sizeof(tsk->vmacache.vmas));
diff --git a/mm/vmacache.c b/mm/vmacache.c
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -7,6 +7,12 @@
 #include <linux/mm.h>
 #include <linux/vmacache.h>
 
+/*
+ * Hash based on the pmd of addr.  Provides a good hit rate for workloads with
+ * spatial locality.
+ */
+#define VMACACHE_HASH(addr) ((addr >> PMD_SHIFT) & VMACACHE_MASK)
+
 /*
  * Flush vma caches for threads that share a given mm.
  *
@@ -87,6 +93,7 @@ static bool vmacache_valid(struct mm_struct *mm)
 
 struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 {
+	int idx = VMACACHE_HASH(addr);
 	int i;
 
 	count_vm_vmacache_event(VMACACHE_FIND_CALLS);
@@ -95,16 +102,18 @@ struct vm_area_struct *vmacache_find(struct mm_struct *mm, unsigned long addr)
 		return NULL;
 
 	for (i = 0; i < VMACACHE_SIZE; i++) {
-		struct vm_area_struct *vma = current->vmacache.vmas[i];
-
-		if (!vma)
-			continue;
-		if (WARN_ON_ONCE(vma->vm_mm != mm))
-			break;
-		if (vma->vm_start <= addr && vma->vm_end > addr) {
-			count_vm_vmacache_event(VMACACHE_FIND_HITS);
-			return vma;
+		struct vm_area_struct *vma = current->vmacache.vmas[idx];
+
+		if (vma) {
+			if (WARN_ON_ONCE(vma->vm_mm != mm))
+				break;
+			if (vma->vm_start <= addr && vma->vm_end > addr) {
+				count_vm_vmacache_event(VMACACHE_FIND_HITS);
+				return vma;
+			}
 		}
+		if (++idx == VMACACHE_SIZE)
+			idx = 0;
 	}
 
 	return NULL;
@@ -115,6 +124,7 @@ struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
 					   unsigned long start,
 					   unsigned long end)
 {
+	int idx = VMACACHE_HASH(addr);
 	int i;
 
 	count_vm_vmacache_event(VMACACHE_FIND_CALLS);
@@ -123,12 +133,14 @@ struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
 		return NULL;
 
 	for (i = 0; i < VMACACHE_SIZE; i++) {
-		struct vm_area_struct *vma = current->vmacache.vmas[i];
+		struct vm_area_struct *vma = current->vmacache.vmas[idx];
 
 		if (vma && vma->vm_start == start && vma->vm_end == end) {
 			count_vm_vmacache_event(VMACACHE_FIND_HITS);
 			return vma;
 		}
+		if (++idx == VMACACHE_SIZE)
+			idx = 0;
 	}
 
 	return NULL;
