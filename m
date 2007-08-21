Date: Tue, 21 Aug 2007 15:32:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water marks
In-Reply-To: <46CB5C89.2070807@redhat.com>
Message-ID: <Pine.LNX.4.64.0708211521260.5728@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com>  <1187692586.6114.211.camel@twins>
  <Pine.LNX.4.64.0708211347480.3082@schroedinger.engr.sgi.com>
 <1187730812.5463.12.camel@lappy> <Pine.LNX.4.64.0708211418120.3267@schroedinger.engr.sgi.com>
 <46CB5C89.2070807@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, dkegel@google.com, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, ak@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Rik van Riel wrote:

> Christoph Lameter wrote:
> 
> > I want general improvements to reclaim to address the issues that you see
> > and other issues related to reclaim instead of the strange code that makes
> > PF_MEMALLOC allocs compete for allocations from a single slab and putting
> > logic into the kernel to decide which allocs to fail. We can reclaim after
> > all. Its just a matter of finding the right way to do this. 
> 
> The simplest way of achieving that would be to allow
> recursion of the page reclaim code, under the condition
> that the second level call can only reclaim clean pages,
> while the "outer" call does what the VM does today.

Yes that is what the precursor to this patchset does.

See http://marc.info/?l=linux-mm&m=118710207203449&w=2

This one did not even come up to the level of the earlier one. Sigh.

The way forward may be:

1. Like in the earlier patchset allow reentry to reclaim under 
   PF_MEMALLOC if we are out of all memory.

2. Do the laundry as here but do not write out laundry directly.
   Instead move laundry to a new lru style list in the zone structure.
   This will allow the recursive reclaim to also trigger writeout
   of pages (what this patchset was supposed to accomplish).

3. Perform writeback only from kswapd. Make other threads
   wait on kswapd if memory is low, we can wait and writeback still
   has to progress.

4. Then allow reclaim of GFP_ATOMIC allocs (see
   http://marc.info/?l=linux-kernel&m=118710595617696&w=2). Atomic
   reclaim can then also put pages onto the zone laundry lists from where
   it is going to be picked up and written out by kswapd ASAP. This one
   may be tricky so maybe keep this separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
