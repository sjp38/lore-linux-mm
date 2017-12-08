Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA7456B0069
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:03:46 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 105so5734167oth.22
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:03:46 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q134si1223620itq.152.2017.12.08.06.03.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 06:03:45 -0800 (PST)
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171208012305.83134-1-surenb@google.com>
	<20171208082220.GQ20234@dhcp22.suse.cz>
	<d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
	<20171208114806.GU20234@dhcp22.suse.cz>
In-Reply-To: <20171208114806.GU20234@dhcp22.suse.cz>
Message-Id: <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 23:03:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: surenb@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

Michal Hocko wrote:
> On Fri 08-12-17 20:36:16, Tetsuo Handa wrote:
> > On 2017/12/08 17:22, Michal Hocko wrote:
> > > On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
> > >> Slab shrinkers can be quite time consuming and when signal
> > >> is pending they can delay handling of the signal. If fatal
> > >> signal is pending there is no point in shrinking that process
> > >> since it will be killed anyway.
> > > 
> > > The thing is that we are _not_ shrinking _that_ process. We are
> > > shrinking globally shared objects and the fact that the memory pressure
> > > is so large that the kswapd doesn't keep pace with it means that we have
> > > to throttle all allocation sites by doing this direct reclaim. I agree
> > > that expediting killed task is a good thing in general because such a
> > > process should free at least some memory.
> > 
> > But doesn't doing direct reclaim mean that allocation request of already
> > fatal_signal_pending() threads will not succeed unless some memory is
> > reclaimed (or selected as an OOM victim)? Won't it just spin the "too
> > small to fail" retry loop at full speed in the worst case?
> 
> Well, normally kswapd would do the work on the background. But this
> would have to be carefully evaluated. That is why I've said "expedite"
> rather than skip.

Relying on kswapd is a bad assumption, for kswapd can be blocked on e.g. fs
locks waiting for somebody else to reclaim memory.

>  
> > >> This change checks for pending
> > >> fatal signals inside shrink_slab loop and if one is detected
> > >> terminates this loop early.
> > > 
> > > This changelog doesn't really address my previous review feedback, I am
> > > afraid. You should mention more details about problems you are seeing
> > > and what causes them. If we have a shrinker which takes considerable
> > > amount of time them we should be addressing that. If that is not
> > > possible then it should be documented at least.
> > 
> > Unfortunately, it is possible to be get blocked inside shrink_slab() for so long
> > like an example from http://lkml.kernel.org/r/1512705038.7843.6.camel@gmail.com .
> 
> As I've said any excessive shrinker should definitely be evaluated.

The cause of stall inside shrink_slab() can be memory pressure itself.
There would be no problem if kswapd is sufficient (i.e. direct reclaim is
not needed). But there are many problems if direct reclaim is needed.



I agree that making waits/loops killable is generally good. But be sure to be
prepared for the worst case. For example, start __GFP_KILLABLE from "best effort"
basis (i.e. no guarantee that the allocating thread will leave the page allocator
slowpath immediately) and check for fatal_signal_pending() only if
__GFP_KILLABLE is set. That is,

+		/*
+		 * We are about to die and free our memory.
+		 * Stop shrinking which might delay signal handling.
+		 */
+		if (unlikely((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current)))
+			break;

at shrink_slab() etc. and

+		if ((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current))
+			goto nopage;

at __alloc_pages_slowpath().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
