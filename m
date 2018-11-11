Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 367F36B0008
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 15:04:56 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id b4-v6so2818157plb.3
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 12:04:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i1si4393866pgs.417.2018.11.11.12.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Nov 2018 12:04:54 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wABJwuF7002470
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 15:04:54 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2npdcu293c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 15:04:54 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 11 Nov 2018 20:04:52 -0000
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: [PATCH tip/core/rcu 6/7] mm: Replace spin_is_locked() with lockdep
Date: Sun, 11 Nov 2018 12:04:42 -0800
In-Reply-To: <20181111200421.GA10551@linux.ibm.com>
References: <20181111200421.GA10551@linux.ibm.com>
Message-Id: <20181111200443.10772-6-paulmck@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, jiangshanlai@gmail.com, dipankar@in.ibm.com, akpm@linux-foundation.org, mathieu.desnoyers@efficios.com, josh@joshtriplett.org, tglx@linutronix.de, peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com, fweisbec@gmail.com, oleg@redhat.com, joel@joelfernandes.org, Lance Roy <ldr709@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, "Paul E . McKenney" <paulmck@linux.ibm.com>

From: Lance Roy <ldr709@gmail.com>

lockdep_assert_held() is better suited to checking locking requirements,
since it only checks if the current thread holds the lock regardless of
whether someone else does. This is also a step towards possibly removing
spin_is_locked().

Signed-off-by: Lance Roy <ldr709@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: <linux-mm@kvack.org>
Signed-off-by: Paul E. McKenney <paulmck@linux.ibm.com>
---
 mm/khugepaged.c | 4 ++--
 mm/swap.c       | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index c13625c1ad5e..7b86600a47c9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1225,7 +1225,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 {
 	struct mm_struct *mm = mm_slot->mm;
 
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+	lockdep_assert_held(&khugepaged_mm_lock);
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
@@ -1631,7 +1631,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	int progress = 0;
 
 	VM_BUG_ON(!pages);
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+	lockdep_assert_held(&khugepaged_mm_lock);
 
 	if (khugepaged_scan.mm_slot)
 		mm_slot = khugepaged_scan.mm_slot;
diff --git a/mm/swap.c b/mm/swap.c
index aa483719922e..5d786019eab9 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -823,8 +823,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
-	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
+	lockdep_assert_held(&lruvec_pgdat(lruvec)->lru_lock);
 
 	if (!list)
 		SetPageLRU(page_tail);
-- 
2.17.1
