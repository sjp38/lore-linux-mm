Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 96E326B005A
	for <linux-mm@kvack.org>; Fri, 29 May 2009 17:35:09 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
In-Reply-To: <200905291135.124267638@firstfloor.org>
Subject: [PATCH] [3/16] HWPOISON: Export some rmap vma locking to outside world
Message-Id: <20090529213528.7E5A41D0291@basil.firstfloor.org>
Date: Fri, 29 May 2009 23:35:28 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Needed for later patch that walks rmap entries on its own.

This used to be very frowned upon, but memory-failure.c does
some rather specialized rmap walking and rmap has been stable
for quite some time, so I think it's ok now to export it.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/rmap.h |    6 ++++++
 mm/rmap.c            |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

Index: linux/include/linux/rmap.h
===================================================================
--- linux.orig/include/linux/rmap.h	2009-05-29 23:32:10.000000000 +0200
+++ linux/include/linux/rmap.h	2009-05-29 23:33:30.000000000 +0200
@@ -118,6 +118,12 @@
 }
 #endif
 
+/*
+ * Called by memory-failure.c to kill processes.
+ */
+struct anon_vma *page_lock_anon_vma(struct page *page);
+void page_unlock_anon_vma(struct anon_vma *anon_vma);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c	2009-05-29 23:32:10.000000000 +0200
+++ linux/mm/rmap.c	2009-05-29 23:33:30.000000000 +0200
@@ -191,7 +191,7 @@
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -211,7 +211,7 @@
 	return NULL;
 }
 
-static void page_unlock_anon_vma(struct anon_vma *anon_vma)
+void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
