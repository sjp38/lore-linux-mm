Message-ID: <466F924A.2040905@yahoo.com.au>
Date: Wed, 13 Jun 2007 16:44:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au> <20070613033306.GA15169@linux-sh.org> <466F66E3.8020200@yahoo.com.au> <466F67A4.9080104@yahoo.com.au> <20070613041319.GA15328@linux-sh.org> <20070613042306.GA15462@linux-sh.org> <Pine.LNX.4.64.0706122225190.28451@schroedinger.engr.sgi.com> <20070613054212.GX11115@waste.org>
In-Reply-To: <20070613054212.GX11115@waste.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
> On Tue, Jun 12, 2007 at 10:30:04PM -0700, Christoph Lameter wrote:
> 
>>Hmmmm. One key advantage that SLOB has over all allocators is the density 
>>of the kmalloc array. I tried to add various schemes to SLUB but there is 
>>still a difference of 340kb on boot. If you get it to do NUMA then may be 
>>we can get a specialized allocator for the kmalloc array out of all of 
>>this?
>>
>>If you focus on the kmalloc array then you can avoid to deal with certain 
>>other issues
>>
>>- No ctor, no reclaim accounting, no rcu etc.
>>- No need to manage partial slabs.
>>- No slab creation, destruction etc.
> 
> 
> That's an interesting point.
> 
> 
>>Maybe that could done in a pretty compact way and replace the space 
>>wasting kmalloc arrays in SLAB and SLUB?
> 
> 
> We'll need to up the SMP scalability for that to make sense. Using
> page flags for per-page locking and such might be a start. I've been
> hoping Nick would propose something here, as those sorts of hacks seem
> to be his thing.

It's tricky as we still have the page list.

It wouldn't be difficult to add a bit-spinlock in the page flags and use
that for the intra-page list traversal, dropping the main lock after
taking the bit lock.

But even if the page list was lockless, I'd worry about locking required
to modify the list, and also, in the current scheme, multiple CPUs all
contending the same bit lock.

So I think from every angle it makes sense to break the page list into
multiple lists first. Per-cpu would be easiest.

After that, we could do lockless page list traversals (and the
finegrained page locking would make a lot of sense) -- easy way would
just be to RCU-free the struct page, cool way would be to instead use
speculative page references from the lockless pagecache :P

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
