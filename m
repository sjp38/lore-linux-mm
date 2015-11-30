Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 624F36B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:24:33 -0500 (EST)
Received: by padhx2 with SMTP id hx2so198209431pad.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:24:33 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id r14si5142415pfi.209.2015.11.30.14.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:24:32 -0800 (PST)
Received: by padhx2 with SMTP id hx2so198209248pad.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:24:32 -0800 (PST)
Date: Mon, 30 Nov 2015 14:24:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request
 failures
In-Reply-To: <20151126095205.GB7953@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511301418040.10460@chino.kir.corp.google.com>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org> <1448448054-804-3-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com> <20151125115527.GF27283@dhcp22.suse.cz> <alpine.DEB.2.10.1511251257320.24689@chino.kir.corp.google.com>
 <20151126095205.GB7953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 26 Nov 2015, Michal Hocko wrote:

> > > > > @@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> > > > >  	if (zonelist_rescan)
> > > > >  		goto zonelist_scan;
> > > > >  
> > > > > +	/* WARN only once unless min_free_kbytes is updated */
> > > > > +	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
> > > > > +		warn_alloc_no_wmarks = 0;
> > > > > +		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
> > > > > +			" You might consider increasing min_free_kbytes\n",
> > > > > +			order, gfp_mask);
> > > > > +	}
> > > > >  	return NULL;
> > > > >  }
> > > > >  
> > > > 
> > > > Doesn't this warn for high-order allocations prior to the first call to 
> > > > direct compaction whereas min_free_kbytes may be irrelevant?
> > > 
> > > Hmm, you are concerned about high order ALLOC_NO_WATERMARKS allocation
> > > which happen prior to compaction, right? I am wondering whether there
> > > are reasonable chances that a compaction would make a difference if we
> > > are so depleted that there is no single page with >= order.
> > > ALLOC_NO_WATERMARKS with high order allocations should be rare if
> > > existing at all.
> > > 
> > 
> > No, I'm concerned about get_page_from_freelist() failing for an order-9 
> > allocation due to _fragmentation_ and then emitting this warning although 
> > free watermarks may be gigabytes of memory higher than min watermarks.
> 
> Hmm, should we allow ALLOC_NO_WATERMARKS for order-9 (or >
> PAGE_ALLOC_COSTLY_ORDER for that matter) allocations though?  What would
> be the point if they are allowed to fail and so they cannot be relied on
> inherently?

This patch isn't addressing what orders the page allocator allows access 
to memory reserves for, I'm not sure this has anything to do with the 
warning you propose to add.

My concern is that this will start doing

	Memory reserves are depleted for order:9. You might consider increasing min_free_kbytes

in the kernel log with a long stack trace that is going to grab attention 
and then some user will actually follow the advice and see that the 
warning persists because the failure was due to fragmentation rather than 
watermarks.  It would be much better if the warning were only emitted when 
the _watermark_, not fragmentation, was the source of the failure.  That 
is very easy to do, by calling __zone_watermark_ok() for order 0.

I would also suggest that this is done in the same way that GFP_ATOMIC 
allocations fail that have depleted ALLOC_HARD and ALLOC_HARDER memory 
reserves, with something resembling a page allocation failure warning that 
actually presents useful data.  Your patch is already insufficient because 
it doesn't handle __GFP_NOWARN.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
