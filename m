Date: Tue, 23 Jul 2002 23:48:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page_add/remove_rmap costs
Message-ID: <20020724064813.GE25028@holomorphy.com>
References: <3D3E4A30.8A108B45@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D3E4A30.8A108B45@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2002 at 11:33:20PM -0700, Andrew Morton wrote:
> So I don't know why the pte_chain_unlock() is so expensive in there.
> But even if it could be fixed, we're still too slow.
> My gut feel here is that this will be hard to tweak - some algorithmic
> change will be needed.

Atomic operation on a cold/unowned/falsely shared cache line. The
operation needs to be avoided when possible.


On Tue, Jul 23, 2002 at 11:33:20PM -0700, Andrew Morton wrote:
> The pte_chains are doing precisely zilch but chew CPU cycles with this
> workload.  The machine has 2G of memory free.  The rmap is pure overhead.
> Would it be possible to not build the pte_chain _at all_ until it is
> actually needed?  Do it lazily?  So in the page reclaim code, if the
> page has no rmap chain we go off and build it then?  This would require
> something like a pfn->pte lookup function at the vma level, and a
> page->vmas_which_own_me lookup.

The space overhead of keeping them up to date can be mitigated, but this
time overhead can't be circumvented so long as strict per-pte updates
are required. I'm uncertain about lazy construction of them; I suspect
it will raise OOM issues (allocating in order to evict) and often be
constructed only never to be used again, but am not sure.


On Tue, Jul 23, 2002 at 11:33:20PM -0700, Andrew Morton wrote:
> Nice thing about this is that a) we already have page->flags
> exclusively owned at that time, so the pte_chain_lock() _should_ be
> cheap.  And b) if the rmap chain is built in this way, all the
> pte_chain structures against a page will have good
> locality-of-reference, so the chain walk will involve far fewer cache
> misses.

This is a less invasive proposal than various others that have been
going around, and could probably be tried and tested quickly.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
