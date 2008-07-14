From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SL*B: drop kmem cache argument from constructor
Date: Mon, 14 Jul 2008 14:44:57 +1000
References: <20080710011132.GA8327@martell.zuzino.mipt.ru> <48763C60.9020805@linux.vnet.ibm.com> <20080711122228.eb40247f.akpm@linux-foundation.org>
In-Reply-To: <20080711122228.eb40247f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807141444.57802.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jon Tollefson <kniht@linux.vnet.ibm.com>, Alexey Dobriyan <adobriyan@gmail.com>, penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Saturday 12 July 2008 05:22, Andrew Morton wrote:
> On Thu, 10 Jul 2008 11:44:16 -0500 Jon Tollefson <kniht@linux.vnet.ibm.com> 
wrote:
> > Alexey Dobriyan wrote:
> > > Kmem cache passed to constructor is only needed for constructors that
> > > are themselves multiplexeres. Nobody uses this "feature", nor does
> > > anybody uses passed kmem cache in non-trivial way, so pass only pointer
> > > to object.
> > >
> > > Non-trivial places are:
> > > 	arch/powerpc/mm/init_64.c
> > > 	arch/powerpc/mm/hugetlbpage.c
> >
> > ...<snip>...
> >
> > > --- a/arch/powerpc/mm/hugetlbpage.c
> > > +++ b/arch/powerpc/mm/hugetlbpage.c
> > > @@ -595,9 +595,9 @@ static int __init hugepage_setup_sz(char *str)
> > >  }
> > >  __setup("hugepagesz=", hugepage_setup_sz);
> > >
> > > -static void zero_ctor(struct kmem_cache *cache, void *addr)
> > > +static void zero_ctor(void *addr)
> > >  {
> > > -	memset(addr, 0, kmem_cache_size(cache));
> > > +	memset(addr, 0, HUGEPTE_TABLE_SIZE);
> >
> > This isn't going to work with the multiple huge page size support.  The
> > HUGEPTE_TABLE_SIZE macro now takes a parameter with of the mmu psize
> > index to indicate the size of page.
>
> hrm.  I suppose we could hold our noses and use ksize(), assuming that
> we're ready to use ksize() at this stage in the object's lifetime.
>
> Better would be to just use kmem_cache_zalloc()?

As this is hugepages we're talking about, probably yes. But note that
page tables are one of those things where we (I?) think constructors are
probably a good idea -- they tend to be very sparse.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
