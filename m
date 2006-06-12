Date: Mon, 12 Jun 2006 14:14:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060612211402.20862.37113.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
References: <20060612211244.20862.41106.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 15/21] reiser4: Conversiion of nr_dirty to ZVC
Sender: owner-linux-mm@kvack.org
Subject: reiser4: conversion of nr_dirty to per zone counter
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, Con Kolivas <kernel@kolivas.org>, Marcelo Tosatti <marcelo@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Chinner <dgc@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Conversion of nr_dirty to a per zone counter

Requested by Andrew.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-rc6-cl/fs/reiser4/as_ops.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/fs/reiser4/as_ops.c	2006-06-10 11:44:14.557965359 -0700
+++ linux-2.6.17-rc6-cl/fs/reiser4/as_ops.c	2006-06-10 15:05:55.473509770 -0700
@@ -83,7 +83,7 @@ int reiser4_set_page_dirty(struct page *
 			if (page->mapping) {
 				assert("vs-1652", page->mapping == mapping);
 				if (mapping_cap_account_dirty(mapping))
-					inc_page_state(nr_dirty);
+					__inc_zone_page_state(page, NR_DIRTY);
 				radix_tree_tag_set(&mapping->page_tree,
 						   page->index,
 						   PAGECACHE_TAG_REISER4_MOVED);
Index: linux-2.6.17-rc6-cl/fs/reiser4/page_cache.c
===================================================================
--- linux-2.6.17-rc6-cl.orig/fs/reiser4/page_cache.c	2006-06-10 11:44:14.641944528 -0700
+++ linux-2.6.17-rc6-cl/fs/reiser4/page_cache.c	2006-06-10 15:05:17.209277244 -0700
@@ -464,7 +464,7 @@ int set_page_dirty_internal(struct page 
 
 	if (!TestSetPageDirty(page)) {
 		if (mapping_cap_account_dirty(mapping))
-			inc_page_state(nr_dirty);
+			inc_zone_page_state(page, NR_DIRTY);
 
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
