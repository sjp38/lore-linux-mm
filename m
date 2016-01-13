Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id DD6A9828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 11:56:51 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u188so306259261wmu.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 08:56:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uw9si3234479wjc.111.2016.01.13.08.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 08:56:50 -0800 (PST)
Date: Wed, 13 Jan 2016 11:56:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
Message-ID: <20160113165609.GA21950@cmpxchg.org>
References: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
 <201601132111.GIG81705.LFOOHFOtQJSMVF@I-love.SAKURA.ne.jp>
 <20160113162610.GD17512@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160113162610.GD17512@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 13, 2016 at 05:26:10PM +0100, Michal Hocko wrote:
> On Wed 13-01-16 21:11:30, Tetsuo Handa wrote:
> [...]
> > Those who use panic_on_oom = 1 expect that the system triggers kernel panic
> > rather than stall forever. This is a translation of administrator's wish that
> > "Please press SysRq-c on behalf of me if the memory exhausted. In that way,
> > I don't need to stand by in front of the console twenty-four seven."
> > 
> > Those who use panic_on_oom = 0 expect that the OOM killer solves OOM condition
> > rather than stall forever. This is a translation of administrator's wish that
> > "Please press SysRq-f on behalf of me if the memory exhausted. In that way,
> > I don't need to stand by in front of the console twenty-four seven."
> 
> I think you are missing an important point. There is _no reliable_ way
> to resolve the OOM condition in general except to panic the system. Even
> killing all user space tasks might not be sufficient in general because
> they might be blocked by an unkillable context (e.g. kernel thread).
> So if you need a reliable behavior then either use panic_on_oom=1 or
> provide a measure to panic after fixed timeout if the OOM cannot get
> resolved. We have seen patches in that regards but there was no general
> interest in them to merge them.

While what you're saying about there not being a failsafe way is true,
I don't understand why we should panic the machine before we tried to
kill every single userspace task. That's what I never understood about
your timeout-panic patches: if the OOM victim doesn't exit in a fixed
amount of time, why is it better to panic the machine than to try the
second-best, third-best, fourth-best etc. OOM candidates?

Yes, you can say that at least the kernel will make a decision in a
fixed amount of time and it'll be more useful in practice. But the
reality of most scenarios is that moving on to other victims will
increase the chance of success dramatically while the chance of
continued hanging would converge toward 0.

And for the more extreme scenarios, where you have a million tasks all
blocked on the same resource, we can decay the timeout exponentially
to cap the decision time to a reasonable worst case; wait 8s for the
first victim, 4s for the next one etc. and the machine will still
recover or panic within 15s after the deadlock first occurs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
