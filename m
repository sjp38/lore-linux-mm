Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id A85BE900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 11:21:38 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so24640539wiw.0
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 08:21:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy1si4590152wib.89.2015.06.05.08.21.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Jun 2015 08:21:37 -0700 (PDT)
Date: Fri, 5 Jun 2015 17:21:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: close the race window between OOM detection
 and killing
Message-ID: <20150605152135.GE26113@dhcp22.suse.cz>
References: <20150603031544.GC7579@mtj.duckdns.org>
 <20150603144414.GG16201@dhcp22.suse.cz>
 <20150603193639.GH20091@mtj.duckdns.org>
 <20150604093031.GB4806@dhcp22.suse.cz>
 <20150604192936.GR20091@mtj.duckdns.org>
 <20150605143534.GD26113@dhcp22.suse.cz>
 <20150605145759.GA5946@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150605145759.GA5946@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri 05-06-15 23:57:59, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Jun 05, 2015 at 04:35:34PM +0200, Michal Hocko wrote:
> > > That doesn't matter because the detection and TIF_MEMDIE assertion are
> > > atomic w.r.t. oom_lock and TIF_MEMDIE essentially extends the locking
> > > by preventing further OOM kills.  Am I missing something?
> > 
> > This is true but TIF_MEMDIE releasing is not atomic wrt. the allocation
> > path. So the oom victim could have released memory and dropped
> 
> This is splitting hairs.  In vast majority of problem cases, if
> anything is gonna be locked up, it's gonna be locked up before
> releasing memory it's holding.  Yet again, this is a blunt instrument
> to unwedge the system.  It's difficult to see the point of aiming that
> level of granularity.

I was just pointing out that the OOM killer is inherently racy even for
the global case. Not sure we are talking about the same thing here.

> 
> > TIF_MEMDIE but the allocation path hasn't noticed that because it's passed
> >         /*
> >          * Go through the zonelist yet one more time, keep very high watermark
> >          * here, this is only to catch a parallel oom killing, we must fail if
> >          * we're still under heavy pressure.
> >          */
> >         page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
> >                                         ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
> > 
> > and goes on to kill another task because there is no TIF_MEMDIE
> > anymore.
> 
> Why would this be an issue if we disallow parallel killing?

I am confused. The whole thread has started by fixing a race in memcg
and I was asking about the global case which is racy currently as well.

> > > Deadlocks from infallible allocations getting interlocked are
> > > different.  OOM killer can't really get around that by itself but I'm
> > > not talking about those deadlocks but at the same time they're a lot
> > > less likely.  It's about OOM victim trapped in a deadlock failing to
> > > release memory because someone else is waiting for that memory to be
> > > released while blocking the victim. 
> > 
> > I thought those would be in the allocator context - which was the
> > example I've provided. What kind of context do you have in mind?
> 
> Yeah, sure, they'd be in the allocator context holding other resources
> which are being waited upon.  The first case was deadlock based on
> purely memory starvation where NOFAIL allocations interlock with each
> other w/o involving other resources.

OK, I guess we were just talking past each other.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
