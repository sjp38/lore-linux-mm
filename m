Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA3E06B0278
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 05:28:26 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id y12-v6so966438lfh.16
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 02:28:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12-v6sor4788094ljb.6.2018.10.25.02.28.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 02:28:24 -0700 (PDT)
Date: Thu, 25 Oct 2018 11:28:21 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] z3fold: encode object length in the handle
Message-Id: <20181025112821.0924423fb9ecc7918896ec2b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Guenter Roeck <linux@roeck-us.net>

Reclaim and free can race on an object (which is basically ok) but
in order for reclaim to be able to  map "freed" object we need to
encode object length in the handle. handle_to_chunks() is thus
introduced to extract object length from a handle and use it during
mapping of the last object we couldn't correctly map before.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 48 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 35 insertions(+), 13 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 4b366d181f35..86359b565d45 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -99,6 +99,7 @@ struct z3fold_header {
 #define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
 
 #define BUDDY_MASK	(0x3)
+#define BUDDY_SHIFT	2
 
 /**
  * struct z3fold_pool - stores metadata for each z3fold pool
@@ -223,8 +224,17 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 	unsigned long handle;
 
 	handle = (unsigned long)zhdr;
-	if (bud != HEADLESS)
-		handle += (bud + zhdr->first_num) & BUDDY_MASK;
+	if (bud != HEADLESS) {
+		unsigned short num_chunks = zhdr->first_chunks;
+
+		if (bud == MIDDLE)
+			num_chunks = zhdr->middle_chunks;
+		if (bud == LAST)
+			num_chunks = zhdr->last_chunks;
+
+		handle |= (bud + zhdr->first_num) & BUDDY_MASK;
+		handle |= (num_chunks << BUDDY_SHIFT);
+	}
 	return handle;
 }
 
@@ -234,6 +244,11 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
 	return (struct z3fold_header *)(handle & PAGE_MASK);
 }
 
+static unsigned short handle_to_chunks(unsigned long handle)
+{
+	return (handle & ~PAGE_MASK) >> BUDDY_SHIFT;
+}
+
 /*
  * (handle & BUDDY_MASK) < zhdr->first_num is possible in encode_handle
  *  but that doesn't matter. because the masking will result in the
@@ -732,7 +747,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 			break;
 		case MIDDLE:
 			zhdr->middle_chunks = 0;
-			zhdr->start_middle = 0;
 			break;
 		case LAST:
 			zhdr->last_chunks = 0;
@@ -746,11 +760,14 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 
 	if (bud == HEADLESS) {
-		spin_lock(&pool->lock);
-		list_del(&page->lru);
-		spin_unlock(&pool->lock);
-		free_z3fold_page(page);
-		atomic64_dec(&pool->pages_nr);
+		/* if a headless page is under reclaim, just leave */
+		if (!test_bit(UNDER_RECLAIM, &page->private)) {
+			spin_lock(&pool->lock);
+			list_del(&page->lru);
+			spin_unlock(&pool->lock);
+			free_z3fold_page(page);
+			atomic64_dec(&pool->pages_nr);
+		}
 		return;
 	}
 
@@ -836,20 +853,24 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		}
 		list_for_each_prev(pos, &pool->lru) {
 			page = list_entry(pos, struct page, lru);
+			zhdr = page_address(page);
 			if (test_bit(PAGE_HEADLESS, &page->private))
-				/* candidate found */
 				break;
 
-			zhdr = page_address(page);
-			if (!z3fold_page_trylock(zhdr))
+			if (!z3fold_page_trylock(zhdr)) {
+				zhdr = NULL;
 				continue; /* can't evict at this point */
+			}
 			kref_get(&zhdr->refcount);
 			list_del_init(&zhdr->buddy);
 			zhdr->cpu = -1;
-			set_bit(UNDER_RECLAIM, &page->private);
 			break;
 		}
 
+		if (!zhdr)
+			break;
+
+		set_bit(UNDER_RECLAIM, &page->private);
 		list_del_init(&page->lru);
 		spin_unlock(&pool->lock);
 
@@ -898,6 +919,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
 				free_z3fold_page(page);
+				atomic64_dec(&pool->pages_nr);
 				return 0;
 			}
 			spin_lock(&pool->lock);
@@ -964,7 +986,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		set_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 		break;
 	case LAST:
-		addr += PAGE_SIZE - (zhdr->last_chunks << CHUNK_SHIFT);
+		addr += PAGE_SIZE - (handle_to_chunks(handle) << CHUNK_SHIFT);
 		break;
 	default:
 		pr_err("unknown buddy id %d\n", buddy);
-- 
2.11.0
