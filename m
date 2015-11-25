Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 462016B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 16:01:59 -0500 (EST)
Received: by padhx2 with SMTP id hx2so67970064pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:01:59 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id v1si36535443pfa.242.2015.11.25.13.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 13:01:58 -0800 (PST)
Received: by padhx2 with SMTP id hx2so67969866pad.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:01:58 -0800 (PST)
Date: Wed, 25 Nov 2015 13:01:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request
 failures
In-Reply-To: <20151125115527.GF27283@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511251257320.24689@chino.kir.corp.google.com>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org> <1448448054-804-3-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com> <20151125115527.GF27283@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 25 Nov 2015, Michal Hocko wrote:

> > > @@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> > >  	if (zonelist_rescan)
> > >  		goto zonelist_scan;
> > >  
> > > +	/* WARN only once unless min_free_kbytes is updated */
> > > +	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
> > > +		warn_alloc_no_wmarks = 0;
> > > +		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
> > > +			" You might consider increasing min_free_kbytes\n",
> > > +			order, gfp_mask);
> > > +	}
> > >  	return NULL;
> > >  }
> > >  
> > 
> > Doesn't this warn for high-order allocations prior to the first call to 
> > direct compaction whereas min_free_kbytes may be irrelevant?
> 
> Hmm, you are concerned about high order ALLOC_NO_WATERMARKS allocation
> which happen prior to compaction, right? I am wondering whether there
> are reasonable chances that a compaction would make a difference if we
> are so depleted that there is no single page with >= order.
> ALLOC_NO_WATERMARKS with high order allocations should be rare if
> existing at all.
> 

No, I'm concerned about get_page_from_freelist() failing for an order-9 
allocation due to _fragmentation_ and then emitting this warning although 
free watermarks may be gigabytes of memory higher than min watermarks.

> > Providing 
> > the order is good, but there's no indication when min_free_kbytes may be 
> > helpful from this warning. 
> 
> I am not sure I understand what you mean here.
> 

You show the order of the failed allocation in your new warning.  Good.  
It won't help to raise min_free_kbytes to infinity if the high-order 
allocation failed due to fragmentation.  Does that make sense?

> > WARN() isn't even going to show the state of memory.
> 
> I was considering to do that but it would make the code unnecessarily
> more complex. If the allocation is allowed to fail it would dump the
> allocation failure. The purpose of the message is to tell us that
> reserves are not sufficient. I am not sure seeing the memory state dump
> would help us much more.
> 

If the purpsoe of the message is to tell us when reserves are 
insufficient, it doesn't achieve that purpose if allocations fail due to 
fragmentation or lowmem_reserve_ratio.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
