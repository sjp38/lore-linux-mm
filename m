Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 55F1D6B005A
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 21:07:04 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n991713k011897
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 9 Oct 2009 10:07:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EAC845DE55
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:07:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A78B45DE57
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:07:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C8EBC1DF8001
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:07:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 64ECB1DB803C
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:07:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/3] mm: move inc_zone_page_state(NR_ISOLATED) to just isolated place
Message-Id: <20091009100527.1284.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  9 Oct 2009 10:06:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This patch series is trivial cleanup and fix of page migration.


==========================================================

Christoph pointed out inc_zone_page_state(NR_ISOLATED) should be placed
in right after isolate_page().

This patch does it.

Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    4 ++++
 mm/mempolicy.c      |    3 +++
 mm/migrate.c        |   12 ++++--------
 3 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 821dee5..653bf1e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -26,6 +26,7 @@
 #include <linux/migrate.h>
 #include <linux/page-isolation.h>
 #include <linux/pfn.h>
+#include <linux/mm_inline.h>
 
 #include <asm/tlbflush.h>
 
@@ -663,6 +664,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (!ret) { /* Success */
 			list_add_tail(&page->lru, &source);
 			move_pages--;
+			inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
+
 		} else {
 			/* Becasue we don't have big zone->lock. we should
 			   check this again here. */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7dd9d9f..473f888 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -89,6 +89,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/ctype.h>
+#include <linux/mm_inline.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -809,6 +810,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
 	if ((flags & MPOL_MF_MOVE_ALL) || page_mapcount(page) == 1) {
 		if (!isolate_lru_page(page)) {
 			list_add_tail(&page->lru, pagelist);
+			inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
 		}
 	}
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 1a4bf48..0f66803 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -746,13 +746,6 @@ int migrate_pages(struct list_head *from,
 	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
 	int rc;
-	unsigned long flags;
-
-	local_irq_save(flags);
-	list_for_each_entry(page, from, lru)
-		__inc_zone_page_state(page, NR_ISOLATED_ANON +
-				page_is_file_cache(page));
-	local_irq_restore(flags);
 
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
@@ -878,8 +871,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto put_and_set;
 
 		err = isolate_lru_page(page);
-		if (!err)
+		if (!err) {
 			list_add_tail(&page->lru, &pagelist);
+			inc_zone_page_state(page, NR_ISOLATED_ANON +
+					    page_is_file_cache(page));
+		}
 put_and_set:
 		/*
 		 * Either remove the duplicate refcount from
-- 
1.6.0.GIT



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
