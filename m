Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8F94B6B01AC
	for <linux-mm@kvack.org>; Sun,  4 Jul 2010 05:22:44 -0400 (EDT)
Received: by pva4 with SMTP id 4so122398pva.14
        for <linux-mm@kvack.org>; Sun, 04 Jul 2010 02:22:43 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] slob:Use _safe funtion to iterate partially free list.
Date: Sun,  4 Jul 2010 17:22:33 +0800
Message-Id: <1278235353-9638-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mpm@selenic.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

Since a list entry may be removed, so use list_for_each_entry_safe
instead of list_for_each_entry.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/slob.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 3f19a34..e2af18b 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -320,7 +320,7 @@ static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
  */
 static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
-	struct slob_page *sp;
+	struct slob_page *sp, *tmp;
 	struct list_head *prev;
 	struct list_head *slob_list;
 	slob_t *b = NULL;
@@ -335,7 +335,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, list) {
+	list_for_each_entry_safe(sp, tmp, slob_list, list) {    
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
