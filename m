Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0811A6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 10:07:34 -0500 (EST)
Received: by wmvv187 with SMTP id v187so259444437wmv.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:07:33 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id 190si5694711wmb.18.2015.12.02.07.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 07:07:32 -0800 (PST)
Received: by wmuu63 with SMTP id u63so218797213wmu.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 07:07:32 -0800 (PST)
Date: Wed, 2 Dec 2015 16:07:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: Give __GFP_NOFAIL allocations access to
 memory reserves
Message-ID: <20151202150730.GH25284@dhcp22.suse.cz>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
 <1448448054-804-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511250248540.32374@chino.kir.corp.google.com>
 <20151125111801.GD27283@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511251254260.24689@chino.kir.corp.google.com>
 <20151126093427.GA7953@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511301415010.10460@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511301415010.10460@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 30-11-15 14:17:03, David Rientjes wrote:
> On Thu, 26 Nov 2015, Michal Hocko wrote:
> 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 8034909faad2..94b04c1e894a 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -2766,8 +2766,13 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > > >  			goto out;
> > > >  	}
> > > >  	/* Exhausted what can be done so it's blamo time */
> > > > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > > > +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> > > >  		*did_some_progress = 1;
> > > > +
> > > > +		if (gfp_mask & __GFP_NOFAIL)
> > > > +			page = get_page_from_freelist(gfp_mask, order,
> > > > +					ALLOC_NO_WATERMARKS, ac);
> > > > +	}
> > > >  out:
> > > >  	mutex_unlock(&oom_lock);
> > > >  	return page;
> > > 
> > > Well, sure, that's one way to do it, but for cpuset users, wouldn't this 
> > > lead to a depletion of the first system zone since you've dropped 
> > > ALLOC_CPUSET and are doing ALLOC_NO_WATERMARKS in the same call?  
> > 
> > Are you suggesting to do?
> > 		if (gfp_mask & __GFP_NOFAIL) {
> > 			page = get_page_from_freelist(gfp_mask, order,
> > 					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > 			/*
> > 			 * fallback to ignore cpuset if our nodes are
> > 			 * depleted
> > 			 */
> > 			if (!page)
> > 				get_page_from_freelist(gfp_mask, order,
> > 					ALLOC_NO_WATERMARKS, ac);
> > 		}
> > 
> > I am not really sure this worth complication.
> 
> I'm objecting to the ability of a process that is doing a __GFP_NOFAIL 
> allocation, which has been disallowed access from allocating on certain 
> mems through cpusets, to cause an oom condition on those disallowed nodes, 
> yes.

That ability will be there even with the fallback mechanism. My primary
objections was that the fallback is unnecessarily complex without any
evidence that such a situation would happen in the real life often
enought to bother about it. __GFP_NOFAIL allocations are and should be
rare and any runaway triggerable from the userspace is a kernel bug.

Anyway, as you seem to feel really strongly about this I will post v2
with the above fallback. This is a superslow path anyway...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
