Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id A82AF6B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 14:16:25 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so26152984pbb.8
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 11:16:25 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id bt3si37127304pbb.224.2013.12.05.11.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 11:16:24 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 6 Dec 2013 05:16:20 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 10B832CE858F
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 05:38:34 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB5IKIaX983300
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 05:20:19 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB5IcWi9025616
	for <linux-mm@kvack.org>; Fri, 6 Dec 2013 05:38:33 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V3] mm: Move change_prot_numa outside CONFIG_ARCH_USES_NUMA_PROT_NONE
Date: Fri,  6 Dec 2013 00:08:22 +0530
Message-Id: <1386268702-30806-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mgorman@suse.de, riel@redhat.com
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

change_prot_numa should work even if _PAGE_NUMA != _PAGE_PROTNONE.
On archs like ppc64 that don't use _PAGE_PROTNONE and also have
a separate page table outside linux pagetable, we just need to
make sure that when calling change_prot_numa we flush the
hardware page table entry so that next page access  result in a numa
fault.

We still need to make sure we use the numa faulting logic only
when CONFIG_NUMA_BALANCING is set. This implies the migrate-on-fault
(Lazy migration) via mbind will only work if CONFIG_NUMA_BALANCING
is set.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
Previous discussion around the patch can be found at
http://article.gmane.org/gmane.linux.kernel.mm/109305

changes from V2:
* Move the numa faulting definition within CONFIG_NUMA_BALANCING

 include/linux/mm.h | 2 +-
 mm/mempolicy.c     | 5 ++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd000cf29..a7b4e310bf42 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1842,7 +1842,7 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
-#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
+#ifdef CONFIG_NUMA_BALANCING
 unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long start, unsigned long end);
 #endif
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index eca4a3129129..9f73b29d304d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -613,7 +613,7 @@ static inline int queue_pages_pgd_range(struct vm_area_struct *vma,
 	return 0;
 }
 
-#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
+#ifdef CONFIG_NUMA_BALANCING
 /*
  * This is used to mark a range of virtual addresses to be inaccessible.
  * These are later cleared by a NUMA hinting fault. Depending on these
@@ -627,7 +627,6 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long end)
 {
 	int nr_updated;
-	BUILD_BUG_ON(_PAGE_NUMA != _PAGE_PROTNONE);
 
 	nr_updated = change_protection(vma, addr, end, vma->vm_page_prot, 0, 1);
 	if (nr_updated)
@@ -641,7 +640,7 @@ static unsigned long change_prot_numa(struct vm_area_struct *vma,
 {
 	return 0;
 }
-#endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
+#endif /* CONFIG_NUMA_BALANCING */
 
 /*
  * Walk through page tables and collect pages to be migrated.
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
