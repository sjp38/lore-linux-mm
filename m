Date: Thu, 22 Jun 2006 11:31:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/6] mm: remove some update_mmu_cache() calls
In-Reply-To: <Pine.LNX.4.64.0606221824260.13355@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0606221107460.29846@schroedinger.engr.sgi.com>
References: <20060619175243.24655.76005.sendpatchset@lappy>
 <20060619175347.24655.67680.sendpatchset@lappy>
 <Pine.LNX.4.64.0606221646000.4977@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0606220935130.28760@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0606221824260.13355@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2006, Hugh Dickins wrote:

> It's intentionally allowed to be racy (ambiguous whether a racing
> thread sees protections before or protections after) up until the
> flush_tlb_range.  Should be well-defined from there on.
> Or am I misunderstanding you?

No thats fine but this line of thinking establishes that we need 
update_mmu_cache for protection changes. So the documentation on the role 
of these calls needs to change.  lazy_mmu_prot_update does not do the 
notification to arch specific code as documented otherwise we would not 
need the flush_tlb_range. In fact it seems that lazy_mmu_prot_update does
only deal with icache/dcache coherency issues and it is separate from 
update_mmu_cache because we can avoid checking the icache/dcache issues in 
every update_mmu_cache. 

> > > But now I wonder, why does do_wp_page reuse case flush_cache_page?
> > 
> > Some arches may have virtual caches?
> 
> Sorry, I don't get it, you'll have to spell it out to me in detail.
> We have a page mapped for reading, we're about to map that same page
> for writing too.  We have no modifications to flush yet,
> why flush_cache_page there?

Hmmm. I found this by Dave Miller in 1999

http://www.ussg.iu.edu/hypermail/linux/kernel/9906.0/1237.html
  
  flush_cache_page(vma, page) is meant to also take care of the case
  here for some reason the TLB entry must exist for the cache entry to
  be valid as well. This is the case on the HyperSparc's combined I/D
  L2 cache (it has no L1 cache), you cannot flush out cache entries
  which have no translation, it will make the cpu trap. Sparc/sun4c's
  mmu is like this too.

If I read this correctly then it seems the reason that flush_cache_page 
was placed there is that on some architecture the TLB entry must exist 
correctly on virtual caches to be able to flush the caches (maybe they 
are hashed?). update_mmu_cache is called after we changed things so there
may be no way to determine how to flush the cache contents for the page 
contents if we later drop the page.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
