Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id ADED26B03A2
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:12:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 7so13976746qtp.8
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 00:12:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w51si1128345qtb.292.2017.03.30.00.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 00:12:33 -0700 (PDT)
Date: Thu, 30 Mar 2017 09:12:23 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170330091223.05aa0efe@redhat.com>
In-Reply-To: <20170330064958.uxih6ik5fkwvjqf6@hirez.programming.kicks-ass.net>
References: <20170327143947.4c237e54@redhat.com>
	<20170327141518.GB27285@bombadil.infradead.org>
	<20170327171500.4beef762@redhat.com>
	<20170327165817.GA28494@bombadil.infradead.org>
	<20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
	<20170329105928.609bc581@redhat.com>
	<20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
	<20170329181226.GA8256@bombadil.infradead.org>
	<20170329211144.3e362ac9@redhat.com>
	<20170329214441.08332799@redhat.com>
	<20170330064958.uxih6ik5fkwvjqf6@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org, brouer@redhat.com

On Thu, 30 Mar 2017 08:49:58 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> > @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
> >  	unsigned long pfn = page_to_pfn(page);
> >  	int migratetype;
> >  
> > -	if (in_interrupt()) {
> > +	/*
> > +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> > +	 * But allow softirq context, via disabling BH.
> > +	 */
> > +	if (in_irq() || irqs_disabled()) {  
> 
> Why do you need irqs_disabled() ? 

Because further down I call local_bh_enable(), which calls
__local_bh_enable_ip() which triggers a warning during early boot on:

  WARN_ON_ONCE(in_irq() || irqs_disabled());

It looks like it is for supporting CONFIG_TRACE_IRQFLAGS.


> Also, your comment is stale, it still refers to NMI context.

True, as you told me NMI is implicit, as it cannot occur.

> >  		__free_pages_ok(page, 0);
> >  		return;
> >  	}  

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
