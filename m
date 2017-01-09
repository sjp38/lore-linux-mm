Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A143A6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 04:48:04 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id r126so321410wmr.2
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 01:48:04 -0800 (PST)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id a63si7825513wrc.293.2017.01.09.01.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 01:48:03 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id AC43B1C104C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:48:02 +0000 (GMT)
Date: Mon, 9 Jan 2017 09:48:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170109094801.bkif6komfepc3rcx@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
 <20170104111049.15501-4-mgorman@techsingularity.net>
 <00ee01d267cc$b61feaa0$225fbfe0$@alibaba-inc.com>
 <20170106101530.zq7mpvu4uw2dppal@techsingularity.net>
 <019901d26a26$7def6c30$79ce4490$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <019901d26a26$7def6c30$79ce4490$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux Kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Mon, Jan 09, 2017 at 11:14:29AM +0800, Hillf Danton wrote:
> > Sent: Friday, January 06, 2017 6:16 PM Mel Gorman wrote: 
> > 
> > On Fri, Jan 06, 2017 at 11:26:46AM +0800, Hillf Danton wrote:
> > >
> > > On Wednesday, January 04, 2017 7:11 PM Mel Gorman wrote:
> > > > @@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> > > >  	struct list_head *list;
> > > >  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
> > > >  	struct page *page;
> > > > -	unsigned long flags;
> > > >
> > > > -	local_irq_save(flags);
> > > > +	preempt_disable();
> > > >  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > > >  	list = &pcp->lists[migratetype];
> > > >  	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
> > > > @@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> > > >  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> > > >  		zone_statistics(preferred_zone, zone, gfp_flags);
> > > >  	}
> > > > -	local_irq_restore(flags);
> > > > +	preempt_enable();
> > > >  	return page;
> > > >  }
> > > >
> > > With PREEMPT configured, preempt_enable() adds entry point to schedule().
> > > Is that needed when we try to allocate a page?
> > >
> > 
> > Not necessarily but what are you proposing as an alternative? 
> 
> preempt_enable_no_resched() looks at first glance a choice for us to 
> avoid flipping interrupts.
> 

Ok, I wasn't sure if you were proposing something more drastic. I can
make it this although I have no reason to believe it will really matter.
The path should be short enough that it's unlikely a scheduler event
would ever occur at that point. Still, no harm in doing what you
suggest.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
