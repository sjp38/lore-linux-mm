Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A39516B0253
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 05:13:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so3097548wmb.7
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 02:13:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c75si3829769wme.91.2017.12.10.02.13.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 02:13:13 -0800 (PST)
Date: Sun, 10 Dec 2017 11:13:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171210101311.GA20234@dhcp22.suse.cz>
References: <20171208012305.83134-1-surenb@google.com>
 <20171208082220.GQ20234@dhcp22.suse.cz>
 <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
 <20171208114806.GU20234@dhcp22.suse.cz>
 <201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
 <CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>, Todd Kjos <tkjos@google.com>

On Fri 08-12-17 10:06:26, Suren Baghdasaryan wrote:
> On Fri, Dec 8, 2017 at 6:03 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > Michal Hocko wrote:
> >> On Fri 08-12-17 20:36:16, Tetsuo Handa wrote:
> >> > On 2017/12/08 17:22, Michal Hocko wrote:
> >> > > On Thu 07-12-17 17:23:05, Suren Baghdasaryan wrote:
> >> > >> Slab shrinkers can be quite time consuming and when signal
> >> > >> is pending they can delay handling of the signal. If fatal
> >> > >> signal is pending there is no point in shrinking that process
> >> > >> since it will be killed anyway.
> >> > >
> >> > > The thing is that we are _not_ shrinking _that_ process. We are
> >> > > shrinking globally shared objects and the fact that the memory pressure
> >> > > is so large that the kswapd doesn't keep pace with it means that we have
> >> > > to throttle all allocation sites by doing this direct reclaim. I agree
> >> > > that expediting killed task is a good thing in general because such a
> >> > > process should free at least some memory.
> 
> Agree, wording here is inaccurate. My original intent was to have a
> safeguard against slow shrinkers but I understand your concern that
> this can mask a real problem in a shrinker. In essence expediting the
> killing is the ultimate goal here but as you mentioned it's not as
> simple as this change.

Moreover it doesn't work if the SIGKILL can be delivered asynchronously
(which is your case AFAICU).  You can be already running the slow
shrinker at that time...
 
[...]
> > I agree that making waits/loops killable is generally good. But be sure to be
> > prepared for the worst case. For example, start __GFP_KILLABLE from "best effort"
> > basis (i.e. no guarantee that the allocating thread will leave the page allocator
> > slowpath immediately) and check for fatal_signal_pending() only if
> > __GFP_KILLABLE is set. That is,
> >
> > +               /*
> > +                * We are about to die and free our memory.
> > +                * Stop shrinking which might delay signal handling.
> > +                */
> > +               if (unlikely((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current)))
> > +                       break;
> >
> > at shrink_slab() etc. and
> >
> > +               if ((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current))
> > +                       goto nopage;
> >
> > at __alloc_pages_slowpath().
> 
> I was thinking about something similar and will experiment to see if
> this solves the problem and if it has any side effects. Anyone sees
> any obvious problems with this approach?

Tetsuo has been proposing this flag in the past and I've had objections
why this is not a great idea. I do not have any link handy but the core
objection was that the semantic would be too fuzzy. All the allocations
in the same context would have to be killable for this flag to have any
effect. Spreading it all over the kernel is simply not feasible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
