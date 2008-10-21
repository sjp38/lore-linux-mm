Date: Tue, 21 Oct 2008 06:34:50 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix anon_vma races
Message-ID: <20081021043450.GB5694@wotan.suse.de>
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

And after that patch, I *think* we should be able to do something like
this.

--
With the change to return only stable, non-empty anon_vmas from
page_lock_anon_vma, we no longer have to hold off RCU while looking at
the anon_vma. After this change, the lockless referencing, and interesting
SLAB_DESTROY_BY_RCU behaviour is pretty well localised to page_lock_anon_vma
and anon_vma_prepare.

Today, for normal RCU, this doesn't matter much. For preemptible RCU and
preemptible anon_vma lock, this change could help with keeping RCU ticking.
It could also help if we ever wanted to add a sleeping lock to anon_vma.
Basically just fewer nested dependencies ~= more flexible and maintainable.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -239,6 +239,8 @@ struct anon_vma *page_lock_anon_vma(stru
 		spin_unlock(&anon_vma->lock);
 		goto out;
 	}
+	rcu_read_unlock();
+
 	VM_BUG_ON(anon_mapping != (unsigned long)page->mapping);
 
 	return anon_vma;
@@ -250,7 +252,6 @@ out:
 void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
 	spin_unlock(&anon_vma->lock);
-	rcu_read_unlock();
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
