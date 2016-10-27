Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBD556B0270
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 07:12:14 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so8136946lfe.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:12:14 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id y3si4124240lfa.151.2016.10.27.04.12.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 04:12:13 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id b75so1748372lfg.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 04:12:13 -0700 (PDT)
Date: Thu, 27 Oct 2016 13:12:11 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCHv3 2/3] z3fold: change per-pool spinlock to rwlock
Message-Id: <20161027131211.15b8233794c51634088e3149@gmail.com>
In-Reply-To: <20161027130647.782b8ab1f71555200ba15605@gmail.com>
References: <20161027130647.782b8ab1f71555200ba15605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Mapping/unmapping goes with no actual modifications so it makes
sense to only take a read lock in map/unmap functions.

This change gives up to 10% performance gain and lower latencies
in fio sequential read/write tests, e.g. before:

Run status group 0 (all jobs):
  WRITE: io=2700.0GB, aggrb=3234.8MB/s, minb=276031KB/s, maxb=277391KB/s, mint=850530msec, maxt=854720msec

Run status group 1 (all jobs):
   READ: io=2700.0GB, aggrb=4838.6MB/s, minb=412888KB/s, maxb=424969KB/s, mint=555168msec, maxt=571412msec

after:
Run status group 0 (all jobs):
  WRITE: io=2700.0GB, aggrb=3284.2MB/s, minb=280249KB/s, maxb=281130KB/s, mint=839218msec, maxt=841856msec

Run status group 1 (all jobs):
   READ: io=2700.0GB, aggrb=5210.7MB/s, minb=444640KB/s, maxb=447791KB/s, mint=526874msec, maxt=530607msec

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 5ac325a..014d84f 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -77,7 +77,7 @@ struct z3fold_ops {
  * pertaining to a particular z3fold pool.
  */
 struct z3fold_pool {
-	spinlock_t lock;
+	rwlock_t lock;
 	struct list_head unbuddied[NCHUNKS];
 	struct list_head buddied;
 	struct list_head lru;
@@ -231,7 +231,7 @@ static struct z3fold_pool *z3fold_create_pool(gfp_t gfp,
 	pool = kzalloc(sizeof(struct z3fold_pool), gfp);
 	if (!pool)
 		return NULL;
-	spin_lock_init(&pool->lock);
+	rwlock_init(&pool->lock);
 	for_each_unbuddied_list(i, 0)
 		INIT_LIST_HEAD(&pool->unbuddied[i]);
 	INIT_LIST_HEAD(&pool->buddied);
@@ -312,7 +312,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		bud = HEADLESS;
 	else {
 		chunks = size_to_chunks(size);
-		spin_lock(&pool->lock);
+		write_lock(&pool->lock);
 
 		/* First, try to find an unbuddied z3fold page. */
 		zhdr = NULL;
@@ -342,14 +342,14 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 			}
 		}
 		bud = FIRST;
-		spin_unlock(&pool->lock);
+		write_unlock(&pool->lock);
 	}
 
 	/* Couldn't find unbuddied z3fold page, create new one */
 	page = alloc_page(gfp);
 	if (!page)
 		return -ENOMEM;
-	spin_lock(&pool->lock);
+	write_lock(&pool->lock);
 	atomic64_inc(&pool->pages_nr);
 	zhdr = init_z3fold_page(page);
 
@@ -387,7 +387,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	list_add(&page->lru, &pool->lru);
 
 	*handle = encode_handle(zhdr, bud);
-	spin_unlock(&pool->lock);
+	write_unlock(&pool->lock);
 
 	return 0;
 }
@@ -409,7 +409,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy bud;
 
-	spin_lock(&pool->lock);
+	write_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
@@ -437,7 +437,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		default:
 			pr_err("%s: unknown bud %d\n", __func__, bud);
 			WARN_ON(1);
-			spin_unlock(&pool->lock);
+			write_unlock(&pool->lock);
 			return;
 		}
 		if (is_unbuddied)
@@ -446,7 +446,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 
 	if (test_bit(UNDER_RECLAIM, &page->private)) {
 		/* z3fold page is under reclaim, reclaim will free */
-		spin_unlock(&pool->lock);
+		write_unlock(&pool->lock);
 		return;
 	}
 
@@ -471,7 +471,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 		atomic64_inc(&pool->unbuddied_nr);
 	}
 
-	spin_unlock(&pool->lock);
+	write_unlock(&pool->lock);
 }
 
 /**
@@ -517,10 +517,10 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 	struct page *page;
 	unsigned long first_handle = 0, middle_handle = 0, last_handle = 0;
 
-	spin_lock(&pool->lock);
+	read_lock(&pool->lock);
 	if (!pool->ops || !pool->ops->evict || list_empty(&pool->lru) ||
 			retries == 0) {
-		spin_unlock(&pool->lock);
+		read_unlock(&pool->lock);
 		return -EINVAL;
 	}
 	for (i = 0; i < retries; i++) {
@@ -556,7 +556,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			last_handle = middle_handle = 0;
 		}
 
-		spin_unlock(&pool->lock);
+		read_unlock(&pool->lock);
 
 		/* Issue the eviction callback(s) */
 		if (middle_handle) {
@@ -575,7 +575,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 				goto next;
 		}
 next:
-		spin_lock(&pool->lock);
+		write_lock(&pool->lock);
 		clear_bit(UNDER_RECLAIM, &page->private);
 		if ((test_bit(PAGE_HEADLESS, &page->private) && ret == 0) ||
 		    (zhdr->first_chunks == 0 && zhdr->last_chunks == 0 &&
@@ -587,7 +587,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 			clear_bit(PAGE_HEADLESS, &page->private);
 			free_z3fold_page(zhdr);
 			atomic64_dec(&pool->pages_nr);
-			spin_unlock(&pool->lock);
+			write_unlock(&pool->lock);
 			return 0;
 		}  else if (!test_bit(PAGE_HEADLESS, &page->private)) {
 			if (zhdr->first_chunks != 0 &&
@@ -607,8 +607,10 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 
 		/* add to beginning of LRU */
 		list_add(&page->lru, &pool->lru);
+		write_unlock(&pool->lock);
+		read_lock(&pool->lock);
 	}
-	spin_unlock(&pool->lock);
+	read_unlock(&pool->lock);
 	return -EAGAIN;
 }
 
@@ -629,7 +631,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
+	read_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
@@ -656,7 +658,7 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 		break;
 	}
 out:
-	spin_unlock(&pool->lock);
+	read_unlock(&pool->lock);
 	return addr;
 }
 
@@ -671,19 +673,19 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy buddy;
 
-	spin_lock(&pool->lock);
+	read_lock(&pool->lock);
 	zhdr = handle_to_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
 	if (test_bit(PAGE_HEADLESS, &page->private)) {
-		spin_unlock(&pool->lock);
+		read_unlock(&pool->lock);
 		return;
 	}
 
 	buddy = handle_to_buddy(handle);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
-	spin_unlock(&pool->lock);
+	read_unlock(&pool->lock);
 }
 
 /**
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
