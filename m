Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 8EFF86B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 08:34:54 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so957962pbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 05:34:53 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/4 v2] mm: correct return value of migrate_pages() and migrate_huge_pages()
Date: Tue, 17 Jul 2012 21:33:32 +0900
Message-Id: <1342528415-2291-1-git-send-email-js1304@gmail.com>
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

migrate_huge_pages() is identical case as migrate_pages()

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>
Acked-by: Christoph Lameter <cl@linux.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>

diff --git a/mm/migrate.c b/mm/migrate.c
index be26d5c..f495c58 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -982,6 +982,7 @@ int migrate_pages(struct list_head *from,
 
 	for(pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
+		nr_failed = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
 			cond_resched();
@@ -1029,6 +1030,7 @@ int migrate_huge_pages(struct list_head *from,
 
 	for (pass = 0; pass < 10 && retry; pass++) {
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
