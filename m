Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 486EC6B01DA
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 08:11:49 -0400 (EDT)
Received: by pxi32 with SMTP id 32so2288481pxi.1
        for <linux-mm@kvack.org>; Wed, 24 Mar 2010 05:11:45 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RFC][PATCH] shrink_page_list: save page_mapped() to local val
Date: Wed, 24 Mar 2010 20:11:27 +0800
Message-Id: <1269432687-1580-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

In funtion shrink_page_list(), page_mapped() is called several
times,save it to local val to reduce atomic_read.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/vmscan.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..08cc3ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -637,6 +637,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
+		int page_mapcount;
 
 		cond_resched();
 
@@ -653,11 +654,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (unlikely(!page_evictable(page, NULL)))
 			goto cull_mlocked;
 
-		if (!sc->may_unmap && page_mapped(page))
+		page_mapcount = page_mapped(page);
+		if (!sc->may_unmap && page_mapcount)
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
-		if (page_mapped(page) || PageSwapCache(page))
+		if (page_mapcount || PageSwapCache(page))
 			sc->nr_scanned++;
 
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
@@ -707,7 +709,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapcount && mapping) {
 			switch (try_to_unmap(page, TTU_UNMAP)) {
 			case SWAP_FAIL:
 				goto activate_locked;
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
