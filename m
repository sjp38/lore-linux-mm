Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DABC86B0390
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 02:50:03 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 19so1658321itj.1
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 23:50:03 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id i124si9369257itf.65.2017.03.29.23.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 23:50:03 -0700 (PDT)
Date: Thu, 30 Mar 2017 08:49:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: in_irq_or_nmi() and RFC patch
Message-ID: <20170330064958.uxih6ik5fkwvjqf6@hirez.programming.kicks-ass.net>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329214441.08332799@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org

On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> -	if (in_interrupt()) {
> +	/*
> +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> +	 * But allow softirq context, via disabling BH.
> +	 */
> +	if (in_irq() || irqs_disabled()) {

Why do you need irqs_disabled() ? Also, your comment is stale, it still
refers to NMI context.

>  		__free_pages_ok(page, 0);
>  		return;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
