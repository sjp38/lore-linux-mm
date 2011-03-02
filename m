Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8EAC8D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:00:19 -0500 (EST)
Message-Id: <20110302175726.199569489@chello.nl>
Date: Wed, 02 Mar 2011 18:55:03 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 5/8] mm: Improve page_lock_anon_vma() comment
References: <20110302175458.726109015@chello.nl>
Content-Disposition: inline; filename=peter_zijlstra-mm-improve_page_lock_anon_vma_comment.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Hugh Dickins <hughd@google.com>

A slightly more verbose comment to go along with the trickery in
page_lock_anon_vma().

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/rmap.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -315,8 +315,22 @@ void __init anon_vma_init(void)
 }
 
 /*
- * Getting a lock on a stable anon_vma from a page off the LRU is
- * tricky: page_lock_anon_vma rely on RCU to guard against the races.
+ * Getting a lock on a stable anon_vma from a page off the LRU is tricky!
+ *
+ * Since there is no serialization what so ever against page_remove_rmap()
+ * the best this function can do is return a locked anon_vma that might
+ * have been relevant to this page.
+ *
+ * The page might have been remapped to a different anon_vma or the anon_vma
+ * returned may already be freed (and even reused).
+ *
+ * All users of this function must be very careful when walking the anon_vma
+ * chain and verify that the page in question is indeed mapped in it
+ * [ something equivalent to page_mapped_in_vma() ].
+ *
+ * Since anon_vma's slab is DESTROY_BY_RCU and we know from page_remove_rmap()
+ * that the anon_vma pointer from page->mapping is valid if there is a
+ * mapcount, we can dereference the anon_vma after observing those.
  */
 struct anon_vma *page_lock_anon_vma(struct page *page)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
