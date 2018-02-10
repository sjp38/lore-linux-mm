Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7BC6B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 18:06:38 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id g17so7708243uak.20
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 15:06:38 -0800 (PST)
Received: from 1271FVH4.localdomain ([31.173.80.65])
        by mx.google.com with ESMTP id v7si1414570ljd.455.2018.02.10.00.58.00
        for <linux-mm@kvack.org>;
        Sat, 10 Feb 2018 00:58:00 -0800 (PST)
Date: Sat, 10 Feb 2018 09:57:44 +0100
From: Vitaly Vul <vitaly.vul@sony.com>
Subject: [PATCH] z3fold: limit use of stale list for allocation
Message-ID: <20180210085744.GA19766@1271FVH4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

Currently if z3fold couldn't find an unbuddied page it would first
try to pull a page off the stale list. The problem with this
approach is that we can't 100% guarantee that the page is not
processed by the workqueue thread at the same time unless we run
cancel_work_sync() on it, which we can't do if we're in an atomic
context. So let's just limit stale list usage to non-atomic
contexts only.

Signed-off-by: Vitaly Vul <vitaly.vul@sony.com>
Signed-off-by: Oleksiy Avramchenko <Oleksiy.Avramchenko@sony.com>
---
 mm/z3fold.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 39e1912..9b0d112 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -620,24 +620,27 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		bud = FIRST;
 	}
 
-	spin_lock(&pool->stale_lock);
-	zhdr = list_first_entry_or_null(&pool->stale,
-					struct z3fold_header, buddy);
-	/*
-	 * Before allocating a page, let's see if we can take one from the
-	 * stale pages list. cancel_work_sync() can sleep so we must make
-	 * sure it won't be called in case we're in atomic context.
-	 */
-	if (zhdr && (can_sleep || !work_pending(&zhdr->work))) {
-		list_del(&zhdr->buddy);
-		spin_unlock(&pool->stale_lock);
-		if (can_sleep)
+	page = NULL;
+	if (can_sleep) {
+		spin_lock(&pool->stale_lock);
+		zhdr = list_first_entry_or_null(&pool->stale,
+						struct z3fold_header, buddy);
+		/*
+		 * Before allocating a page, let's see if we can take one from
+		 * the stale pages list. cancel_work_sync() can sleep so we
+		 * limit this case to the contexts where we can sleep
+		 */
+		if (zhdr) {
+			list_del(&zhdr->buddy);
+			spin_unlock(&pool->stale_lock);
 			cancel_work_sync(&zhdr->work);
-		page = virt_to_page(zhdr);
-	} else {
-		spin_unlock(&pool->stale_lock);
-		page = alloc_page(gfp);
+			page = virt_to_page(zhdr);
+		} else {
+			spin_unlock(&pool->stale_lock);
+		}
 	}
+	if (!page)
+		page = alloc_page(gfp);
 
 	if (!page)
 		return -ENOMEM;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
