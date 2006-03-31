Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k2VNMAnx027815
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 17:22:10 -0600
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k2VNe67p22259556
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 15:40:06 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k2VNMAnB30232486
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 15:22:10 -0800 (PST)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1FPSwU-0002Hm-00
	for <linux-mm@kvack.org>; Fri, 31 Mar 2006 15:22:10 -0800
Date: Fri, 31 Mar 2006 15:17:10 -0800 (PST)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
In-Reply-To: <20060331150120.21fad488.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
 <20060331150120.21fad488.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0603311522040.8789@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: nickpiggin@yahoo.com.au, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 31 Mar 2006, Andrew Morton wrote:

> Christoph Lameter <clameter@sgi.com> wrote:
> >
> > We experienced that concurrent slab shrinking on 2.6.16 can slow down a
> >  system excessively due to lock contention.
> 
> How much?

System sluggish in general. cscope takes 20 minutes to start etc. Dropping 
the caches restored performance.

> Which lock(s)?

Seems to be mainly iprune_sem. So its inode reclaim.
 
> > Slab shrinking is a global
> >  operation so it does not make sense for multiple slab shrink operations
> >  to be ongoing at the same time.
> 
> That's how it used to be - it was a semaphore and we baled out if
> down_trylock() failed.  If we're going to revert that change then I'd
> prefer to just go back to doing it that way (only with a mutex).

No problem with that. Seems that the behavior <2.6.9 was okay. This showed 
up during beta testing of a new major distribution release.
 
> The reason we made that change in 2.6.9:
> 
>   Use an rwsem to protect the shrinker list instead of a regular
>   semaphore.  Modifications to the list are now done under the write lock,
>   shrink_slab takes the read lock, and access to shrinker->nr becomes racy
>   (which is no concurrent.
> 
>   Previously, having the slab scanner get preempted or scheduling while
>   holding the semaphore would cause other tasks to skip putting pressure on
>   the slab.
> 
>   Also, make shrink_icache_memory return -1 if it can't do anything in
>   order to hold pressure on this cache and prevent useless looping in
>   shrink_slab.

Shrink_icache_memory() never returns -1.

> Note the lack of performance numbers?  How are we to judge which the
> regression which your proposal introduces is outweighed by the (unmeasured)
> gain it provides?

We just noticed general sluggishness and took some stackdumps to see what 
the system was up to. Do we have a benchmark for slab shrinking?

> We need a *lot* of testing results with varied workloads and varying
> machine types before we can say that changes like this are of aggregate
> benefit and do not introduce bad corner-case regressions.

The slowdown of the system running concurrent slab reclaim is pretty 
severe. Machine is basically unusable until you manually trigger the 
dropping of the caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
