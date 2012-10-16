Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C0B2F6B0073
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 20:45:26 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so6135440pbb.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 17:45:25 -0700 (PDT)
Date: Mon, 15 Oct 2012 17:45:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Q] Default SLAB allocator
In-Reply-To: <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1210151743130.31712@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com> <m27gqwtyu9.fsf@firstfloor.org> <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com> <m2391ktxjj.fsf@firstfloor.org>
 <alpine.DEB.2.00.1210130249070.7462@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

On Sat, 13 Oct 2012, David Rientjes wrote:

> This was in August when preparing for LinuxCon, I tested netperf TCP_RR on 
> two 64GB machines (one client, one server), four nodes each, with thread 
> counts in multiples of the number of cores.  SLUB does a comparable job, 
> but once we have the the number of threads equal to three times the number 
> of cores, it degrades almost linearly.  I'll run it again next week and 
> get some numbers on 3.6.
> 

On 3.6, I tested CONFIG_SLAB (no CONFIG_DEBUG_SLAB) vs.
CONFIG_SLUB and CONFIG_SLUB_DEBUG (no CONFIG_SLUB_DEBUG_ON or 
CONFIG_SLUB_STATS), which are the defconfigs for both allocators.

Using netperf-2.4.5 and two machines both with 16 cores (4 cores/node) and 
32GB of memory each (one client, one netserver), here are the results:

	threads		SLAB		SLUB
	 16		115408		114477 (-0.8%)
	 32		214664		209582 (-2.4%)
	 48		297414		290552 (-2.3%)
	 64		372207		360177 (-3.2%)
	 80		435872		421674 (-3.3%)
	 96		490927		472547 (-3.7%)
	112		543685		522593 (-3.9%)
	128		586026		564078 (-3.7%)
	144		630320		604681 (-4.1%)
	160		671953		639643 (-4.8%)

It seems that slub has improved because of the per-cpu partial lists, 
which truly makes the "unqueued" allocator queued, by significantly 
increasing the amount of memory that the allocator uses.  However, the 
netperf benchmark still regresses significantly and is still a non-
starter for us.

This type of workload that really exhibits the problem with remote freeing 
would suggest that the design of slub itself is the problem here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
