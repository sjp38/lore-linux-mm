Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5D1C28024F
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 05:10:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b130so66655700wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:10:45 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id pc9si13640321wjb.179.2016.09.29.02.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 02:10:41 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id b184so9686906wma.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:10:41 -0700 (PDT)
Date: Thu, 29 Sep 2016 11:10:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: warn about allocations which stall for too long
Message-ID: <20160929091040.GE408@dhcp22.suse.cz>
References: <20160923081555.14645-1-mhocko@kernel.org>
 <20160929084407.7004-1-mhocko@kernel.org>
 <20160929084407.7004-3-mhocko@kernel.org>
 <201609291802.GFG81203.FLHtOMSJOVFFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609291802.GFG81203.FLHtOMSJOVFFQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 29-09-16 18:02:44, Tetsuo Handa wrote:
[...]
> > @@ -3650,6 +3652,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> >  		goto nopage;
> >  
> > +	/* Make sure we know about allocations which stall for too long */
> > +	if (time_after(jiffies, alloc_start + stall_timeout)) {
> > +		warn_alloc(gfp_mask,
> 
> I expect "gfp_mask & ~__GFP_NOWARN" rather than "gfp_mask" here.
> Otherwise, we can't get a clue for __GFP_NOWARN allocations.

If there is an explicit __GFP_NOWARN then I believe we should obey it
same way we do for the allocation failure. If you believe this is not
the best way then feel free to send a patch with an example where a
__GFP_NOWARN user would really like to see about the stall.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
