Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 560558D0040
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:12:45 -0400 (EDT)
Subject: [PATCH 1/3] mem-hotplug: call isolate_lru_page with elevated refcount
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 21 Apr 2011 17:12:39 +0400
Message-ID: <20110421131239.17363.82750.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

isolate_lru_page() must be called only with stable reference to page.
So, let's grab normal page reference.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memory_hotplug.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9ca1d60..0a19109 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -705,7 +705,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
-		if (!page_count(page))
+		if (!get_page_unless_zero(page))
 			continue;
 		/*
 		 * We can skip free pages. And we can only deal with pages on
@@ -713,6 +713,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		 */
 		ret = isolate_lru_page(page);
 		if (!ret) { /* Success */
+			put_page(page);
 			list_add_tail(&page->lru, &source);
 			move_pages--;
 			inc_zone_page_state(page, NR_ISOLATED_ANON +
@@ -724,6 +725,7 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 			       pfn);
 			dump_page(page);
 #endif
+			put_page(page);
 			/* Because we don't have big zone->lock. we should
 			   check this again here. */
 			if (page_count(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
