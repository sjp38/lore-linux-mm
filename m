Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0385F6B0032
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 13:15:19 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id h11so25355662wiw.15
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 10:15:18 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mb2si41222965wjb.3.2014.12.03.10.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Dec 2014 10:15:17 -0800 (PST)
Date: Wed, 3 Dec 2014 13:15:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141203181509.GA24567@phnom.home.cmpxchg.org>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
 <20141127102547.GA18833@dhcp22.suse.cz>
 <20141201233040.GB29642@phnom.home.cmpxchg.org>
 <20141203155222.GH23236@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141203155222.GH23236@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 03, 2014 at 04:52:22PM +0100, Michal Hocko wrote:
> On Mon 01-12-14 18:30:40, Johannes Weiner wrote:
> > On Thu, Nov 27, 2014 at 11:25:47AM +0100, Michal Hocko wrote:
> > > On Wed 26-11-14 14:17:32, David Rientjes wrote:
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -2706,7 +2706,7 @@ rebalance:
> > > >  	 * running out of options and have to consider going OOM
> > > >  	 */
> > > >  	if (!did_some_progress) {
> > > > -		if (oom_gfp_allowed(gfp_mask)) {
> > > 		/*
> > > 		 * Do not attempt to trigger OOM killer for !__GFP_FS
> > > 		 * allocations because it would be premature to kill
> > > 		 * anything just because the reclaim is stuck on
> > > 		 * dirty/writeback pages.
> > > 		 * __GFP_NORETRY allocations might fail and so the OOM
> > > 		 * would be more harmful than useful.
> > > 		 */
> > 
> > I don't think we need to explain the individual flags, but it would
> > indeed be useful to remark here that we shouldn't OOM kill from
> > allocations contexts with (severely) limited reclaim abilities.
> 
> Is __GFP_NORETRY really related to limited reclaim abilities? I thought
> it was merely a way to tell the allocator to fail rather than spend too
> much time reclaiming.

And you wouldn't call that "limited reclaim ability"?  I guess it's a
matter of phrasing, but the point is that we don't want anybody to OOM
kill that didn't exhaust all other options that are usually available
to allocators.  This includes the ability to enter the FS, the ability
to do IO in general, and the ability to retry reclaim.  Possibly more.

> If you are referring to __GFP_FS part then I have
> no objections to be less specific, of course, but __GFP_IO would fall
> into the same category but we are not checking for it. I have no idea
> why we consider the first and not the later one, to be honest...

Which proves my point that we should document high-level intent rather
than implementation.  Suddenly, that missing __GFP_IO is sticking out
like a sore thumb...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
