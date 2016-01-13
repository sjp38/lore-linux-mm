Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 056A0828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 13:01:51 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id u188so308721444wmu.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:01:50 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id f15si3603521wjs.71.2016.01.13.10.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 10:01:48 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id f206so384792149wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 10:01:48 -0800 (PST)
Date: Wed, 13 Jan 2016 19:01:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160113180147.GL17512@dhcp22.suse.cz>
References: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
 <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
 <20160113162610.GD17512@dhcp22.suse.cz>
 <20160113165609.GA21950@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113165609.GA21950@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-01-16 11:56:09, Johannes Weiner wrote:
> On Wed, Jan 13, 2016 at 05:26:10PM +0100, Michal Hocko wrote:
> > On Wed 13-01-16 21:11:30, Tetsuo Handa wrote:
> > [...]
> > > Those who use panic_on_oom = 1 expect that the system triggers kernel panic
> > > rather than stall forever. This is a translation of administrator's wish that
> > > "Please press SysRq-c on behalf of me if the memory exhausted. In that way,
> > > I don't need to stand by in front of the console twenty-four seven."
> > > 
> > > Those who use panic_on_oom = 0 expect that the OOM killer solves OOM condition
> > > rather than stall forever. This is a translation of administrator's wish that
> > > "Please press SysRq-f on behalf of me if the memory exhausted. In that way,
> > > I don't need to stand by in front of the console twenty-four seven."
> > 
> > I think you are missing an important point. There is _no reliable_ way
> > to resolve the OOM condition in general except to panic the system. Even
> > killing all user space tasks might not be sufficient in general because
> > they might be blocked by an unkillable context (e.g. kernel thread).
> > So if you need a reliable behavior then either use panic_on_oom=1 or
> > provide a measure to panic after fixed timeout if the OOM cannot get
> > resolved. We have seen patches in that regards but there was no general
> > interest in them to merge them.
> 
> While what you're saying about there not being a failsafe way is true,
> I don't understand why we should panic the machine before we tried to
> kill every single userspace task. That's what I never understood about
> your timeout-panic patches: if the OOM victim doesn't exit in a fixed
> amount of time, why is it better to panic the machine than to try the
> second-best, third-best, fourth-best etc. OOM candidates?
> 
> Yes, you can say that at least the kernel will make a decision in a
> fixed amount of time and it'll be more useful in practice.

Yes, this is the main argument. The predictability of the behavior is
the main concern for any timeout based solution. If you know that your
failover mechanisms requires N + reboot_time then you want the
system to act very close to N. To act after _at least N_ without upper
bound sounds more than impractical to me.
If you can handle more tasks within that time period, as you are
suggesting below, then such a solution would satisfy this requirement as
well. I haven't explored how complex such a solution would be though.

Timeout-to-panic patches were just trying to be as simple as possible
to guarantee the predictability requirement. No other timeout based
solutions, which were proposed so far, did guarantee the same AFAIR.

> But the
> reality of most scenarios is that moving on to other victims will
> increase the chance of success dramatically while the chance of
> continued hanging would converge toward 0.

While theoretically the probability of hang decreases with the number of
oom victims (if the amount of memory reserves scales as well) most of
the cases where we really got stuck during OOM required a major screw up
and something must have gone really wrong. There are many tasks blocked
on the shared resource and it would take to kill them all (if that is
possible) to move on.

In other words I haven't seen a real world use case on a reasonably
configured system to lock up during OOM. It is much more probable that
the system is trashing for hours before it even hits the OOM killer from
my experience.

> And for the more extreme scenarios, where you have a million tasks all
> blocked on the same resource, we can decay the timeout exponentially
> to cap the decision time to a reasonable worst case; wait 8s for the
> first victim, 4s for the next one etc. and the machine will still
> recover or panic within 15s after the deadlock first occurs.

Yes this would be usable. Basically any timeout based solution must
converge to a known state to be usable as said above IMHO.
I am just not convinced such a sophisticated mechanism will be really
needed after we have functional async memory reaping in place. I might
be wrong here of course and then we can explore other ways to mitigate
issues that pop out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
