Received: from toip7.srvr.bell.ca ([209.226.175.124])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071129023423.EWKY17217.tomts5-srv.bellnexxia.net@toip7.srvr.bell.ca>
          for <linux-mm@kvack.org>; Wed, 28 Nov 2007 21:34:23 -0500
Date: Wed, 28 Nov 2007 21:34:22 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC PATCH] LTTng instrumentation mm (using page_to_pfn)
Message-ID: <20071129023421.GA711@Krystal>
References: <20071113193349.214098508@polymtl.ca> <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost> <20071116143019.GA16082@Krystal> <1195495485.27759.115.camel@localhost> <20071128140953.GA8018@Krystal> <1196268856.18851.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1196268856.18851.20.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

I am adding the rest.. two questions left :

* Dave Hansen (haveblue@us.ibm.com) wrote:
 
> > 
> > Index: linux-2.6-lttng/mm/memory.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/memory.c	2007-11-28 08:42:09.000000000 -0500
> > +++ linux-2.6-lttng/mm/memory.c	2007-11-28 09:02:57.000000000 -0500
> > @@ -2072,6 +2072,7 @@ static int do_swap_page(struct mm_struct
> >  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> >  	page = lookup_swap_cache(entry);
> >  	if (!page) {
> > +		trace_mark(mm_swap_in, "pfn %lu", page_to_pfn(page));
> >  		grab_swap_token(); /* Contend for token _before_ read-in */
> >   		swapin_readahead(entry, address, vma);
> >   		page = read_swap_cache_async(entry, vma, address);
> 
> How about putting the swap file number and the offset as well?
> 
[...]
> > Index: linux-2.6-lttng/mm/page_io.c
> > ===================================================================
> > --- linux-2.6-lttng.orig/mm/page_io.c	2007-11-28 08:38:47.000000000 -0500
> > +++ linux-2.6-lttng/mm/page_io.c	2007-11-28 08:52:14.000000000 -0500
> > @@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
> >  		rw |= (1 << BIO_RW_SYNC);
> >  	count_vm_event(PSWPOUT);
> >  	set_page_writeback(page);
> > +	trace_mark(mm_swap_out, "pfn %lu", page_to_pfn(page));
> >  	unlock_page(page);
> >  	submit_bio(rw, bio);
> 
> I'd also like to see the swap file number and the location in swap for
> this one.  
> 

Before I start digging deeper in checking whether it is already
instrumented by the fs instrumentation (and would therefore be
redundant), is there a particular data structure from mm/ that you
suggest taking the swap file number and location in swap from ?

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
