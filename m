Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id ACF406B00D2
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 08:56:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 22:56:16 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8CCuhFN27066526
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:56:43 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8CCuhIU018742
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:56:43 +1000
Message-ID: <50508689.50904@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 20:56:41 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] thp: move release mmap_sem lock out of khugepaged_alloc_page
References: <50508632.9090003@linux.vnet.ibm.com>
In-Reply-To: <50508632.9090003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

To make the code more clear, move release the lock out of khugepaged_alloc_page

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 66d2bc6..5622347 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1854,11 +1854,6 @@ static struct page
 	*hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
 				      node, __GFP_OTHER_NODE);

-	/*
-	 * After allocating the hugepage, release the mmap_sem read lock in
-	 * preparation for taking it in write mode.
-	 */
-	up_read(&mm->mmap_sem);
 	if (unlikely(!*hpage)) {
 		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
@@ -1905,7 +1900,6 @@ static struct page
 		       struct vm_area_struct *vma, unsigned long address,
 		       int node)
 {
-	up_read(&mm->mmap_sem);
 	VM_BUG_ON(!*hpage);
 	return  *hpage;
 }
@@ -1931,8 +1925,14 @@ static void collapse_huge_page(struct mm_struct *mm,

 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);

-	/* release the mmap_sem read lock. */
 	new_page = khugepaged_alloc_page(hpage, mm, vma, address, node);
+
+	/*
+	 * After allocating the hugepage, release the mmap_sem read lock in
+	 * preparation for taking it in write mode.
+	 */
+	up_read(&mm->mmap_sem);
+
 	if (!new_page)
 		return;

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
