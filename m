From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/8] fs: cachefiles: use add_to_page_cache_lru()
Date: Thu, 10 Oct 2013 17:46:55 -0400
Message-ID: <1381441622-26215-2-git-send-email-hannes@cmpxchg.org>
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

This code used to have its own lru cache pagevec up until a0b8cab3
("mm: remove lru parameter from __pagevec_lru_add and remove parts of
pagevec API").  Now it's just add_to_page_cache() followed by
lru_cache_add(), might as well use add_to_page_cache_lru() directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/cachefiles/rdwr.c | 33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index ebaff36..4b1fb5c 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -265,24 +265,22 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 				goto nomem_monitor;
 		}
 
-		ret = add_to_page_cache(newpage, bmapping,
-					netpage->index, cachefiles_gfp);
+		ret = add_to_page_cache_lru(newpage, bmapping,
+					    netpage->index, cachefiles_gfp);
 		if (ret == 0)
 			goto installed_new_backing_page;
 		if (ret != -EEXIST)
 			goto nomem_page;
 	}
 
-	/* we've installed a new backing page, so now we need to add it
-	 * to the LRU list and start it reading */
+	/* we've installed a new backing page, so now we need to start
+	 * it reading */
 installed_new_backing_page:
 	_debug("- new %p", newpage);
 
 	backpage = newpage;
 	newpage = NULL;
 
-	lru_cache_add_file(backpage);
-
 read_backing_page:
 	ret = bmapping->a_ops->readpage(NULL, backpage);
 	if (ret < 0)
@@ -510,24 +508,23 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 					goto nomem;
 			}
 
-			ret = add_to_page_cache(newpage, bmapping,
-						netpage->index, cachefiles_gfp);
+			ret = add_to_page_cache_lru(newpage, bmapping,
+						    netpage->index,
+						    cachefiles_gfp);
 			if (ret == 0)
 				goto installed_new_backing_page;
 			if (ret != -EEXIST)
 				goto nomem;
 		}
 
-		/* we've installed a new backing page, so now we need to add it
-		 * to the LRU list and start it reading */
+		/* we've installed a new backing page, so now we need
+		 * to start it reading */
 	installed_new_backing_page:
 		_debug("- new %p", newpage);
 
 		backpage = newpage;
 		newpage = NULL;
 
-		lru_cache_add_file(backpage);
-
 	reread_backing_page:
 		ret = bmapping->a_ops->readpage(NULL, backpage);
 		if (ret < 0)
@@ -538,8 +535,8 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 	monitor_backing_page:
 		_debug("- monitor add");
 
-		ret = add_to_page_cache(netpage, op->mapping, netpage->index,
-					cachefiles_gfp);
+		ret = add_to_page_cache_lru(netpage, op->mapping,
+					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
 				page_cache_release(netpage);
@@ -549,8 +546,6 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 			goto nomem;
 		}
 
-		lru_cache_add_file(netpage);
-
 		/* install a monitor */
 		page_cache_get(netpage);
 		monitor->netfs_page = netpage;
@@ -613,8 +608,8 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 	backing_page_already_uptodate:
 		_debug("- uptodate");
 
-		ret = add_to_page_cache(netpage, op->mapping, netpage->index,
-					cachefiles_gfp);
+		ret = add_to_page_cache_lru(netpage, op->mapping,
+					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
 				page_cache_release(netpage);
@@ -631,8 +626,6 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 
 		fscache_mark_page_cached(op, netpage);
 
-		lru_cache_add_file(netpage);
-
 		/* the netpage is unlocked and marked up to date here */
 		fscache_end_io(op, netpage, 0);
 		page_cache_release(netpage);
-- 
1.8.4
