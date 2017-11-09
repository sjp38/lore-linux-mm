Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D5633440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 06:27:26 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id n37so2965985wrb.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 03:27:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si5392389edi.539.2017.11.09.03.27.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 03:27:25 -0800 (PST)
Date: Thu, 9 Nov 2017 12:27:23 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 5/5] nommu,oom: Set MMF_OOM_SKIP without waiting for
 termination.
Message-ID: <20171109112723.b4jg3naw7enb6g5w@dhcp22.suse.cz>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1510138908-6265-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171108162427.3hstwbagywwjrh44@dhcp22.suse.cz>
 <201711091949.BDB73475.OSHFOMQtLFOFVJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711091949.BDB73475.OSHFOMQtLFOFVJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@techsingularity.net

On Thu 09-11-17 19:49:16, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 08-11-17 20:01:48, Tetsuo Handa wrote:
> > > Commit 212925802454672e ("mm: oom: let oom_reap_task and exit_mmap run
> > > concurrently") moved the location of setting MMF_OOM_SKIP from __mmput()
> > > in kernel/fork.c (which is used by both MMU and !MMU) to exit_mm() in
> > > mm/mmap.c (which is used by MMU only). As a result, that commit required
> > > OOM victims in !MMU kernels to disappear from the task list in order to
> > > reenable the OOM killer, for !MMU kernels can no longer set MMF_OOM_SKIP
> > > (unless the OOM victim's mm is shared with global init process).
> > 
> > nack withtout demonstrating that the problem is real. It is true it
> > removes some lines but this is mostly this...
> 
> Then, it is impossible unless somebody volunteers proving it.
> I'm not a nommu kernel user.

Do not convolute the code for a non-existent problem. Full stop.
 
[...]
> > On Wed 08-11-17 20:01:48, Tetsuo Handa wrote:
> > [...]
> > > @@ -829,7 +831,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > >  	unsigned int victim_points = 0;
> > >  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> > >  					      DEFAULT_RATELIMIT_BURST);
> > > -	bool can_oom_reap = true;
> > > +	bool can_oom_reap = IS_ENABLED(CONFIG_MMU);
> > >  
> > >  	/*
> > >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> > > @@ -929,7 +931,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > >  			continue;
> > >  		if (is_global_init(p)) {
> > >  			can_oom_reap = false;
> > > -			set_bit(MMF_OOM_SKIP, &mm->flags);
> > >  			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
> > >  					task_pid_nr(victim), victim->comm,
> > >  					task_pid_nr(p), p->comm);
> > > @@ -947,6 +948,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > >  
> > >  	if (can_oom_reap)
> > >  		wake_oom_reaper(victim);
> > > +	else
> > > +		set_bit(MMF_OOM_SKIP, &mm->flags);
> > >  
> > >  	mmdrop(mm);
> > >  	put_task_struct(victim);
> > 
> > Also this looks completely broken. nommu kernels lose the premature oom
> > killing protection almost completely (they simply rely on the sleep
> > before dropping the oom_lock).
> > 
> 
> If you are worrying that setting MMF_OOM_SKIP immediately might cause
> premature OOM killing), what we would afford is timeout-based approach
> shown below, for it will be a waste of resource to add the OOM reaper kernel
> thread which does nothing but setting MMF_OOM_SKIP.

No! See above
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
