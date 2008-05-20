Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
	ksize().
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>
	 <2373.1211296724@redhat.com>
	 <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 20 May 2008 13:23:40 -0500
Message-Id: <1211307820.18026.190.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-05-20 at 09:52 -0700, Christoph Lameter wrote:
> On Tue, 20 May 2008, David Howells wrote:
> 
> > Paul Mundt <lethal@linux-sh.org> wrote:
> > 
> > > Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> > > ksize() directly seems to do the right thing in all cases, and allows me
> > > to boot with any of the slab allocators enabled, rather than simply SLAB
> > > by itself.
> > > 
> > > I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> > > which also seems to produce the correct results. Hopefully someone more
> > > familiar with the history of kobjsize()/ksize() interaction can scream if
> > > this is the wrong thing to do. :-)
> > 
> > That seems reasonable.  I can't test it until I get back to the UK next week.
> 
> Hmm. That means we are sanctioning using ksize on arbitrary objects? SLUB 
> supports that but SLAB wont and neither will SLOB. I think we need to stay 
> with the strict definition that is needed by SLOB.

Of course SLUB won't be able to tell you the size of objects allocated
statically, through bootmem, etc.

> It seems also that the existing kobjsize function is wrong:
> 
> 1. For compound pages the head page needs to be determined.
> 
> So do a virt_to_head_page() instead of a virt_to_page().
> 
> 2. Why is page->index take as the page order?
> 
> Use compound_order instead?
> 
> I think the following patch will work for all allocators (can 
> virt_to_page() really return NULL if the addr is invalid if so we may
> have to fix virt_to_head_page()?):
> 
> ---
>  mm/nommu.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6/mm/nommu.c
> ===================================================================
> --- linux-2.6.orig/mm/nommu.c	2008-05-20 09:50:25.686495370 -0700
> +++ linux-2.6/mm/nommu.c	2008-05-20 09:50:51.797745535 -0700
> @@ -109,16 +109,14 @@ unsigned int kobjsize(const void *objp)
>  	 * If the object we have should not have ksize performed on it,
>  	 * return size of 0
>  	 */
> -	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
> +	if (!objp || (unsigned long)objp >= memory_end ||
> +				!((page = virt_to_head_page(objp))))

I think the real problem here is that nommu is way too intimate with the
allocator. This makes it even more so. Paul's approach of pushing this
down into SLAB is a step in the right direction. The next step is
teaching nommu to distinguish (statically) between
kmalloced/kmem_cache_alloced/static objects, which is a somewhat bigger
problem.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
