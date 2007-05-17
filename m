Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 17 May 2007 09:08:38 +0200
Message-Id: <1179385718.27354.17.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-16 at 20:02 -0700, Christoph Lameter wrote:
> On Mon, 14 May 2007, Peter Zijlstra wrote:
> 
> > 
> > In the interest of creating a reserve based allocator; we need to make the slab
> > allocator (*sigh*, all three) fair with respect to GFP flags.
> > 
> > That is, we need to protect memory from being used by easier gfp flags than it
> > was allocated with. If our reserve is placed below GFP_ATOMIC, we do not want a
> > GFP_KERNEL allocation to walk away with it - a scenario that is perfectly
> > possible with the current allocators.
> 
> And the solution is to fail the allocation of the process which tries to 
> walk away with it. The failing allocation will lead to the killing of the 
> process right?

Not necessarily, we have this fault injection system that can fail
allocations; that doesn't bring the processes down, now does it?

> Could you please modify the patchset to *avoid* failure conditions. This 
> patchset here only manages failure conditions. The system should not get 
> into the failure conditions in the first place! For that purpose you may 
> want to put processes to sleep etc. But in order to do so you need to 
> figure out which processes you need to make progress.

Those that have __GFP_WAIT set will go to sleep - or do whatever
__GFP_WAIT allocations do best; the other allocations must handle
failure anyway. (even __GFP_WAIT allocations must handle failure for
that matter)

I'm really not seeing why you're making such a fuzz about it; normally
when you push the system this hard we're failing allocations left right
and center too. Its just that the block IO path has some mempools which
allow it to write out some (swap) pages and slowly get back to sanity.

This really is not much different; the system is in dire need for
memory; those allocations that cannot sleep will fail, simple.

All I'm wanting to do is limit the reserve to PF_MEMALLOC processes;
those that are in charge of cleaning memory; not every other random
process that just wants to do its thing - that doesn't seem like a weird
thing to do at all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
