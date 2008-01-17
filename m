Date: Thu, 17 Jan 2008 01:27:15 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] #ifdef very expensive debug check in page fault path
Message-ID: <20080117002715.GA10056@wotan.suse.de>
References: <1200506488.32116.11.camel@cotte.boeblingen.de.ibm.com> <20080116234540.GB29823@wotan.suse.de> <20080116161021.c9a52c0f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080116161021.c9a52c0f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Carsten Otte <cotte@de.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, schwidefsky@de.ibm.com, holger.wolf@de.ibm.com, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2008 at 04:10:21PM -0800, Andrew Morton wrote:
> On Thu, 17 Jan 2008 00:45:40 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > On Wed, Jan 16, 2008 at 07:01:28PM +0100, Carsten Otte wrote:
> > > This patch puts #ifdef CONFIG_DEBUG_VM around a check in vm_normal_page
> > > that verifies that a pfn is valid. This patch increases performance of
> > > the page fault microbenchmark in lmbench by 13% and overall dbench
> > > performance by 7% on s390x.  pfn_valid() is an expensive operation on
> > > s390 that needs a high double digit amount of CPU cycles.
> > > Nick Piggin suggested that pfn_valid() involves an array lookup on
> > > systems with sparsemem, and therefore is an expensive operation there
> > > too.
> > > The check looks like a clear debug thing to me, it should never trigger
> > > on regular kernels. And if a pte is created for an invalid pfn, we'll
> > > find out once the memory gets accessed later on anyway. Please consider
> > > inclusion of this patch into mm.
> > > 
> > > Signed-off-by: Carsten Otte <cotte@de.ibm.com>
> > 
> > Wow, that's a big performance hit for a few instructions ;)
> > I haven't seen it to be quite so expensive on x86, but it definitely is
> > not zero cost, especially with NUMA kernels. Thanks for getting those
> > numbers.
> > 
> > I posted a version which got rid of that big comment block too, but
> > no feedback as yet.
> > 
> > http://marc.info/?l=linux-arch&m=120046068604222&w=2
> > 
> > The one actual upside of this code is that if there is pte corruption
> > detected, the failure should be a little more graceful... but there
> > is also lots of pte corruption that could go undetected and cause much
> > worse problems anyway so I don't feel it is something that needs to
> > be turned on in production kernels. It could be a good debugging aid
> > to mm/ or device driver writers though.
> > 
> > Anyway, again I've cc'ed Hugh, because he nacked this same patch a
> > while back. So let's try to get him on board before merging anything.
> > 
> > If we get an ack, why not send this upstream for 2.6.24? Those s390
> > numbers are pretty insane.
> 
> I intend to merge this into 2.6.24.

Good. If it helps,
Acked-by: Nick Piggin <npiggin@suse.de>

> 
> > > --- 
> > > Index: linux-2.6/mm/memory.c
> > > ===================================================================
> > > --- linux-2.6.orig/mm/memory.c
> > > +++ linux-2.6/mm/memory.c
> > > @@ -392,6 +392,7 @@ struct page *vm_normal_page(struct vm_ar
> > >  			return NULL;
> > >  	}
> > >  
> > > +#ifdef CONFIG_DEBUG_VM
> > >  	/*
> > >  	 * Add some anal sanity checks for now. Eventually,
> > >  	 * we should just do "return pfn_to_page(pfn)", but
> > > @@ -402,6 +403,7 @@ struct page *vm_normal_page(struct vm_ar
> > >  		print_bad_pte(vma, pte, addr);
> > >  		return NULL;
> > >  	}
> > > +#endif
> > >  
> > >  	/*
> > >  	 * NOTE! We still have PageReserved() pages in the page 
> > > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
