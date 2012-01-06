Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A513C6B0069
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 12:38:55 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so1435832eek.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 09:38:55 -0800 (PST)
Subject: [PATCH 2/3] mm: postpone migrated page mapping reset
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 06 Jan 2012 21:38:51 +0400
Message-ID: <20120106173850.11700.42919.stgit@zurg>
In-Reply-To: <20120106173827.11700.74305.stgit@zurg>
References: <20120106173827.11700.74305.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Postpone resetting page->mapping till final remove_migration_ptes(),
otherwise expression PageAnon(migration_entry_to_page(entry)) does not work.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/migrate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 177aca4..f59cd76 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -386,7 +386,6 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 	ClearPageSwapCache(page);
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page->mapping = NULL;
 
 	/*
 	 * If any waiters have accumulated on the new page then
@@ -614,6 +613,7 @@ static int move_to_new_page(struct page *newpage, struct page *page,
 	} else {
 		if (remap_swapcache)
 			remove_migration_ptes(page, newpage);
+		page->mapping = NULL;
 	}
 
 	unlock_page(newpage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
