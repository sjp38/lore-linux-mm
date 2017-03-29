Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30F126B03A0
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:12:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s29so3568992pfg.21
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:12:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c7si6663717pgn.352.2017.03.29.01.12.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 01:12:24 -0700 (PDT)
Date: Wed, 29 Mar 2017 10:12:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: in_irq_or_nmi()
Message-ID: <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
References: <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
 <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
 <20170327143947.4c237e54@redhat.com>
 <20170327141518.GB27285@bombadil.infradead.org>
 <20170327171500.4beef762@redhat.com>
 <20170327165817.GA28494@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170327165817.GA28494@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org

On Mon, Mar 27, 2017 at 09:58:17AM -0700, Matthew Wilcox wrote:
> On Mon, Mar 27, 2017 at 05:15:00PM +0200, Jesper Dangaard Brouer wrote:
> > And I also verified it worked:
> > 
> >   0.63 a??       mov    __preempt_count,%eax
> >        a??     free_hot_cold_page():
> >   1.25 a??       test   $0x1f0000,%eax
> >        a??     a?? jne    1e4
> > 
> > And this simplification also made the compiler change this into a
> > unlikely branch, which is a micro-optimization (that I will leave up to
> > the compiler).
> 
> Excellent!  That said, I think we should define in_irq_or_nmi() in
> preempt.h, rather than hiding it in the memory allocator.  And since we're
> doing that, we might as well make it look like the other definitions:
> 
> diff --git a/include/linux/preempt.h b/include/linux/preempt.h
> index 7eeceac52dea..af98c29abd9d 100644
> --- a/include/linux/preempt.h
> +++ b/include/linux/preempt.h
> @@ -81,6 +81,7 @@
>  #define in_interrupt()		(irq_count())
>  #define in_serving_softirq()	(softirq_count() & SOFTIRQ_OFFSET)
>  #define in_nmi()		(preempt_count() & NMI_MASK)
> +#define in_irq_or_nmi()		(preempt_count() & (HARDIRQ_MASK | NMI_MASK))
>  #define in_task()		(!(preempt_count() & \
>  				   (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
>  

No, that's horrible. Also, wth is this about? A memory allocator that
needs in_nmi()? That sounds beyond broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
