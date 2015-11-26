Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EFCBA6B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 04:52:07 -0500 (EST)
Received: by wmuu63 with SMTP id u63so14239754wmu.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 01:52:07 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id j10si10581420wjr.153.2015.11.26.01.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 01:52:06 -0800 (PST)
Received: by wmvv187 with SMTP id v187so23011188wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 01:52:06 -0800 (PST)
Date: Thu, 26 Nov 2015 10:52:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request failures
Message-ID: <20151126095205.GB7953@dhcp22.suse.cz>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
 <1448448054-804-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com>
 <20151125115527.GF27283@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511251257320.24689@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511251257320.24689@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-11-15 13:01:56, David Rientjes wrote:
> On Wed, 25 Nov 2015, Michal Hocko wrote:
> 
> > > > @@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> > > >  	if (zonelist_rescan)
> > > >  		goto zonelist_scan;
> > > >  
> > > > +	/* WARN only once unless min_free_kbytes is updated */
> > > > +	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
> > > > +		warn_alloc_no_wmarks = 0;
> > > > +		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
> > > > +			" You might consider increasing min_free_kbytes\n",
> > > > +			order, gfp_mask);
> > > > +	}
> > > >  	return NULL;
> > > >  }
> > > >  
> > > 
> > > Doesn't this warn for high-order allocations prior to the first call to 
> > > direct compaction whereas min_free_kbytes may be irrelevant?
> > 
> > Hmm, you are concerned about high order ALLOC_NO_WATERMARKS allocation
> > which happen prior to compaction, right? I am wondering whether there
> > are reasonable chances that a compaction would make a difference if we
> > are so depleted that there is no single page with >= order.
> > ALLOC_NO_WATERMARKS with high order allocations should be rare if
> > existing at all.
> > 
> 
> No, I'm concerned about get_page_from_freelist() failing for an order-9 
> allocation due to _fragmentation_ and then emitting this warning although 
> free watermarks may be gigabytes of memory higher than min watermarks.

Hmm, should we allow ALLOC_NO_WATERMARKS for order-9 (or >
PAGE_ALLOC_COSTLY_ORDER for that matter) allocations though?  What would
be the point if they are allowed to fail and so they cannot be relied on
inherently?
I can see that we might do that currently - e.g. TIF_MEMDIE might be
set while doing hugetlb page allocation but I seriously doubt that this is
intentional and probably worth fixing.

> > > Providing 
> > > the order is good, but there's no indication when min_free_kbytes may be 
> > > helpful from this warning. 
> > 
> > I am not sure I understand what you mean here.
> > 
> 
> You show the order of the failed allocation in your new warning.  Good.  
> It won't help to raise min_free_kbytes to infinity if the high-order 
> allocation failed due to fragmentation.  Does that make sense?

Sure this makes sense but as I've tried to argue the warning is just a
hint. It should warn that something unexpected is happening and offer
a workaround. And yes increasing min_free_kbytes helps to keep more
high order pages availble from my experience.
If the workaround doesn't help I suspect the bug report would come more
promptly. Your example about order-9 ALLOC_NO_WATERMARKS failure is more
than exaggarated IMHO.

> > > WARN() isn't even going to show the state of memory.
> > 
> > I was considering to do that but it would make the code unnecessarily
> > more complex. If the allocation is allowed to fail it would dump the
> > allocation failure. The purpose of the message is to tell us that
> > reserves are not sufficient. I am not sure seeing the memory state dump
> > would help us much more.
> > 
> 
> If the purpsoe of the message is to tell us when reserves are 
> insufficient, it doesn't achieve that purpose if allocations fail due to 
> fragmentation or lowmem_reserve_ratio.

Do you have any better suggestion or you just think that warning about
depleted reserves doesn't make any sense at all?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
