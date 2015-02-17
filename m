Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id ECE2B6B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 11:50:28 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id y19so36984390wgg.13
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:50:28 -0800 (PST)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id lt12si29905954wic.25.2015.02.17.08.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 08:50:27 -0800 (PST)
Received: by mail-wi0-f180.google.com with SMTP id h11so35359556wiw.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 08:50:26 -0800 (PST)
Date: Tue, 17 Feb 2015 17:50:24 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217165024.GI32017@dhcp22.suse.cz>
References: <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
 <20150216154201.GA27295@phnom.home.cmpxchg.org>
 <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
 <20150217131618.GA14778@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150217131618.GA14778@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue 17-02-15 08:16:18, Johannes Weiner wrote:
> On Tue, Feb 17, 2015 at 08:57:05PM +0900, Tetsuo Handa wrote:
> > Johannes Weiner wrote:
> > > On Mon, Feb 16, 2015 at 08:23:16PM +0900, Tetsuo Handa wrote:
> > > >   (2) Implement TIF_MEMDIE timeout.
> > > 
> > > How about something like this?  This should solve the deadlock problem
> > > in the page allocator, but it would also simplify the memcg OOM killer
> > > and allow its use by in-kernel faults again.
> > 
> > Yes, basic idea would be same with
> > http://marc.info/?l=linux-mm&m=142002495532320&w=2 .
> > 
> > But Michal and David do not like the timeout approach.
> > http://marc.info/?l=linux-mm&m=141684783713564&w=2
> > http://marc.info/?l=linux-mm&m=141686814824684&w=2

Yes I really hate time based solutions for reasons already explained in
the referenced links.
 
> I'm open to suggestions, but we can't just stick our heads in the sand
> and pretend that these are just unrelated bugs.  They're not. 

Requesting GFP_NOFAIL allocation with locks held is IMHO a bug and
should be fixed.
Hopelessly looping in the page allocator without GFP_NOFAIL is too risky
as well and we should get rid of this. Why should we still try to loop
when previous 1000 attempts failed with OOM killer invocation? Can we
simply fail after a configurable number of attempts? This is prone to
reveal unchecked allocation failures but those are bugs as well and we
shouldn't pretend otherwise.

> As long
> as it's legal to enter the allocator with *anything* that can prevent
> another random task in the system from making progress, we have this
> deadlock potential.  One side has to give up, and it can't be the page
> allocator because it has to support __GFP_NOFAIL allocations, which
> are usually exactly the allocations that are buried in hard-to-unwind
> state that is likely to trip up exiting OOM victims.

I am not convinced that GFP_NOFAIL is the biggest problem. Most if
OOM livelocks I have seen were either due to GFP_KERNEL treated as
GFP_NOFAIL or an incorrect gfp mask (e.g. GFP_FS added where not
appropriate). I think we should focus on this part before we start
adding heuristics into OOM killer.
 
> The alternative would be lock dependency tracking, but I'm not sure it
> can be realistically done for production environments.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
