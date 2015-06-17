Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE1B6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 11:42:07 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so40454923wgb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:42:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wu1si8599748wjc.31.2015.06.17.08.42.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 08:42:04 -0700 (PDT)
Date: Wed, 17 Jun 2015 17:41:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -v2] panic_on_oom_timeout
Message-ID: <20150617154159.GJ25056@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <20150617121104.GD25056@dhcp22.suse.cz>
 <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
 <20150617125127.GF25056@dhcp22.suse.cz>
 <201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 22:59:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > But you have a point that we could have
> > - constrained OOM which elevates oom_victims
> > - global OOM killer strikes but wouldn't start the timer
> > 
> > This is certainly possible and timer_pending(&panic_on_oom) replacing
> > oom_victims check should help here. I will think about this some more.
> 
> Yes, please.

Fixed in my local version. I will post the new version of the patch
after we settle with the approach.
 
> > The important thing is to decide what is the reasonable way forward. We
> > have two two implementations of panic based timeout. So we should decide
> > - Should we add a panic timeout at all?
> > - Should be the timeout bound to panic_on_oom?
> > - Should we care about constrained OOM contexts?
> > - If yes should they use the same timeout?
> > - If no should each memcg be able to define its own timeout?
> > 
> Exactly.
> 
> > My thinking is that it should be bound to panic_on_oom=1 only until we
> > hear from somebody actually asking for a constrained oom and even then
> > do not allow for too large configuration space (e.g. no per-memcg
> > timeout) or have separate mempolicy vs. memcg timeouts.
> 
> My implementation comes from providing debugging hints when analyzing
> vmcore of a stalled system. I'm posting logs of stalls after global OOM
> killer struck because it is easy to reproduce. But what I have problem
> is when a system stalled before the OOM killer strikes (I saw many cases
> for customer's enterprise servers), for we don't have hints for guessing
> whether memory allocator is the cause or not. Thus, my version tried to
> emit warning messages using sysctl_memalloc_task_warn_secs .

I can understand your frustration but I believe that a debugability is
a separate topic and we should start by defining a reasonable _policy_
so that an administrator has a way to handle potential OOM stalls
reasonably and with a well defined semantic.

> Ability to take care of constrained OOM contexts is a side effect of use of
> per a "struct task_struct" variable. Even if we come to a conclusion that
> we should not add a timeout for panic, I hope that a timeout for warning
> about memory allocation stalls is added.
> 
> > Let's start simple and make things more complicated later!
> 
> I think we mismatch about what the timeout counters are for.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
