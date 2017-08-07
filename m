Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 718186B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 04:44:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o82so88224360pfj.11
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 01:44:11 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s67si4362806pgb.303.2017.08.07.01.44.09
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 01:44:10 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [RESEND PATCH] mm: Don't reinvent the wheel but use existing llist API
Date: Mon,  7 Aug 2017 17:42:54 +0900
Message-Id: <1502095374-16112-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, zijun_hu@htc.com, mhocko@suse.com, vbabka@suse.cz, joelaf@google.com, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

Although llist provides proper APIs, they are not used. Make them used.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 mm/vmalloc.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3ca82d4..8c0eb45 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -49,12 +49,10 @@ struct vfree_deferred {
 static void free_work(struct work_struct *w)
 {
 	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
-	struct llist_node *llnode = llist_del_all(&p->list);
-	while (llnode) {
-		void *p = llnode;
-		llnode = llist_next(llnode);
-		__vunmap(p, 1);
-	}
+	struct llist_node *t, *llnode;
+
+	llist_for_each_safe(llnode, t, llist_del_all(&p->list))
+		__vunmap((void *)llnode, 1);
 }
 
 /*** Page table manipulation functions ***/
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
