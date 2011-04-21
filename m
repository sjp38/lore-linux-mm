Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 305128D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:12:45 -0400 (EDT)
Subject: [PATCH 2/3] mem-hwpoison: fix page refcount around isolate_lru_page()
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 21 Apr 2011 17:12:40 +0400
Message-ID: <20110421131240.17363.15414.stgit@localhost6>
In-Reply-To: <20110421131239.17363.82750.stgit@localhost6>
References: <20110421131239.17363.82750.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

Drop first page reference only after calling isolate_lru_page()
to keep page stable reference while isolating.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/memory-failure.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 2b9a5ee..a17d31e 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1440,16 +1440,12 @@ int soft_offline_page(struct page *page, int flags)
 	 */
 	ret = invalidate_inode_page(page);
 	unlock_page(page);
-
 	/*
-	 * Drop count because page migration doesn't like raised
-	 * counts. The page could get re-allocated, but if it becomes
-	 * LRU the isolation will just fail.
 	 * RED-PEN would be better to keep it isolated here, but we
 	 * would need to fix isolation locking first.
 	 */
-	put_page(page);
 	if (ret == 1) {
+		put_page(page);
 		ret = 0;
 		pr_info("soft_offline: %#lx: invalidated\n", pfn);
 		goto done;
@@ -1461,6 +1457,11 @@ int soft_offline_page(struct page *page, int flags)
 	 * handles a large number of cases for us.
 	 */
 	ret = isolate_lru_page(page);
+	/*
+	 * Drop page reference which is came from get_any_page()
+	 * successful isolate_lru_page() already took another one.
+	 */
+	put_page(page);
 	if (!ret) {
 		LIST_HEAD(pagelist);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
