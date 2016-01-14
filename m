Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1FE6B025A
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:38:29 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so106073667pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:38:29 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id y78si5373968pfa.174.2016.01.13.16.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 16:38:28 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id n128so89739836pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 16:38:28 -0800 (PST)
Date: Wed, 13 Jan 2016 16:38:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <20160113093046.GA28942@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com> <20160113093046.GA28942@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed, 13 Jan 2016, Michal Hocko wrote:

> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index abefeeb42504..2b9dc5129a89 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -326,6 +326,17 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
> > >  		case OOM_SCAN_OK:
> > >  			break;
> > >  		};
> > > +
> > > +		/*
> > > +		 * If we are doing sysrq+f then it doesn't make any sense to
> > > +		 * check OOM victim or killed task because it might be stuck
> > > +		 * and unable to terminate while the forced OOM might be the
> > > +		 * only option left to get the system back to work.
> > > +		 */
> > > +		if (is_sysrq_oom(oc) && (test_tsk_thread_flag(p, TIF_MEMDIE) ||
> > > +				fatal_signal_pending(p)))
> > > +			continue;
> > > +
> > >  		points = oom_badness(p, NULL, oc->nodemask, totalpages);
> > >  		if (!points || points < chosen_points)
> > >  			continue;
> > 
> > I think you can make a case for testing TIF_MEMDIE here since there is no 
> > chance of a panic from the sysrq trigger.  However, I'm not convinced that 
> > checking fatal_signal_pending() is appropriate. 
> 
> My thinking was that such a process would get TIF_MEMDIE if it hits the
> OOM from the allocator.
> 

It certainly would get TIF_MEMDIE set if it needs to allocate memory 
itself and it calls the oom killer.  That doesn't mean that we should kill 
a different process, though, when the killed process should exit and free 
its memory.  So NACK to the fatal_signal_pending() check here.

> > I think it would be 
> > better for sysrq+f to first select a process with fatal_signal_pending() 
> > set so it silently gets access to memory reserves and then a second 
> > sysrq+f to choose a different process, if necessary, because of 
> > TIF_MEMDIE.
> 
> The disadvantage of this approach is that sysrq+f might silently be
> ignored and the administrator doesn't have any signal about that.

The administrator can check the kernel log for an oom kill.  Killing 
additional processes is not going to help and has never been the semantics 
of the sysrq trigger, it is quite clearly defined as killing a process 
when out of memory, not serial killing everything on the machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
