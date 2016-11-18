Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65FBE6B0402
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:34 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so247216820pgc.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 03:10:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g80si7784751pfg.11.2016.11.18.03.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 03:10:31 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIB8oRT058711
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:30 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26svx42ajp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 06:10:30 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 11:08:57 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B49FB17D806F
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:11:19 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAIB8sLB39518394
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:08:54 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAIB8sHD020872
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 04:08:54 -0700
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 3/7] mm: Introduce pte_spinlock
Date: Fri, 18 Nov 2016 12:08:47 +0100
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
In-Reply-To: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
References: <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
Message-Id: <476f370cb4d118d455182640e0bce26e6f785bec.1479465699.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

This is needed because in handle_pte_fault() pte_offset_map() called
and then fe->ptl is fetched and spin_locked.

This was previously embedded in the call to pte_offset_map_lock().

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 08922b34575d..d19800904272 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2095,6 +2095,13 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 	return VM_FAULT_WRITE;
 }
 
+static bool pte_spinlock(struct fault_env *fe)
+{
+	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
+	spin_lock(fe->ptl);
+	return true;
+}
+
 static bool pte_map_lock(struct fault_env *fe)
 {
 	fe->pte = pte_offset_map_lock(fe->vma->vm_mm, fe->pmd, fe->address, &fe->ptl);
@@ -3366,8 +3373,8 @@ static int do_numa_page(struct fault_env *fe, pte_t pte)
 	* page table entry is not accessible, so there would be no
 	* concurrent hardware modifications to the PTE.
 	*/
-	fe->ptl = pte_lockptr(vma->vm_mm, fe->pmd);
-	spin_lock(fe->ptl);
+	if (!pte_spinlock(fe))
+		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*fe->pte, pte))) {
 		pte_unmap_unlock(fe->pte, fe->ptl);
 		goto out;
@@ -3535,8 +3542,8 @@ static int handle_pte_fault(struct fault_env *fe)
 	if (pte_protnone(entry) && vma_is_accessible(fe->vma))
 		return do_numa_page(fe, entry);
 
-	fe->ptl = pte_lockptr(fe->vma->vm_mm, fe->pmd);
-	spin_lock(fe->ptl);
+	if (!pte_spinlock(fe))
+		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*fe->pte, entry)))
 		goto unlock;
 	if (fe->flags & FAULT_FLAG_WRITE) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
