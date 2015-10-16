Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2A482F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 08:07:19 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so6586992wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 05:07:18 -0700 (PDT)
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com. [195.75.94.113])
        by mx.google.com with ESMTPS id y3si23527736wju.91.2015.10.16.05.07.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 05:07:18 -0700 (PDT)
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 16 Oct 2015 13:07:17 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 93EBA1B0804B
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:07:20 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9GC7E2334865180
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:07:14 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9GC7Bus009860
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 06:07:13 -0600
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm: clearing pte in clear_soft_dirty()
Date: Fri, 16 Oct 2015 14:07:06 +0200
Message-Id: <8352032008c7d9f1eee8d39599888a4cbe570bf7.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulus@samba.org
Cc: criu@openvz.org

As mentioned in the commit 56eecdb912b5 ("mm: Use ptep/pmdp_set_numa()
for updating _PAGE_NUMA bit"), architecture like ppc64 doesn't do
tlb flush in set_pte/pmd functions.

So when dealing with existing pte in clear_soft_dirty, the pte must
be cleared before being modified.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/proc/task_mmu.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e2d46adb54b4..c9454ee39b28 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -753,19 +753,20 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 	pte_t ptent = *pte;
 
 	if (pte_present(ptent)) {
+		ptent = ptep_modify_prot_start(vma->vm_mm, addr, pte);
 		ptent = pte_wrprotect(ptent);
 		ptent = pte_clear_flags(ptent, _PAGE_SOFT_DIRTY);
+		ptep_modify_prot_commit(vma->vm_mm, addr, pte, ptent);
 	} else if (is_swap_pte(ptent)) {
 		ptent = pte_swp_clear_soft_dirty(ptent);
+		set_pte_at(vma->vm_mm, addr, pte, ptent);
 	}
-
-	set_pte_at(vma->vm_mm, addr, pte, ptent);
 }
 
 static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmdp)
 {
-	pmd_t pmd = *pmdp;
+	pmd_t pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
 
 	pmd = pmd_wrprotect(pmd);
 	pmd = pmd_clear_flags(pmd, _PAGE_SOFT_DIRTY);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
