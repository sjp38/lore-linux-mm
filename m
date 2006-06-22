Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5MEutnx006121
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 09:56:55 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5MFCx7p36203621
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 08:12:59 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5MEusnB42603995
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 07:56:54 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FtQc2-0007IJ-00
	for <linux-mm@kvack.org>; Thu, 22 Jun 2006 07:56:54 -0700
Date: Thu, 22 Jun 2006 07:54:50 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: [PATCH 02/14] Basic ZVC (zoned vm counter) implementation
In-Reply-To: <20060622041034.84b3c997.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0606220750580.27962@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
 <20060621154430.18741.99957.sendpatchset@schroedinger.engr.sgi.com>
 <20060622041034.84b3c997.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606220756500.27962@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: mbligh@google.com, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jun 2006, Andrew Morton wrote:

> These patches were a bit of a disaster - what happened?

I am not sure what you did to them. You removed pieces that were not 
touched by this patch. Could you undo your additional patches and tell me 
what the original problem was?

> > +atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
> > +
> > +static inline void zone_page_state_add(long x, struct zone *zone,
> > +				 enum zone_stat_item item)
> > +{
> > +	atomic_long_add(x, &zone->vm_stat[item]);
> > +	atomic_long_add(x, &vm_stat[item]);
> > +}
> 
> I'd have thought it'd be worth padding vm_stat out to one-per-cacheline.

On the other hand if the whole vm_stat is in one cacheline then multiple 
references to counters can be satisfied from one cacheline.

> > +	x = delta + *p;
> > +
> > +	if (unlikely(x > STAT_THRESHOLD || x < -STAT_THRESHOLD)) {
> > +		zone_page_state_add(x, zone, item);
> > +		x = 0;
> > +	}
> > +
> > +	*p = x;
> > +}
> 
> We'd get a little more efficiency with the same accuracy by doing:
> 
> 	if (x > STAT_THRESHOLD) {
> 		zone_page_state_add(x + STAT_THRESHOLD/2, zone, item);
> 		x = -STAT_THRESHOLD/2;
> 	}
> 
> because these things aren't random - a CPU tends to do a lot of identical
> operations in sequence, then a batch of the opposite operation happens a
> relatively long time later.  Memory allocations, pagetable instantiation,
> etc.  Plus some counters only go in one direction.

0 is already in the middle of the interval. The interval is from 
-STAT_THRESHOLD to +STAT_THRESHOLD not from 0 to STAT_THRESHOLD.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
