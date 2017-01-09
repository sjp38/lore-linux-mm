Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 550346B0038
	for <linux-mm@kvack.org>; Sun,  8 Jan 2017 22:14:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so96314220pfx.1
        for <linux-mm@kvack.org>; Sun, 08 Jan 2017 19:14:47 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 17si55378284pfq.99.2017.01.08.19.14.44
        for <linux-mm@kvack.org>;
        Sun, 08 Jan 2017 19:14:46 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170104111049.15501-1-mgorman@techsingularity.net> <20170104111049.15501-4-mgorman@techsingularity.net> <00ee01d267cc$b61feaa0$225fbfe0$@alibaba-inc.com> <20170106101530.zq7mpvu4uw2dppal@techsingularity.net>
In-Reply-To: <20170106101530.zq7mpvu4uw2dppal@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for irq-safe requests
Date: Mon, 09 Jan 2017 11:14:29 +0800
Message-ID: <019901d26a26$7def6c30$79ce4490$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@techsingularity.net>
Cc: 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

> Sent: Friday, January 06, 2017 6:16 PM Mel Gorman wrote: 
> 
> On Fri, Jan 06, 2017 at 11:26:46AM +0800, Hillf Danton wrote:
> >
> > On Wednesday, January 04, 2017 7:11 PM Mel Gorman wrote:
> > > @@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> > >  	struct list_head *list;
> > >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> > >  	struct page *page;
> > > -	unsigned long flags;
> > >
> > > -	local_irq_save(flags);
> > > +	preempt_disable();
> > >  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > >  	list = &pcp->lists[migratetype];
> > >  	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
> > > @@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> > >  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> > >  		zone_statistics(preferred_zone, zone, gfp_flags);
> > >  	}
> > > -	local_irq_restore(flags);
> > > +	preempt_enable();
> > >  	return page;
> > >  }
> > >
> > With PREEMPT configured, preempt_enable() adds entry point to schedule().
> > Is that needed when we try to allocate a page?
> >
> 
> Not necessarily but what are you proposing as an alternative? 

preempt_enable_no_resched() looks at first glance a choice for us to 
avoid flipping interrupts.

> get_cpu()
> is not an alternative and the point is to avoid disabling interrupts
> which is a much more expensive operation.
> 
Agree with every word.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
