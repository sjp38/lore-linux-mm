Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5639B6B27C4
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 16:54:48 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id 71-v6so8614408itl.5
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 13:54:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g67sor15430804iof.86.2018.11.21.13.54.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 13:54:47 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v3] mm: use swp_offset as key in shmem_replace_page()
Date: Wed, 21 Nov 2018 14:54:42 -0700
Message-Id: <20181121215442.138545-1-yuzhao@google.com>
In-Reply-To: <20181119010924.177177-1-yuzhao@google.com>
References: <20181119010924.177177-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

We changed key of swap cache tree from swp_entry_t.val to
swp_offset. Need to do so in shmem_replace_page() as well.

Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
Cc: stable@vger.kernel.org # v4.9+
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/shmem.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index d44991ea5ed4..42b70978e814 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1509,11 +1509,13 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 {
 	struct page *oldpage, *newpage;
 	struct address_space *swap_mapping;
+	swp_entry_t entry;
 	pgoff_t swap_index;
 	int error;
 
 	oldpage = *pagep;
-	swap_index = page_private(oldpage);
+	entry.val = page_private(oldpage);
+	swap_index = swp_offset(entry);
 	swap_mapping = page_mapping(oldpage);
 
 	/*
@@ -1532,7 +1534,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	__SetPageLocked(newpage);
 	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
-	set_page_private(newpage, swap_index);
+	set_page_private(newpage, entry.val);
 	SetPageSwapCache(newpage);
 
 	/*
-- 
2.19.1.1215.g8438c0b245-goog
