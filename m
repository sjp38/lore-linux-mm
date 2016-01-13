Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCA1828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 04:30:49 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id f206so361604873wmf.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:30:49 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id i7si2896259wmf.59.2016.01.13.01.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 01:30:48 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id b14so361643912wmb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 01:30:48 -0800 (PST)
Date: Wed, 13 Jan 2016 10:30:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160113093046.GA28942@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Tue 12-01-16 16:41:50, David Rientjes wrote:
> On Tue, 12 Jan 2016, Michal Hocko wrote:
> 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index abefeeb42504..2b9dc5129a89 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -326,6 +326,17 @@ static struct task_struct *select_bad_process(struct oom_control *oc,
> >  		case OOM_SCAN_OK:
> >  			break;
> >  		};
> > +
> > +		/*
> > +		 * If we are doing sysrq+f then it doesn't make any sense to
> > +		 * check OOM victim or killed task because it might be stuck
> > +		 * and unable to terminate while the forced OOM might be the
> > +		 * only option left to get the system back to work.
> > +		 */
> > +		if (is_sysrq_oom(oc) && (test_tsk_thread_flag(p, TIF_MEMDIE) ||
> > +				fatal_signal_pending(p)))
> > +			continue;
> > +
> >  		points = oom_badness(p, NULL, oc->nodemask, totalpages);
> >  		if (!points || points < chosen_points)
> >  			continue;
> 
> I think you can make a case for testing TIF_MEMDIE here since there is no 
> chance of a panic from the sysrq trigger.  However, I'm not convinced that 
> checking fatal_signal_pending() is appropriate. 

My thinking was that such a process would get TIF_MEMDIE if it hits the
OOM from the allocator.

> I think it would be 
> better for sysrq+f to first select a process with fatal_signal_pending() 
> set so it silently gets access to memory reserves and then a second 
> sysrq+f to choose a different process, if necessary, because of 
> TIF_MEMDIE.

The disadvantage of this approach is that sysrq+f might silently be
ignored and the administrator doesn't have any signal about that. IMHO
sysrq+f would be much better defined if it _always_ selected and killed
a task. After all it is an explicit administrator action.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
