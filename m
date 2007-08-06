From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 00/10] foundations for reserve-based allocation
Date: Mon, 6 Aug 2007 10:35:18 -0700
References: <20070806102922.907530000@chello.nl>
In-Reply-To: <20070806102922.907530000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061035.18742.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 03:29, Peter Zijlstra wrote:
> In the interrest of getting swap over network working and posting in
> smaller series, here is the first series.
>
> This series lays the foundations needed to do reserve based
> allocation. Traditionally we have used mempools (and others like
> radix_tree_preload) to handle the problem.
>
> However this does not fit the network stack. It is built around
> variable sized allocations using kmalloc().
>
> This calls for a different approach.
>
> We want a guarantee for N bytes from kmalloc(), this translates to a
> demand on the slab allocator for 2*N+m (due to the power-of-two
> nature of kmalloc slabs), where m is the meta-data needed by the
> allocator itself.

Where does the 2* come from?  Isn't it exp2(ceil(log2(N + m)))?

> The slab allocator then puts a demand of P pages on the page
> allocator.
>
> So we need functions translating our demanded kmalloc space into a
> page reserve limit, and then need to provide a reserve of pages.
> 
> And we need to ensure that once we hit the reserve, the slab
> allocator honours the reserve's access. That is, a regular allocation
> may not get objects from a slab allocated from the reserves.

Patch [3/10] adds a new field to struct page.  I do not think this is 
necessary.   Allocating a page from reserve does not make it special.  
All we care about is that the total number of pages taken out of 
reserve is balanced by the total pages freed by a user of the reserve.

We do care about slab fragmentation in the sense that a slab page may be 
pinned in the slab by an unprivileged allocation and so that page may 
never be returned to the global page reserve.  One way to solve this is 
to have a per slabpage flag indicating the page came from reserve, and 
prevent mixing of privileged and unprivileged allocations on such a 
page.

> There is already a page reserve, but it does not fully comply with
> our needs. For example, it does not guarantee a strict level (due to
> the relative nature of ALLOC_HIGH and ALLOC_HARDER). Hence we augment
> this reserve with a strict limit.
>
> Furthermore a new __GFP flag is added to allow easy access to the
> reserves along-side the existing PF_MEMALLOC.
>
> Users of this infrastructure will need to do the necessary bean
> counting to ensure they stay within the requested limits.

This patch set is _way_ less intimidating than its predecessor.  
However, I see we have entered the era of sets of patch sets, since it 
is impossible to understand the need for this allocation infrastructure 
without reading the dependent network patch set.  Waiting with 
breathless anticipation.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
