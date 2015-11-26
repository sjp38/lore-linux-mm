Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D53F26B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 04:34:30 -0500 (EST)
Received: by wmww144 with SMTP id w144so14532080wmw.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 01:34:30 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id x84si2355665wmg.94.2015.11.26.01.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 01:34:29 -0800 (PST)
Received: by wmww144 with SMTP id w144so13607433wmw.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 01:34:29 -0800 (PST)
Date: Thu, 26 Nov 2015 10:34:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: Give __GFP_NOFAIL allocations access to
 memory reserves
Message-ID: <20151126093427.GA7953@dhcp22.suse.cz>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
 <1448448054-804-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511250248540.32374@chino.kir.corp.google.com>
 <20151125111801.GD27283@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511251254260.24689@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511251254260.24689@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-11-15 12:57:08, David Rientjes wrote:
> On Wed, 25 Nov 2015, Michal Hocko wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8034909faad2..94b04c1e894a 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2766,8 +2766,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  			goto out;
> >  	}
> >  	/* Exhausted what can be done so it's blamo time */
> > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> >  		*did_some_progress = 1;
> > +
> > +		if (gfp_mask & __GFP_NOFAIL)
> > +			page = get_page_from_freelist(gfp_mask, order,
> > +					ALLOC_NO_WATERMARKS, ac);
> > +	}
> >  out:
> >  	mutex_unlock(&oom_lock);
> >  	return page;
> 
> Well, sure, that's one way to do it, but for cpuset users, wouldn't this 
> lead to a depletion of the first system zone since you've dropped 
> ALLOC_CPUSET and are doing ALLOC_NO_WATERMARKS in the same call?  

Are you suggesting to do?
		if (gfp_mask & __GFP_NOFAIL) {
			page = get_page_from_freelist(gfp_mask, order,
					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
			/*
			 * fallback to ignore cpuset if our nodes are
			 * depleted
			 */
			if (!page)
				get_page_from_freelist(gfp_mask, order,
					ALLOC_NO_WATERMARKS, ac);
		}

I am not really sure this worth complication. __GFP_NOFAIL should be
relatively rare and nodes are rarely depeleted so much that
ALLOC_NO_WATERMARKS wouldn't be able to allocate from the first zone in
the zone list. I mean I have no problem to do the above it just sounds
overcomplicating the situation without making practical difference.
If you and others insist I can resping the patch though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
