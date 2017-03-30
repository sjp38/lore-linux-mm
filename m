Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0B76B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:35:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e129so10396788ioe.8
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:35:07 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id c66si1877775ita.92.2017.03.30.00.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 00:35:06 -0700 (PDT)
Date: Thu, 30 Mar 2017 09:35:02 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170330073502.4wl66zyz7e4z4aes@hirez.programming.kicks-ass.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170330091223.05aa0efe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

On Thu, Mar 30, 2017 at 09:12:23AM +0200, Jesper Dangaard Brouer wrote:
> On Thu, 30 Mar 2017 08:49:58 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> > > @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
> > >  	unsigned long pfn = page_to_pfn(page);
> > >  	int migratetype;
> > >  
> > > -	if (in_interrupt()) {
> > > +	/*
> > > +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> > > +	 * But allow softirq context, via disabling BH.
> > > +	 */
> > > +	if (in_irq() || irqs_disabled()) {  
> > 
> > Why do you need irqs_disabled() ? 
> 
> Because further down I call local_bh_enable(), which calls
> __local_bh_enable_ip() which triggers a warning during early boot on:
> 
>   WARN_ON_ONCE(in_irq() || irqs_disabled());
> 
> It looks like it is for supporting CONFIG_TRACE_IRQFLAGS.

Ah, no. Its because when you do things like:

	local_irq_disable();
	local_bh_enable();
	local_irq_enable();

you can loose a pending softirq.

Bugger.. that irqs_disabled() is something we could do without.

I'm thinking that when tglx finishes his soft irq disable patches for
x86 (same thing ppc also does) we can go revert all these patches.

Thomas, see:

  https://lkml.kernel.org/r/20170301144845.783f8cad@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
