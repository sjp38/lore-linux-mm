Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1F0900002
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 14:52:26 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so4843838wgh.35
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 11:52:26 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ck20si50902192wjb.112.2014.07.07.11.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 11:52:25 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/3] mm: memcontrol: rewrite uncharge API fix - migrate before re-mapping
Date: Mon,  7 Jul 2014 14:52:13 -0400
Message-Id: <1404759133-29218-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
References: <1404759133-29218-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Mapped file accounting depends on the the page being charged already,
or it won't get accounted properly, and the mapped file counter will
underflow during unmap later on.

Move mem_cgroup_migrate() before remove_migration_ptes().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index ab43fbfff8ba..7f5a42403fae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -781,11 +781,11 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 		if (!PageAnon(newpage))
 			newpage->mapping = NULL;
 	} else {
+		mem_cgroup_migrate(page, newpage, false);
 		if (remap_swapcache)
 			remove_migration_ptes(page, newpage);
 		if (!PageAnon(page))
 			page->mapping = NULL;
-		mem_cgroup_migrate(page, newpage, false);
 	}
 
 	unlock_page(newpage);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
