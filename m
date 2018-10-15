Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 970F16B0003
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:23:14 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n1-v6so21777163qtb.17
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:23:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p93si2467971qva.126.2018.10.15.13.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 13:23:13 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm: thp: relocate flush_cache_range() in migrate_misplaced_transhuge_page()
Date: Mon, 15 Oct 2018 16:23:11 -0400
Message-Id: <20181015202311.7209-1-aarcange@redhat.com>
In-Reply-To: <20181013002430.698-4-aarcange@redhat.com>
References: <20181013002430.698-4-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

There should be no cache left by the time we overwrite the old
transhuge pmd with the new one. It's already too late to flush through
the virtual address because we already copied the page data to the new
physical address.

So flush the cache before the data copy.

Also delete the "end" variable to shutoff a "unused variable" warning
on x86 where flush_cache_range() is a noop.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/migrate.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index c9e9b7db8b6d..8afb41167641 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2019,7 +2019,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	struct page *new_page = NULL;
 	int page_lru = page_is_file_cache(page);
 	unsigned long start = address & HPAGE_PMD_MASK;
-	unsigned long end = start + HPAGE_PMD_SIZE;
 
 	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
@@ -2050,6 +2049,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
+	/* flush the cache before copying using the kernel virtual address */
+	flush_cache_range(vma, start, start + HPAGE_PMD_SIZE);
 	migrate_page_copy(new_page, page);
 	WARN_ON(PageLRU(new_page));
 
@@ -2087,7 +2088,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * new page and page_add_new_anon_rmap guarantee the copy is
 	 * visible before the pagetable update.
 	 */
-	flush_cache_range(vma, start, end);
 	page_add_anon_rmap(new_page, vma, start, true);
 	/*
 	 * At this point the pmd is numa/protnone (i.e. non present)
