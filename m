Date: Tue, 2 Oct 2007 11:28:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: kswapd min order, slub max order [was Re: -mm merge plans for
 2.6.24]
In-Reply-To: <1191350333.2708.6.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710021120220.30615@schroedinger.engr.sgi.com>
References: <20071001142222.fcaa8d57.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0710021646420.4916@blonde.wat.veritas.com>
 <1191350333.2708.6.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Oct 2007, Mel Gorman wrote:

> > I agree.  I spent a while last week bisecting down to see why my heavily
> > swapping loads take 30%-60% longer with -mm than mainline, and it was
> > here that they went bad.  Trying to keep higher orders free is costly.

The larger order allocations may cause excessive reclaim under certain 
circumstances. Reclaim will continue to evict pages until a larger order 
page can be coalesced. And it seems that this eviction is not that well 
targeted at this point. So lots of pages may be needlessly evicted.

> > On the other hand, hasn't SLUB efficiency been built on the expectation
> > that higher orders can be used?  And it would be a twisted shame for
> > high performance to be held back by some idiot's swapping load.
> > 
> 
> My belief is that SLUB can still use the higher orders if configured to
> do so at boot-time. The loss of these patches means it won't try and do
> it automatically. Christoph will chime in I'm sure.

You can still manually configure those at boot time via slub_max_order 
etc.

I think Mel and I have to rethink how to do these efficiently. Mel has 
some ideas and there is some talk about using the vmalloc fallback to 
insure that things always work. Probably we may have to tune things so 
that fallback is chosen if reclaim cannot get us the larger order page 
with reasonable effort.

The maximum order of allocation used by SLUB may have to depend on the 
number of page structs in the system since small systems (128M was the 
case that Peter found) can easier get into trouble. SLAB has similar 
measures to avoid order 1 allocations for small systems below 32M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
