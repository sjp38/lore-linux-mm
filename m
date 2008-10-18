Date: Fri, 17 Oct 2008 17:42:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
Message-ID: <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Fri, 17 Oct 2008, Linus Torvalds wrote:
> 
> But I think that what Nick did is correct - we always start traversal 
> through anon_vma->head, so no, the "list_add_tail()" won't expose it to 
> anybody else, because nobody else has seen the anon_vma().
> 
> That said, that's really too damn subtle. We shouldn't rely on memory 
> ordering for the list handling, when the list handling is _supposed_ to be 
> using that anon_vma->lock thing.

So maybe a better patch would be as follows? It simplifies the whole thing 
by just always locking and unlocking the vma, whether it's newly allocated 
or not (and whether it then gets dropped as unnecessary or not).

It still does that "smp_read_barrier_depends()" in the same old place. I 
don't have the energy to look at Hugh's point about people reading 
anon_vma without doing the whole "prepare" thing.

It adds more lines than it removes, but it's just because of the comments. 
With the locking simplification, it actually removes more lines of actual 
code than it adds. And now we always do that list_add_tail() with the 
anon_vma lock held, which should simplify thinking about this, and avoid 
at least one subtle ordering issue.

		Linus

---
 mm/rmap.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 0383acf..9221bf7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -63,35 +63,48 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 	might_sleep();
 	if (unlikely(!anon_vma)) {
 		struct mm_struct *mm = vma->vm_mm;
-		struct anon_vma *allocated, *locked;
+		struct anon_vma *allocated;
 
 		anon_vma = find_mergeable_anon_vma(vma);
-		if (anon_vma) {
-			allocated = NULL;
-			locked = anon_vma;
-			spin_lock(&locked->lock);
-		} else {
+		allocated = NULL;
+		if (!anon_vma) {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
 				return -ENOMEM;
 			allocated = anon_vma;
-			locked = NULL;
 		}
+		spin_lock(&anon_vma->lock);
 
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
+			/*
+			 * We hold the mm->page_table_lock, but another
+			 * CPU may be doing an optimistic load (the one
+			 * at the top), and we want to make sure that
+			 * the anon_vma changes are visible.
+			 */
+			smp_wmb();
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
-
-		if (locked)
-			spin_unlock(&locked->lock);
+		spin_unlock(&anon_vma->lock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
+	/*
+	 * Subtle: we looked up anon_vma without any locking
+	 * (in the comon case), and are going to look at the
+	 * spinlock etc behind it. In order to know that it's
+	 * initialized, we need to do a read barrier here.
+	 *
+	 * We can use the cheaper "depends" version, since we
+	 * are following a pointer, and only on alpha may that
+	 * give a stale value.
+	 */
+	smp_read_barrier_depends();
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
