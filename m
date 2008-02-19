Date: Tue, 19 Feb 2008 02:46:00 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm: scalable vmaps
Message-ID: <20080219014600.GC21165@wotan.suse.de>
References: <20080218082219.GA2018@wotan.suse.de> <200802181104.45898.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200802181104.45898.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, David Chinner <dgc@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2008 at 11:04:45AM +0100, Andi Kleen wrote:
> 
> > One thing that will be common to any high performance vmap implementation,
> > however, will be the use of lazy TLB flushing. So I'm mainly interested
> > in comments about this. AFAIK, Xen must be able to eliminate these aliases
> > on demand, and CPA also doesn't want aliases around even if they don't
> > get explicitly referenced by software 
> 
> It's not really a requirement by CPA, but one by the hardware. Alias
> mappings always need to have the same caching attributes.

Right, yes.

 
> > (because the hardware may do a 
> > random speculative operation through the TLB).
> > 
> > So I just wonder if it is enough to provide a (quite heavyweight) function
> > to flush aliases? (vm_unmap_aliases)
> 
> For CPA that would work currently (calling that function there
> if the caching attributes are changed),  although when CPA use is more wide 
> spread than it currently is it might be a problem at some point if it is very slow.

I guess CPA is pretty slow anyway because it does a global tlb flush.
vm_unmap_aliases is not going to be terribly slow by comparison (the
global TLB flush is one of its more expensive aspects).

 
> > I ripped the not-very-good vunmap batching code out of XFS, and implemented
> > the large buffer mapping with vm_map_ram and vm_unmap_ram... along with
> > a couple of other tricks, I was able to speed up a large directory workload
> > by 20x on a 64 CPU system. Basically I believe vmap/vunmap is actually
> > sped up a lot more than 20x on such a system, but I'm running into other
> > locks now. vmap is pretty well blown off the profiles.
> 
> Cool. Gratulations.

Thanks! I'm not sure how "interesting" the workload is ;) but at least it
shows the new vmap is scalable and working properly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
