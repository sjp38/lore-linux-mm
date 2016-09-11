Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A02366B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 18:54:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u14so83245084lfd.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 15:54:29 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id hn1si12714218wjb.164.2016.09.11.15.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 15:54:28 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a6so11220734wmc.2
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 15:54:27 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Date: Sun, 11 Sep 2016 23:54:25 +0100
Message-Id: <20160911225425.10388-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net, torvalds@linux-foundation.org, riel@redhat.com, tbsaunde@tbsaunde.org, robert@ocallahan.org, Lorenzo Stoakes <lstoakes@gmail.com>

The NUMA balancing logic uses an arch-specific PROT_NONE page table flag defined
by pte_protnone() or pmd_protnone() to mark PTEs or huge page PMDs respectively
as requiring balancing upon a subsequent page fault. User-defined PROT_NONE
memory regions which also have this flag set will not normally invoke the NUMA
balancing code as do_page_fault() will send a segfault to the process before
handle_mm_fault() is even called.

However if access_remote_vm() is invoked to access a PROT_NONE region of memory,
handle_mm_fault() is called via faultin_page() and __get_user_pages() without
any access checks being performed, meaning the NUMA balancing logic is
incorrectly invoked on a non-NUMA memory region.

A simple means of triggering this problem is to access PROT_NONE mmap'd memory
using /proc/self/mem which reliably results in the NUMA handling functions being
invoked when CONFIG_NUMA_BALANCING is set.

This issue was reported in bugzilla (issue 99101) which includes some simple
repro code.

There are BUG_ON() checks in do_numa_page() and do_huge_pmd_numa_page() added at
commit c0e7cad to avoid accidentally provoking strange behaviour by attempting
to apply NUMA balancing to pages that are in fact PROT_NONE. The BUG_ON()'s are
consistently triggered by the repro.

This patch moves the PROT_NONE check into mm/memory.c rather than invoking
BUG_ON() as faulting in these pages via faultin_page() is a valid reason for
reaching the NUMA check with the PROT_NONE page table flag set and is therefore
not always a bug.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=99101
Reported-by: Trevor Saunders <tbsaunde@tbsaunde.org>
Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 mm/huge_memory.c |  3 ---
 mm/memory.c      | 12 +++++++-----
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d76700d..954be55 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1198,9 +1198,6 @@ int do_huge_pmd_numa_page(struct fault_env *fe, pmd_t pmd)
 	bool was_writable;
 	int flags = 0;

-	/* A PROT_NONE fault should not end up here */
-	BUG_ON(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)));
-
 	fe->ptl = pmd_lock(vma->vm_mm, fe->pmd);
 	if (unlikely(!pmd_same(pmd, *fe->pmd)))
 		goto out_unlock;
diff --git a/mm/memory.c b/mm/memory.c
index 020226b..aebc04f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3351,9 +3351,6 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	bool was_writable = pte_write(pte);
 	int flags = 0;

-	/* A PROT_NONE fault should not end up here */
-	BUG_ON(!(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)));
-
 	/*
 	* The "pte" at this point cannot be used safely without
 	* validation through pte_unmap_same(). It's of NUMA type but
@@ -3458,6 +3455,11 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
 	return VM_FAULT_FALLBACK;
 }

+static inline bool vma_is_accessible(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE);
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3524,7 +3526,7 @@ static int handle_pte_fault(struct fault_env *fe)
 	if (!pte_present(entry))
 		return do_swap_page(fe, entry);

-	if (pte_protnone(entry))
+	if (pte_protnone(entry) && vma_is_accessible(fe->vma))
 		return do_numa_page(fe, entry);

 	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
@@ -3590,7 +3592,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,

 		barrier();
 		if (pmd_trans_huge(orig_pmd) || pmd_devmap(orig_pmd)) {
-			if (pmd_protnone(orig_pmd))
+			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&fe, orig_pmd);

 			if ((fe.flags & FAULT_FLAG_WRITE) &&
--
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
