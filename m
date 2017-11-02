Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B0866B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:02:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l18so2905564wrc.23
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:02:56 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r202si2912772wmd.7.2017.11.02.06.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 06:02:54 -0700 (PDT)
Date: Thu, 2 Nov 2017 14:02:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] mm: drop hotplug lock from lru_add_drain_all
In-Reply-To: <20171102123749.zwnlsvpoictnmp53@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1711021359250.2090@nanos>
References: <20171102093613.3616-1-mhocko@kernel.org> <20171102093613.3616-3-mhocko@kernel.org> <20171102123749.zwnlsvpoictnmp53@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 2 Nov 2017, Michal Hocko wrote:
> On Thu 02-11-17 10:36:13, Michal Hocko wrote:
> [...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 67330a438525..8c6e9c6d194c 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6830,8 +6830,12 @@ void __init free_area_init(unsigned long *zones_size)
> >  
> >  static int page_alloc_cpu_dead(unsigned int cpu)
> >  {
> > +	unsigned long flags;
> >  
> > +	local_irq_save(flags);
> >  	lru_add_drain_cpu(cpu);
> > +	local_irq_restore(flags);
> > +
> >  	drain_pages(cpu);
>   
> I was staring into the hotplug code and tried to understand the context
> this callback runs in and AFAIU IRQ disabling is not needed at all
> because cpuhp_thread_fun runs with IRQ disabled when offlining an online
> cpu. I have a bit hard time to follow the code due to all the
> indirection so please correct me if I am wrong.

No. That function does neither run from the cpu hotplug thread of the
outgoing CPU nor its called with interrupts disabled.

The callback is in the DEAD section, i.e. its called on the controlling CPU
_after_ the hotplugged CPU vanished completely.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
