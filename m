Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C47436B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 05:57:19 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so22457814wmi.6
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 02:57:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si49505475wjc.180.2016.12.27.02.57.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Dec 2016 02:57:18 -0800 (PST)
Date: Tue, 27 Dec 2016 11:57:15 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161227105715.GE1308@dhcp22.suse.cz>
References: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <201612222233.CBC56295.LFOtMOVQSJOFHF@I-love.SAKURA.ne.jp>
 <20161222192406.GB19898@dhcp22.suse.cz>
 <201612241525.EDB52697.OQSFOLJFFOHVMt@I-love.SAKURA.ne.jp>
 <20161226114935.GB16042@dhcp22.suse.cz>
 <201612271939.FFF56780.tOFQOHJSVLMOFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612271939.FFF56780.tOFQOHJSVLMOFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, pmladek@suse.cz

On Tue 27-12-16 19:39:28, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 24-12-16 15:25:43, Tetsuo Handa wrote:
[...]
> > > Thus, I'm proposing to save CPU time if waiting for the OOM killer/reaper
> > > when direct reclaim did not help.
> > 
> > Which will just move problem somewhere else I am afraid. Now you will
> > have hundreds of tasks bouncing on the global mutex. That never turned
> > out to be a good thing in the past and I am worried that it will just
> > bite us from a different side. What is worse it might hit us in cases
> > which do actually happen in the real life.
> > 
> > I am not saying that the current code works perfectly when we are
> > hitting the direct reclaim close to the OOM but improving that requires
> > much more than slapping a global lock there.
> 
> So, we finally agreed that there are problems when we are hitting the direct
> reclaim close to the OOM. Good.

There has never been a disagreement here. The point we seem to be
disagreeing is how much those issues you are seeing matter. I do not
consider them top priority because they are not happening in real life
enough.
 
> > > > > Then, you call such latency as scheduler's problem?
> > > > > mutex_lock_killable(&oom_lock) change helps coping with whatever delays
> > > > > OOM killer/reaper might encounter.
> > > > 
> > > > It helps _your_ particular insane workload. I believe you can construct
> > > > many others which which would cause a similar problem and the above
> > > > suggestion wouldn't help a bit. Until I can see this is easily
> > > > triggerable on a reasonably configured system then I am not convinced
> > > > we should add more non trivial changes to the oom killer path.
> > > 
> > > I'm not using root privileges nor realtime priority nor CONFIG_PREEMPT=y.
> > > Why you don't care about the worst situation / corner cases?
> > 
> > I do care about them! I just do not want to put random hacks which might
> > seem to work on this _particular_ workload while it brings risks for
> > others. Look, those corner cases you are simulating are _interesting_ to
> > see how robust we are but they are no way close to what really happens
> > in the real life out there - we call those situations DoS from any
> > practical POV. Admins usually do everything to prevent from them by
> > configuring their systems and limiting untrusted users as much as
> > possible.
> 
> I wonder why you introduce "untrusted users" concept. From my experience,
> there was no "untrusted users". All users who use their systems are trusted
> and innocent, but they _by chance_ hit problems when close to (or already)
> the OOM.

my experience is that innocent users are no way close to what you are
simulating. And we tend to handle most OOMs just fine in my experience.
 
[...]

> > Just try to remember how you were pushing really hard for oom timeouts
> > one year back because the OOM killer was suboptimal and could lockup. It
> > took some redesign and many changes to fix that. The result is
> > imho a better, more predictable and robust code which wouldn't be the
> > case if we just went your way to have a fix quickly...
> 
> I agree that the result is good for users who can update kernels. But that
> change was too large to backport. Any approach which did not in time for
> customers' deadline of deciding their kernels to use for 10 years is
> useless for them. Lack of catch-all reporting/triggering mechanism is
> unhappy for both customers and troubleshooting staffs at support centers.

Then implement whatever you find appropriate on those old kernels and
deal with the follow up reports. This is the fair deal you have cope
with when using and supporting old kernels.
 
> Improving the direct reclaim close to the OOM requires a lot of effort.
> We might add new bugs during that effort. So, where is valid reason that
> we can not have asynchronous watchdog like kmallocwd? Please do explain
> at kmallocwd thread. You have never persuaded me about keeping kmallocwd
> out of tree.

I am not going to repeat my arguments over again. I haven't nacked that
patch and it seems there is no great interest in it so do not try to
claim that it is me who is blocking this feature. I just do not think it
is worth it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
