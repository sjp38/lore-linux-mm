Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j35HsT5b215498
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:54:29 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35HsTOq196566
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:54:29 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j35HsSFt021052
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 11:54:28 -0600
Subject: Re: [PATCH 1/6] CKRM: Basic changes to the core kernel
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050405172519.GC32645@chandralinux.beaverton.ibm.com>
References: <20050402031206.GB23284@chandralinux.beaverton.ibm.com>
	 <1112622313.7189.50.camel@localhost>
	 <20050405172519.GC32645@chandralinux.beaverton.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Apr 2005 10:54:20 -0700
Message-Id: <1112723661.19430.71.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chandra Seetharaman <sekharan@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-05 at 10:25 -0700, Chandra Seetharaman wrote:
> > > +#define PG_ckrm_account                21      /* CKRM accounting */
> > 
> > Are you sure you really need this bit *and* a whole new pointer in
> > 'struct page'?  We already do some tricks with ->mapping so that we can
> > tell what is stored in it.  You could easily do something with the low
> > bit of your new structure member.
> 
> I think I canavoid using  the bit. The problem with having a pointer in page
> data structure is two-fold:
> 	1. goes over the page-cahe (I ran cache-bench with mem controller
> 	      enabled, and didn't see much of a difference. will post the
> 	      new results sometime soon)
> 	2. additional memory used, especially in large systems
> 
> Using the mapping logic, we can avoid problem (1), but increase problem (2)
> with added complexity and run-time logic. I am looking a way to avoid both
> the problems, any help appreciated.

First of all, why do you need to track individual pages?  Seems a little
bit silly to charge the first user of something like a commonly-mapped
library for all users.

For instance, when you have your super-partitioned-CKRMed-eWLM-apache
server, doesn't the first class to execute apache get charged for all of
the pages in the executable and the libraries?  Won't any subsequent
user classes get it "for free"?  Perhaps tracking which classes have
mapped pages and sharing the cost among them is a more reasonable
measurement.

If you find a way to track things based on files, you could keep your
class pointers in the struct address_space, or even in the vma,
depending on what behavior you want.  You could keep anonymous stuff in
the anon_vma, just like the objrmap code.  
 
> > > @@ -355,6 +356,7 @@ free_pages_bulk(struct zone *zone, int c
> > >                 /* have to delete it as __free_pages_bulk list manipulates */
> > >                 list_del(&page->lru);
> > >                 __free_pages_bulk(page, zone, order);
> > > +               ckrm_clear_page_class(page);
> > >                 ret++;
> > >         }
> > >         spin_unlock_irqrestore(&zone->lock, flags);
> > 
> > When your option is on, how costly is the addition of code, here?  How
> > much does it hurt the microbenchmarks?  How much larger does it
> 
> As I said earlier cache-bench doesn't show much effect. Will post that and 
> other results sometime soon.
...

Looks like only 3k.  

> > > +       if (!in_interrupt() && !ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> > > +               return NULL;
> > 
> > ckrm_class_limit_ok() is called later on in the same hot path, and
> > there's a for loop in there over each zone.  How expensive is this on
> 
> It doesn't get into the for loop unless the class is over the limit(which
> is not a frequent event)

... if the class is behaving itself.  Somebody trying to take down a
machine, or a single badly-behaved or runaway app might not behave like
that.

> Also, the loop is just to wakeup kswapd once..
> may be I can get rid of that and use pgdat_list directly.

I'd try to be a little more selective than a big for loop like that.

> > SGI's machines?  What about an 8-node x44[05]?  Why can't you call it
> > from interrupts?
> 
> I just wanted to avoid limit related failures in interrupt context, as it
> might lead to wierd problems.

You mean you didn't want to make your code robust enough to handle it?
Is there something fundamental keeping you from checking limits when in
an interrupt?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
