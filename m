Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id BC6126B0070
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:51:33 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so132562337wiw.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:51:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg6si7722117wjb.12.2015.06.17.05.51.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 05:51:32 -0700 (PDT)
Date: Wed, 17 Jun 2015 14:51:28 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150617125127.GF25056@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <20150617121104.GD25056@dhcp22.suse.cz>
 <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 21:31:21, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > I think we can rely on timers. A downside would be that we cannot dump
> > the full OOM report from the IRQ context because we rely on task_lock
> > which is not IRQ safe. But I do not think we really need it. An OOM
> > report will be in the log already most of the time and show_mem will
> > tell us the current memory situation.
> > 
> > What do you think?
> 
> We can rely on timers, but we can't rely on global timer.

Why not?

> 
> > +	if (sysctl_panic_on_oom_timeout) {
> > +		if (sysctl_panic_on_oom > 1) {
> > +			pr_warn("panic_on_oom_timeout is ignored for panic_on_oom=2\n");
> > +		} else {
> > +			/*
> > +			 * Only schedule the delayed panic_on_oom when this is
> > +			 * the first OOM triggered. oom_lock will protect us
> > +			 * from races
> > +			 */
> > +			if (atomic_read(&oom_victims))
> > +				return;
> > +
> > +			mod_timer(&panic_on_oom_timer,
> > +					jiffies + (sysctl_panic_on_oom_timeout * HZ));
> > +			return;
> > +		}
> > +	}
> 
> Since this version uses global panic_on_oom_timer, you cannot handle
> OOM race like below.
> 
>   (1) p1 in memcg1 calls out_of_memory().
>   (2) 5 seconds of timeout is started by p1.
>   (3) p1 takes 3 seconds for some reason.
>   (4) p2 in memcg2 calls out_of_memory().
>   (5) p1 calls unmark_oom_victim() but timer continues.
>   (6) p2 takes 2 seconds for some reason.
>   (7) 5 seconds of timeout expires despite individual delay was less than
>       5 seconds.

Yes it is not intended to handle such a race. Timeout is completely
ignored for panic_on_oom=2 and contrained oom context doesn't trigger
this path for panic_on_oom=1.

But you have a point that we could have
- constrained OOM which elevates oom_victims
- global OOM killer strikes but wouldn't start the timer

This is certainly possible and timer_pending(&panic_on_oom) replacing
oom_victims check should help here. I will think about this some more.
But this sounds like a minor detail.

The important thing is to decide what is the reasonable way forward. We
have two two implementations of panic based timeout. So we should decide
- Should be the timeout bound to panic_on_oom?
- Should we care about constrained OOM contexts?
- If yes should they use the same timeout?
- If yes should each memcg be able to define its own timeout?

My thinking is that it should be bound to panic_on_oom=1 only until we
hear from somebody actually asking for a constrained oom and even then
do not allow for too large configuration space (e.g. no per-memcg
timeout) or have separate mempolicy vs. memcg timeouts.

Let's start simple and make things more complicated later!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
