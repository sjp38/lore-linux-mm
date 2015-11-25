Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 562E36B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:18:04 -0500 (EST)
Received: by wmec201 with SMTP id c201so251220429wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:18:03 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id bk4si33866730wjc.149.2015.11.25.03.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 03:18:03 -0800 (PST)
Received: by wmec201 with SMTP id c201so251219865wme.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:18:03 -0800 (PST)
Date: Wed, 25 Nov 2015 12:18:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: Give __GFP_NOFAIL allocations access to
 memory reserves
Message-ID: <20151125111801.GD27283@dhcp22.suse.cz>
References: <1448448054-804-1-git-send-email-mhocko@kernel.org>
 <1448448054-804-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1511250248540.32374@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511250248540.32374@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 25-11-15 02:51:38, David Rientjes wrote:
> On Wed, 25 Nov 2015, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_NOFAIL is a big hammer used to ensure that the allocation
> > request can never fail. This is a strong requirement and as such
> > it also deserves a special treatment when the system is OOM. The
> > primary problem here is that the allocation request might have
> > come with some locks held and the oom victim might be blocked
> > on the same locks. This is basically an OOM deadlock situation.
> > 
> > This patch tries to reduce the risk of such a deadlocks by giving
> > __GFP_NOFAIL allocations a special treatment and let them dive into
> > memory reserves after oom killer invocation. This should help them
> > to make a progress and release resources they are holding. The OOM
> > victim should compensate for the reserves consumption.
> > 
> > Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 8034909faad2..70db11c27046 100644
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
> > +					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
> > +	}
> >  out:
> >  	mutex_unlock(&oom_lock);
> >  	return page;
> 
> I don't understand why you're setting ALLOC_CPUSET if you're giving them 
> "special treatment".  If you want to allow access to memory reserves to 
> prevent an oom livelock, then why not also allow it access to allocate 
> outside its cpuset?

Good question. My thinking was that __GFP_NOFAIL allocations might be
done on behalf on a process so they are not necessarily system wide. We
do the same before we actually go to out_of_memory. On the other hand
__GFP_NOFAIL should be used really rarely and so breaking the cpuset
restriction shouldn't be a big deal if that helps to break out from the
potential OOM deadlock. I will drop it.

Thanks!
---
