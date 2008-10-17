Date: Fri, 17 Oct 2008 16:05:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix anon_vma races
In-Reply-To: <Pine.LNX.4.64.0810172300280.30871@blonde.site>
Message-ID: <alpine.LFD.2.00.0810171549310.3438@nehalem.linux-foundation.org>
References: <20081016041033.GB10371@wotan.suse.de> <Pine.LNX.4.64.0810172300280.30871@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 17 Oct 2008, Hugh Dickins wrote:
> 
> My problem is really with the smp_read_barrier_depends() you each
> have in anon_vma_prepare().  But the only thing which its CPU
> does with the anon_vma is put its address into a struct page
> (or am I forgetting more?).  Wouldn't the smp_read_barrier_depends()
> need to be, not there in anon_vma_prepare(), but over on the third
> CPU, perhaps in page_lock_anon_vma()?

I thought about it, but it's a disaster from a maintenance standpoint to 
put it there, rather than make it all clear in the _one_ function that 
actually does things optimistically.

I agree that it's a bit subtle the way I did it (haven't seen Nick's 
patch, I assume he was upset at me for shouting at him), but that's part 
of why I put that comment in there and said things are subtle.

Anyway, technically you're right: the smp_read_barrier_depends() really 
would be more obvious in the place where we actually fetch that "anon_vma" 
pointer again and actually derefernce it.

HOWEVER:

 - there are potentially multiple places that do that, and putting it in 
   the anon_vma_prepare() thing not only matches things with the 
   smp_wmb(), making that whole pairing much more obvious, but it also 
   means that we're guaranteed that any anon_vma user will have done the 
   smp_read_barrier_depends(), since they all have to do that prepare 
   thing anyway.

   So putting it there is simpler and gives better guarantees, and pairs 
   up the barriers better.

 - Now, "simpler" (etc) is no help if it doesn't work, so now I have to 
   convince you that it's _sufficient_ to do that "read_barrier_depends()" 
   early, even if we then end up re-doing the first read and thus the 
   "depends" part doesn't work any more. So "simpler" is all good, but not 
   if it's incorrect.

   And I admit it, here my argument is one of implementation. The fact is, 
   the only architecture where "read_barrier_depends()" exists at all as 
   anything but a no-op is alpha, and there it's a full read barrier. On 
   all other architectures, causality implies a read barrier anyway, so 
   for them, placement (or non-placement) of the smp_read_barrier_depends 
   is a total non-issue.

   And so, since on the only architecture where it could possibly matter, 
   that _depends thing turns into a full read barrier, and since 
   "anon_vma" is actually stable since written, and since the only 
   ordering constrain is that initial ordering of seeing the "anon_vma" 
   turn non-NULL, you may as well think of that "read_barrier_depends()" 
   as a full read barrier between the _original_ read of the anon_vma 
   pointer and then the read of the lock data we want to protect.

   Which it is, on alpha. And that is sufficient. IOW, think of it as a 
   real read_barrier(), with no dependency thing, but that only happens 
   when an architecture doesn't already guarantee the causality barrier.

   And once you think of it as a "smp_rmb() for alpha", you realize that 
   it's perfectly ok for it to be where it is.

Anyway, lockless is bad. It would certainly be a *lot* simpler to just 
take the page_table_lock around the whole thing, except I think we really 
*really* don't want to do that. That thing is solidly in a couple of 
*very* timing-critical routines. Doing another lock there is just not an 
option.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
