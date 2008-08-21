Date: Thu, 21 Aug 2008 08:14:04 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
Message-ID: <20080821131404.GC26567@sgi.com>
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080820113131.f032c8a2.akpm@linux-foundation.org> <20080821024240.GC23397@sgi.com> <48AD689F.6080103@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AD689F.6080103@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tokunaga.keiich@jp.fujitsu.com, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 21, 2008 at 08:07:43AM -0500, Christoph Lameter wrote:
> Robin Holt wrote:
> >
> > Index: ia64-cleanups/include/linux/quicklist.h
> > ===================================================================
> > --- ia64-cleanups.orig/include/linux/quicklist.h	2008-08-20 21:35:10.000000000 -0500
> > +++ ia64-cleanups/include/linux/quicklist.h	2008-08-20 21:38:00.891943270 -0500
> > @@ -66,6 +66,15 @@ static inline void __quicklist_free(int 
> >  
> >  static inline void quicklist_free(int nr, void (*dtor)(void *), void *pp)
> >  {
> > +#ifdef CONFIG_NUMA
> > +	unsigned long nid = page_to_nid(virt_to_page(pp));
> > +
> > +	if (unlikely(nid != numa_node_id())) {
> > +		free_page((unsigned long)pp);
> > +		return;
> > +	}
> > +#endif
> > +
> >  	__quicklist_free(nr, dtor, pp, virt_to_page(pp));
> >  }
> >  
> 
> We removed this code because it frees a page before the TLB flush has been
> performed. This code segment was the reason that quicklists were not accepted
> for x86.

How could we do this.  It was a _HUGE_ problem on altix boxes.  When you
started a jobs with a large number of MPI ranks, they would all start
from the shepherd process on a single node and the children would
migrate to a different cpu.  Unless subsequent jobs used enough memory
to flush those remote quicklists, we would end up with a depleted node
that never reclaimed.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
