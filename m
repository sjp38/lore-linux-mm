Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C595B828E8
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 04:15:12 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kp3so5179801pab.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 01:15:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qc8si52766216pac.39.2016.02.09.01.15.12
        for <linux-mm@kvack.org>;
        Tue, 09 Feb 2016 01:15:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp, vmstats: count deferred split events
Date: Tue,  9 Feb 2016 12:15:02 +0300
Message-Id: <1455009302-57702-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Counts how many times we put a THP in split queue. Currently, it happens
on partial unmap of a THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/vm_event_item.h | 1 +
 mm/huge_memory.c              | 1 +
 mm/vmstat.c                   | 1 +
 3 files changed, 3 insertions(+)

diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 67c1dbd19c6d..b79e831006b0 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -71,6 +71,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		THP_COLLAPSE_ALLOC_FAILED,
 		THP_SPLIT_PAGE,
 		THP_SPLIT_PAGE_FAILED,
+		THP_DEFERRED_SPLIT_PAGE,
 		THP_SPLIT_PMD,
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c13ced03a2c5..db244d6a6feb 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3403,6 +3403,7 @@ void deferred_split_huge_page(struct page *page)
 
 	spin_lock_irqsave(&pgdata->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
+		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
 		list_add_tail(page_deferred_list(page), &pgdata->split_queue);
 		pgdata->split_queue_len++;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 69ce64f7b8d7..05c6ba2534fe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -847,6 +847,7 @@ const char * const vmstat_text[] = {
 	"thp_collapse_alloc_failed",
 	"thp_split_page",
 	"thp_split_page_failed",
+	"thp_deferred_split_page",
 	"thp_split_pmd",
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
