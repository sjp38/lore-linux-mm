Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 889D56B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 09:16:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n62so22351763lfn.7
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 06:16:25 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id e16si7615746ljb.221.2017.04.10.06.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 06:16:23 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id r36so11375834lfi.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 06:16:23 -0700 (PDT)
Date: Mon, 10 Apr 2017 15:16:21 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: fix page locking in z3fold_alloc()
Message-Id: <20170410151621.b75118d3d883ea4afe4e00bf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com

Stress testing of the current z3fold implementation on a 8-core system
revealed it was possible that a z3fold page deleted from its unbuddied
list in z3fold_alloc() would be put on another unbuddied list by
z3fold_free() while z3fold_alloc() is still processing it. This has
been introduced with commit 5a27aa822 ("z3fold: add kref refcounting")
due to the removal of special handling of a z3fold page not on any list
in z3fold_free().

To fix this, the z3fold page lock should be taken in z3fold_alloc()
before the pool lock is released. To avoid deadlocking, we just try to
lock the page as soon as we get a hold of it, and if trylock fails, we
drop this page and take the next one.

---
 mm/z3fold.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index f9492bc..54f63c4 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -185,6 +185,12 @@ static inline void z3fold_page_lock(struct z3fold_header *zhdr)
 	spin_lock(&zhdr->page_lock);
 }
 
+/* Try to lock a z3fold page */
+static inline int z3fold_page_trylock(struct z3fold_header *zhdr)
+{
+	return spin_trylock(&zhdr->page_lock);
+}
+
 /* Unlock a z3fold page */
 static inline void z3fold_page_unlock(struct z3fold_header *zhdr)
 {
@@ -385,7 +391,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			spin_lock(&pool->lock);
 			zhdr = list_first_entry_or_null(&pool->unbuddied[i],
 						struct z3fold_header, buddy);
-			if (!zhdr) {
+			if (!zhdr || !z3fold_page_trylock(zhdr)) {
 				spin_unlock(&pool->lock);
 				continue;
 			}
@@ -394,7 +400,6 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			spin_unlock(&pool->lock);
 
 			page = virt_to_page(zhdr);
-			z3fold_page_lock(zhdr);
 			if (zhdr->first_chunks == 0) {
 				if (zhdr->middle_chunks != 0 &&
 				    chunks >= zhdr->start_middle)
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
