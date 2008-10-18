Date: Sat, 18 Oct 2008 04:25:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081018022541.GA19018@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <1224285222.10548.22.camel@lappy.programming.kicks-ass.net> <alpine.LFD.2.00.0810171621180.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171737350.3438@nehalem.linux-foundation.org> <alpine.LFD.2.00.0810171801220.3438@nehalem.linux-foundation.org> <20081018013258.GA3595@wotan.suse.de> <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0810171846180.3438@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 07:11:38PM -0700, Linus Torvalds wrote:
> 
> 
> On Sat, 18 Oct 2008, Nick Piggin wrote:
> > > 
> > > Side note: it would be nicer if we had a "spin_lock_init_locked()", so 
> > > that we could avoid the more expensive "true lock" when doing the initial 
> > > allocation, but we don't. That said, the case of having to allocate a new 
> > > anon_vma _should_ be the rare one.
> > 
> > We can't do that, unfortuantely, because anon_vmas are allocated with
> > SLAB_DESTROY_BY_RCU.
> 
> Aughh. I see what you're saying. We don't _free_ them by RCU, we just 
> destroy the page allocation. So an anon_vma can get _re-allocated_ for 
> another page (without being destroyed), concurrently with somebody 
> optimistically being busy with that same anon_vma that they got through 
> that optimistic 'page_lock_anon_vma()' thing.
> 
> So if we were to just set the lock, we might actually be messing with 
> something that is still actively used by the previous page that was 
> unmapped concurrently and still being accessed by try_to_unmap_anon. So 
> even though we allocated a "new" anon_vma, it might still be busy.
> 
> Yes? No?

That's what I'm thinking, yes. But I admit the last time I looked at
this really closely was probably reading through Hugh's patches and
changelogs (which at the time must have convinced me ;)). So I could
be wrong.


> That thing really is too subtle for words. But if that's actually what you 
> are alluding to, then doesn't that mean that we _really_ should be doing 
> that "spin_lock(&anon_vma->lock)" even for the first allocation, and that 
> the current code is broken? Because otherwise that other concurrent user 
> that found the stale vma through page_lock_anon_vma() will now try to 
> follow the linked list and _think_ it's stable (thanks to the lock), but 
> we're actually inserting entries into it without holding any locks at all.

Yes, that's what I meant by "has other problems". Another thing is also
that even if we have the lock here, I can't see why page_lock_anon_vma
is safe against finding an anon_vma which has been deallocated then
allocated for something else (and had vmas inserted into it etc.).

I think most of our memory ordering problems can be solved by locking.
Note that I don't think we need any barriers there, and callers don't
need any read_barrier_depends either, because AFAIKS they all take the
lock too. (it shouldn't actually need the reordering of the assignments
either, which shows it is a bit more robust than relying on ordering,
but I think it is neater if we reorder them).

Whether this page_lock_anon_vma is really a problem or not... I've
added a test in there that I think may be a problem (at least, I'd like
to know why I'm wrong and have a comment in there).


> But I'm hoping I actually am totally *not* understanding what you meant, 
> and am actually just terminally confused.
> 
> Hugh, this is very much your code. Can you please tell me I'm really 
> confused here, and un-confuse me. Pretty please?

Ditto ;)

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
@@ -171,6 +181,10 @@ static struct anon_vma *page_lock_anon_v
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+
+	if (anon_mapping != (unsigned long)page->mapping)
+		goto out;
+
 	return anon_vma;
 out:
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
