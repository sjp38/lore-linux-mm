Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE20B62008B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 13:53:32 -0400 (EDT)
Date: Wed, 5 May 2010 18:53:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
	the wrong VMA information
Message-ID: <20100505175311.GU20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie> <1273065281-13334-2-git-send-email-mel@csn.ul.ie> <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org> <20100505145620.GP20979@csn.ul.ie> <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 08:31:42AM -0700, Linus Torvalds wrote:
> That said, I do wonder if we could _make_ the ordering reliable. I did 
> that for the 'same_vma' one, because I wanted to be able to verify that 
> chains were consistent (and we also needed to be able to find the "oldest 
> anon_vma" for the case of re-instantiating pages that migth exist in 
> multiple different anon_vma's).
> 
> Any ideas?
> 

If the same_vma list is properly ordered then maybe something like the
following is allowed?

(This patch is on top of mm,migration: Prevent rmap_walk_[anon|ksm]
seeing the wrong VMA information)

At least it booted and did not immediately kill itself during migration.
It's less clear what to do for KSM but I'm ignoring it for the moment.

==== CUT HERE ====
mm,migration: In rmap_walk, always take the locks in the same order

---
 include/linux/rmap.h |   32 ++++++++++++++++++++++++++++++++
 mm/ksm.c             |    5 +----
 mm/rmap.c            |   13 ++-----------
 3 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 7721674..749aaca 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -99,6 +99,38 @@ static inline struct anon_vma *page_anon_vma(struct page *page)
 	return page_rmapping(page);
 }
 
+static inline struct anon_vma *page_anon_vma_lock_oldest(struct page *page)
+{
+	struct anon_vma *anon_vma, *oldest_anon_vma;
+	struct anon_vma_chain *avc, *oldest_avc;
+
+	/* Get the pages anon_vma */
+	if (((unsigned long)page->mapping & PAGE_MAPPING_FLAGS) !=
+					    PAGE_MAPPING_ANON)
+		return NULL;
+	anon_vma = page_rmapping(page);
+	if (!anon_vma)
+		return NULL;
+
+	spin_lock(&anon_vma->lock);
+
+	/*
+	 * Get the oldest anon_vma on the list by depending on the ordering
+	 * of the same_vma list setup by __page_set_anon_rmap
+	 */
+	avc = list_entry(&anon_vma->head, struct anon_vma_chain, same_anon_vma);
+	oldest_avc = list_entry(avc->vma->anon_vma_chain.prev,
+				struct anon_vma_chain, same_vma);
+	oldest_anon_vma = oldest_avc->anon_vma;
+
+	if (anon_vma != oldest_anon_vma) {
+		spin_lock(&oldest_anon_vma->lock);
+		spin_unlock(&anon_vma->lock);
+	}
+
+	return oldest_anon_vma;
+}
+
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
diff --git a/mm/ksm.c b/mm/ksm.c
index 0c09927..113f972 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1680,10 +1680,7 @@ again:
 			locked_vma = NULL;
 			if (anon_vma != vma->anon_vma) {
 				locked_vma = vma->anon_vma;
-				if (!spin_trylock(&locked_vma->lock)) {
-					spin_unlock(&anon_vma->lock);
-					goto again;
-				}
+				spin_lock(&locked_vma->lock);
 			}
 
 			if (rmap_item->address < vma->vm_start ||
diff --git a/mm/rmap.c b/mm/rmap.c
index f7ed89f..ae37a63 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1368,26 +1368,17 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
 	 */
-retry:
-	anon_vma = page_anon_vma(page);
+	anon_vma = page_anon_vma_lock_oldest(page);
 	if (!anon_vma)
 		return ret;
-	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
 		unsigned long address;
 
-		/*
-		 * Guard against deadlocks by not spinning against
-		 * vma->anon_vma->lock. On contention release and retry
-		 */
 		locked_vma = NULL;
 		if (anon_vma != vma->anon_vma) {
 			locked_vma = vma->anon_vma;
-			if (!spin_trylock(&locked_vma->lock)) {
-				spin_unlock(&anon_vma->lock);
-				goto retry;
-			}
+			spin_lock(&locked_vma->lock);
 		}
 		address = vma_address(page, vma);
 		if (address != -EFAULT)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
