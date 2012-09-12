Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 5BF2E6B00D9
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 08:57:41 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 22:56:03 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8CCvP4r17694782
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:57:25 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8CCvPDc019289
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:57:25 +1000
Message-ID: <505086B3.6070603@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 20:57:23 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] thp: introduce khugepaged_cleanup_page
References: <50508632.9090003@linux.vnet.ibm.com>
In-Reply-To: <50508632.9090003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

It is used to release the page on the fail path, then the page need not
be cleaned up in khugepaged_prealloc_page anymore

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5622347..de0a028 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1827,9 +1827,6 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 		*wait = false;
 		*hpage = NULL;
 		khugepaged_alloc_sleep();
-	} else if (*hpage) {
-		put_page(*hpage);
-		*hpage = NULL;
 	}

 	return true;
@@ -1863,6 +1860,13 @@ static struct page
 	count_vm_event(THP_COLLAPSE_ALLOC);
 	return *hpage;
 }
+
+static void khugepaged_cleanup_page(struct page **hpage)
+{
+	VM_BUG_ON(!*hpage);
+	put_page(*hpage);
+	*hpage = NULL;
+}
 #else
 static struct page *khugepaged_alloc_hugepage(bool *wait)
 {
@@ -1903,6 +1907,10 @@ static struct page
 	VM_BUG_ON(!*hpage);
 	return  *hpage;
 }
+
+static void khugepaged_cleanup_page(struct page **hpage)
+{
+}
 #endif

 static void collapse_huge_page(struct mm_struct *mm,
@@ -1936,8 +1944,10 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;

-	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
+	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
+		khugepaged_cleanup_page(hpage);
 		return;
+	}

 	/*
 	 * Prevent all access to pagetables with the exception of
@@ -2048,6 +2058,7 @@ out_up_write:
 	return;

 out:
+	khugepaged_cleanup_page(hpage);
 	mem_cgroup_uncharge_page(new_page);
 	goto out_up_write;
 }
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
