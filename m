Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 92F7D6B03F9
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:24 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 184so2951691ybg.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:09:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c5si1559562ywf.56.2016.11.18.03.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:09:23 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB9Klx145300
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:23 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26sx9jee9b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:09:21 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:08:55 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4ADA317D806A
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:11:19 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8rjM32112664
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:53 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8r9n020861
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:53 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 2/7] mm: Prepare for FAULT_FLAG_SPECULATIVE
Date: Fri, 18 Nov 2016 12:08:46 +0100
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Message-Id: <a07d2d6952e6904ce6bbabfd549f397f3c1c631d.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

From: Peter Zijlstra <peterz@infradead.org>

When speculating faults (without holding mmap_sem) we need to validate
that the vma against which we loaded pages is still valid when we're
ready to install the new PTE.

Therefore, replace the pte_offset_map_lock() calls that (re)take the
PTL with pte_map_lock() which can fail in case we find the VMA changed
since we started the fault.

Instead of passing around the endless list of function arguments,
replace the lot with a single structure so we can change context
without endless function signature changes.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
[port to 4.8 kernel]
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h |  1 +
 mm/memory.c        | 73 +++++++++++++++++++++++++++++++++++++++---------------
 2 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ef815b9cd426..e8e9e3dc4a0d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -280,6 +280,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
+#define FAULT_FLAG_SPECULATIVE	0x200	/* Speculative fault, not holding mmap_sem */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff --git a/mm/memory.c b/mm/memory.c
index 53e0abb35c2e..08922b34575d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2095,6 +2095,12 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 	return VM_FAULT_WRITE;
 }
 
+static bool pte_map_lock(struct fault_env *fe)
+{
+	fe->pte = pte_offset_map_lock(fe->vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
+	return true;
+}
+
 /*
  * Handle the case of a page which we actually need to copy to a new page.
  *
@@ -2122,6 +2128,7 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 	const unsigned long mmun_start = fe->address & PAGE_MASK;
 	const unsigned long mmun_end = mmun_start + PAGE_SIZE;
 	struct mem_cgroup *memcg;
+	int ret = VM_FAULT_OOM;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
@@ -2148,7 +2155,11 @@ static int wp_page_copy(struct fault_env *fe, pte_t orig_pte,
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
-	fe->pte = pte_offset_map_lock(mm, fe->pmd, fe->address, &fe->ptl);
+	if (!pte_map_lock(fe)) {
+		mem_cgroup_cancel_charge(new_page, memcg, false);
+		ret = VM_FAULT_RETRY;
+		goto oom_free_new;
+	}
 	if (likely(pte_same(*fe->pte, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2236,7 +2247,7 @@ oom_free_new:
 oom:
 	if (old_page)
 		put_page(old_page);
-	return VM_FAULT_OOM;
+	return ret;
 }
 
 /*
@@ -2261,8 +2272,12 @@ static int wp_pfn_shared(struct fault_env *fe,  pte_t orig_pte)
 		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
 		if (ret & VM_FAULT_ERROR)
 			return ret;
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-				&fe->ptl);
+
+		if (!pte_map_lock(fe)) {
+			ret |= VM_FAULT_RETRY;
+			return ret;
+		}
+
 		/*
 		 * We might have raced with another page fault while we
 		 * released the pte_offset_map_lock.
@@ -2300,8 +2315,11 @@ static int wp_page_shared(struct fault_env *fe, pte_t orig_pte,
 		 * they did, we just return, as we can count on the
 		 * MMU to tell us if they didn't also make it writable.
 		 */
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-						 &fe->ptl);
+		if (!pte_map_lock(fe)) {
+			unlock_page(old_page);
+			put_page(old_page);
+			return VM_FAULT_RETRY;
+		}
 		if (!pte_same(*fe->pte, orig_pte)) {
 			unlock_page(old_page);
 			pte_unmap_unlock(fe->pte, fe->ptl);
@@ -2365,8 +2383,11 @@ static int do_wp_page(struct fault_env *fe, pte_t orig_pte)
 			get_page(old_page);
 			pte_unmap_unlock(fe->pte, fe->ptl);
 			lock_page(old_page);
-			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
-					fe->address, &fe->ptl);
+			if (!pte_map_lock(fe)) {
+				unlock_page(old_page);
+				put_page(old_page);
+				return VM_FAULT_RETRY;
+			}
 			if (!pte_same(*fe->pte, orig_pte)) {
 				unlock_page(old_page);
 				pte_unmap_unlock(fe->pte, fe->ptl);
@@ -2522,8 +2543,10 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 			 * Back out if somebody else faulted in this pte
 			 * while we released the pte lock.
 			 */
-			fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd,
-					fe->address, &fe->ptl);
+			if (!pte_map_lock(fe)) {
+				delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+				return VM_FAULT_RETRY;
+			}
 			if (likely(pte_same(*fe->pte, orig_pte)))
 				ret = VM_FAULT_OOM;
 			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
@@ -2579,8 +2602,11 @@ int do_swap_page(struct fault_env *fe, pte_t orig_pte)
 	/*
 	 * Back out if somebody else already faulted in this pte.
 	 */
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
+	if (!pte_map_lock(fe)) {
+		ret = VM_FAULT_RETRY;
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto out_page;
+	}
 	if (unlikely(!pte_same(*fe->pte, orig_pte)))
 		goto out_nomap;
 
@@ -2712,6 +2738,7 @@ static int do_anonymous_page(struct fault_env *fe)
 	struct mem_cgroup *memcg;
 	struct page *page;
 	pte_t entry;
+	int ret = 0;
 
 	/* File mapping without ->vm_ops ? */
 	if (vma->vm_flags & VM_SHARED)
@@ -2743,8 +2770,8 @@ static int do_anonymous_page(struct fault_env *fe)
 			!mm_forbids_zeropage(vma->vm_mm)) {
 		entry = pte_mkspecial(pfn_pte(my_zero_pfn(fe->address),
 						vma->vm_page_prot));
-		fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-				&fe->ptl);
+		if (!pte_map_lock(fe))
+			return VM_FAULT_RETRY;
 		if (!pte_none(*fe->pte))
 			goto unlock;
 		/* Deliver the page fault to userland, check inside PT lock */
@@ -2776,8 +2803,12 @@ static int do_anonymous_page(struct fault_env *fe)
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
+	if (!pte_map_lock(fe)) {
+		/* XXX: should be factorized */
+		mem_cgroup_cancel_charge(page, memcg, false);
+		put_page(page);
+		return VM_FAULT_RETRY;
+	}
 	if (!pte_none(*fe->pte))
 		goto release;
 
@@ -2800,7 +2831,7 @@ setpte:
 	update_mmu_cache(vma, fe->address, fe->pte);
 unlock:
 	pte_unmap_unlock(fe->pte, fe->ptl);
-	return 0;
+	return ret;
 release:
 	mem_cgroup_cancel_charge(page, memcg, false);
 	put_page(page);
@@ -2842,7 +2873,7 @@ static int __do_fault(struct fault_env *fe, pgoff_t pgoff,
 		if (ret & VM_FAULT_LOCKED)
 			unlock_page(vmf.page);
 		put_page(vmf.page);
-		return VM_FAULT_HWPOISON;
+		return ret | VM_FAULT_HWPOISON;
 	}
 
 	if (unlikely(!(ret & VM_FAULT_LOCKED)))
@@ -2889,8 +2920,9 @@ map_pte:
 	if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))
 		return VM_FAULT_NOPAGE;
 
-	fe->pte = pte_offset_map_lock(vma->vm_mm, fe->pmd, fe->address,
-			&fe->ptl);
+	if (!pte_map_lock(fe))
+		return VM_FAULT_RETRY;
+
 	return 0;
 }
 
@@ -3152,6 +3184,7 @@ static int do_read_fault(struct fault_env *fe, pgoff_t pgoff)
 	 * something).
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
+		/* XXX: is a call to pte_map_lock(fe) required here ? */
 		ret = do_fault_around(fe, pgoff);
 		if (ret)
 			return ret;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
