Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id EA6B46B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 22:35:46 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so4472648bkz.5
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 19:35:46 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id zd1si4269501bkb.105.2013.11.29.19.35.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 19:35:45 -0800 (PST)
Date: Fri, 29 Nov 2013 22:35:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131130033536.GL22729@cmpxchg.org>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
 <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com>
 <20131128031313.GK3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com>
 <20131128035218.GM3556@cmpxchg.org>
 <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Nov 29, 2013 at 04:00:09PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > None that I am currently aware of, I'll continue to try them out.  I'd 
> > > suggest just dropping the stable@kernel.org from the whole series though 
> > > unless there is another report of such a problem that people are running 
> > > into.
> > 
> > The series has long been merged, how do we drop stable@kernel.org from
> > it?
> > 
> 
> You said you have informed stable to not merge these patches until further 
> notice, I'd suggest simply avoid ever merging the whole series into a 
> stable kernel since the problem isn't serious enough.  Marking changes 
> that do "goto nomem" seem fine to mark for stable, though.

These are followup fixes for the series that is upstream but didn't go
to stable.  I truly have no idea what you are talking about.

> > > We've had this patch internally since we started using memcg, it has 
> > > avoided some unnecessary oom killing.
> > 
> > Do you have quantified data that OOM kills are reduced over a longer
> > sampling period?  How many kills are skipped?  How many of them are
> > deferred temporarily but the VM ended up having to kill something
> > anyway?
> 
> On the scale that we run memcg, we would see it daily in automated testing 
> primarily because we panic the machine for memcg oom conditions where 
> there are no killable processes.  It would typically manifest by two 
> processes that are allocating memory in a memcg; one is oom killed, is 
> allowed to allocate, handles its SIGKILL, exits and frees its memory and 
> the second process which is oom disabled races with the uncharge and is 
> oom disabled so the machine panics.

So why don't you implement proper synchronization instead of putting
these random checks all over the map to make the race window just
small enough to not matter most of the time?

> The upstream kernel of course doesn't panic in such a condition but if the 
> same scenario were to have happened, the second process would be 
> unnecessarily oom killed because it raced with the uncharge of the first 
> victim and it had exited before the scan of processes in the memcg oom 
> killer could detect it and defer.  So this patch definitely does prevent 
> unnecessary oom killing when run at such a large scale that we do.

If you are really bothered by this race, then please have OOM kill
invocations wait for any outstanding TIF_MEMDIE tasks in the same
context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
