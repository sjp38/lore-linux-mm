Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5756B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:48:15 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so7787561pga.23
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:48:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i195si5441218pgc.30.2017.12.08.03.48.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 03:48:12 -0800 (PST)
Date: Fri, 8 Dec 2017 12:48:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171208114806.GU20234@dhcp22.suse.cz>
References: <20171208012305.83134-1-surenb@google.com>
 <20171208082220.GQ20234@dhcp22.suse.cz>
 <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Fri 08-12-17 20:36:16, Tetsuo Handa wrote:
> On 2017/12/08 17:22, Michal Hocko wrote:
> > On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
> >> Slab shrinkers can be quite time consuming and when signal
> >> is pending they can delay handling of the signal. If fatal
> >> signal is pending there is no point in shrinking that process
> >> since it will be killed anyway.
> > 
> > The thing is that we are _not_ shrinking _that_ process. We are
> > shrinking globally shared objects and the fact that the memory pressure
> > is so large that the kswapd doesn't keep pace with it means that we have
> > to throttle all allocation sites by doing this direct reclaim. I agree
> > that expediting killed task is a good thing in general because such a
> > process should free at least some memory.
> 
> But doesn't doing direct reclaim mean that allocation request of already
> fatal_signal_pending() threads will not succeed unless some memory is
> reclaimed (or selected as an OOM victim)? Won't it just spin the "too
> small to fail" retry loop at full speed in the worst case?

Well, normally kswapd would do the work on the background. But this
would have to be carefully evaluated. That is why I've said "expedite"
rather than skip.
 
> >> This change checks for pending
> >> fatal signals inside shrink_slab loop and if one is detected
> >> terminates this loop early.
> > 
> > This changelog doesn't really address my previous review feedback, I am
> > afraid. You should mention more details about problems you are seeing
> > and what causes them. If we have a shrinker which takes considerable
> > amount of time them we should be addressing that. If that is not
> > possible then it should be documented at least.
> 
> Unfortunately, it is possible to be get blocked inside shrink_slab() for so long
> like an example from http://lkml.kernel.org/r/1512705038.7843.6.camel@gmail.com .

As I've said any excessive shrinker should definitely be evaluated.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
