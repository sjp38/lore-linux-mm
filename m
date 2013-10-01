Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3EB6B003B
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 11:27:37 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7285128pbc.2
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:27:36 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id eh20so6058143lab.32
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 08:27:33 -0700 (PDT)
Date: Tue, 1 Oct 2013 19:26:40 +0400
From: Sergey Dyasly <dserrg@gmail.com>
Subject: Re: [PATCH] OOM killer: wait for tasks with pending SIGKILL to exit
Message-Id: <20131001192640.ed55682d3113b00b402bbef5@gmail.com>
In-Reply-To: <alpine.DEB.2.02.1309301457590.28109@chino.kir.corp.google.com>
References: <1378740624-2456-1-git-send-email-dserrg@gmail.com>
	<alpine.DEB.2.02.1309091303010.12523@chino.kir.corp.google.com>
	<20130911190605.5528ee4563272dbea1ed56a6@gmail.com>
	<alpine.DEB.2.02.1309251328130.24412@chino.kir.corp.google.com>
	<20130927185833.6c72b77ab105d70d4996ebef@gmail.com>
	<alpine.DEB.2.02.1309301457590.28109@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Rusty Russell <rusty@rustcorp.com.au>, Sha Zhengju <handai.szj@taobao.com>, Oleg Nesterov <oleg@redhat.com>

It seems to me that we are going nowhere with this discussion...

If you are ok with the first change in my patch regarding fatal_signal_pending,
I can send new patch with just that change.


On Mon, 30 Sep 2013 15:08:25 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Fri, 27 Sep 2013, Sergey Dyasly wrote:
> 
> > What you are saying contradicts current OOMk code the way I read it. Comment in
> > oom_kill_process() says:
> > 
> > "If the task is already exiting ... set TIF_MEMDIE so it can die quickly"
> > 
> > I just want to know the right solution.
> > 
> 
> That's a comment, not code.  The point of the PF_EXITING special handling 
> in oom_kill_process() is to avoid telling sysadmins that a process has 
> been killed to free memory when it has already called exit() and to avoid 
> sacrificing one of its children for the exiting process.
> 
> It may or may not need access to memory reserves to actually exit after 
> PF_EXITING depending on whether it needs to allocate memory for 
> coredumping or anything else.  So instead of waiting for it to recall the 
> oom killer, TIF_MEMDIE is set anyway.  The point is that PF_EXITING 
> processes can already get TIF_MEMDIE immediately when their memory 
> allocation fails so there's no reason not to set it now as an 
> optimization.
> 
> But we definitely want to avoid printing anything to the kernel log when 
> the process has already called exit() and issuing the SIGKILL at that 
> point would be pointless.
> 
> > You are mistaken, oom_kill_process() is only called from out_of_memory()
> > and mem_cgroup_out_of_memory().
> > 
> 
> out_of_memory() calls oom_kill_process() in two places, plus the call from 
> mem_cgroup_out_of_memory(), making three calls in the tree.  Not that this 
> matters in the slightest, though.
> 
> > > Read the comment about why we don't emit anything to the kernel log in 
> > > this case; the process is already exiting, there's no need to kill it or 
> > > make anyone believe that it was killed.
> > 
> > Yes, but there is already the PF_EXITING check in oom_scan_process_thread(),
> > and in this case oom_kill_process() won't be even called. That's why it's
> > redundant.
> > 
> 
> You apparently have no idea how long select_bad_process() runs on a large 
> system with thousands of processes.  Keep in mind that SGI requested the 
> addition of the oom_kill_allocating_task sysctl specifically because of 
> how long select_bad_process() runs.  The PF_EXITING check in 
> oom_kill_process() is simply an optimization to return early and with 
> access to memory reserves so it can exit as quickly as possible and 
> without the kernel stating it's killing something that has already called 
> exit().


-- 
Sergey Dyasly <dserrg@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
