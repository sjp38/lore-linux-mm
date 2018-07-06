Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Jongseok Kim <ks77sj@gmail.com>
Subject: [PATCH] z3fold: fix wrong handling of headless pages
Date: Fri,  6 Jul 2018 14:10:46 +0900
Message-Id: <1530853846-30215-1-git-send-email-ks77sj@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Vitaly Wool <vitalywool@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jongseok Kim <ks77sj@gmail.com>
List-ID: <linux-mm.kvack.org>

During the processing of headless pages in z3fold_reclaim_page(),
there was a problem that the zhdr pointed to another page
or a page was already released in z3fold_free(). So, the wrong page
is encoded in headless, or test_bit does not work properly
in z3fold_reclaim_page(). This patch fixed these problems.

Signed-off-by: Jongseok Kim <ks77sj@gmail.com>
---
 mm/z3fold.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 4b366d1..201a8ac 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -746,6 +746,9 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 
 	if (bud == HEADLESS) {
+		if (test_bit(UNDER_RECLAIM, &page->private))
+			return;
+
 		spin_lock(&pool->lock);
 		list_del(&page->lru);
 		spin_unlock(&pool->lock);
@@ -836,20 +839,20 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		}
 		list_for_each_prev(pos, &pool->lru) {
 			page = list_entry(pos, struct page, lru);
+			zhdr = page_address(page);
 			if (test_bit(PAGE_HEADLESS, &page->private))
 				/* candidate found */
 				break;
 
-			zhdr = page_address(page);
 			if (!z3fold_page_trylock(zhdr))
 				continue; /* can't evict at this point */
 			kref_get(&zhdr->refcount);
 			list_del_init(&zhdr->buddy);
 			zhdr->cpu = -1;
-			set_bit(UNDER_RECLAIM, &page->private);
 			break;
 		}
 
+		set_bit(UNDER_RECLAIM, &page->private);
 		list_del_init(&page->lru);
 		spin_unlock(&pool->lock);
 
@@ -898,6 +901,7 @@ static int z3fold_reclaim_page(struct z3fold_pool *pool, unsigned int retries)
 		if (test_bit(PAGE_HEADLESS, &page->private)) {
 			if (ret == 0) {
 				free_z3fold_page(page);
+				atomic64_dec(&pool->pages_nr);
 				return 0;
 			}
 			spin_lock(&pool->lock);
-- 
2.7.4
