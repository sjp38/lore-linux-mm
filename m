Received: from toip3.srvr.bell.ca ([209.226.175.86])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071116143021.XRBN18413.tomts22-srv.bellnexxia.net@toip3.srvr.bell.ca>
          for <linux-mm@kvack.org>; Fri, 16 Nov 2007 09:30:21 -0500
Date: Fri, 16 Nov 2007 09:30:19 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC 5/7] LTTng instrumentation mm
Message-ID: <20071116143019.GA16082@Krystal>
References: <20071113193349.214098508@polymtl.ca> <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1195164977.27759.10.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Dave Hansen (haveblue@us.ibm.com) wrote:
> On Thu, 2007-11-15 at 16:51 -0500, Mathieu Desnoyers wrote:
> > * Dave Hansen (haveblue@us.ibm.com) wrote:
> > > > On Tue, 2007-11-13 at 14:33 -0500, Mathieu Desnoyers wrote:
> > > >  linux-2.6-lttng/mm/page_io.c        2007-11-13 09:49:35.000000000 -0500
> > > > @@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
> > > >                 rw |= (1 << BIO_RW_SYNC);
> > > >         count_vm_event(PSWPOUT);
> > > >         set_page_writeback(page);
> > > > +       trace_mark(mm_swap_out, "address %p", page_address(page));
> > > >         unlock_page(page);
> > > >         submit_bio(rw, bio);
> > > >  out:
> > > 
> > > I'm not sure all this page_address() stuff makes any sense on highmem
> > > systems.  How about page_to_pfn()?
> >
> > Knowing which page frame number has been swapped out is not always as
> > relevant as knowing the page's virtual address (when it has one). Saving
> > both the PFN and the page's virtual address could give us useful
> > information when the page is not mapped.
> 
> For most (all?) architectures, the PFN and the virtual address in the
> kernel's linear are interchangeable with pretty trivial arithmetic.  All
> pages have a pfn, but not all have a virtual address.  Thus, I suggested
> using the pfn.  What kind of virtual addresses are you talking about?
> 

Hum, the mappings I was referring to are the virual memory mappings of
all processes, which is not at all what interests us here.

Let's use the PFN then.

I see that the standard macro to get the kernel address from a pfn is :

asm-x86/page_32.h:#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)

The question might seem trivial, but I wonder how this deals with large
pages ?

Mathieu


> -- Dave
> 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
