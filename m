From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/22] HWPOISON: Export some rmap vma locking to outside world
Date: Mon, 15 Jun 2009 10:45:22 +0800
Message-ID: <20090615031252.519447238@intel.com>
References: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5723A6B0055
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:27 -0400 (EDT)
Content-Disposition: inline; filename=export-rmap
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Needed for later patch that walks rmap entries on its own.

This used to be very frowned upon, but memory-failure.c does
some rather specialized rmap walking and rmap has been stable
for quite some time, so I think it's ok now to export it.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/rmap.h |    6 ++++++
 mm/rmap.c            |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

--- sound-2.6.orig/include/linux/rmap.h
+++ sound-2.6/include/linux/rmap.h
@@ -116,6 +116,12 @@ int try_to_munlock(struct page *);
 int page_wrprotect(struct page *page, int *odirect_sync, int count_offset);
 #endif
 
+/*
+ * Called by memory-failure.c to kill processes.
+ */
+struct anon_vma *page_lock_anon_vma(struct page *page);
+void page_unlock_anon_vma(struct anon_vma *anon_vma);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
--- sound-2.6.orig/mm/rmap.c
+++ sound-2.6/mm/rmap.c
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
