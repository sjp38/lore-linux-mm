Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 874BC6B006C
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 07:24:04 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id 10so5338780lbg.1
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:24:03 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yz5si38429393wjc.119.2014.12.23.04.24.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 04:24:02 -0800 (PST)
Date: Tue, 23 Dec 2014 13:24:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223122401.GC28549@dhcp22.suse.cz>
References: <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
 <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
 <20141222202511.GA9485@dhcp22.suse.cz>
 <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
 <20141223095159.GA28549@dhcp22.suse.cz>
 <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412232046.FHB81206.OVMOOSJHQFFFLt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 20:46:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > Also, why not to call set_tsk_thread_flag() and do_send_sig_info() together
> > > like below
> > 
> > What would be an advantage? I am not really sure whether the two locks
> > might nest as well.
> 
> I imagined that current thread sets TIF_MEMDIE on a victim thread, then
> sleeps for 30 seconds immediately after task_unlock() (it's an overdone
> delay),

Only if the current task was preempted for such a long time. Which
doesn't sound too probable to me.

> and finally sets SIGKILL on that victim thread. If such a delay
> happened, that victim thread is free to abuse TIF_MEMDIE for that period.
> Thus, I thought sending SIGKILL followed by setting TIF_MEMDIE is better.

I don't know, I can hardly find a scenario where it would make any
difference in the real life. If the victim needs to allocate a memory to
finish then it would trigger OOM again and have to wait/loop until this
OOM killer releases the oom zonelist lock just to find out it already
has TIF_MEMDIE set and can dive into memory reserves. Which way is more
correct is a question but I wouldn't change it without having a really
good reason. This whole code is subtle already, let's not make it even
more so.

> 
>  	rcu_read_unlock();
>  
> -	set_tsk_thread_flag(victim, TIF_MEMDIE);
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> +	task_lock(victim);
> +	if (victim->mm)
> +		set_tsk_thread_flag(victim, TIF_MEMDIE);
> +	task_unlock(victim);
>  	put_task_struct(victim);
> 
> If such a delay is theoretically impossible, I'm OK with your patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
