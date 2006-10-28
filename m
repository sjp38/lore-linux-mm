Date: Fri, 27 Oct 2006 21:43:24 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page allocator: Single Zone optimizations
Message-Id: <20061027214324.4f80e992.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
	<20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
	<45347288.6040808@yahoo.com.au>
	<Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
	<45360CD7.6060202@yahoo.com.au>
	<20061018123840.a67e6a44.akpm@osdl.org>
	<Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
	<20061026150938.bdf9d812.akpm@osdl.org>
	<Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
	<20061027190452.6ff86cae.akpm@osdl.org>
	<Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
	<20061027192429.42bb4be4.akpm@osdl.org>
	<Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Oct 2006 19:31:20 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 27 Oct 2006, Andrew Morton wrote:
> 
> > We need some way of preventing unreclaimable kernel memory allocations from
> > using certain physical pages.  That means zones.
> 
> Well then we may need zones for defragmentation and zeroed pages as well 
> etc etc. The problem is that such things make the VM much more 
> complex and not simpler and faster.

Right.  We need zones for lots and lots of things.  This all comes back to
my main point: the hardwired and magical DMA, DMA32, NORMAL and HIGHMEM
zones don't cut it.  We'd be well-served by implementing the core MM as
just "one or more zones".  The placement, sizing and *meaning* behind those
zones is externally defined.

> > > Memory hot unplug 
> > > seems to have been dropped in favor of baloons.
> > 
> > Has it?  I don't recall seeing a vague proposal, let alone an implementation?
> 
> That is the impression that I got at the OLS. There were lots of talks 
> about baloons approaches.

That's all virtual machine stuff, where the "kernel"'s memory is virtual,
not physical.

> > Userspace allocations are reclaimable: pagecache, anonymous memory.  These
> > happen to be allocated with __GFP_HIGHMEM set.
> 
> On certain platforms yes.

On _all_ platforms.  See GFP_HIGHUSER.

The only exception here is highpte.

> > So right now __GFP_HIGHMEM is an excellent hint telling the page allocator
> > that it is safe to satisfy this request from removeable memory.
> 
> OK this works on i386 but most other platforms wont have a highmem 
> zone.

Under this proposal platforms which wish to implement physical hot-unplug
would need to effectively implement highmem.  They won't keep to kmap the
pages to access their contents, but they will need to ensure that
unreclaimable allocations be constrained to the non-removable physical
memory.

It's all pretty simple.  But it'd be hacky to implement it in terms of
"highmem".  It would be better if we could just tell the core MM "here's a
4G zone" and "here's a 60G zone".  The 60G zone is only used for
GFP_HIGHUSER allocations and is hence unpluggable.

I don't think there's any other (practical) way of implementing hot-unplug.


But hot-unplug is just an example.  My main point here is that it is
desirable that we get away from the up-to-four magical hard-wired zones in
core MM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
