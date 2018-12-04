Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB87A6B710C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:36:10 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 74so15137650pfk.12
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:36:10 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id l184si16016164pgd.523.2018.12.04.14.36.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 14:36:09 -0800 (PST)
Date: Tue, 4 Dec 2018 14:36:03 -0800
From: tip-bot for Lance Roy <tipbot@zytor.com>
Message-ID: <tip-35f3aa39f243e8c95e12a2b2d05b1d2e62ac58a4@git.kernel.org>
Reply-To: linux-mm@kvack.org, akpm@linux-foundation.org, jack@suse.cz,
        yang.shi@linux.alibaba.com, linux-kernel@vger.kernel.org,
        kirill.shutemov@linux.intel.com, vbabka@suse.cz, ldr709@gmail.com,
        tglx@linutronix.de, hpa@zytor.com, paulmck@linux.ibm.com,
        mgorman@techsingularity.net, mingo@kernel.org, shakeelb@google.com,
        mawilcox@microsoft.com
Subject: [tip:core/rcu] mm: Replace spin_is_locked() with lockdep
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: tglx@linutronix.de, ldr709@gmail.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, yang.shi@linux.alibaba.com, jack@suse.cz, mawilcox@microsoft.com, shakeelb@google.com, mgorman@techsingularity.net, mingo@kernel.org, paulmck@linux.ibm.com, hpa@zytor.com, linux-mm@kvack.org, akpm@linux-foundation.org

Commit-ID:  35f3aa39f243e8c95e12a2b2d05b1d2e62ac58a4
Gitweb:     https://git.kernel.org/tip/35f3aa39f243e8c95e12a2b2d05b1d2e62ac58a4
Author:     Lance Roy <ldr709@gmail.com>
AuthorDate: Thu, 4 Oct 2018 23:45:47 -0700
Committer:  Paul E. McKenney <paulmck@linux.ibm.com>
CommitDate: Mon, 12 Nov 2018 09:06:22 -0800

mm: Replace spin_is_locked() with lockdep

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
