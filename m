Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2DD6B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 13:10:35 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id bs8so4752330wib.2
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 10:10:34 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id z9si14786988wiw.6.2014.07.28.10.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 10:10:33 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: rewrite uncharge API fix - clear page->mapping in migration
Date: Mon, 28 Jul 2014 13:10:23 -0400
Message-Id: <1406567423-8305-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The page->mapping reset in migration was conditionalized so that a
later uncharge could use PageAnon() to figure out the page type.  But
after "mm: memcontrol: rewrite uncharge API fix - double migration",
the old page is uncharged directly in mem_cgroup_migrate() and so this
is no longer necessary.

Once all fixups are folded into the "rewrite uncharge API" patch,
there will be no reason and no explanation for this change anymore, so
revert it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/migrate.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 7f5a42403fae..5a46f1ec5f43 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -778,14 +778,12 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		rc = fallback_migrate_page(mapping, newpage, page, mode);
 
 	if (rc != MIGRATEPAGE_SUCCESS) {
-		if (!PageAnon(newpage))
-			newpage->mapping = NULL;
+		newpage->mapping = NULL;
 	} else {
 		mem_cgroup_migrate(page, newpage, false);
 		if (remap_swapcache)
 			remove_migration_ptes(page, newpage);
-		if (!PageAnon(page))
-			page->mapping = NULL;
+		page->mapping = NULL;
 	}
 
 	unlock_page(newpage);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
