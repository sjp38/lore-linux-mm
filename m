Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 440566B004D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 12:16:14 -0400 (EDT)
Received: by yenr5 with SMTP id r5so6211117yen.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 09:16:13 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/3] mm: correct return value of migrate_pages()
Date: Tue, 17 Jul 2012 01:14:30 +0900
Message-Id: <1342455272-32703-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

migrate_pages() should return number of pages not migrated or error code.
When unmap_and_move return -EAGAIN, outer loop is re-execution without
initialising nr_failed. This makes nr_failed over-counted.

So this patch correct it by initialising nr_failed in outer loop.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>

diff --git a/mm/migrate.c b/mm/migrate.c
index be26d5c..294d52a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -982,6 +982,7 @@ int migrate_pages(struct list_head *from,
 
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
+		nr_failed = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
