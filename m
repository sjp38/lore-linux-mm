Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7540A6B0078
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:16:11 -0400 (EDT)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:15:39 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DB7YZv23920708
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:07:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBG569000930
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:16:05 +1000
Message-ID: <5028E1F2.5070407@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:16:02 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 08/12] thp: release page in page pre-alloc path
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

If NUMA is enabled, we can release the page in the page pre-alloc operation,
then the CONFIG_NUMA dependent code can be reduced

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 42d3d74..050b8d0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1879,15 +1879,12 @@ static void collapse_huge_page(struct mm_struct *mm,
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
+	*hpage = new_page;
 	count_vm_event(THP_COLLAPSE_ALLOC);
 #endif

-	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
-#ifdef CONFIG_NUMA
-		put_page(new_page);
-#endif
+	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
 		return;
-	}

 	/*
 	 * Prevent all access to pagetables with the exception of
@@ -1992,9 +1989,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	prepare_pmd_huge_pte(pgtable, mm);
 	spin_unlock(&mm->page_table_lock);

-#ifndef CONFIG_NUMA
 	*hpage = NULL;
-#endif
+
 	khugepaged_pages_collapsed++;
 out_up_write:
 	up_write(&mm->mmap_sem);
@@ -2002,9 +1998,6 @@ out_up_write:

 out:
 	mem_cgroup_uncharge_page(new_page);
-#ifdef CONFIG_NUMA
-	put_page(new_page);
-#endif
 	goto out_up_write;
 }

@@ -2275,8 +2268,6 @@ static void khugepaged_do_scan(void)
 	barrier(); /* write khugepaged_pages_to_scan to local stack */

 	while (progress < pages) {
-		cond_resched();
-
 #ifndef CONFIG_NUMA
 		if (!hpage)
 			hpage = khugepaged_alloc_hugepage(&wait);
@@ -2289,8 +2280,12 @@ static void khugepaged_do_scan(void)
 				break;
 			wait = false;
 			khugepaged_alloc_sleep();
+		} else if (hpage) {
+			put_page(hpage);
+			hpage = NULL;
 		}
 #endif
+		cond_resched();

 		if (unlikely(kthread_should_stop() || freezing(current)))
 			break;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
