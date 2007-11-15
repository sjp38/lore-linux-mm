Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts25-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071115215143.CCRZ19497.tomts25-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:51:43 -0500
Date: Thu, 15 Nov 2007 16:51:42 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC 5/7] LTTng instrumentation mm
Message-ID: <20071115215142.GA7825@Krystal>
References: <20071113193349.214098508@polymtl.ca> <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1195160783.7078.203.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Dave Hansen (haveblue@us.ibm.com) wrote:
> > On Tue, 2007-11-13 at 14:33 -0500, Mathieu Desnoyers wrote:
> >  linux-2.6-lttng/mm/page_io.c        2007-11-13 09:49:35.000000000 -0500
> > @@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
> >                 rw |= (1 << BIO_RW_SYNC);
> >         count_vm_event(PSWPOUT);
> >         set_page_writeback(page);
> > +       trace_mark(mm_swap_out, "address %p", page_address(page));
> >         unlock_page(page);
> >         submit_bio(rw, bio);
> >  out:
> 
> I'm not sure all this page_address() stuff makes any sense on highmem
> systems.  How about page_to_pfn()?
> 

Hrm, maybe both ?

Knowing which page frame number has been swapped out is not always as
relevant as knowing the page's virtual address (when it has one). Saving
both the PFN and the page's virtual address could give us useful
information when the page is not mapped.

We face two possible approaches : either we save both the address and
the pfn at each event and later have the information at once in the
trace, or we instrument the kernel virtual addresses map/unmap
operations and let the trace analyzer figure out the mappings.

It is sometimes a big benefit traffic-wise to let the userspace tool do
recreate the kernel structures from the traced information, but it
involved specialized treatment in the userspace tools. If we chose this
solution, we could simply save the PFN in the event, as you propose.


> I also have to wonder if you should be hooking into count_vm_event() and
> using those.  Could you give a high-level overview of exactly why you
> need these hooks, and perhaps what you expect from future people adding
> things to the VM?
> 

Yep, I guess we could put useful markers beside the count_vm_events
inline function calls.

High level overview :

We currently have a "LTTng statedump", which iterates on the mappings of
all tasks at trace start time to dump them in the trace. We also
instrument memory allocation/free. We therefore have much of the
information needed to recreate the memory mappings in the kernel at any
point during the trace by "replaying" the trace.

Having the events that helps us to recreate it
- precisely
- efficiently
- with a level of generality that should not break "too much" between
  kernel versions

would be useful to us.

Then we could start creating plugins in our userspace trace analysis
tool to analyze fun stuff such as sources of memory fragmentation.

Then coupling that with, eventually, performance counter, we could start
doing really fun things with cache misses...

It can also be useful to you guys to find our problems by adding ad-hoc
instrumentation to the VM code when pinpointing the cause of a problem.
Martin Bligh made interesting things applying a tracer to the vm,
described in "Linux Kernel Debugging on Google-sized clusters" in
OLS2007 proceedings.

(https://ols2006.108.redhat.com/2007/Reprints/OLS2007-Proceedings-V1.pdf)

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
