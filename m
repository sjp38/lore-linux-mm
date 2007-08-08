Date: Wed, 8 Aug 2007 11:09:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <200708061559.41680.phillips@phunq.net>
  <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
 <200708061649.56487.phillips@phunq.net>  <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
 <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.raymond.phillips@gmail.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Daniel Phillips wrote:

>   1. If the allocation can be satisified in the usual way, do that.
>   2. Otherwise, if the GFP flags do not include __GFP_MEMALLOC or
> PF_MEMALLOC is not set, fail the allocation
>   3. Otherwise, if the memcache's reserve quota is not reached,
> satisfy the request, allocating a new page from the MEMALLOC reserve,
> but the memcache's reserve counter and succeed

Maybe we need to kill PF_MEMALLOC....

> > Try NUMA constraints and zone limitations.
> 
> Are you worried about a correctness issue that would prevent the
> machine from operating, or are you just worried about allocating
> reserve pages to the local node for performance reasons?

I am worried that allocation constraints will make the approach incorrect. 
Because logically you must have distinct pools for each set of allocations 
constraints. Otherwise something will drain the precious reserve slab.

> > No I mean all 1024 processors of our system running into this fail/succeed
> > thingy that was added.
> 
> If an allocation now fails that would have succeeded in the past, the
> patch set is buggy.  I can't say for sure one way or another at this
> time of night.  If you see something, could you please mention a
> file/line number?

It seems that allocations fail that the reclaim logic should have taken 
care of letting succeed. Not good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
