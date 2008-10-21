Date: Tue, 21 Oct 2008 14:55:29 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <20081021043450.GB5694@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0810211453080.4529@blonde.site>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810200427270.5543@blonde.site>
 <alpine.LFD.2.00.0810200742300.3518@nehalem.linux-foundation.org>
 <200810211356.13191.nickpiggin@yahoo.com.au>
 <alpine.LFD.2.00.0810202024150.3287@nehalem.linux-foundation.org>
 <20081021043450.GB5694@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, Nick Piggin wrote:
> On Mon, Oct 20, 2008 at 08:25:54PM -0700, Linus Torvalds wrote:
> 
> And after that patch, I *think* we should be able to do something like
> this.
> 
> --
> With the change to return only stable, non-empty anon_vmas from
> page_lock_anon_vma, we no longer have to hold off RCU while looking at
> the anon_vma. After this change, the lockless referencing, and interesting
> SLAB_DESTROY_BY_RCU behaviour is pretty well localised to page_lock_anon_vma
> and anon_vma_prepare.
> 
> Today, for normal RCU, this doesn't matter much. For preemptible RCU and
> preemptible anon_vma lock, this change could help with keeping RCU ticking.
> It could also help if we ever wanted to add a sleeping lock to anon_vma.
> Basically just fewer nested dependencies ~= more flexible and maintainable.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Interesting.  That's how it used to be originally (and we just did
the spin_unlock directly without any page_unlock_anon_vma wrapper).
I rather liked keeping the RCU trickery in the one function.

But it worried ChristophL that way (and caused the -rt tree problems?):
eventually he persuaded me to allow the patch moving rcu_read_unlock()
after the spin_unlock().

I think he was seeing the same point that you are seeing, when you say
that this can come (only) after your patch checking page_mapped i.e.
anon_vma stability after getting the spinlock.

Since I only knew classic RCU in which rcu_read_lock is preempt_disable,
and a spin_lock does preempt_disable, it was all theoretical to me.

I like this patch, but let's see how Christoph feels about it.

Hugh

> ---
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c
> +++ linux-2.6/mm/rmap.c
> @@ -239,6 +239,8 @@ struct anon_vma *page_lock_anon_vma(stru
>  		spin_unlock(&anon_vma->lock);
>  		goto out;
>  	}
> +	rcu_read_unlock();
> +
>  	VM_BUG_ON(anon_mapping != (unsigned long)page->mapping);
>  
>  	return anon_vma;
> @@ -250,7 +252,6 @@ out:
>  void page_unlock_anon_vma(struct anon_vma *anon_vma)
>  {
>  	spin_unlock(&anon_vma->lock);
> -	rcu_read_unlock();
>  }
>  
>  /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
