Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0736E6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 10:18:02 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so34998783wib.16
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 07:18:01 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id bf5si45208839wjc.82.2014.12.04.07.18.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 07:18:00 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id y19so22920607wgg.7
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 07:18:00 -0800 (PST)
Date: Thu, 4 Dec 2014 16:17:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141204151758.GC25001@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
 <20141127102547.GA18833@dhcp22.suse.cz>
 <20141201233040.GB29642@phnom.home.cmpxchg.org>
 <20141203155222.GH23236@dhcp22.suse.cz>
 <20141203181509.GA24567@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141203181509.GA24567@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 03-12-14 13:15:09, Johannes Weiner wrote:
> On Wed, Dec 03, 2014 at 04:52:22PM +0100, Michal Hocko wrote:
> > On Mon 01-12-14 18:30:40, Johannes Weiner wrote:
> > > On Thu, Nov 27, 2014 at 11:25:47AM +0100, Michal Hocko wrote:
> > > > On Wed 26-11-14 14:17:32, David Rientjes wrote:
> > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -2706,7 +2706,7 @@ rebalance:
> > > > >  	 * running out of options and have to consider going OOM
> > > > >  	 */
> > > > >  	if (!did_some_progress) {
> > > > > -		if (oom_gfp_allowed(gfp_mask)) {
> > > > 		/*
> > > > 		 * Do not attempt to trigger OOM killer for !__GFP_FS
> > > > 		 * allocations because it would be premature to kill
> > > > 		 * anything just because the reclaim is stuck on
> > > > 		 * dirty/writeback pages.
> > > > 		 * __GFP_NORETRY allocations might fail and so the OOM
> > > > 		 * would be more harmful than useful.
> > > > 		 */
> > > 
> > > I don't think we need to explain the individual flags, but it would
> > > indeed be useful to remark here that we shouldn't OOM kill from
> > > allocations contexts with (severely) limited reclaim abilities.
> > 
> > Is __GFP_NORETRY really related to limited reclaim abilities? I thought
> > it was merely a way to tell the allocator to fail rather than spend too
> > much time reclaiming.
> 
> And you wouldn't call that "limited reclaim ability"?

I really do not want to go into language lawyering here. But to me the
reclaim ability is what the reclaim is capable to do with the given gfp.
And __GFP_NORETRY is completely irrelevant for the reclaim. It tells the
allocator how hard it should try (similar like __GFP_REPEAT or
__GFP_NOFAIL) unlike __GFP_FS which restricts the reclaim in its
operation.

> I guess it's a
> matter of phrasing, but the point is that we don't want anybody to OOM
> kill that didn't exhaust all other options that are usually available
> to allocators.  This includes the ability to enter the FS, the ability
> to do IO in general, and the ability to retry reclaim.  Possibly more.

Right.

> > If you are referring to __GFP_FS part then I have
> > no objections to be less specific, of course, but __GFP_IO would fall
> > into the same category but we are not checking for it. I have no idea
> > why we consider the first and not the later one, to be honest...
> 
> Which proves my point that we should document high-level intent rather
> than implementation.  Suddenly, that missing __GFP_IO is sticking out
> like a sore thumb...

I am obviously not insisting on the above wording. I am for everything
that would clarify the test and do not force me to go through several
hops of the git blame to find the original intention again after year
when I forget this again.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
