Date: Wed, 15 Mar 2006 10:08:34 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <20060315204742.GB12432@dmt.cnet>
Message-ID: <Pine.LNX.4.64.0603151002490.27212@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <1142434053.5198.1.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com>
 <20060315204742.GB12432@dmt.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Mar 2006, Marcelo Tosatti wrote:

> > At that point we can also follow Marcelo's suggestion and move the 
> > migration code into mm/mmigrate.c because it then becomes easier to 
> > separate the migration code from swap. 
> 
> Please - the migration code really does not belong to mm/vmscan.c.

It performs scanning and has lots of overlapping functionality with 
swap. Migration was developed based on the swap code in vmscan.c.

> On the assumption that those page mappings are going to be used, which
> is questionable.
> 
> Lazily faulting the page mappings instead of "pre-faulting" really
> depends on the load (tradeoff) - might be interesting to make it 
> selectable.

If the ptes are removed then the mapcount of the pages also sinks which 
makes it likely that the swapper will evict these.

> > - Support migration of VM_LOCKED pages (First question is if we want to 
> >   have that at all. Does VM_LOCKED imply that a page is fixed at a 
> >   specific location in memory?).
> Cryptographic  security  software often handles critical bytes like passwords
> or secret keys as data structures. As a result of paging, these secrets
> could  be  transferred  onto a persistent swap store medium, where they
> might be accessible to the enemy long after the security  software  has
> erased  the secrets in RAM and terminated. 

That does not answer the question if VM_LOCKED pages should be 
migratable. We all agree that they should not show up on swap.

> > - Think about how to realize migration of kernel pages (some arches have
> >   page table for kernel space, one could potentially remap the address 
> >   instead of going through all the twists and turns of the existing 
> >   hotplug approach. See also what virtual iron has done about this.).
> 
> Locking sounds tricky, how do you guarantee that nobody is going to
> access such kernel virtual addresses (and their TLB-cached entries)
> while they're physical address is being changed ?

I guess this could be done by having a very simple fault handler for 
kernel memory that would simply wait on a valid pte.

Then invalidate pte, move the page and reinstall pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
