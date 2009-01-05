Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA23B6B00B0
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 13:00:16 -0500 (EST)
Date: Mon, 5 Jan 2009 19:00:08 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: fix lockless pagecache reordering bug (was Re: BUG: soft lockup - is this XFS problem?)
Message-ID: <20090105180008.GE32675@wotan.suse.de>
References: <gifgp1$8ic$1@ger.gmane.org> <20081223171259.GA11945@infradead.org> <20081230042333.GC27679@wotan.suse.de> <20090103214443.GA6612@infradead.org> <20090105014821.GA367@wotan.suse.de> <20090105041959.GC367@wotan.suse.de> <20090105064838.GA5209@wotan.suse.de> <49623384.2070801@aon.at> <20090105164135.GC32675@wotan.suse.de> <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0901050859430.3057@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Klotz <peter.klotz@aon.at>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Christoph Hellwig <hch@infradead.org>, Roman Kononov <kernel@kononov.ftml.net>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 05, 2009 at 09:30:55AM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 5 Jan 2009, Nick Piggin wrote:
> > 
> > This patch should be applied to 2.6.29 and 27/28 stable kernels, please.
> 
> No. I think this patch is utter crap. But please feel free to educate me 
> on why that is not the case.
> 
> Here's my explanation:
> 
> Not only is it ugly (which is already sufficient ground to suspect it is 
> wrong or could at least be done better), but reading the comment, it makes 
> no sense at all. You only put the barrier in the "goto repeat" case, but 
> the thing is, if you worry about radix tree slot not being reloaded in the 
> repeat case, then you damn well should worry about it not being reloaded 
> in the non-repeat case too!

In which case atomic_inc_unless is defined to provide a barrier.

 
> The code is immediately followed by a test to see that the page is still 
> the same in the slot, ie this:
> 
>                 /*
>                  * Has the page moved?
>                  * This is part of the lockless pagecache protocol. See
>                  * include/linux/pagemap.h for details.
>                  */
>                 if (unlikely(page != *pagep)) {
> 
> and if you need a barrier for the repeat case, you need one for this case 
> too.
> 
> In other words, it looks like you fixed the symptom, but not the real 
> cause! That's now how we work in the kernel.
> 
> The real cause, btw, appears to be that radix_tree_deref_slot() is a piece 
> of slimy sh*t, and has not been correctly updated to RCU. The proper fix 
> doesn't require any barriers that I can see - I think the proper fix is 
> this simple one-liner.
> 
> If you use RCU to protect a data structure, then any data loaded from that 
> data structure that can change due to RCU should be loaded with 
> "rcu_dereference()". 

It doesn't need that because the last level pointers in the radix
tree are not necessarily under RCU, but whatever synchronisation
the caller uses (in this case, speculative page references, which
should not require smp_read_barrier_depends, AFAIKS). Putting an
rcu_dereference there might work, but I think it misses a subtlety
of this code.


> Now, I can't test this, because it makes absolutely no difference for me 
> (the diff isn't empty, but the asm changes seem to be all due to just gcc 
> variable numbering changing). I can't seem to see the buggy code. Maybe it 
> needs a specific compiler version, or some specific config option to 
> trigger?
> 
> So because I can't see the issue, I also obviously can't verify that it's 
> the only possible case. Maybe there is some other memory access that 
> should also be done with the proper rcu accessors?
> 
> Of course, it's also possible that we should just put a barrier in 
> page_cache_get_speculative(). That doesn't seem to make a whole lot of 
> conceptual sense, though (the same way that your barrier() didn't make any 
> sense - I don't see that the barrier has absolutely _anything_ to do with 
> whether the speculative getting of the page fails or not!)

When that fails, the caller can (almost) assume the pointer has changed.
So it has to load the new pointer to continue. The object pointed to is
not protected with RCU, nor is there a requirement to see a specific
load execution ordering. 

>
> In general, I'd like fewer "band-aid" patches, and more "deep thinking" 
> patches. I'm not saying mine is very deep either, but I think it's at 
> least scrathing the surface of the real problem rather than just trying to 
> cover it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
