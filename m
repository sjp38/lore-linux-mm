Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j35HUxWf009558
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:30:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j35HUtkS088288
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 13:30:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j35HUtFU004998
	for <linux-mm@kvack.org>; Tue, 5 Apr 2005 12:30:55 -0500
Date: Tue, 5 Apr 2005 10:25:19 -0700
From: Chandra Seetharaman <sekharan@us.ibm.com>
Subject: Re: [PATCH 1/6] CKRM: Basic changes to the core kernel
Message-ID: <20050405172519.GC32645@chandralinux.beaverton.ibm.com>
References: <20050402031206.GB23284@chandralinux.beaverton.ibm.com> <1112622313.7189.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112622313.7189.50.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 04, 2005 at 06:45:13AM -0700, Dave Hansen wrote:
> >  static inline void
> >  add_page_to_active_list(struct zone *zone, struct page *page)
> >  {
> >         list_add(&page->lru, &zone->active_list);
> >         zone->nr_active++;
> > +       ckrm_mem_inc_active(page);
> >  }
> 
> Are any of the current zone statistics used any more when this is
> compiled in?

They are being used. The reason I left them is that if you want those 
statictics with just ckrm info, we need to go thru all the defined classes,
which might be costly, depend on the number of classes.
> 
> Also, why does everything have to say ckrm_* on it?  What if somebody
> else comes along and wants to use the same functions to do some other
> kind of accounting? 
> 
> I think names like this are plenty long and descriptive enough:
> 
>         mem_inc_active(page);
>         clear_page_class(page);
>         set_page_class(...);
>         
> I'd drop the "ckrm_".

Because we got some review comments to keep it that way :).... Currently
they do ckrm specific things. In future if that changes, we can change the
name too.

>         
> > +#define PG_ckrm_account                21      /* CKRM accounting */
> 
> Are you sure you really need this bit *and* a whole new pointer in
> 'struct page'?  We already do some tricks with ->mapping so that we can
> tell what is stored in it.  You could easily do something with the low
> bit of your new structure member.

I think I canavoid using  the bit. The problem with having a pointer in page
data structure is two-fold:
	1. goes over the page-cahe (I ran cache-bench with mem controller
	      enabled, and didn't see much of a difference. will post the
	      new results sometime soon)
	2. additional memory used, especially in large systems

Using the mapping logic, we can avoid problem (1), but increase problem (2)
with added complexity and run-time logic. I am looking a way to avoid both
the problems, any help appreciated.

> 
> > @@ -355,6 +356,7 @@ free_pages_bulk(struct zone *zone, int c
> >                 /* have to delete it as __free_pages_bulk list manipulates */
> >                 list_del(&page->lru);
> >                 __free_pages_bulk(page, zone, order);
> > +               ckrm_clear_page_class(page);
> >                 ret++;
> >         }
> >         spin_unlock_irqrestore(&zone->lock, flags);
> 
> When your option is on, how costly is the addition of code, here?  How
> much does it hurt the microbenchmarks?  How much larger does it

As I said earlier cache-bench doesn't show much effect. Will post that and 
other results sometime soon.
> make .text?
------------------ 2612-rc1.... no memory controller patch applied
vmlinux-nomem:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         002455d5  c0100000  c0100000  00001000  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
------------------ 2612-rc1.... mem ctlr patch applied, config turned off
vmlinux-mem_out:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00245575  c0100000  c0100000  00001000  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
------------------ 2612-rc1.... mem ctlr patch applied, config turned on
vmlinux-mem_in:     file format elf32-i386

Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00248195  c0100000  c0100000  00001000  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
------------------

> 
> > +       if (!in_interrupt() && !ckrm_class_limit_ok(ckrm_get_mem_class(p)))
> > +               return NULL;
> 
> ckrm_class_limit_ok() is called later on in the same hot path, and
> there's a for loop in there over each zone.  How expensive is this on

It doesn't get into the for loop unless the class is over the limit(which
is not a frequent event). Also, the loop is just to wakeup kswapd once..
may be I can get rid of that and use pgdat_list directly.

> SGI's machines?  What about an 8-node x44[05]?  Why can't you call it
> from interrupts?

I just wanted to avoid limit related failures in interrupt context, as it
might lead to wierd problems.
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
