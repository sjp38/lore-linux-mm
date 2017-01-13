Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 404F26B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 09:58:59 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id an2so391156wjc.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:58:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u133si2421863wmu.53.2017.01.13.06.58.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 06:58:58 -0800 (PST)
Date: Fri, 13 Jan 2017 15:58:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/4] mm, page_alloc: warn_alloc print nodemask
Message-ID: <20170113145856.GM25212@dhcp22.suse.cz>
References: <20170112131659.23058-1-mhocko@kernel.org>
 <20170112131659.23058-3-mhocko@kernel.org>
 <dedb6ad3-f41e-7da1-29da-bb42e53ed3e7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dedb6ad3-f41e-7da1-29da-bb42e53ed3e7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

On Fri 13-01-17 12:31:52, Vlastimil Babka wrote:
> On 01/12/2017 02:16 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > warn_alloc is currently used for to report an allocation failure or an
> > allocation stall. We print some details of the allocation request like
> > the gfp mask and the request order. We do not print the allocation
> > nodemask which is important when debugging the reason for the allocation
> > failure as well. We alreaddy print the nodemask in the OOM report.
> > 
> > Add nodemask to warn_alloc and print it in warn_alloc as well.
> 
> That's helpful, but still IMHO incomplete compared to oom killer, see below.
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3031,12 +3031,13 @@ static void warn_alloc_show_mem(gfp_t gfp_mask)
> >  	show_mem(filter);
> >  }
> > 
> > -void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
> > +void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
> >  {
> >  	struct va_format vaf;
> >  	va_list args;
> >  	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
> >  				      DEFAULT_RATELIMIT_BURST);
> > +	nodemask_t *nm = (nodemask) ? nodemask : &cpuset_current_mems_allowed;
> 
> Yes that's same as oom's dump_header() does it. But what if there's both
> mempolicy nodemask and cpuset at play? From oom report you'll see that as it
> also calls cpuset_print_current_mems_allowed(). So could we do that here as
> well?

OK, I will add it. It cannot be harmful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
