Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFDD6B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 14:12:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id a72so14453166pge.10
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:12:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s3si8081338pgn.344.2017.03.29.11.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 11:12:33 -0700 (PDT)
Date: Wed, 29 Mar 2017 11:12:26 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: in_irq_or_nmi()
Message-ID: <20170329181226.GA8256@bombadil.infradead.org>
References: <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
 <20170327143947.4c237e54@redhat.com>
 <20170327141518.GB27285@bombadil.infradead.org>
 <20170327171500.4beef762@redhat.com>
 <20170327165817.GA28494@bombadil.infradead.org>
 <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
 <20170329105928.609bc581@redhat.com>
 <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org

On Wed, Mar 29, 2017 at 11:19:49AM +0200, Peter Zijlstra wrote:
> On Wed, Mar 29, 2017 at 10:59:28AM +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 29 Mar 2017 10:12:19 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > > No, that's horrible. Also, wth is this about? A memory allocator that
> > > needs in_nmi()? That sounds beyond broken.
> > 
> > It is the other way around. We want to exclude NMI and HARDIRQ from
> > using the per-cpu-pages (pcp) lists "order-0 cache" (they will
> > fall-through using the normal buddy allocator path).
> 
> Any in_nmi() code arriving at the allocator is broken. No need to fix
> the allocator.

That's demonstrably true.  You can't grab a spinlock in NMI code and
the first thing that happens if this in_irq_or_nmi() check fails is ...
        spin_lock_irqsave(&zone->lock, flags);
so this patch should just use in_irq().

(the concept of NMI code needing to allocate memory was blowing my mind
a little bit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
