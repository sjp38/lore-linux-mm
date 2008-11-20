Date: Thu, 20 Nov 2008 01:24:20 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 7/7] mm: make page_lock_anon_vma static
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200122520.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

page_lock_anon_vma() and page_unlock_anon_vma() were made available to
show_page_path() in vmscan.c; but now that has been removed, make them
static in rmap.c again, they're better kept private if possible.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/rmap.h |    3 ---
 mm/rmap.c            |    4 ++--
 2 files changed, 2 insertions(+), 5 deletions(-)

--- mmclean6/include/linux/rmap.h	2008-10-24 09:28:24.000000000 +0100
+++ mmclean7/include/linux/rmap.h	2008-11-19 15:26:33.000000000 +0000
@@ -63,9 +63,6 @@ void anon_vma_unlink(struct vm_area_stru
 void anon_vma_link(struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 
-extern struct anon_vma *page_lock_anon_vma(struct page *page);
-extern void page_unlock_anon_vma(struct anon_vma *anon_vma);
-
 /*
  * rmap interfaces called when adding or removing pte of page
  */
--- mmclean6/mm/rmap.c	2008-11-19 15:26:28.000000000 +0000
+++ mmclean7/mm/rmap.c	2008-11-19 15:26:33.000000000 +0000
@@ -193,7 +193,7 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-struct anon_vma *page_lock_anon_vma(struct page *page)
+static struct anon_vma *page_lock_anon_vma(struct page *page)
 {
 	struct anon_vma *anon_vma;
 	unsigned long anon_mapping;
@@ -213,7 +213,7 @@ out:
 	return NULL;
 }
 
-void page_unlock_anon_vma(struct anon_vma *anon_vma)
+static void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
