Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id B2B166B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 10:45:37 -0400 (EDT)
Received: by oiha141 with SMTP id a141so5179881oih.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 07:45:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s204si606513oia.32.2015.06.11.07.45.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Jun 2015 07:45:36 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
	<201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
	<20150610142801.GD4501@dhcp22.suse.cz>
	<201506112212.JAG26531.FLSVFMOQJOtOHF@I-love.SAKURA.ne.jp>
	<20150611141813.GA14088@dhcp22.suse.cz>
In-Reply-To: <20150611141813.GA14088@dhcp22.suse.cz>
Message-Id: <201506112345.HBE32188.LJMOOFtVHOFSQF@I-love.SAKURA.ne.jp>
Date: Thu, 11 Jun 2015 23:45:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 11-06-15 22:12:40, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > > The moom_work used by SysRq-f sometimes cannot be executed
> > > > because some work which is processed before the moom_work is processed is
> > > > stalled for unbounded amount of time due to looping inside the memory
> > > > allocator.
> > > 
> > > Wouldn't wq code pick up another worker thread to execute the work.
> > > There is also a rescuer thread as the last resort AFAIR.
> > > 
> > 
> > Below is an example of moom_work lockup in v4.1-rc7 from
> > http://I-love.SAKURA.ne.jp/tmp/serial-20150611.txt.xz
> > 
> > ----------
> > [  171.710406] sysrq: SysRq : Manual OOM execution
> > [  171.720193] kworker/2:9 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> > [  171.722699] kworker/2:9 cpuset=/ mems_allowed=0
> > [  171.724603] CPU: 2 PID: 11016 Comm: kworker/2:9 Not tainted 4.1.0-rc7 #3
> > [  171.726817] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > [  171.729727] Workqueue: events moom_callback
> > (...snipped...)
> > [  258.302016] sysrq: SysRq : Manual OOM execution
> 
> Wow, this is a _lot_. I was aware that workqueues might be overloaded.
> We have seen that in real loads and that led to
> http://marc.info/?l=linux-kernel&m=141456398425553 wher the rescuer
> didn't handle pending work properly. I thought that the fix helped in
> the end. But 1.5 minutes is indeed unexpected for me.

Excuse me, but you misunderstood the log. The logs for uptime = 171 and
uptime = 258 are cases where SysRq-f (indicated by "sysrq: SysRq : Manual
OOM execution" message) immediately invoked the OOM killer (indicated by
"invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0" message).

What you should check is uptime > 301. Until I do SysRq-b at uptime = 707,
the "sysrq: SysRq : Manual OOM execution" message is printed but the
"invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0" message is not
printed. During this period (so far 5 minutes, presumably forever),
moom_callback() remained pending.

> 
> This of course disqualifies DELAYED_WORK for anything that has at least
> reasonable time expectations which is the case here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
