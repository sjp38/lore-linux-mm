Date: Thu, 9 Aug 2007 19:01:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04/10] mm: slub: add knowledge of reserve pages
In-Reply-To: <4a5909270708091854n7c84ae9aj84170092a5eb61db@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708091857230.3368@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <20070806103658.603735000@chello.nl>
  <Pine.LNX.4.64.0708071702560.4941@schroedinger.engr.sgi.com>
 <20070808014435.GG30556@waste.org>  <Pine.LNX.4.64.0708081004290.12652@schroedinger.engr.sgi.com>
  <Pine.LNX.4.64.0708081050590.12652@schroedinger.engr.sgi.com>
 <20070808114636.7c6f26ab.akpm@linux-foundation.org>
 <4a5909270708091854n7c84ae9aj84170092a5eb61db@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.raymond.phillips@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Daniel Phillips wrote:

> No matter how you look at this problem, you still need to have _some_
> sort of reserve, and limit access to it.  We extend existing methods,

The reserve is in the memory in the zone and reclaim can guarantee that 
there are a sufficient number of easily reclaimable pages in it.

> you are proposing to what seems like an entirely new reserve

The reserve always has been managed by per zone counters. Nothing new 
there.

> management system.  Great idea, maybe, but it does not solve the
> deadlocks.  You still need some organized way of being sure that your
> reserve is as big as you need (hopefully not an awful lot bigger) and
> you still have to make sure that nobody dips into that reserve further
> than they are allowed to.

Nope there is no need to have additional reserves. You delay the writeout 
until you are finished with reclaim. Then you do the writeout. During 
writeout reclaim may be called as needed. After the writeout is complete 
then you recheck the vm counters again to be sure that dirty ratio / 
easily reclaimable ratio and mem low / high boundaries are still okay. If not go 
back to reclaim.

> So translation: reclaim from "easily freeable" lists is an
> optimization, maybe a great one.  Probably great.  Reclaim from atomic
> context is also a great idea, probably. But you are talking about a
> whole nuther patch set.  Neither of those are in themselves a fix for
> these deadlocks.

Yes they are a much better fix and may allow code cleanup by getting rid 
of checks for PF_MEMALLOC. They integrate in a straightforward way 
into the existing reclaim methods.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
