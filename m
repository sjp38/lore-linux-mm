Date: Tue, 1 May 2007 12:25:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705011215180.25494@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Hugh Dickins wrote:

> > Most of the rest of slub.  Will merge it all.
> 
> Merging slub already?  I'm surprised.  That's a very key piece of
> infrastructure, and I doubt it's had the exposure it needs yet.

Its not the default. Its just an alternative like SLOB. It will take some 
time to test with various loads in order to see if it can really replace
SLAB in all scenarios.
 
> Just what has it been widely tested on so far?  x86_64.  Not many
> of us have ia64, but I guess SGI people will have been trying it
> on that.  Not i386, that's excluded.

There is an i386 patch pending and I have used it on i386 for a while.
 
> Not powerpc - hmm, I thought that was known, but looking I see no
> ARCH_USES_SLAB_PAGE_STRUCT there: just built and tried to run it up,
> crashes in slab_free from pgtable_free_tlb frpm free_pte_range from
> free_pgd_range from free_pgtables from unmap_region form do_munmap.
> That's 2.6.21-rc7-mm2.

Hmmm... True I have not spend any time with that platform. We can set 
ARCH_USES_SLAB_PAGE_STRUCT there to switch it off. SLUB is the default for 
mm so I am a bit surprised that this did not surface earlier.

> I've nothing against slub in itself, though I'm wary of its
> cache merging (more scope for one corrupting another) (and

Yes but then SLUB has more diagnostics etc etc than SLAB to prevent any 
issues. In debug mode all slabs are separate. The merge feature is very 
stable these days and significantly reduces cache overhead problems 
that plague SLAB and require it to have a complex object expiration 
technique. As a result I was able to rip out all timers. SLUB has no cache 
reaper nor any timer. Its silent if not in use.

> sometimes I think Christoph spent one life uglifying slab for
> NUMA, then another life ripping that all out to make slub ;)

SLAB has a certain paradigm of doing things (queues) and I had to work 
within that framework. It was a group effort. SLUB is an answer to those 
complaints and a result of the lessons learned through years of some 
painful slab debugging. SLUB makes debugging extremely easy (and also the 
design is very simple and comprehensible). No rebuilding of the kernel. 
Just pop in a debug option on the command line which can even be targeted 
to a slab cache if we know that things break there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
