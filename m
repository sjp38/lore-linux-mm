Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 88AF76B025E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 09:00:43 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id n5so120378527pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 06:00:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x2si6324623pfa.33.2016.03.17.06.00.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 06:00:40 -0700 (PDT)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160315114300.GC6108@dhcp22.suse.cz>
	<20160315115001.GE6108@dhcp22.suse.cz>
	<201603162016.EBJ05275.VHMFSOLJOFQtOF@I-love.SAKURA.ne.jp>
	<201603171949.FHE57319.SMFFtJOHOVOFLQ@I-love.SAKURA.ne.jp>
	<20160317121751.GE26017@dhcp22.suse.cz>
In-Reply-To: <20160317121751.GE26017@dhcp22.suse.cz>
Message-Id: <201603172200.CIE52148.QOVSOHJFMLOFtF@I-love.SAKURA.ne.jp>
Date: Thu, 17 Mar 2016 22:00:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Thu 17-03-16 19:49:01, Tetsuo Handa wrote:
> [...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 2199c71..affbb79 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -502,8 +502,26 @@ static void oom_reap_vmas(struct mm_struct *mm)
> >  		schedule_timeout_idle(HZ/10);
> >  
> >  	if (attempts > MAX_OOM_REAP_RETRIES) {
> > +		struct task_struct *p;
> > +		struct task_struct *t;
> > +
> >  		pr_info("oom_reaper: unable to reap memory\n");
> > -		debug_show_all_locks();
> > +		rcu_read_lock();
> > +		for_each_process_thread(p, t) {
> > +			if (likely(t->mm != mm))
> > +				continue;
> > +			pr_info("oom_reaper: %s(%u) flags=0x%x%s%s%s%s\n",
> > +				t->comm, t->pid, t->flags,
> > +				(t->state & TASK_UNINTERRUPTIBLE) ?
> > +				" uninterruptible" : "",
> > +				(t->flags & PF_EXITING) ? " exiting" : "",
> > +				fatal_signal_pending(t) ? " dying" : "",
> > +				test_tsk_thread_flag(t, TIF_MEMDIE) ?
> > +				" victim" : "");
> > +			sched_show_task(t);
> > +			debug_show_held_locks(t);
> > +		}
> > +		rcu_read_unlock();
> 
> Isn't this way too much work for a single RCU lock? Also wouldn't it
> generate way too much output in the pathological situations a so hide
> other potentially more important log messages?
> 
I don't think we can compare it. It is possible that 50 out of 10000
threads' traces and locks are reported with this change, but it is also
possible that 10000 threads' locks are reported without this change.

If you worry about too much work for a single RCU, you can do like
what kmallocwd does. kmallocwd adds a marker to task_struct so that
kmallocwd can reliably resume reporting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
