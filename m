Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74AE86B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:04:39 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 87-v6so29306763pfq.8
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:04:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor580207pgv.58.2018.10.18.06.04.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Oct 2018 06:04:38 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm: get pfn by page_to_pfn() instead of save in page->private
Date: Thu, 18 Oct 2018 21:04:29 +0800
Message-Id: <20181018130429.37837-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, mgorman@techsingularity.net
Cc: linux-mm@kvack.org, Wei Yang <richard.weiyang@gmail.com>

This is not necessary to save the pfn to page->private.

The pfn could be retrieved by page_to_pfn() directly.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
Maybe I missed some critical reason to save pfn to private.

Thanks in advance if someone could reveal the special reason.
---
 mm/page_alloc.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15ea511fb41c..a398eafbae46 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2793,24 +2793,19 @@ void free_unref_page(struct page *page)
 void free_unref_page_list(struct list_head *list)
 {
 	struct page *page, *next;
-	unsigned long flags, pfn;
+	unsigned long flags;
 	int batch_count = 0;
 
 	/* Prepare pages for freeing */
-	list_for_each_entry_safe(page, next, list, lru) {
-		pfn = page_to_pfn(page);
-		if (!free_unref_page_prepare(page, pfn))
+	list_for_each_entry_safe(page, next, list, lru)
+		if (!free_unref_page_prepare(page, page_to_pfn(page)))
 			list_del(&page->lru);
-		set_page_private(page, pfn);
-	}
 
 	local_irq_save(flags);
 	list_for_each_entry_safe(page, next, list, lru) {
-		unsigned long pfn = page_private(page);
-
 		set_page_private(page, 0);
 		trace_mm_page_free_batched(page);
-		free_unref_page_commit(page, pfn);
+		free_unref_page_commit(page, page_to_pfn(page));
 
 		/*
 		 * Guard against excessive IRQ disabled times when we get
-- 
2.15.1
