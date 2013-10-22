Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id A1A2F6B00EC
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 11:31:26 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so8813103pbb.0
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:31:26 -0700 (PDT)
Received: from psmtp.com ([74.125.245.165])
        by mx.google.com with SMTP id gu5si12576648pac.101.2013.10.22.08.31.24
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 08:31:25 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 22 Oct 2013 21:01:20 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id D8006394296F
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:15 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9MBVOEx46858480
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 17:01:26 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9MBSXCs023071
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 16:58:34 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 3/9] mm: Move change_prot_numa outside CONFIG_ARCH_USES_NUMA_PROT_NONE
Date: Tue, 22 Oct 2013 16:58:14 +0530
Message-Id: <1382441300-1513-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1382441300-1513-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

change_prot_numa should work even if _PAGE_NUMA != _PAGE_PROTNONE.
On archs like ppc64 that don't use _PAGE_PROTNONE and also have
a separate page table outside linux pagetable, we just need to
make sure that when calling change_prot_numa we flush the
hardware page table entry so that next page access  result in a numa
fault.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/mm.h | 3 ---
 mm/mempolicy.c     | 9 ---------
 2 files changed, 12 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55e..5ab0e22 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1668,11 +1668,8 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
-#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
 unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
-#endif
-
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0472964..efb4300 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -612,7 +612,6 @@ static inline int queue_pages_pgd_range(struct vm_area_struct *vma,
 	return 0;
 }
 
-#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
 /*
  * This is used to mark a range of virtual addresses to be inaccessible.
  * These are later cleared by a NUMA hinting fault. Depending on these
@@ -626,7 +625,6 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long end)
 {
 	int nr_updated;
-	BUILD_BUG_ON(_PAGE_NUMA != _PAGE_PROTNONE);
 
 	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
 	if (nr_updated)
@@ -634,13 +632,6 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 
 	return nr_updated;
 }
-#else
-static unsigned long change_prot_numa(struct vm_area_struct *vma,
-			unsigned long addr, unsigned long end)
-{
-	return 0;
-}
-#endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
 
 /*
  * Walk through page tables and collect pages to be migrated.
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
