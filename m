Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87DBE6B027F
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 04:44:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m186so269169210ioa.0
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 01:44:45 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id f79si7527429iof.44.2016.09.23.01.44.41
        for <linux-mm@kvack.org>;
        Fri, 23 Sep 2016 01:44:43 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20160923081555.14645-1-mhocko@kernel.org> <007901d21574$9ef82d60$dce88820$@alibaba-inc.com> <20160923083224.GF4478@dhcp22.suse.cz>
In-Reply-To: <20160923083224.GF4478@dhcp22.suse.cz>
Subject: Re: [PATCH] mm: warn about allocations which stall for too long
Date: Fri, 23 Sep 2016 16:44:26 +0800
Message-ID: <007a01d21576$b12ac4a0$13804de0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

On Friday, September 23, 2016 4:32 PM, Michal Hocko wrote
> On Fri 23-09-16 16:29:36, Hillf Danton wrote:
> [...]
> > > @@ -3659,6 +3661,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > >  	else
> > >  		no_progress_loops++;
> > >
> > > +	/* Make sure we know about allocations which stall for too long */
> > > +	if (!(gfp_mask & __GFP_NOWARN) && time_after(jiffies, alloc_start + stall_timeout)) {
> > > +		pr_warn("%s: page alloction stalls for %ums: order:%u mode:%#x(%pGg)\n",
> > > +				current->comm, jiffies_to_msecs(jiffies-alloc_start),
> >
> > Better if pid is also printed.
> 
> I've tried to be consistent with warn_alloc_failed and that doesn't
> print pid either. Maybe both of them should. Dunno
> 
With pid imho we can distinguish two tasks with same name in a simpler way. 

> > > +				order, gfp_mask, &gfp_mask);
> > > +		stall_timeout += 10 * HZ;
> >
> > Alternatively	 alloc_start = jiffies;
> 
> Then we would lose the cumulative time in the output which is imho
> helpful because you cannot tell whether the new warning is a new request
> or the old one still looping.
> 
Fair.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
