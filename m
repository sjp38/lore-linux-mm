Date: Wed, 21 May 2008 10:19:25 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
Message-ID: <20080521011925.GB24455@linux-sh.org>
References: <20080520095935.GB18633@linux-sh.org> <2373.1211296724@redhat.com> <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com> <1211307820.18026.190.camel@calx> <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com> <1211310023.18026.210.camel@calx> <Pine.LNX.4.64.0805201206040.10964@schroedinger.engr.sgi.com> <1211310896.18026.214.camel@calx> <Pine.LNX.4.64.0805201215330.11020@schroedinger.engr.sgi.com> <1211318557.18026.215.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211318557.18026.215.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <clameter@sgi.com>, David Howells <dhowells@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 04:22:37PM -0500, Matt Mackall wrote:
> On Tue, 2008-05-20 at 12:16 -0700, Christoph Lameter wrote:
> > On Tue, 20 May 2008, Matt Mackall wrote:
> > > > How would that work given that both SLUB and SLOB forward >4k allocs to 
> > > > the page allocator? So any compound page allocation may be a slab 
> > > > allocation. Is there some way to distinguish between a 
> > > > allocations of the page allocator and a slab alloc?
> > > 
> > > We can't do it at all for SLOB. But when debugging is turned on, we can
> > > notice (in SLAB and SLUB) whenever anyone asks for the ksize() of
> > > something that lives on a non-kmalloc slab.
> > 
> > We could mark the pages specially I guess. Add a slab flag for 
> > kmalloc? PageSlab and PageKmalloc?
> 
> No, just warn for the cases where we already have enough information.
> 
If we go in that direction the existing users are already going to
trigger this a lot (ie, commit 4016a1390d07f15b267eecb20e76a48fd5c524ef).
Without this sort of heuristic in place, simply killing off kobjsize()
and calling in to ksize() directly would be a reasonable option.

Having WARN_ON()'s for !PageSlab() pages in ksize() in SLAB/SLUB would
make these cases more visible, at least.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
