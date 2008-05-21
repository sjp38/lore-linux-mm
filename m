Date: Thu, 22 May 2008 08:43:47 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
Message-ID: <20080521234347.GA32707@linux-sh.org>
References: <20080520095935.GB18633@linux-sh.org> <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805212009001.20700@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 08:13:35PM +0300, Pekka J Enberg wrote:
> Hi!
> 
> On Tue, 20 May 2008, Paul Mundt wrote:
> > Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> > ksize() directly seems to do the right thing in all cases, and allows me
> > to boot with any of the slab allocators enabled, rather than simply SLAB
> > by itself.
> > 
> > I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> > which also seems to produce the correct results. Hopefully someone more
> > familiar with the history of kobjsize()/ksize() interaction can scream if
> > this is the wrong thing to do. :-)
> 
> As pointed out by Christoph, it. ksize() works with SLUB and SLOB 
> accidentally because they do page allocator pass-through and thus need to 
> deal with non-PageSlab pages. SLAB, however, does not do that which is why 
> all pages passed to it must have PageSlab set (we ought to add a WARN_ON() 
> there btw).
> 
> So I suggest we fix up kobjsize() instead. Paul, does the following 
> untested patch work for you?
> 
It seems to, but I wonder if compound_order() needs to take a
virt_to_head_page(objp) instead of virt_to_page()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
