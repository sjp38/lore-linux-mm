Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id A658D6B0253
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 12:51:23 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fn2so84170070pad.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:51:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id uj2si12680644pab.206.2016.10.13.09.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 09:50:56 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so5434521pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 09:50:56 -0700 (PDT)
Date: Thu, 13 Oct 2016 18:50:49 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 2/3] z3fold: remove redundant locking
Message-Id: <20161013185049.adaf153cc8bb1eb1408702f5@gmail.com>
In-Reply-To: <20161013184758.9ecfd318fa542e14e2d2c5b1@gmail.com>
References: <20161013184758.9ecfd318fa542e14e2d2c5b1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

The per-pool z3fold spinlock should generally be taken only when
a non-atomic pool variable is modified. There's no need to take it
to map/unmap an object.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 5197d7b..10513b5 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -580,6 +580,7 @@ next:
 		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
 		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
 		     zhdr->middle_chunks == 0)) {
+			spin_unlock(&pool->lock);
 			/*
 			 * All buddies are now free, free the z3fold page and
 			 * return success.
@@ -587,7 +588,6 @@ next:
 			clear_bit(PAGE_HEADLESS, &page->private);
 			free_z3fold_page(zhdr);
 			atomic64_dec(&pool->pages_nr);
-			spin_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			if (zhdr->first_chunks != 0 &&
@@ -629,7 +629,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
@@ -656,7 +655,6 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		break;
 	}
 out:
-	spin_unlock(&pool->lock);
 	return addr;
 }
 
@@ -671,19 +669,14 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
-	if (test_bit(PAGE_HEADLESS, &page->private)) {
-		spin_unlock(&pool->lock);
-		return;
+	if (!test_bit(PAGE_HEADLESS, &page->private)) {
+		buddy = handle_to_buddy(handle);
+		if (buddy == MIDDLE)
+			clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 	}
-
-	buddy = handle_to_buddy(handle);
-	if (buddy == MIDDLE)
-		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
-	spin_unlock(&pool->lock);
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
