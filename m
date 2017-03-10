Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22D54280911
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:45:31 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id e12so61488790ioj.0
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 03:45:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a21si1855467itc.80.2017.03.10.03.45.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 03:45:30 -0800 (PST)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170307133057.26182-1-mhocko@kernel.org>
	<1488916356.6405.4.camel@redhat.com>
	<20170309180540.GA8678@cmpxchg.org>
	<20170310102010.GD3753@dhcp22.suse.cz>
In-Reply-To: <20170310102010.GD3753@dhcp22.suse.cz>
Message-Id: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
Date: Fri, 10 Mar 2017 20:44:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 09-03-17 13:05:40, Johannes Weiner wrote:
> > On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> > > It only does this to some extent.  If reclaim made
> > > no progress, for example due to immediately bailing
> > > out because the number of already isolated pages is
> > > too high (due to many parallel reclaimers), the code
> > > could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> > > test without ever looking at the number of reclaimable
> > > pages.
> > 
> > Hm, there is no early return there, actually. We bump the loop counter
> > every time it happens, but then *do* look at the reclaimable pages.
> > 
> > > Could that create problems if we have many concurrent
> > > reclaimers?
> > 
> > With increased concurrency, the likelihood of OOM will go up if we
> > remove the unlimited wait for isolated pages, that much is true.
> > 
> > I'm not sure that's a bad thing, however, because we want the OOM
> > killer to be predictable and timely. So a reasonable wait time in
> > between 0 and forever before an allocating thread gives up under
> > extreme concurrency makes sense to me.
> > 
> > > It may be OK, I just do not understand all the implications.
> > > 
> > > I like the general direction your patch takes the code in,
> > > but I would like to understand it better...
> > 
> > I feel the same way. The throttling logic doesn't seem to be very well
> > thought out at the moment, making it hard to reason about what happens
> > in certain scenarios.
> > 
> > In that sense, this patch isn't really an overall improvement to the
> > way things work. It patches a hole that seems to be exploitable only
> > from an artificial OOM torture test, at the risk of regressing high
> > concurrency workloads that may or may not be artificial.
> > 
> > Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
> > behind this patch. Can we think about a general model to deal with
> > allocation concurrency? 
> 
> I am definitely not against. There is no reason to rush the patch in.

I don't hurry if we can check using watchdog whether this problem is occurring
in the real world. I have to test corner cases because watchdog is missing.

> My main point behind this patch was to reduce unbound loops from inside
> the reclaim path and push any throttling up the call chain to the
> page allocator path because I believe that it is easier to reason
> about them at that level. The direct reclaim should be as simple as
> possible without too many side effects otherwise we end up in a highly
> unpredictable behavior. This was a first step in that direction and my
> testing so far didn't show any regressions.
> 
> > Unlimited parallel direct reclaim is kinda
> > bonkers in the first place. How about checking for excessive isolation
> > counts from the page allocator and putting allocations on a waitqueue?
> 
> I would be interested in details here.

That will help implementing __GFP_KILLABLE.
https://bugzilla.kernel.org/show_bug.cgi?id=192981#c15

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
