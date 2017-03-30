Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 624316B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 05:47:01 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id b9so15191222qtg.4
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 02:47:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u57si1399218qtb.149.2017.03.30.02.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 02:47:00 -0700 (PDT)
Date: Thu, 30 Mar 2017 11:46:50 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170330114650.297573a4@redhat.com>
In-Reply-To: <20170330073502.4wl66zyz7e4z4aes@hirez.programming.kicks-ass.net>
References: <20170327171500.4beef762@redhat.com>
	<20170327165817.GA28494@bombadil.infradead.org>
	<20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
	<20170329105928.609bc581@redhat.com>
	<20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
	<20170329181226.GA8256@bombadil.infradead.org>
	<20170329211144.3e362ac9@redhat.com>
	<20170329214441.08332799@redhat.com>
	<20170330064958.uxih6ik5fkwvjqf6@hirez.programming.kicks-ass.net>
	<20170330091223.05aa0efe@redhat.com>
	<20170330073502.4wl66zyz7e4z4aes@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, brouer@redhat.com

On Thu, 30 Mar 2017 09:35:02 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Mar 30, 2017 at 09:12:23AM +0200, Jesper Dangaard Brouer wrote:
> > On Thu, 30 Mar 2017 08:49:58 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> >   
> > > On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:  
> > > > @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
> > > >  	unsigned long pfn = page_to_pfn(page);
> > > >  	int migratetype;
> > > >  
> > > > -	if (in_interrupt()) {
> > > > +	/*
> > > > +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> > > > +	 * But allow softirq context, via disabling BH.
> > > > +	 */
> > > > +	if (in_irq() || irqs_disabled()) {    
> > > 
> > > Why do you need irqs_disabled() ?   
> > 
> > Because further down I call local_bh_enable(), which calls
> > __local_bh_enable_ip() which triggers a warning during early boot on:
> > 
> >   WARN_ON_ONCE(in_irq() || irqs_disabled());
> > 
> > It looks like it is for supporting CONFIG_TRACE_IRQFLAGS.  
> 
> Ah, no. Its because when you do things like:
> 
> 	local_irq_disable();
> 	local_bh_enable();
> 	local_irq_enable();
> 
> you can loose a pending softirq.
> 
> Bugger.. that irqs_disabled() is something we could do without.

Yes, I really don't like adding this irqs_disabled() check here.

> I'm thinking that when tglx finishes his soft irq disable patches for
> x86 (same thing ppc also does) we can go revert all these patches.
> 
> Thomas, see:
> 
>   https://lkml.kernel.org/r/20170301144845.783f8cad@redhat.com

The summary is Mel and I found a way to optimized the page allocator,
by avoiding a local_irq_{save,restore} operation, see commit
374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe
requests")  [1] https://git.kernel.org/davem/net-next/c/374ad05ab64d696

But Tariq discovered that this caused a regression for 100Gbit/s NICs,
as the patch excluded softirq from using the per-cpu-page (PCP) lists.
As DMA RX page-refill happens in softirq context.

Now we are trying to re-enable allowing softirq to use the PCP.
My proposal is: https://lkml.kernel.org/r/20170329214441.08332799@redhat.com
The alternative is to revert this optimization.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
