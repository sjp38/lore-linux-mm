Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id EF1D86B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 18:53:37 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id um15so5544703pbc.38
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 15:53:37 -0700 (PDT)
Date: Wed, 19 Jun 2013 15:53:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
In-Reply-To: <51C176AC.4000709@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1306191543070.15308@chino.kir.corp.google.com>
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com> <51C176AC.4000709@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Wed, 19 Jun 2013, Srivatsa S. Bhat wrote:

> > __zone_pcp_update() is called via stop_machine(), which already disables
> > local irq.
> > 
> > Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
> 
> Reviewed-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> 

What was reviewed?

> > ---
> >  mm/page_alloc.c | 4 +---
> >  1 file changed, 1 insertion(+), 3 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bac3107..b46b54a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6179,7 +6179,7 @@ static int __meminit __zone_pcp_update(void *data)
> >  {
> >  	struct zone *zone = data;
> >  	int cpu;
> > -	unsigned long batch = zone_batchsize(zone), flags;
> > +	unsigned long batch = zone_batchsize(zone);
> > 
> >  	for_each_possible_cpu(cpu) {
> >  		struct per_cpu_pageset *pset;
> > @@ -6188,12 +6188,10 @@ static int __meminit __zone_pcp_update(void *data)
> >  		pset = per_cpu_ptr(zone->pageset, cpu);
> >  		pcp = &pset->pcp;
> > 
> > -		local_irq_save(flags);
> >  		if (pcp->count > 0)
> >  			free_pcppages_bulk(zone, pcp->count, pcp);
> >  		drain_zonestat(zone, pset);
> >  		setup_pageset(pset, batch);
> > -		local_irq_restore(flags);

This seems like a fine cleanup because stop_machine() disable irqs, but it 
appears like there is two problems with this function already:

 - it's doing for_each_possible_cpu() internally, why?  local_irq_save()
   works on the local cpu and won't protect
   per_cpu_ptr(zone->pageset, cpu)->pcp of some random cpu, and

 - setup_pageset() is what is ultimately responsible for doing 
   pcp->count = 0 after free_pcppages_bulk(), but what happens if 
   pcp->count is read in between the two on the cpu that has not disabled 
   irqs?

You can't just do

	for_each_possible_cpu(cpu) {
		unsigned long flags;

		local_irq_save(flags);
		...
		local_irq_restore(flags);
	}

This is just disabling irqs locally over and over again, not on the cpu 
you're manipulating in its per-cpu critical section.

I don't think we hit this because onlining and offlining memory isn't a 
very common operation, but it doesn't change the fact that it's broken.

> >  	}
> >  	return 0;
> >  }
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
