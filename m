Date: Tue, 21 Oct 2008 06:33:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081021043338.GA5694@wotan.suse.de>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810200427270.5543@blonde.site> <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org> <200810211356.13191.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0810202024150.3287@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0810202024150.3287@nehalem.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 20, 2008 at 08:25:54PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 21 Oct 2008, Nick Piggin wrote:
> > >
> > > So what I'm trying to figure out is why Nick wanted to add another check
> > > for page_mapped(). I'm not seeing what it is supposed to protect against.
> > 
> > It's not supposed to protect against anything that would be a problem
> > in the existing code (well, I initially thought it might be, but Hugh
> > explained why its not needed). I'd still like to put the check in, in
> > order to constrain this peculiarity of SLAB_DESTROY_BY_RCU to those
> > couple of functions which allocate or take a reference.
> 
> Hmm.  Ok, as long as I understand what it is for (and if it's not a 
> bug-fix but a "like to drop the stale anon_vma early), I'm ok.
> 
> So I won't mind, and Hugh seems to prefer it. So if you send that patch 
> alogn with a good explanation for a changelog entry, I'll apply it.

Well something like this, then. Hugh?

--

With the existing SLAB_DESTROY_BY_RCU scheme for anon_vma, page_lock_anon_vma
might take the lock of the anon_vma at a point where it has already been freed
then re-allocated and reused for something else.

This is OK (with the exception of the now-fixed case where newly allocated
anon_vma had its list manipulated without holding the lock), because in order
to get to the pte, the page tables must be walked and the pte confirmed to
point to this page anyway. So technically it should work.

The problem with it is that it is quite subtle, and it means that we have to
keep this stale-anon_vma problem in the back of our minds, when reviewing or
modifying any part of the anonymous rmap code. It *could* be that it would
break some otherwise legitimate change to the code.

Add another page_mapped check to weed out these anon_vmas. Comment the
existing page_mapped check a little bit.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -200,11 +200,47 @@ struct anon_vma *page_lock_anon_vma(stru
 	anon_mapping = (unsigned long) page->mapping;
 	if (!(anon_mapping & PAGE_MAPPING_ANON))
 		goto out;
+
+	/*
+	 * The page_mapped check is required in order to ensure anon_vma is
+	 * protected under this RCU critical section before we touch it.
+	 *
+	 * If page_mapped was not checked, page->mapping may refer to an
+	 * anon_vma that has since been freed (see page_remove_rmap comment not
+	 * resetting PageAnon). And hence it would not be protected with RCU
+	 * and could be freed and reused at any time.
+	 */
 	if (!page_mapped(page))
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+
+	/*
+	 * If the page is no longer mapped, we have no way to keep the anon_vma
+	 * stable. It may be freed and even re-allocated for some other set of
+	 * anonymous mappings at any point. Technically this should be OK, as
+	 * we hold the spinlock, and should be able to tolerate finding
+	 * unrelated vmas on our list. However we'd rather nip these in the bud
+	 * here, for simplicity.
+	 *
+	 * If the page is mapped while we have the lock on the anon_vma, then
+	 * we know anon_vma_unlink can't run and garbage collect the anon_vma:
+	 * unmapping the page and decrementing its mapcount happens before
+	 * unlinking the anon_vma; unlinking the anon_vma requires the
+	 * anon_vma lock to be held. So this check ensures we have a stable
+	 * anon_vma.
+	 *
+	 * Note: the page can still become unmapped, and the !page_mapped
+	 * condition become true at any point. This check is definitely not
+	 * preventing any such thing.
+	 */
+	if (unlikely(!page_mapped(page))) {
+		spin_unlock(&anon_vma->lock);
+		goto out;
+	}
+	VM_BUG_ON(anon_mapping != (unsigned long)page->mapping);
+
 	return anon_vma;
 out:
 	rcu_read_unlock();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
