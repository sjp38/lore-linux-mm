Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id C747D6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:41:36 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so519080eek.15
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:41:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si4602721eei.228.2013.12.19.06.41.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 06:41:35 -0800 (PST)
Date: Thu, 19 Dec 2013 15:41:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131219144134.GH10855@dhcp22.suse.cz>
References: <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312131551220.28704@chino.kir.corp.google.com>
 <20131217162342.GG28991@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312171240541.21640@chino.kir.corp.google.com>
 <20131218200434.GA4161@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed 18-12-13 22:09:12, David Rientjes wrote:
> On Wed, 18 Dec 2013, Michal Hocko wrote:
> 
> > > For memory isolation, we'd only want to bypass memcg charges when 
> > > absolutely necessary and it seems like TIF_MEMDIE is the only case where 
> > > that's required.  We don't give processes with pending SIGKILLs or those 
> > > in the exit() path access to memory reserves in the page allocator without 
> > > first determining that reclaim can't make any progress for the same reason 
> > > and then we only do so by setting TIF_MEMDIE when calling the oom killer.  
> > 
> > While I do understand arguments about isolation I would also like to be
> > practical here. How many charges are we talking about? Dozen pages? Much
> > more?
> 
> The PF_EXITING bypass is indeed much less concerning than the 
> fatal_signal_pending() bypass.

OK, so can we at least agree on the patch posted here:
https://lkml.org/lkml/2013/12/12/129. This is a real bug and definitely
worth fixing.

> > Besides that all of those should be very short lived because the task
> > is going to die very soon and so the memory will be freed.
> > 
> 
> We don't know how much memory is being allocated while 
> fatal_signal_pending() is true before the process can handle the SIGKILL, 
> so this could potentially bypass a significant amount of memory. 

The question is. Does it in _practice_?

We have this behavior since 867578cbccb08 which is 2.6.34 and we haven't
seen a single report where a shotdown task would break over the limit too
much. This would suggest that such a case doesn't happen very often.  If
it happens or it is easily triggerable then I am all for reverting that
check but that would require a proper justification rather than
speculations.

> If we are to have a configuration such as what Tejun recommended for
> oom handling:
> 
> 			 _____root______
> 			/		\
> 		    user		 oom
> 		   /    \		/   \
> 		  A	 B	       a     b
> 
> where the limit of A + B can be greater than the limit of user for 
> overcommit, and the limit of user is the amount of RAM minus whatever is 
> reserved for the oom hierarchy, then significant bypass to the root memcg 
> will cause memcgs in the oom hierarchy to actually not be able to allocate 
> memory from the page allocator.

I can imagine that the killed task might be in the middle of an
allocation loop and rather far away from returning to userspace (e.g.
readahead comes to mind - although that one shouldn't cause the global
OOM).
I would argue that we shouldn't reclaim in such a case and rather fail
the charge. Reclaiming will not help us much. In an extreme case we
would end up in OOM and the killed task would get TIF_MEMDIE and so it
would be allowed to bypass charges and break the isolation anyway.
Can we fail charges for killed tasks in general? I am very skeptical
because this might be a regular allocation to make a progress on the way
out.

So this doesn't solve the isolation problem, it just postpones it to
later and makes the life of other tasks in the same memcg worse because
their memory gets reclaimed which can lead to different performance
issues. And all of that for temporal charges which will go away shortly.

> The PF_EXITING bypass is much less concerning because we shouldn't be 
> doing significant memory allocation in the exit() path, but it's also true 
> that neither the PF_EXITING nor the fatal_signal_pending() bypass is 
> required. 

Yes, it is not, strictly speaking, required. It is very practical to do,
though. We do not know much about the context which called us so we
cannot base our decisions properly and just doing reclaim to see what
happens sounds like a bad decision to me.

> In Tejun's suggested configuration above, we absolutely do want 
> to reclaim from the user hierarchy before declaring oom and setting 
> TIF_MEMDIE, otherwise the oom hierarchy cannot allocate.
> 
> > So from my POV I would like to see these heuristics as simple as
> > possible and placed at very few places. Doing a bypass before charge
> > - or even after a failed charge before doing reclaim sounds like an easy
> > enough heuristic without a big risk.
> 
> It's a very significant risk of depleting memory that is available for oom 
> handling in the suggested configuration.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
