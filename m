Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 93EB86B0070
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:00:03 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so40779550pdj.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:00:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rl7si6420650pab.173.2015.06.17.07.00.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 07:00:02 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
	<20150617121104.GD25056@dhcp22.suse.cz>
	<201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
	<20150617125127.GF25056@dhcp22.suse.cz>
In-Reply-To: <20150617125127.GF25056@dhcp22.suse.cz>
Message-Id: <201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jun 2015 22:59:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > +	if (sysctl_panic_on_oom_timeout) {
> > > +		if (sysctl_panic_on_oom > 1) {
> > > +			pr_warn("panic_on_oom_timeout is ignored for panic_on_oom=2\n");
> > > +		} else {
> > > +			/*
> > > +			 * Only schedule the delayed panic_on_oom when this is
> > > +			 * the first OOM triggered. oom_lock will protect us
> > > +			 * from races
> > > +			 */
> > > +			if (atomic_read(&oom_victims))
> > > +				return;
> > > +
> > > +			mod_timer(&panic_on_oom_timer,
> > > +					jiffies + (sysctl_panic_on_oom_timeout * HZ));
> > > +			return;
> > > +		}
> > > +	}
> > 
> > Since this version uses global panic_on_oom_timer, you cannot handle
> > OOM race like below.
> > 
> >   (1) p1 in memcg1 calls out_of_memory().
> >   (2) 5 seconds of timeout is started by p1.
> >   (3) p1 takes 3 seconds for some reason.
> >   (4) p2 in memcg2 calls out_of_memory().
> >   (5) p1 calls unmark_oom_victim() but timer continues.
> >   (6) p2 takes 2 seconds for some reason.
> >   (7) 5 seconds of timeout expires despite individual delay was less than
> >       5 seconds.
> 
> Yes it is not intended to handle such a race. Timeout is completely
> ignored for panic_on_oom=2 and contrained oom context doesn't trigger
> this path for panic_on_oom=1.
> 
Oops.

> But you have a point that we could have
> - constrained OOM which elevates oom_victims
> - global OOM killer strikes but wouldn't start the timer
> 
> This is certainly possible and timer_pending(&panic_on_oom) replacing
> oom_victims check should help here. I will think about this some more.

Yes, please.



> The important thing is to decide what is the reasonable way forward. We
> have two two implementations of panic based timeout. So we should decide
> - Should we add a panic timeout at all?
> - Should be the timeout bound to panic_on_oom?
> - Should we care about constrained OOM contexts?
> - If yes should they use the same timeout?
> - If no should each memcg be able to define its own timeout?
> 
Exactly.

> My thinking is that it should be bound to panic_on_oom=1 only until we
> hear from somebody actually asking for a constrained oom and even then
> do not allow for too large configuration space (e.g. no per-memcg
> timeout) or have separate mempolicy vs. memcg timeouts.
> 
My implementation comes from providing debugging hints when analyzing
vmcore of a stalled system. I'm posting logs of stalls after global OOM
killer struck because it is easy to reproduce. But what I have problem
is when a system stalled before the OOM killer strikes (I saw many cases
for customer's enterprise servers), for we don't have hints for guessing
whether memory allocator is the cause or not. Thus, my version tried to
emit warning messages using sysctl_memalloc_task_warn_secs .

Ability to take care of constrained OOM contexts is a side effect of use of
per a "struct task_struct" variable. Even if we come to a conclusion that
we should not add a timeout for panic, I hope that a timeout for warning
about memory allocation stalls is added.

> Let's start simple and make things more complicated later!

I think we mismatch about what the timeout counters are for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
