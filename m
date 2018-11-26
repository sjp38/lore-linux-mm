Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 961956B4475
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 18:33:17 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w19-v6so22295595plq.1
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 15:33:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c84sor2876236pfe.49.2018.11.26.15.33.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 15:33:16 -0800 (PST)
Date: Mon, 26 Nov 2018 15:33:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/10] mm/khugepaged: fix the xas_create_range() error path
In-Reply-To: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1811261531200.2275@eggly.anvils>
References: <alpine.LSU.2.11.1811261444420.2275@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org

collapse_shmem()'s xas_nomem() is very unlikely to fail, but it is
rightly given a failure path, so move the whole xas_create_range() block
up before __SetPageLocked(new_page): so that it does not need to remember
to unlock_page(new_page).  Add the missing mem_cgroup_cancel_charge(),
and set (currently unused) result to SCAN_FAIL rather than SCAN_SUCCEED.

Fixes: 77da9389b9d5 ("mm: Convert collapse_shmem to XArray")
Signed-off-by: Hugh Dickins <hughd@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/khugepaged.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 2c5fe4f7a0c6..8e2ff195ecb3 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1329,6 +1329,20 @@ static void collapse_shmem(struct mm_struct *mm,
 		goto out;
 	}
 
+	/* This will be less messy when we use multi-index entries */
+	do {
+		xas_lock_irq(&xas);
+		xas_create_range(&xas);
+		if (!xas_error(&xas))
+			break;
+		xas_unlock_irq(&xas);
+		if (!xas_nomem(&xas, GFP_KERNEL)) {
+			mem_cgroup_cancel_charge(new_page, memcg, true);
+			result = SCAN_FAIL;
+			goto out;
+		}
+	} while (1);
+
 	__SetPageLocked(new_page);
 	__SetPageSwapBacked(new_page);
 	new_page->index = start;
@@ -1340,17 +1354,6 @@ static void collapse_shmem(struct mm_struct *mm,
 	 * be able to map it or use it in another way until we unlock it.
 	 */
 
-	/* This will be less messy when we use multi-index entries */
-	do {
-		xas_lock_irq(&xas);
-		xas_create_range(&xas);
-		if (!xas_error(&xas))
-			break;
-		xas_unlock_irq(&xas);
-		if (!xas_nomem(&xas, GFP_KERNEL))
-			goto out;
-	} while (1);
-
 	xas_set(&xas, start);
 	for (index = start; index < end; index++) {
 		struct page *page = xas_next(&xas);
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
