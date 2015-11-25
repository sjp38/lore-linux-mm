Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B20876B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:55:29 -0500 (EST)
Received: by wmuu63 with SMTP id u63so134698793wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:55:29 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id l141si5283621wmd.68.2015.11.25.03.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 03:55:28 -0800 (PST)
Received: by wmww144 with SMTP id w144so66011145wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:55:28 -0800 (PST)
Date: Wed, 25 Nov 2015 12:55:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: warn about ALLOC_NO_WATERMARKS request failures
Message-ID: <20151125115527.GF27283@dhcp22.suse.cz>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
 <1448448054-804-3-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511250251490.32374@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-11-15 02:59:19, David Rientjes wrote:
> On Wed, 25 Nov 2015, Michal Hocko wrote:
[...]
> > @@ -2642,6 +2644,13 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >  	if (zonelist_rescan)
> >  		goto zonelist_scan;
> >  
> > +	/* WARN only once unless min_free_kbytes is updated */
> > +	if (warn_alloc_no_wmarks && (alloc_flags & ALLOC_NO_WATERMARKS)) {
> > +		warn_alloc_no_wmarks = 0;
> > +		WARN(1, "Memory reserves are depleted for order:%d, mode:0x%x."
> > +			" You might consider increasing min_free_kbytes\n",
> > +			order, gfp_mask);
> > +	}
> >  	return NULL;
> >  }
> >  
> 
> Doesn't this warn for high-order allocations prior to the first call to 
> direct compaction whereas min_free_kbytes may be irrelevant?

Hmm, you are concerned about high order ALLOC_NO_WATERMARKS allocation
which happen prior to compaction, right? I am wondering whether there
are reasonable chances that a compaction would make a difference if we
are so depleted that there is no single page with >= order.
ALLOC_NO_WATERMARKS with high order allocations should be rare if
existing at all.

> Providing 
> the order is good, but there's no indication when min_free_kbytes may be 
> helpful from this warning. 

I am not sure I understand what you mean here.

> WARN() isn't even going to show the state of memory.

I was considering to do that but it would make the code unnecessarily
more complex. If the allocation is allowed to fail it would dump the
allocation failure. The purpose of the message is to tell us that
reserves are not sufficient. I am not sure seeing the memory state dump
would help us much more.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
