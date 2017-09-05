Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E62A280300
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 11:30:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 187so4317056wmn.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 08:30:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k8si459179wmh.181.2017.09.05.08.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 08:30:47 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v85FSaL2140835
	for <linux-mm@kvack.org>; Tue, 5 Sep 2017 11:30:46 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2csweqc246-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 05 Sep 2017 11:30:46 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 5 Sep 2017 16:30:44 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH] mm: Fix mem_cgroup_oom_disable() call missing
Date: Tue,  5 Sep 2017 17:30:39 +0200
Message-Id: <1504625439-31313-1-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, linux-kernel@vger.kernel.org

Seen while reading the code, in handle_mm_fault(), in the case
arch_vma_access_permitted() is failing the call to mem_cgroup_oom_disable()
is not made.

To fix that, move the call to mem_cgroup_oom_enable() after calling
arch_vma_access_permitted() as it should not have entered the memcg OOM.

Fixes: bae473a423f6 ("mm: introduce fault_env")
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 56e48e4593cb..274547075486 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3888,6 +3888,11 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	/* do counter updates before entering really critical section. */
 	check_sync_rss_stat(current);
 
+	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
+					    flags & FAULT_FLAG_INSTRUCTION,
+					    flags & FAULT_FLAG_REMOTE))
+		return VM_FAULT_SIGSEGV;
+
 	/*
 	 * Enable the memcg OOM handling for faults triggered in user
 	 * space.  Kernel faults are handled more gracefully.
@@ -3895,11 +3900,6 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	if (flags & FAULT_FLAG_USER)
 		mem_cgroup_oom_enable();
 
-	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
-					    flags & FAULT_FLAG_INSTRUCTION,
-					    flags & FAULT_FLAG_REMOTE))
-		return VM_FAULT_SIGSEGV;
-
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
 	else
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
