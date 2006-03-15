Date: Wed, 15 Mar 2006 15:39:04 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: page migration: Fail with error if swap not setup
Message-ID: <20060315213904.GA13771@dmt.cnet>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com> <1142434053.5198.1.camel@localhost.localdomain> <Pine.LNX.4.64.0603150901530.26799@schroedinger.engr.sgi.com> <20060315204742.GB12432@dmt.cnet> <Pine.LNX.4.64.0603151002490.27212@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0603151002490.27212@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, nickpiggin@yahoo.com.au, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 15, 2006 at 10:08:34AM -0800, Christoph Lameter wrote:
> On Wed, 15 Mar 2006, Marcelo Tosatti wrote:
> 
> > > At that point we can also follow Marcelo's suggestion and move the 
> > > migration code into mm/mmigrate.c because it then becomes easier to 
> > > separate the migration code from swap. 
> > 
> > Please - the migration code really does not belong to mm/vmscan.c.
> 
> It performs scanning and has lots of overlapping functionality with 
> swap. Migration was developed based on the swap code in vmscan.c.
> 
> > On the assumption that those page mappings are going to be used, which
> > is questionable.
> > 
> > Lazily faulting the page mappings instead of "pre-faulting" really
> > depends on the load (tradeoff) - might be interesting to make it 
> > selectable.
> 
> If the ptes are removed then the mapcount of the pages also sinks which 
> makes it likely that the swapper will evict these.
> 
> > > - Support migration of VM_LOCKED pages (First question is if we want to 
> > >   have that at all. Does VM_LOCKED imply that a page is fixed at a 
> > >   specific location in memory?).
> > Cryptographic  security  software often handles critical bytes like passwords
> > or secret keys as data structures. As a result of paging, these secrets
> > could  be  transferred  onto a persistent swap store medium, where they
> > might be accessible to the enemy long after the security  software  has
> > erased  the secrets in RAM and terminated. 
> 
> That does not answer the question if VM_LOCKED pages should be 
> migratable. We all agree that they should not show up on swap.

I guess you missed the first part of the man page:

All pages which contain a part of the specified memory range are
guaranteed be resident in RAM when the mlock system call returns
successfully and they are guaranteed to stay in RAM until the pages are
unlocked by munlock or munlockall, until the pages are unmapped via
munmap, or until the process terminates or starts another program with
exec. Child processes do not inherit page locks across a fork.

That is, mlock() only guarantees that pages are kept in RAM and not
swapped. It does seem to refer to physical placing of pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
