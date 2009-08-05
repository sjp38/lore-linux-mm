Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2BE6B0062
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 05:36:31 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200908051136.682859934@firstfloor.org>
In-Reply-To: <200908051136.682859934@firstfloor.org>
Subject: [PATCH] [2/19] HWPOISON: Export some rmap vma locking to outside world
Message-Id: <20090805093629.BBAAEB15D8@basil.firstfloor.org>
Date: Wed,  5 Aug 2009 11:36:29 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
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
--- linux.orig/include/linux/rmap.h
+++ linux/include/linux/rmap.h
@@ -112,6 +112,12 @@ int page_mkclean(struct page *);
  */
 int try_to_munlock(struct page *);
 
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
--- linux.orig/mm/rmap.c
+++ linux/mm/rmap.c
@@ -191,7 +191,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -211,7 +211,7 @@ out:
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
