Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 465C6828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:18:38 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id u188so218625949wmu.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:18:38 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id t9si104064199wjf.169.2016.01.11.07.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 07:18:37 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id b14so273765138wmb.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:18:37 -0800 (PST)
Date: Mon, 11 Jan 2016 16:18:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Exclude TIF_MEMDIE processes from candidates.
Message-ID: <20160111151835.GH27317@dhcp22.suse.cz>
References: <201512292258.ABF87505.OFOSJLHMFVOQFt@I-love.SAKURA.ne.jp>
 <20160107091512.GB27868@dhcp22.suse.cz>
 <201601072231.DGG78695.OOFVLHJFFQOStM@I-love.SAKURA.ne.jp>
 <20160107145841.GN27868@dhcp22.suse.cz>
 <201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601080038.CIF04698.VFJHSOQLOFFMOt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 08-01-16 00:38:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > @@ -333,6 +333,14 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
> >  		if (points == chosen_points && thread_group_leader(chosen))
> >  			continue;
> >  
> > +		/*
> > +		 * If the current major task is already ooom killed and this
> > +		 * is sysrq+f request then we rather choose somebody else
> > +		 * because the current oom victim might be stuck.
> > +		 */
> > +		if (is_sysrq_oom(sc) && test_tsk_thread_flag(p, TIF_MEMDIE))
> > +			continue;
> > +
> >  		chosen = p;
> >  		chosen_points = points;
> >  	}
> 
> Do we want to require SysRq-f for each thread in a process?
> If g has 1024 p, dump_tasks() will do
> 
>   pr_info("[%5d] %5d %5d %8lu %8lu %7ld %7ld %8lu         %5hd %s\n",
> 
> for 1024 times? I think one SysRq-f per one process is sufficient.

I am not following you here. If we kill the process the whole process
group (aka all threads) will get killed which ever thread we happen to
send the sigkill to.
 
> How can we guarantee that find_lock_task_mm() from oom_kill_process()
> chooses !TIF_MEMDIE thread when try_to_sacrifice_child() somehow chose
> !TIF_MEMDIE thread? I think choosing !TIF_MEMDIE thread at
> find_lock_task_mm() is the simplest way.

find_lock_task_mm chosing TIF_MEMDIE thread shouldn't change anything
because the whole thread group will go down anyway. If you want to
guarantee that the sysrq+f never choses a task which has a TIF_MEMDIE
thread then we would have to check for fatal_signal_pending as well
AFAIU. Fiddling with find find_lock_task_mm will not help you though
unless I am missing something.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
