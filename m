From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [git pull] SLUB updates for 2.6.25
Date: Tue, 5 Feb 2008 11:42:20 +1100
References: <Pine.LNX.4.64.0802041206190.3241@schroedinger.engr.sgi.com> <200802051105.12194.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802041629290.5057@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802041629290.5057@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802051142.20413.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: willy@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 05 February 2008 11:32, Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Nick Piggin wrote:
> > Ok. But the approach is just not so good. If you _really_ need something
> > like that and it is a win over the regular non-atomic unlock, then you
> > just have to implement it as a generic locking / atomic operation and
> > allow all architectures to implement the optimal (and correct) memory
> > barriers.
>
> Assuming this really gives a benefit on several benchmarks then we need
> to think about how to do this some more. Its a rather strange form of
> locking.
>
> Basically you lock the page with a single atomic operation that sets
> PageLocked and retrieves the page flags.

This operation is not totally unusual. I could use it for my optimised
page lock patches for example (although I need an operation that clears
a flag and has release semantics, but similar class of "thing").


> Then we shovel the page state 
> around a couple of functions in a register and finally store the page
> state back which at the same time unlocks the page.

And this is a store-for-unlock (eg. with release semantics).
Nothing too special about that either I guess. (it is almost the word
equivalent of clear_bit_unlock).


> So two memory 
> references with one of them being atomic with none in between. We have
> nothing that can do something like that right now.

The load you are trying to avoid in the lock really isn't that
expensive. The cacheline is in L1. Even after a store, many CPUs
have store forwarding so it is probably not going to matter at all
on those.

Anyway, not saying the operations are useless, but they should be
made available to core kernel and implemented per-arch. (if they are
found to be useful)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
