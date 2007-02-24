Date: Fri, 23 Feb 2007 20:30:46 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC/PATCH] slab: free pages in a batch in drain_freelist
Message-ID: <20070224043046.GV21484@holomorphy.com>
References: <Pine.LNX.4.64.0702221500420.22546@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702221500420.22546@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Pekka J Enberg wrote:
>> As suggested by William, free the actual pages in a batch so that we
>> don't keep pounding on l3->list_lock.

On Thu, Feb 22, 2007 at 03:01:30PM -0800, Christoph Lameter wrote:
> This means holding the l3->list_lock for a prolonged time period. The 
> existing code was done this way in order to make sure that the interrupt 
> holdoffs are minimal.
> There is no pounding. The cacheline with the list_lock is typically held 
> until the draining is complete. While we drain the freelist we need to be 
> able to respond to interrupts.

I had in mind something more like a list_splice_init() operation under
the lock, since it empties the entire list except in the case of
cache_reap(). For cache_reap(), not much could be done unless they were
organized into batches of (l3->free_limit+5*searchp->num-1)/(5*searchp->num)
such as a list of lists of that length, which would need to be
reorganized when tuning ->batchcount occurs.

It's not terribly meaningful since only grand reorganizations that are
presumed to stop the world actually get "sped up" without the additional
effort required to improve cache_reap(). My commentary was more about
the data structures being incapable of bulk movement operations for
batching like or analogous to list_splice() than trying to say that
drain_freelist() in particular should be optimized. Allowing movement of
larger batches without increased hold time in transfer_objects() is
clearly a more meaningful goal, for example.

Furthermore, the patch as written merely increases hold time in
exchange for decreased arrival rate resulting in no net improvement.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
