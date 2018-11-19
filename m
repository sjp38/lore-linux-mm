Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 874826B17AD
	for <linux-mm@kvack.org>; Sun, 18 Nov 2018 20:09:34 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id u5-v6so29016183iol.11
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 17:09:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor6733807itd.32.2018.11.18.17.09.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Nov 2018 17:09:33 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH v2] mm: fix swap offset when replacing shmem page
Date: Sun, 18 Nov 2018 18:09:24 -0700
Message-Id: <20181119010924.177177-1-yuzhao@google.com>
In-Reply-To: <20181119004719.156411-1-yuzhao@google.com>
References: <20181119004719.156411-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

We used to have a single swap address space with swp_entry_t.val
as its radix tree index. This is not the case anymore. Now Each
swp_type() has its own address space and should use swp_offset()
as radix tree index.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/shmem.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index d44991ea5ed4..685faa3e0191 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1509,11 +1509,13 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 {
 	struct page *oldpage, *newpage;
 	struct address_space *swap_mapping;
-	pgoff_t swap_index;
+	swp_entry_t entry;
 	int error;
 
+	VM_BUG_ON(!PageSwapCache(*pagep));
+
 	oldpage = *pagep;
-	swap_index = page_private(oldpage);
+	entry.val = page_private(oldpage);
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
@@ -1540,7 +1542,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	 * a nice clean interface for us to replace oldpage by newpage there.
 	 */
 	xa_lock_irq(&swap_mapping->i_pages);
-	error = shmem_replace_entry(swap_mapping, swap_index, oldpage, newpage);
+	error = shmem_replace_entry(swap_mapping, swp_offset(entry),
+				    oldpage, newpage);
 	if (!error) {
 		__inc_node_page_state(newpage, NR_FILE_PAGES);
 		__dec_node_page_state(oldpage, NR_FILE_PAGES);
-- 
2.19.1.1215.g8438c0b245-goog
