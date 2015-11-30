Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 90E4E6B0253
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:17:05 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so203895317pab.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:17:05 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id t13si12239989pas.21.2015.11.30.14.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:17:04 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so203894987pab.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:17:04 -0800 (PST)
Date: Mon, 30 Nov 2015 14:17:03 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, oom: Give __GFP_NOFAIL allocations access to
 memory reserves
In-Reply-To: <20151126093427.GA7953@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1511301415010.10460@chino.kir.corp.google.com>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org> <1448448054-804-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1511250248540.32374@chino.kir.corp.google.com> <20151125111801.GD27283@dhcp22.suse.cz> <alpine.DEB.2.10.1511251254260.24689@chino.kir.corp.google.com>
 <20151126093427.GA7953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 26 Nov 2015, Michal Hocko wrote:

> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 8034909faad2..94b04c1e894a 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2766,8 +2766,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >  			goto out;
> > >  	}
> > >  	/* Exhausted what can be done so it's blamo time */
> > > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > > +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > >  		*did_some_progress = 1;
> > > +
> > > +		if (gfp_mask & __GFP_NOFAIL)
> > > +			page = get_page_from_freelist(gfp_mask, order,
> > > +					ALLOC_NO_WATERMARKS, ac);
> > > +	}
> > >  out:
> > >  	mutex_unlock(&oom_lock);
> > >  	return page;
> > 
> > Well, sure, that's one way to do it, but for cpuset users, wouldn't this 
> > lead to a depletion of the first system zone since you've dropped 
> > ALLOC_CPUSET and are doing ALLOC_NO_WATERMARKS in the same call?  
> 
> Are you suggesting to do?
> 		if (gfp_mask & __GFP_NOFAIL) {
> 			page = get_page_from_freelist(gfp_mask, order,
> 					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> 			/*
> 			 * fallback to ignore cpuset if our nodes are
> 			 * depleted
> 			 */
> 			if (!page)
> 				get_page_from_freelist(gfp_mask, order,
> 					ALLOC_NO_WATERMARKS, ac);
> 		}
> 
> I am not really sure this worth complication.

I'm objecting to the ability of a process that is doing a __GFP_NOFAIL 
allocation, which has been disallowed access from allocating on certain 
mems through cpusets, to cause an oom condition on those disallowed nodes, 
yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
