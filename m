Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id AD6086B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 11:38:31 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so77561159wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:38:31 -0700 (PDT)
Received: from mail-wi0-x244.google.com (mail-wi0-x244.google.com. [2a00:1450:400c:c05::244])
        by mx.google.com with ESMTPS id s2si1859779wjw.208.2015.06.11.08.38.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 08:38:30 -0700 (PDT)
Received: by wivr20 with SMTP id r20so3915543wiv.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 08:38:29 -0700 (PDT)
Date: Thu, 11 Jun 2015 17:38:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150611153826.GB14088@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
 <20150610142801.GD4501@dhcp22.suse.cz>
 <201506112212.JAG26531.FLSVFMOQJOtOHF@I-love.SAKURA.ne.jp>
 <20150611141813.GA14088@dhcp22.suse.cz>
 <201506112345.HBE32188.LJMOOFtVHOFSQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506112345.HBE32188.LJMOOFtVHOFSQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 11-06-15 23:45:26, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 11-06-15 22:12:40, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > [...]
> > > > > The moom_work used by SysRq-f sometimes cannot be executed
> > > > > because some work which is processed before the moom_work is processed is
> > > > > stalled for unbounded amount of time due to looping inside the memory
> > > > > allocator.
> > > > 
> > > > Wouldn't wq code pick up another worker thread to execute the work.
> > > > There is also a rescuer thread as the last resort AFAIR.
> > > > 
> > > 
> > > Below is an example of moom_work lockup in v4.1-rc7 from
> > > http://I-love.SAKURA.ne.jp/tmp/serial-20150611.txt.xz
> > > 
> > > ----------
> > > [  171.710406] sysrq: SysRq : Manual OOM execution
> > > [  171.720193] kworker/2:9 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> > > [  171.722699] kworker/2:9 cpuset=/ mems_allowed=0
> > > [  171.724603] CPU: 2 PID: 11016 Comm: kworker/2:9 Not tainted 4.1.0-rc7 #3
> > > [  171.726817] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> > > [  171.729727] Workqueue: events moom_callback
> > > (...snipped...)
> > > [  258.302016] sysrq: SysRq : Manual OOM execution
> > 
> > Wow, this is a _lot_. I was aware that workqueues might be overloaded.
> > We have seen that in real loads and that led to
> > http://marc.info/?l=linux-kernel&m=141456398425553 wher the rescuer
> > didn't handle pending work properly. I thought that the fix helped in
> > the end. But 1.5 minutes is indeed unexpected for me.
> 
> Excuse me, but you misunderstood the log.

Yes I've misread the log (I've interpreted (...) is the wait time and
haven't payed closer attention to what was the triggering and the invocation
part). Sorry about that.
[...]
> What you should check is uptime > 301. Until I do SysRq-b at uptime = 707,
> the "sysrq: SysRq : Manual OOM execution" message is printed but the
> "invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0" message is not
> printed. During this period (so far 5 minutes, presumably forever),
> moom_callback() remained pending.

OK, I can see it now. So this is even worse than a latency caused by
overloaded workqueues. A long lag would be a sufficient reason to
disqualify DELAYED_WORK already but this makes it no no completely.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
