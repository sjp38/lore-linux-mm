Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j35ISFkF004348
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 14:28:15 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35ISFBG220782
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 14:28:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j35ISFKK029979
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:28:15 -0500
Date: Tue, 5 Apr 2005 11:22:40 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 1/6] CKRM: Basic changes to the core kernel
Message-ID: <20050405182240.GE32645@chandralinux.beaverton.ibm.com>
References: <20050402031206.GB23284@chandralinux.beaverton.ibm.com> <1112622313.7189.50.camel@localhost> <20050405172519.GC32645@chandralinux.beaverton.ibm.com> <1112723661.19430.71.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112723661.19430.71.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 05, 2005 at 10:54:20AM -0700, Dave Hansen wrote:
> On Tue, 2005-04-05 at 10:25 -0700, Chandra Seetharaman wrote:
> First of all, why do you need to track individual pages?  Seems a little
> bit silly to charge the first user of something like a commonly-mapped
> library for all users.
> 
> For instance, when you have your super-partitioned-CKRMed-eWLM-apache
> server, doesn't the first class to execute apache get charged for all of
> the pages in the executable and the libraries?  Won't any subsequent
> user classes get it "for free"?  Perhaps tracking which classes have
> mapped pages and sharing the cost among them is a more reasonable
> measurement.
> 
> If you find a way to track things based on files, you could keep your
> class pointers in the struct address_space, or even in the vma,
> depending on what behavior you want.  You could keep anonymous stuff in
> the anon_vma, just like the objrmap code.  

This is the first version of memory controller... Handling shared pages
appropriately are in the plans.
>  
> > > > @@ -355,6 +356,7 @@ free_pages_bulk(struct zone *zone, int c
> > > >                 /* have to delete it as __free_pages_bulk list manipulates */
> > > >                 list_del(&page->lru);
> > > >                 __free_pages_bulk(page, zone, order);
> > > > +               ckrm_clear_page_class(page);
> > > >                 ret++;
> > > >         }
> > > >         spin_unlock_irqrestore(&zone->lock, flags);
> > > 
> > > When your option is on, how costly is the addition of code, here?  How
> > > much does it hurt the microbenchmarks?  How much larger does it
> > 
> > As I said earlier cache-bench doesn't show much effect. Will post that and 
> > other results sometime soon.
> ...
> 
> Looks like only 3k.  
> 
> > > > +       if (!in_interrupt() && !ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> > > > +               return NULL;
> > > 
> > > ckrm_class_limit_ok() is called later on in the same hot path, and
> > > there's a for loop in there over each zone.  How expensive is this on
> > 
> > It doesn't get into the for loop unless the class is over the limit(which
> > is not a frequent event)
> 
> ... if the class is behaving itself.  Somebody trying to take down a
> machine, or a single badly-behaved or runaway app might not behave like
> that.

There are checks in that code to make sure that a runaway app doesn't
get the kernel into this code path often and bring down the system...
instead the runaway app(its class) is penalised.

> 
> > Also, the loop is just to wakeup kswapd once..
> > may be I can get rid of that and use pgdat_list directly.
> 
> I'd try to be a little more selective than a big for loop like that.

'big' for loop ? in that code path ?
> 
> > > SGI's machines?  What about an 8-node x44[05]?  Why can't you call it
> > > from interrupts?
> > 
> > I just wanted to avoid limit related failures in interrupt context, as it
> > might lead to wierd problems.
> 
> You mean you didn't want to make your code robust enough to handle it?
> Is there something fundamental keeping you from checking limits when in
> an interrupt?

It is not the 'checking limit' part that I meant in my reply. It is the
failure due to over limit(that the class is over its limit).

This is my thinking: if a class is not configured properly, and is over
its limit in interrupt context, we are going to fail the memory alloc,
which 'could' lead to unwanted results in the system depending on how the
interrupt handler treats the alloc failure ;)... 

May be I don't have to think that far...

Let me make it clear, there is no CKRM specific reasoning for that check.
> 
> -- Dave
> 

-- 

----------------------------------------------------------------------
    Chandra Seetharaman               | Be careful what you choose....
              - sekharan@us.ibm.com   |      .......you may get it.
----------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
