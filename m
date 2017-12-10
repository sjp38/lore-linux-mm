Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACCC6B0069
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 06:38:27 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id i66so9271947itf.0
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 03:38:27 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id l19si983891iog.328.2017.12.10.03.38.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 03:38:25 -0800 (PST)
Subject: Re: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <d5cc35f6-57a4-adb9-5b32-07c1db7c2a7a@I-love.SAKURA.ne.jp>
	<20171208114806.GU20234@dhcp22.suse.cz>
	<201712082303.DDG90166.FOLSHOOFVQJMtF@I-love.SAKURA.ne.jp>
	<CAJuCfpHmdcA=t9p8kjJYrgkrreQZt9Sa1=_up+1yV9BE4xJ-8g@mail.gmail.com>
	<20171210101311.GA20234@dhcp22.suse.cz>
In-Reply-To: <20171210101311.GA20234@dhcp22.suse.cz>
Message-Id: <201712102037.IEB12405.OLFOMtSOQFVHFJ@I-love.SAKURA.ne.jp>
Date: Sun, 10 Dec 2017 20:37:59 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, surenb@google.com
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

Michal Hocko wrote:
> > > I agree that making waits/loops killable is generally good. But be sure to be
> > > prepared for the worst case. For example, start __GFP_KILLABLE from "best effort"
> > > basis (i.e. no guarantee that the allocating thread will leave the page allocator
> > > slowpath immediately) and check for fatal_signal_pending() only if
> > > __GFP_KILLABLE is set. That is,
> > >
> > > +               /*
> > > +                * We are about to die and free our memory.
> > > +                * Stop shrinking which might delay signal handling.
> > > +                */
> > > +               if (unlikely((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current)))
> > > +                       break;
> > >
> > > at shrink_slab() etc. and
> > >
> > > +               if ((gfp_mask & __GFP_KILLABLE) && fatal_signal_pending(current))
> > > +                       goto nopage;
> > >
> > > at __alloc_pages_slowpath().
> > 
> > I was thinking about something similar and will experiment to see if
> > this solves the problem and if it has any side effects. Anyone sees
> > any obvious problems with this approach?
> 
> Tetsuo has been proposing this flag in the past and I've had objections
> why this is not a great idea. I do not have any link handy but the core
> objection was that the semantic would be too fuzzy. All the allocations
> in the same context would have to be killable for this flag to have any
> effect. Spreading it all over the kernel is simply not feasible.
> 

Refusing __GFP_KILLABLE based on "All the allocations in the same context
would have to be killable" does not make sense. Outside of MM, we update
code to use _killable version step by step based on best effort basis.
People don't call efforts to change like

  func1() {
    // As of this point it is easy to bail out.
    if (mutex_lock_killable(&lock1) == 0) {
      func2();
      mutex_unlock(&lock1);
    }
  }

  func2() {
    mutex_lock(&lock2);
    // Do something which is not possible to bail out for now.
    mutex_unlock(&lock2);
  }

pointless.

If you insist on "All the allocations in the same context would
have to be killable", then we will offload all activities to some
kernel thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
