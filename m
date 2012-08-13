Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5D2206B007D
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:16:49 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:16:13 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DB7osq20447412
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:07:50 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBGUUC002553
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:16:30 +1000
Message-ID: <5028E20C.3080607@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:16:28 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 09/12] thp: introduce khugepaged_prealloc_page and khugepaged_alloc_page
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

They are used to abstract the difference between NUMA enabled and NUMA disabled
to make the code more readable

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |  166 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 98 insertions(+), 68 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 050b8d0..82f6cce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1833,28 +1833,34 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 	}
 }

-static void collapse_huge_page(struct mm_struct *mm,
-			       unsigned long address,
-			       struct page **hpage,
-			       struct vm_area_struct *vma,
-			       int node)
+static void khugepaged_alloc_sleep(void)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd, _pmd;
-	pte_t *pte;
-	pgtable_t pgtable;
-	struct page *new_page;
-	spinlock_t *ptl;
-	int isolated;
-	unsigned long hstart, hend;
+	wait_event_freezable_timeout(khugepaged_wait, false,
+			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
+}

-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-#ifndef CONFIG_NUMA
-	up_read(&mm->mmap_sem);
-	VM_BUG_ON(!*hpage);
-	new_page = *hpage;
-#else
+#ifdef CONFIG_NUMA
+static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
+{
+	if (IS_ERR(*hpage)) {
+		if (!*wait)
+			return false;
+
+		*wait = false;
+		khugepaged_alloc_sleep();
+	} else if (*hpage) {
+		put_page(*hpage);
+		*hpage = NULL;
+	}
+
+	return true;
+}
+
+static struct page
+*khugepaged_alloc_page(struct page **hpage, struct mm_struct *mm,
+		       struct vm_area_struct *vma, unsigned long address,
+		       int node)
+{
 	VM_BUG_ON(*hpage);
 	/*
 	 * Allocate the page while the vma is still valid and under
@@ -1866,7 +1872,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * mmap_sem in read mode is good idea also to allow greater
 	 * scalability.
 	 */
-	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
+	*hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
 				      node, __GFP_OTHER_NODE);

 	/*
@@ -1874,15 +1880,81 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * preparation for taking it in write mode.
 	 */
 	up_read(&mm->mmap_sem);
-	if (unlikely(!new_page)) {
+	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
-		return;
+		return NULL;
 	}
-	*hpage = new_page;
+
 	count_vm_event(THP_COLLAPSE_ALLOC);
+	return *hpage;
+}
+#else
+static struct page *khugepaged_alloc_hugepage(bool *wait)
+{
+	struct page *hpage;
+
+	do {
+		hpage = alloc_hugepage(khugepaged_defrag());
+		if (!hpage) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
+			if (!*wait)
+				return NULL;
+
+			*wait = false;
+			khugepaged_alloc_sleep();
+		} else
+			count_vm_event(THP_COLLAPSE_ALLOC);
+	} while (unlikely(!hpage) && likely(khugepaged_enabled()));
+
+	return hpage;
+}
+
+static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
+{
+	if (!*hpage)
+		*hpage = khugepaged_alloc_hugepage(wait);
+
+	if (unlikely(!*hpage))
+		return false;
+
+	return true;
+}
+
+static struct page
+*khugepaged_alloc_page(struct page **hpage, struct mm_struct *mm,
+		       struct vm_area_struct *vma, unsigned long address,
+		       int node)
+{
+	up_read(&mm->mmap_sem);
+	VM_BUG_ON(!*hpage);
+	return  *hpage;
+}
 #endif

+static void collapse_huge_page(struct mm_struct *mm,
+				   unsigned long address,
+				   struct page **hpage,
+				   struct vm_area_struct *vma,
+				   int node)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd, _pmd;
+	pte_t *pte;
+	pgtable_t pgtable;
+	struct page *new_page;
+	spinlock_t *ptl;
+	int isolated;
+	unsigned long hstart, hend;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+	/* release the mmap_sem read lock. */
+	new_page = khugepaged_alloc_page(hpage, mm, vma, address, node);
+	if (!new_page)
+		return;
+
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
 		return;

@@ -2230,34 +2302,6 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }

-static void khugepaged_alloc_sleep(void)
-{
-	wait_event_freezable_timeout(khugepaged_wait, false,
-			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
-}
-
-#ifndef CONFIG_NUMA
-static struct page *khugepaged_alloc_hugepage(bool *wait)
-{
-	struct page *hpage;
-
-	do {
-		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage) {
-			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
-			if (!*wait)
-				return NULL;
-
-			*wait = false;
-			khugepaged_alloc_sleep();
-		} else
-			count_vm_event(THP_COLLAPSE_ALLOC);
-	} while (unlikely(!hpage) && likely(khugepaged_enabled()));
-
-	return hpage;
-}
-#endif
-
 static void khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
@@ -2268,23 +2312,9 @@ static void khugepaged_do_scan(void)
 	barrier(); /* write khugepaged_pages_to_scan to local stack */

 	while (progress < pages) {
-#ifndef CONFIG_NUMA
-		if (!hpage)
-			hpage = khugepaged_alloc_hugepage(&wait);
-
-		if (unlikely(!hpage))
+		if (!khugepaged_prealloc_page(&hpage, &wait))
 			break;
-#else
-		if (IS_ERR(hpage)) {
-			if (!wait)
-				break;
-			wait = false;
-			khugepaged_alloc_sleep();
-		} else if (hpage) {
-			put_page(hpage);
-			hpage = NULL;
-		}
-#endif
+
 		cond_resched();

 		if (unlikely(kthread_should_stop() || freezing(current)))
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
