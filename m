Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFD06B0036
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:58:38 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id f15so4022069eak.2
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:58:37 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id h9si38692264eev.63.2014.02.03.16.58.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 16:58:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 02/10] fs: cachefiles: use add_to_page_cache_lru()
Date: Mon,  3 Feb 2014 19:53:34 -0500
Message-Id: <1391475222-1169-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
References: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

This code used to have its own lru cache pagevec up until a0b8cab3
("mm: remove lru parameter from __pagevec_lru_add and remove parts of
pagevec API").  Now it's just add_to_page_cache() followed by
lru_cache_add(), might as well use add_to_page_cache_lru() directly.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
---
 fs/cachefiles/rdwr.c | 33 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index ebaff368120d..4b1fb5ca65b8 100644
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
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
