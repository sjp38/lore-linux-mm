Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8285E6B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:29:29 -0500 (EST)
Received: by wmvv187 with SMTP id v187so151083256wmv.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:29:29 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id n131si18001772wmf.11.2015.11.23.01.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:29:28 -0800 (PST)
Received: by wmuu63 with SMTP id u63so45486127wmu.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:29:28 -0800 (PST)
Date: Mon, 23 Nov 2015 10:29:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151123092925.GB21050@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5651BB43.8030102@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sun 22-11-15 13:55:31, Vlastimil Babka wrote:
> On 11.11.2015 14:48, mhocko@kernel.org wrote:
> >  mm/page_alloc.c | 10 +++++++++-
> >  1 file changed, 9 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8034909faad2..d30bce9d7ac8 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2766,8 +2766,16 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  			goto out;
> >  	}
> >  	/* Exhausted what can be done so it's blamo time */
> > -	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
> > +	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
> >  		*did_some_progress = 1;
> > +
> > +		if (gfp_mask & __GFP_NOFAIL) {
> > +			page = get_page_from_freelist(gfp_mask, order,
> > +					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > +			WARN_ONCE(!page, "Unable to fullfil gfp_nofail allocation."
> > +				    " Consider increasing min_free_kbytes.\n");
> 
> It seems redundant to me to keep the WARN_ON_ONCE also above in the if () part?

They are warning about two different things. The first one catches a
buggy code which uses __GFP_NOFAIL from oom disabled context while the
second one tries to help the administrator with a hint that memory
reserves are too small.

> Also s/gfp_nofail/GFP_NOFAIL/ for consistency?

Fair enough, changed.

> Hm and probably out of scope of your patch, but I understand the WARN_ONCE
> (WARN_ON_ONCE) to be _ONCE just to prevent a flood from a single task looping
> here. But for distinct tasks and potentially far away in time, wouldn't we want
> to see all the warnings? Would that be feasible to implement?

I was thinking about that as well some time ago but it was quite
hard to find a good enough API to tell when to warn again. The first
WARN_ON_ONCE should trigger for all different _code paths_ no matter
how frequently they appear to catch all the buggy callers. The second
one would benefit from a new warning after min_free_kbytes was updated
because it would tell the administrator that the last update was not
sufficient for the workload.

> 
> > +		}
> > +	}
> >  out:
> >  	mutex_unlock(&oom_lock);
> >  	return page;
> > 

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
