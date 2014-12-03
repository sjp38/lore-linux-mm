Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E20EF6B006E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 18:10:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so16664114pab.35
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 15:10:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fq4si19869387pbd.242.2014.12.03.15.10.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Dec 2014 15:10:31 -0800 (PST)
Date: Wed, 3 Dec 2014 15:10:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-Id: <20141203151029.7ae782a811c47a21ab81f8a1@linux-foundation.org>
In-Reply-To: <20141203155222.GH23236@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
	<20141127102547.GA18833@dhcp22.suse.cz>
	<20141201233040.GB29642@phnom.home.cmpxchg.org>
	<20141203155222.GH23236@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Qiang Huang <h.huangqiang@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 Dec 2014 16:52:22 +0100 Michal Hocko <mhocko@suse.cz> wrote:

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

That's my understanding of __GFP_NORETRY.  However it seems that I
really didn't have a plan:

: commit 75908778d91e92ca3c9ed587c4550866f4c903fc
: Author: Andrew Morton <akpm@digeo.com>
: Date:   Sun Apr 20 00:28:12 2003 -0700
: 
:     [PATCH] implement __GFP_REPEAT, __GFP_NOFAIL, __GFP_NORETRY
:     
:     This is a cleanup patch.
:     
:     There are quite a lot of places in the kernel which will infinitely retry a
:     memory allocation.
:     
:     Generally, they get it wrong.  Some do yield(), the semantics of which have
:     changed over time.  Some do schedule(), which can lock up if the caller is
:     SCHED_FIFO/RR.  Some do schedule_timeout(), etc.
:     
:     And often it is unnecessary, because the page allocator will do the retry
:     internally anyway.  But we cannot rely on that - this behaviour may change
:     (-aa and -rmap kernels do not do this, for instance).
:     
:     So it is good to formalise and to centralise this operation.  If an
:     allocation specifies __GFP_REPEAT then the page allocator must infinitely
:     retry the allocation.
:     
:     The semantics of __GFP_REPEAT are "try harder".  The allocation _may_ fail
:     (the 2.4 -aa and -rmap VM's do not retry infinitely by default).
:     
:     The semantics of __GFP_NOFAIL are "cannot fail".  It is a no-op in this VM,
:     but needs to be honoured (or fix up the callers) if the VM ischanged to not
:     retry infinitely by default.
:     
:     The semantics of __GFP_NOREPEAT are "try once, don't loop".  This isn't used
:     at present (although perhaps it should be, in swapoff).  It is mainly for
:     completeness.

(that's a braino in the changelog: it should be
s/__GFP_NOREPEAT/__GFP_NORETRY/)

> If you are referring to __GFP_FS part then I have
> no objections to be less specific, of course, but __GFP_IO would fall
> into the same category but we are not checking for it. I have no idea
> why we consider the first and not the later one, to be honest...

(__GFP_FS && !__GFP_IO) doesn't make much sense and probably doesn't
happen.  "__GFP_FS implies __GFP_IO" is OK.

Anyway, yes, This particular piece of __alloc_pages_slowpath() sorely
needs documenting please.  Once we manage to work out why we're doing
what we're doing!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
