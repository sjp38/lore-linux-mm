Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0216B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 04:04:04 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so18534097pab.27
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 01:04:03 -0800 (PST)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id wm3si54150066pab.223.2014.01.06.01.04.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 01:04:02 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 6 Jan 2014 19:03:59 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 456B53578054
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 20:03:57 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0693amJ5374302
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 20:03:44 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0693nPl005905
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 20:03:49 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3 2/2] powerpc: thp: Fix crash on mremap
Date: Mon,  6 Jan 2014 14:33:32 +0530
Message-Id: <1388999012-14424-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1388999012-14424-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch fix the below crash

NIP [c00000000004cee4] .__hash_page_thp+0x2a4/0x440
LR [c0000000000439ac] .hash_page+0x18c/0x5e0
...
Call Trace:
[c000000736103c40] [00001ffffb000000] 0x1ffffb000000(unreliable)
[437908.479693] [c000000736103d50] [c0000000000439ac] .hash_page+0x18c/0x5e0
[437908.479699] [c000000736103e30] [c00000000000924c] .do_hash_page+0x4c/0x58

On ppc64 we use the pgtable for storing the hpte slot information and
store address to the pgtable at a constant offset (PTRS_PER_PMD) from
pmd. On mremap, when we switch the pmd, we need to withdraw and deposit
the pgtable again, so that we find the pgtable at PTRS_PER_PMD offset
from new pmd.

We also want to move the withdraw and deposit before the set_pmd so
that, when page fault find the pmd as trans huge we can be sure that
pgtable can be located at the offset.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h | 14 ++++++++++++++
 include/asm-generic/pgtable.h            | 12 ++++++++++++
 mm/huge_memory.c                         | 14 +++++---------
 3 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 9935e9b79524..ff3afce40f3b 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -12,6 +12,7 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/spinlock.h>
 /*
  * This is the default implementation of various PTE accessors, it's
  * used in all cases except Book3S with 64K pages where we have a
@@ -459,5 +460,18 @@ extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 #define __HAVE_ARCH_PMDP_INVALIDATE
 extern void pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
+
+#define pmd_move_must_withdraw pmd_move_must_withdraw
+static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
+					 spinlock_t *old_pmd_ptl)
+{
+	/*
+	 * Archs like ppc64 use pgtable to store per pmd
+	 * specific information. So when we switch the pmd,
+	 * we should also withdraw and deposit the pgtable
+	 */
+	return true;
+}
+
 #endif /* __ASSEMBLY__ */
 #endif /* _ASM_POWERPC_PGTABLE_PPC64_H_ */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index db0923458940..8e4f41d9af4d 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -558,6 +558,18 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 }
 #endif
 
+#ifndef pmd_move_must_withdraw
+static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
+					 spinlock_t *old_pmd_ptl)
+{
+	/*
+	 * With split pmd lock we also need to move preallocated
+	 * PTE page table if new_pmd is on different PMD page table.
+	 */
+	return new_pmd_ptl != old_pmd_ptl;
+}
+#endif
+
 /*
  * This function is meant to be used by sites walking pagetables with
  * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9c0b17295ba0..b77bb5df4db9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1502,19 +1502,15 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
 			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
 		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
-		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
-		if (new_ptl != old_ptl) {
-			pgtable_t pgtable;
 
-			/*
-			 * Move preallocated PTE page table if new_pmd is on
-			 * different PMD page table.
-			 */
+		if (pmd_move_must_withdraw(new_ptl, old_ptl)) {
+			pgtable_t pgtable;
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
-
-			spin_unlock(new_ptl);
 		}
+		set_pmd_at(mm, new_addr, new_pmd, pmd_mksoft_dirty(pmd));
+		if (new_ptl != old_ptl)
+			spin_unlock(new_ptl);
 		spin_unlock(old_ptl);
 	}
 out:
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
