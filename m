Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id AEF8F82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:34 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id n5so237558132pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i62si14046921pfi.222.2016.03.20.11.41.45
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 23/71] cachefiles: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:30 +0300
Message-Id: <1458499278-1516-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
---
 fs/cachefiles/rdwr.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index c0f3da3926a0..afbdc418966d 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -194,10 +194,10 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
 			error = -EIO;
 		}
 
-		page_cache_release(monitor->back_page);
+		put_page(monitor->back_page);
 
 		fscache_end_io(op, monitor->netfs_page, error);
-		page_cache_release(monitor->netfs_page);
+		put_page(monitor->netfs_page);
 		fscache_retrieval_complete(op, 1);
 		fscache_put_retrieval(op);
 		kfree(monitor);
@@ -288,8 +288,8 @@ monitor_backing_page:
 	_debug("- monitor add");
 
 	/* install the monitor */
-	page_cache_get(monitor->netfs_page);
-	page_cache_get(backpage);
+	get_page(monitor->netfs_page);
+	get_page(backpage);
 	monitor->back_page = backpage;
 	monitor->monitor.private = backpage;
 	add_page_wait_queue(backpage, &monitor->monitor);
@@ -310,7 +310,7 @@ backing_page_already_present:
 	_debug("- present");
 
 	if (newpage) {
-		page_cache_release(newpage);
+		put_page(newpage);
 		newpage = NULL;
 	}
 
@@ -342,7 +342,7 @@ success:
 
 out:
 	if (backpage)
-		page_cache_release(backpage);
+		put_page(backpage);
 	if (monitor) {
 		fscache_put_retrieval(monitor->op);
 		kfree(monitor);
@@ -363,7 +363,7 @@ io_error:
 	goto out;
 
 nomem_page:
-	page_cache_release(newpage);
+	put_page(newpage);
 nomem_monitor:
 	fscache_put_retrieval(monitor->op);
 	kfree(monitor);
@@ -530,7 +530,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
-				page_cache_release(netpage);
+				put_page(netpage);
 				fscache_retrieval_complete(op, 1);
 				continue;
 			}
@@ -538,10 +538,10 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		}
 
 		/* install a monitor */
-		page_cache_get(netpage);
+		get_page(netpage);
 		monitor->netfs_page = netpage;
 
-		page_cache_get(backpage);
+		get_page(backpage);
 		monitor->back_page = backpage;
 		monitor->monitor.private = backpage;
 		add_page_wait_queue(backpage, &monitor->monitor);
@@ -555,10 +555,10 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 			unlock_page(backpage);
 		}
 
-		page_cache_release(backpage);
+		put_page(backpage);
 		backpage = NULL;
 
-		page_cache_release(netpage);
+		put_page(netpage);
 		netpage = NULL;
 		continue;
 
@@ -603,7 +603,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 					    netpage->index, cachefiles_gfp);
 		if (ret < 0) {
 			if (ret == -EEXIST) {
-				page_cache_release(netpage);
+				put_page(netpage);
 				fscache_retrieval_complete(op, 1);
 				continue;
 			}
@@ -612,14 +612,14 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 
 		copy_highpage(netpage, backpage);
 
-		page_cache_release(backpage);
+		put_page(backpage);
 		backpage = NULL;
 
 		fscache_mark_page_cached(op, netpage);
 
 		/* the netpage is unlocked and marked up to date here */
 		fscache_end_io(op, netpage, 0);
-		page_cache_release(netpage);
+		put_page(netpage);
 		netpage = NULL;
 		fscache_retrieval_complete(op, 1);
 		continue;
@@ -632,11 +632,11 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 out:
 	/* tidy up */
 	if (newpage)
-		page_cache_release(newpage);
+		put_page(newpage);
 	if (netpage)
-		page_cache_release(netpage);
+		put_page(netpage);
 	if (backpage)
-		page_cache_release(backpage);
+		put_page(backpage);
 	if (monitor) {
 		fscache_put_retrieval(op);
 		kfree(monitor);
@@ -644,7 +644,7 @@ out:
 
 	list_for_each_entry_safe(netpage, _n, list, lru) {
 		list_del(&netpage->lru);
-		page_cache_release(netpage);
+		put_page(netpage);
 		fscache_retrieval_complete(op, 1);
 	}
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
