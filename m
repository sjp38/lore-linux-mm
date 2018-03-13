Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB2BD6B0031
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 12:05:13 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id w9so69216uaa.17
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:05:13 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f4si184766uam.44.2018.03.13.09.05.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 09:05:12 -0700 (PDT)
Date: Tue, 13 Mar 2018 12:04:30 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [v5 1/2] mm: disable interrupts while initializing deferred pages
Message-ID: <20180313160430.hbjnyiazadt3jwa6@xakep.localdomain>
References: <20180309220807.24961-1-pasha.tatashin@oracle.com>
 <20180309220807.24961-2-pasha.tatashin@oracle.com>
 <20180312130410.e2fce8e5e38bc2086c7fd924@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180312130410.e2fce8e5e38bc2086c7fd924@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, m.mizuma@jp.fujitsu.com, mhocko@suse.com, catalin.marinas@arm.com, takahiro.akashi@linaro.org, gi-oh.kim@profitbricks.com, heiko.carstens@de.ibm.com, baiyaowei@cmss.chinamobile.com, richard.weiyang@gmail.com, paul.burton@mips.com, miles.chen@mediatek.com, vbabka@suse.cz, mgorman@suse.de, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Andrew,

> > +/* Disable interrupts and save previous IRQ state in flags before locking */
> > +static inline
> > +void pgdat_resize_lock_irq(struct pglist_data *pgdat, unsigned long *flags)
> > +{
> > +	unsigned long tmp_flags;
> > +
> > +	local_irq_save(*flags);
> > +	local_irq_disable();
> > +	pgdat_resize_lock(pgdat, &tmp_flags);
> > +}
> 
> As far as I can tell, this ugly-looking thing is identical to
> pgdat_resize_lock().

I will get rid of it, and use pgdat_resize_lock(). My confusion was that I
thought that local_irq_save() only saves the IRQ flags does not disable
them.

> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1506,7 +1506,6 @@ static void __init deferred_free_pages(int nid, int zid, unsigned long pfn,
> >  		} else if (!(pfn & nr_pgmask)) {
> >  			deferred_free_range(pfn - nr_free, nr_free);
> >  			nr_free = 1;
> > -			cond_resched();
> >  		} else {
> >  			nr_free++;
> 
> And how can we simply remove these cond_resched()s?  I assume this is
> being done because interrupts are now disabled?  But those were there
> for a reason, weren't they?

We must remove cond_resched() because we can't sleep anymore. They were
added to fight NMI timeouts, so I will replace them with
touch_nmi_watchdog() in a follow-up fix.

Thank you for your review,
Pavel
