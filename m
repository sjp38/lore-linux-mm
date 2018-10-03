Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F39A6B000A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 01:40:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so1543373pge.5
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 22:40:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor183634pgq.14.2018.10.02.22.40.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Oct 2018 22:40:15 -0700 (PDT)
From: Lance Roy <ldr709@gmail.com>
Subject: [PATCH 13/16] mm: Replace spin_is_locked() with lockdep
Date: Tue,  2 Oct 2018 22:38:59 -0700
Message-Id: <20181003053902.6910-14-ldr709@gmail.com>
In-Reply-To: <20181003053902.6910-1-ldr709@gmail.com>
References: <20181003053902.6910-1-ldr709@gmail.com>
Reply-To: Lance Roy <ldr709@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Paul E. McKenney" <paulmck@linux.ibm.com>, Lance Roy <ldr709@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org

lockdep_assert_held() is better suited to checking locking requirements,
since it won't get confused when someone else holds the lock. This is
also a step towards possibly removing spin_is_locked().

Signed-off-by: Lance Roy <ldr709@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: <linux-mm@kvack.org>
---
 mm/khugepaged.c | 4 ++--
 mm/swap.c       | 3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index a31d740e6cd1..80f12467ccb3 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1225,7 +1225,7 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 {
 	struct mm_struct *mm = mm_slot->mm;
 
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+	lockdep_assert_held(&khugepaged_mm_lock);
 
 	if (khugepaged_test_exit(mm)) {
 		/* free mm_slot */
@@ -1665,7 +1665,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	int progress = 0;
 
 	VM_BUG_ON(!pages);
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+	lockdep_assert_held(&khugepaged_mm_lock);
 
 	if (khugepaged_scan.mm_slot)
 		mm_slot = khugepaged_scan.mm_slot;
diff --git a/mm/swap.c b/mm/swap.c
index 26fc9b5f1b6c..c89eb442c0bf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -824,8 +824,7 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 	VM_BUG_ON_PAGE(!PageHead(page), page);
 	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
 	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
-	VM_BUG_ON(NR_CPUS != 1 &&
-		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
+	lockdep_assert_held(&lruvec_pgdat(lruvec)->lru_lock);
 
 	if (!list)
 		SetPageLRU(page_tail);
-- 
2.19.0
