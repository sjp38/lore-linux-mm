Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 126356B027E
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:06:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g5-v6so6578804pgv.12
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:06:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v11-v6si62952812plp.25.2018.06.11.07.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:53 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 30/72] radix tree test suite: Convert regression1 to XArray
Date: Mon, 11 Jun 2018 07:05:57 -0700
Message-Id: <20180611140639.17215-31-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

Now the page cache lookup is using the XArray, let's convert this
regression test from the radix tree API to the XArray so it's testing
roughly the same thing it was testing before.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 tools/testing/radix-tree/regression1.c | 58 +++++++++-----------------
 1 file changed, 19 insertions(+), 39 deletions(-)

diff --git a/tools/testing/radix-tree/regression1.c b/tools/testing/radix-tree/regression1.c
index 0aece092f40e..b4a4a7168986 100644
--- a/tools/testing/radix-tree/regression1.c
+++ b/tools/testing/radix-tree/regression1.c
@@ -53,12 +53,12 @@ struct page {
 	unsigned long index;
 };
 
-static struct page *page_alloc(void)
+static struct page *page_alloc(int index)
 {
 	struct page *p;
 	p = malloc(sizeof(struct page));
 	p->count = 1;
-	p->index = 1;
+	p->index = index;
 	pthread_mutex_init(&p->lock, NULL);
 
 	return p;
@@ -80,53 +80,33 @@ static void page_free(struct page *p)
 static unsigned find_get_pages(unsigned long start,
 			    unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
+	XA_STATE(xas, &mt_tree, start);
+	struct page *page;
+	unsigned int ret = 0;
 
 	rcu_read_lock();
-restart:
-	nr_found = radix_tree_gang_lookup_slot(&mt_tree,
-				(void ***)pages, NULL, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
-		if (unlikely(!page))
+	xas_for_each(&xas, page, ULONG_MAX) {
+		if (xas_retry(&xas, page))
 			continue;
 
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				assert((start | i) == 0);
-				goto restart;
-			}
-			/*
-			 * No exceptional entries are inserted in this test.
-			 */
-			assert(0);
-		}
-
 		pthread_mutex_lock(&page->lock);
-		if (!page->count) {
-			pthread_mutex_unlock(&page->lock);
-			goto repeat;
-		}
+		if (!page->count)
+			goto unlock;
+
 		/* don't actually update page refcount */
 		pthread_mutex_unlock(&page->lock);
 
 		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
-			goto repeat;
-		}
+		if (unlikely(page != xas_reload(&xas)))
+			goto put_page;
 
 		pages[ret] = page;
 		ret++;
+		continue;
+unlock:
+		pthread_mutex_unlock(&page->lock);
+put_page:
+		xas_reset(&xas);
 	}
 	rcu_read_unlock();
 	return ret;
@@ -145,12 +125,12 @@ static void *regression1_fn(void *arg)
 		for (j = 0; j < 1000000; j++) {
 			struct page *p;
 
-			p = page_alloc();
+			p = page_alloc(0);
 			pthread_mutex_lock(&mt_lock);
 			radix_tree_insert(&mt_tree, 0, p);
 			pthread_mutex_unlock(&mt_lock);
 
-			p = page_alloc();
+			p = page_alloc(1);
 			pthread_mutex_lock(&mt_lock);
 			radix_tree_insert(&mt_tree, 1, p);
 			pthread_mutex_unlock(&mt_lock);
-- 
2.17.1
