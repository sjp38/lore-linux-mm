Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 09CED6B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 05:15:33 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so2683059wmi.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 02:15:32 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 7si2234986wmu.55.2017.01.06.02.15.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 02:15:31 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 50FD2995BF
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 10:15:31 +0000 (UTC)
Date: Fri, 6 Jan 2017 10:15:30 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170106101530.zq7mpvu4uw2dppal@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
 <20170104111049.15501-4-mgorman@techsingularity.net>
 <00ee01d267cc$b61feaa0$225fbfe0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00ee01d267cc$b61feaa0$225fbfe0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Fri, Jan 06, 2017 at 11:26:46AM +0800, Hillf Danton wrote:
> 
> On Wednesday, January 04, 2017 7:11 PM Mel Gorman wrote: 
> > @@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> >  	struct list_head *list;
> >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> >  	struct page *page;
> > -	unsigned long flags;
> > 
> > -	local_irq_save(flags);
> > +	preempt_disable();
> >  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> >  	list = &pcp->lists[migratetype];
> >  	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
> > @@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> >  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> >  		zone_statistics(preferred_zone, zone, gfp_flags);
> >  	}
> > -	local_irq_restore(flags);
> > +	preempt_enable();
> >  	return page;
> >  }
> > 
> With PREEMPT configured, preempt_enable() adds entry point to schedule().
> Is that needed when we try to allocate a page?
> 

Not necessarily but what are you proposing as an alternative? get_cpu()
is not an alternative and the point is to avoid disabling interrupts
which is a much more expensive operation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
