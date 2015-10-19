Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id C80FD82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:57:23 -0400 (EDT)
Received: by obbzf10 with SMTP id zf10so129768918obb.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:57:23 -0700 (PDT)
Received: from mail-oi0-x22c.google.com (mail-oi0-x22c.google.com. [2607:f8b0:4003:c06::22c])
        by mx.google.com with ESMTPS id u7si16178515oej.90.2015.10.18.21.57.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:57:23 -0700 (PDT)
Received: by oiev17 with SMTP id v17so44555140oie.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:57:23 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:57:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 6/12] mm: page migration use the put_new_page whenever
 necessary
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182156010.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

I don't know of any problem from the way it's used in our current tree,
but there is one defect in page migration's custom put_new_page feature.

An unused newpage is expected to be released with the put_new_page(),
but there was one MIGRATEPAGE_SUCCESS (0) path which released it with
putback_lru_page(): which can be very wrong for a custom pool.

Fixed more easily by resetting put_new_page once it won't be needed,
than by adding a further flag to modify the rc test.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

--- migrat.orig/mm/migrate.c	2015-10-18 17:53:17.579329434 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:20.159332371 -0700
@@ -938,10 +938,11 @@ static ICE_noinline int unmap_and_move(n
 				   int force, enum migrate_mode mode,
 				   enum migrate_reason reason)
 {
-	int rc = 0;
+	int rc = MIGRATEPAGE_SUCCESS;
 	int *result = NULL;
-	struct page *newpage = get_new_page(page, private, &result);
+	struct page *newpage;
 
+	newpage = get_new_page(page, private, &result);
 	if (!newpage)
 		return -ENOMEM;
 
@@ -955,6 +956,8 @@ static ICE_noinline int unmap_and_move(n
 			goto out;
 
 	rc = __unmap_and_move(page, newpage, force, mode);
+	if (rc == MIGRATEPAGE_SUCCESS)
+		put_new_page = NULL;
 
 out:
 	if (rc != -EAGAIN) {
@@ -981,7 +984,7 @@ out:
 	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
 	 * during isolation.
 	 */
-	if (rc != MIGRATEPAGE_SUCCESS && put_new_page) {
+	if (put_new_page) {
 		ClearPageSwapBacked(newpage);
 		put_new_page(newpage, private);
 	} else if (unlikely(__is_movable_balloon_page(newpage))) {
@@ -1022,7 +1025,7 @@ static int unmap_and_move_huge_page(new_
 				struct page *hpage, int force,
 				enum migrate_mode mode)
 {
-	int rc = 0;
+	int rc = -EAGAIN;
 	int *result = NULL;
 	int page_was_mapped = 0;
 	struct page *new_hpage;
@@ -1044,8 +1047,6 @@ static int unmap_and_move_huge_page(new_
 	if (!new_hpage)
 		return -ENOMEM;
 
-	rc = -EAGAIN;
-
 	if (!trylock_page(hpage)) {
 		if (!force || mode != MIGRATE_SYNC)
 			goto out;
@@ -1070,8 +1071,10 @@ static int unmap_and_move_huge_page(new_
 	if (anon_vma)
 		put_anon_vma(anon_vma);
 
-	if (rc == MIGRATEPAGE_SUCCESS)
+	if (rc == MIGRATEPAGE_SUCCESS) {
 		hugetlb_cgroup_migrate(hpage, new_hpage);
+		put_new_page = NULL;
+	}
 
 	unlock_page(hpage);
 out:
@@ -1083,7 +1086,7 @@ out:
 	 * it.  Otherwise, put_page() will drop the reference grabbed during
 	 * isolation.
 	 */
-	if (rc != MIGRATEPAGE_SUCCESS && put_new_page)
+	if (put_new_page)
 		put_new_page(new_hpage, private);
 	else
 		putback_active_hugepage(new_hpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
