Date: Sat, 18 Oct 2008 07:20:46 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081018052046.GA26472@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org> <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org> <20081018022541.GA19018@wotan.suse.de> <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0810171949010.3438@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 07:53:49PM -0700, Linus Torvalds wrote:
> 
> 
> On Sat, 18 Oct 2008, Nick Piggin wrote:
> > @@ -171,6 +181,10 @@ static struct anon_vma *page_lock_anon_v
> >  
> >  	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
> >  	spin_lock(&anon_vma->lock);
> > +
> > +	if (anon_mapping != (unsigned long)page->mapping)
> > +		goto out;
> > +
> >  	return anon_vma;
> >  out:
> >  	rcu_read_unlock();
> 
> I see why you'd like to try to do this, but look a bit closer, and you'll 
> realize that this is *really* wrong.
> 
> So there's the brown-paper-bag-reason why it's wrong: you need to unlock 
> in this case,

Check.


> but there's a subtler reason why I doubt the whole approach 
> works: I don't think we actually hold the anon_vma lock when we set 
> page->mapping.

No, we don't, but I think that's OK because we do an atomic assignment
to page->mapping. I can't see any bugs there (the change to always take
the anon_vma lock when inserting a new anon_vma into vma->anon_vma
should ensure the vma->anon_vma assignment happens after the busy lock
is visible, and the fact that anyone looking into the anon_vma should
hold the lock takes care of everything else).

 
> So I don't think you really fixed the race that you want to fix, and I 
> don't think that does what you wanted to do.
> 
> But I might have missed something.

No, I think this race is different. It's because it is "hard" to get a
reference on anon_vma from the lru->page path, because unmapping a vma
doesn't take any of the same locks (in particular it doesn't take the
page lock, which would be the big hammer solution).

So we can have a thread in reclaim who has a locked page, and is just
about to call page_lock_anon_vma.

At this point, another thread might unmap the whole vma. If this is
the last vma in the anon_vma, then it garbage collects it in anon_vma_unlink.
page->mapping does not get NULLed out or anything.

So the first thread picks up the anon_vma under RCU, sees page_mapped is
still true (let's say this part runs just before the unmapper decrements
the last ->mapcount, then the page gets garbage collected).

Then we take the page lock. Still OK because we are under SLAB_DESTROY_BY_RCU.
Then we return the anon_vma and start using it. But when we took the page
lock, we don't actually know that the anon_vma hasn't been allocated and used
for something else entirely.

Taking the anon_vma->lock in anon_vma_prepare of a new anon_vma closes the
obvious list corruption problems that could occur if we tried to walk it
at the same time a new vma was being put on there. But AFAIKS, even then we
have a problem where we might be trying to walk over completely the wrong
vmas now.

Slight improvement attached.
---
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -63,32 +63,42 @@ int anon_vma_prepare(struct vm_area_stru
 	might_sleep();
 	if (unlikely(!anon_vma)) {
 		struct mm_struct *mm = vma->vm_mm;
-		struct anon_vma *allocated, *locked;
+		struct anon_vma *allocated;
 
 		anon_vma = find_mergeable_anon_vma(vma);
 		if (anon_vma) {
 			allocated = NULL;
-			locked = anon_vma;
-			spin_lock(&locked->lock);
 		} else {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
 				return -ENOMEM;
 			allocated = anon_vma;
-			locked = NULL;
 		}
 
+		/*
+		 * The lock is required even for new anon_vmas, because as
+		 * soon as we store vma->anon_vma = anon_vma, then the
+		 * anon_vma becomes visible via the vma. This means another
+		 * CPU can find the anon_vma, then store it into the struct
+		 * page with page_add_anon_rmap. At this point, anon_vma can
+		 * be loaded from the page with page_lock_anon_vma.
+		 *
+		 * So long as the anon_vma->lock is taken before looking at
+		 * any fields in the anon_vma, the lock should take care of
+		 * races and memory ordering issues WRT anon_vma fields.
+		 */
+		spin_lock(&anon_vma->lock);
+
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
-			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+			vma->anon_vma = anon_vma;
 			allocated = NULL;
 		}
 		spin_unlock(&mm->page_table_lock);
+		spin_lock(&anon_vma->lock);
 
-		if (locked)
-			spin_unlock(&locked->lock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -171,6 +181,21 @@ static struct anon_vma *page_lock_anon_v
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+
+	/*
+	 * If the page is no longer mapped, we have no way to keep the
+	 * anon_vma stable. It may be freed and even re-allocated for some
+	 * other set of anonymous mappings at any point. If the page is
+	 * mapped while we have the lock on the anon_vma, then we know
+	 * anon_vma_unlink can't run and garbage collect the anon_vma
+	 * (because unmapping the page happens before unlinking the anon_vma).
+	 */
+	if (unlikely(!page_mapped(page))) {
+		spin_unlock(&anon_vma->lock);
+		goto out;
+	}
+	BUG_ON(page->mapping != anon_mapping);
+
 	return anon_vma;
 out:
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
