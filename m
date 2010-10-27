Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6A18C6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:21:38 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] mm: don't flush TLB when propagate PTE access bit to struct page.
Date: Wed, 27 Oct 2010 10:21:30 -0700
Message-Id: <1288200090-23554-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

kswapd's use case of hardware PTE accessed bit is to approximate page LRU.  The
ActiveLRU demotion to InactiveLRU are not base on accessed bit, while it is only
used to promote when a page is on inactive LRU list.  All of the state transitions
are triggered by memory pressure and thus has weak relationship with respect to
time.  In addition, hardware already transparently flush tlb whenever CPU context
switch processes and given limited hardware TLB resource, the time period in
which a page is accessed but not yet propagated to struct page is very small
in practice. With the nature of approximation, kernel really don't need to flush TLB
for changing PTE's access bit.  This commit removes the flush operation from it.

Signed-off-by: Ying Han <yinghan@google.com>
Singed-off-by: Ken Chen <kenchen@google.com>
---
 include/linux/mmu_notifier.h |   12 ++++++++++++
 mm/rmap.c                    |    2 +-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 4e02ee2..be32c51 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -254,6 +254,17 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
+#define ptep_clear_young_notify(__vma, __address, __ptep)		\
+({									\
+	int __young;							\
+	struct vm_area_struct *___vma = __vma;				\
+	unsigned long ___address = __address;				\
+	__young = ptep_test_and_clear_young(___vma, ___address, __ptep);\
+	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
+						  ___address);		\
+	__young;							\
+})
+
 #define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
 ({									\
 	struct mm_struct *___mm = __mm;					\
@@ -304,6 +315,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 }
 
+#define ptep_clear_young_notify ptep_test_and_clear_young
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
 #define set_pte_at_notify set_pte_at
diff --git a/mm/rmap.c b/mm/rmap.c
index 92e6757..96f2553 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -506,7 +506,7 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		goto out_unmap;
 	}
 
-	if (ptep_clear_flush_young_notify(vma, address, pte)) {
+	if (ptep_clear_young_notify(vma, address, pte)) {
 		/*
 		 * Don't treat a reference through a sequentially read
 		 * mapping as such.  If the page has been used in
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
