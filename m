Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 0B45B6B0032
	for <linux-mm@kvack.org>; Sat, 21 Feb 2015 06:52:52 -0500 (EST)
Received: by pdev10 with SMTP id v10so13731690pde.10
        for <linux-mm@kvack.org>; Sat, 21 Feb 2015 03:52:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pf2si4159091pdb.161.2015.02.21.03.52.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 21 Feb 2015 03:52:50 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150217225430.GJ4251@dastard>
	<20150219102431.GA15569@phnom.home.cmpxchg.org>
	<20150219225217.GY12722@dastard>
	<201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
	<20150220231511.GH12722@dastard>
In-Reply-To: <20150220231511.GH12722@dastard>
Message-Id: <201502212012.BJJ39083.LQFOtJFSHMVOFO@I-love.SAKURA.ne.jp>
Date: Sat, 21 Feb 2015 20:12:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

My main issue is

  c) whether to oom-kill more processes when the OOM victim cannot be
     terminated presumably due to the OOM killer deadlock.

Dave Chinner wrote:
> On Fri, Feb 20, 2015 at 07:36:33PM +0900, Tetsuo Handa wrote:
> > Dave Chinner wrote:
> > > I really don't care about the OOM Killer corner cases - it's
> > > completely the wrong way line of development to be spending time on
> > > and you aren't going to convince me otherwise. The OOM killer a
> > > crutch used to justify having a memory allocation subsystem that
> > > can't provide forward progress guarantee mechanisms to callers that
> > > need it.
> > 
> > I really care about the OOM Killer corner cases, for I'm
> > 
> >   (1) seeing trouble cases which occurred in enterprise systems
> >       under OOM conditions
> 
> You reach OOM, then your SLAs are dead and buried. Reboot the
> box - its a much more reliable way of returning to a working system
> than playing Russian Roulette with the OOM killer.

What Service Level Agreements? Such troubles are occurring on RHEL systems
where users are not sitting in front of the console. Unless somebody is
sitting in front of the console in order to do SysRq-b when troubles
occur, the down time of system will become significantly longer.

What mechanisms are available for minimizing the down time of system
when troubles under OOM condition occur? Software/hardware watchdog?
Indeed they may help, but they may be triggered prematurely when the
system has not entered into the OOM condition. Only the OOM killer knows.

> 
> >   (2) trying to downgrade OOM "Deadlock or Genocide" attacks (which
> >       an unprivileged user with a login shell can trivially trigger
> >       since Linux 2.0) to OOM "Genocide" attacks in order to allow
> >       OOM-unkillable daemons to restart OOM-killed processes
> > 
> >   (3) waiting for a bandaid for (2) in order to propose changes for
> >       mitigating OOM "Genocide" attacks (as bad guys will find how to
> >       trigger OOM "Deadlock or Genocide" attacks from changes for
> >       mitigating OOM "Genocide" attacks)
> 
> Which is yet another indication that the OOM killer is the wrong
> solution to the "lack of forward progress" problem. Any one can
> generate enough memory pressure to trigger the OOM killer; we can't
> prevent that from occurring when the OOM killer can be invoked by
> user processes.
> 

We have memory cgroups to reduce the possibility of triggering the OOM
killer, though there will be several bugs remaining in RHEL kernels
which make administrators hesitate to use memory cgroups.

> > I started posting to linux-mm ML in order to make forward progress
> > about (1) and (2). I don't want the memory allocation subsystem to
> > lock up an entire system by indefinitely disabling memory releasing
> > mechanism provided by the OOM killer.
> > 
> > > I've proposed a method of providing this forward progress guarantee
> > > for subsystems of arbitrary complexity, and this removes the
> > > dependency on the OOM killer for fowards allocation progress in such
> > > contexts (e.g. filesystems). We should be discussing how to
> > > implement that, not what bandaids we need to apply to the OOM
> > > killer. I want to fix the underlying problems, not push them under
> > > the OOM-killer bus...
> > 
> > I'm fine with that direction for new kernels provided that a simple
> > bandaid which can be backported to distributor kernels for making
> > OOM "Deadlock" attacks impossible is implemented. Therefore, I'm
> > discussing what bandaids we need to apply to the OOM killer.
> 
> The band-aids being proposed are worse than the problem they are
> intended to cover up. In which case, the band-aids should not be
> applied.
> 

The problem is simple. /proc/sys/vm/panic_on_oom == 0 setting does not
help if the OOM killer failed to determine correct task to kill + allow
access to memory reserves. The OOM killer is waiting forever under
the OOM deadlock condition than triggering kernel panic.

https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_MRG/2/html/Realtime_Tuning_Guide/sect-Realtime_Tuning_Guide-General_System_Tuning-Swapping_and_Out_Of_Memory_Tips.html
says that "Usually, oom_killer can kill rogue processes and the system
will survive." but says nothing about what to do when we hit the OOM
killer deadlock condition.

My band-aids allows the OOM killer to trigger kernel panic (followed
by optionally kdump and automatic reboot) for people who want to reboot
the box when default /proc/sys/vm/panic_on_oom == 0 setting failed to
kill rogue processes, and allows people who want the system to survive
when the OOM killer failed to determine correct task to kill + allow
access to memory reserves.

Not only we cannot expect that the OOM killer messages being saved to
/var/log/messages under the OOM killer deadlock condition, but also
we do not emit the OOM killer messages if we hit

    void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
                          unsigned int points, unsigned long totalpages,
                          struct mem_cgroup *memcg, nodemask_t *nodemask,
                          const char *message)
    {
            struct task_struct *victim = p;
            struct task_struct *child;
            struct task_struct *t;
            struct mm_struct *mm;
            unsigned int victim_points = 0;
            static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
                                                  DEFAULT_RATELIMIT_BURST);
    
            /*
             * If the task is already exiting, don't alarm the sysadmin or kill
             * its children or threads, just set TIF_MEMDIE so it can die quickly
             */
            if (task_will_free_mem(p)) { /***** _THIS_ _CONDITION_ *****/
                    set_tsk_thread_flag(p, TIF_MEMDIE);
                    put_task_struct(p);
                    return;
            }
    
            if (__ratelimit(&oom_rs))
                    dump_header(p, gfp_mask, order, memcg, nodemask);
    
            task_lock(p);
            pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
                    message, task_pid_nr(p), p->comm, points);
            task_unlock(p);

followed by entering into the OOM killer deadlock condition. This is
annoying for me because neither serial console nor netconsole helps
finding out that the system entered into the OOM condition.

If you want to stop people from playing Russian Roulette with the OOM
killer, please remove the OOM killer code entirely from RHEL kernels so that
people must use their systems with hardcoded /proc/sys/vm/panic_on_oom == 1
setting. Can you do it?

> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> david@fromorbit.com
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
