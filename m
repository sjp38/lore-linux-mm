Date: Tue, 15 May 2007 21:09:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Fix: find_or_create_page skips cpuset memory spreading.
Message-ID: <Pine.LNX.4.64.0705152108060.5173@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

We call alloc_page where we should be calling __page_cache_alloc.

__page_cache_alloc performs cpuset memory spreading. alloc_page does not.
There is no reason that pages allocated via find_or_create should be
exempt.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/filemap.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: vps/mm/filemap.c
===================================================================
--- vps.orig/mm/filemap.c	2007-05-15 19:03:27.000000000 -0700
+++ vps/mm/filemap.c	2007-05-15 21:06:15.000000000 -0700
@@ -670,7 +671,8 @@ repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
-			cached_page = alloc_page(gfp_mask);
+			cached_page =
+				__page_cache_alloc(gfp_mask);
 			if (!cached_page)
 				return NULL;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
