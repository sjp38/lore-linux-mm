Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88AE26B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 19:41:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id w10-v6so10871229plz.0
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 16:41:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a33-v6sor25751655plc.51.2018.11.13.16.41.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 16:41:09 -0800 (PST)
From: p.jaroszynski@gmail.com
Subject: [PATCH] Fix do_move_pages_to_node() error handling
Date: Tue, 13 Nov 2018 16:40:59 -0800
Message-Id: <20181114004059.1287439-1-pjaroszynski@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>

From: Piotr Jaroszynski <pjaroszynski@nvidia.com>

migrate_pages() can return the number of pages that failed to migrate
instead of 0 or an error code. If that happens, the positive return is
treated as an error all the way up through the stack leading to the
move_pages() syscall returning a positive number. I believe this
regressed with commit a49bd4d71637 ("mm, numa: rework do_pages_move")
that refactored a lot of this code.

Fix this by treating positive returns as success in
do_move_pages_to_node() as that seems to most closely follow the
previous code. This still leaves the question whether silently
considering this case a success is the right thing to do as even the
status of the pages will be set as if they were successfully migrated,
but that seems to have been the case before as well.

Fixes: a49bd4d71637 ("mm, numa: rework do_pages_move")
Signed-off-by: Piotr Jaroszynski <pjaroszynski@nvidia.com>
---
 mm/migrate.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/migrate.c b/mm/migrate.c
index 8baeb7ff2f6d..b42efef780d6 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1461,6 +1461,7 @@ static int store_status(int __user *status, int start, int value, int nr)
 	return 0;
 }
 
+/* Returns 0 or an error code. */
 static int do_move_pages_to_node(struct mm_struct *mm,
 		struct list_head *pagelist, int node)
 {
@@ -1473,6 +1474,15 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 			MIGRATE_SYNC, MR_SYSCALL);
 	if (err)
 		putback_movable_pages(pagelist);
+
+	/*
+	 * migrate_pages() can return the number of not migrated pages, but the
+	 * callers of do_move_pages_to_node() only care about and handle hard
+	 * failures.
+	 */
+	if (err > 0)
+		err = 0;
+
 	return err;
 }
 
-- 
2.11.0.262.g4b0a5b2.dirty
