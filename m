Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7992D6B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 02:06:28 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fe3so136985964pab.1
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 23:06:28 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id q84si39375101pfa.197.2016.04.03.23.06.27
        for <linux-mm@kvack.org>;
        Sun, 03 Apr 2016 23:06:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] mm/hwpoison: fix wrong num_poisoned_pages account
Date: Mon,  4 Apr 2016 15:06:32 +0900
Message-Id: <1459749992-7861-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Currently, migration code increases num_poisoned_pages on failed
migration page as well as successfully migrated one at the trial
of memory-failure. It will make the stat wrong.

As well, it marks page as PG_HWPoison even if the migration trial
failed. It would make we cannot recover the corrupted page using
memory-failure facility.

This patches fixes it.

Cc: stable@vger.kernel.org
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/migrate.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 6c822a7b27e0..f9dfb18a4eba 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -975,7 +975,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason == MR_MEMORY_FAILURE) {
+		if (reason == MR_MEMORY_FAILURE && rc == MIGRATEPAGE_SUCCESS) {
+			/*
+			 * With this release, we free successfully migrated
+			 * page and set PG_HWPoison on just freed page
+			 * intentionally. Although it's rather weird, it's how
+			 * HWPoison flag works at the moment.
+			 */
 			put_page(page);
 			if (!test_set_page_hwpoison(page))
 				num_poisoned_pages_inc();
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
