Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 49E276B0009
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 07:19:16 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id z14so6663135igp.1
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:19:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b19si2590392igr.28.2016.01.30.04.19.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 30 Jan 2016 04:19:15 -0800 (PST)
Subject: Re: [PATCH 4/3] mm, oom: drop the last allocation attempt before out_of_memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454013603-3682-1-git-send-email-mhocko@kernel.org>
	<20160128213634.GA4903@cmpxchg.org>
	<alpine.DEB.2.10.1601281508380.31035@chino.kir.corp.google.com>
	<20160128235110.GA5805@cmpxchg.org>
	<20160129153250.GH32174@dhcp22.suse.cz>
In-Reply-To: <20160129153250.GH32174@dhcp22.suse.cz>
Message-Id: <201601302118.FIE60411.JVOFLtFFHOSQOM@I-love.SAKURA.ne.jp>
Date: Sat, 30 Jan 2016 21:18:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, hannes@cmpxchg.org
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > https://lkml.org/lkml/2015/3/25/40
> > 
> > We could have out_of_memory() wait until the number of outstanding OOM
> > victims drops to 0. Then __alloc_pages_may_oom() doesn't relinquish
> > the lock until its kill has been finalized:
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 914451a..4dc5b9d 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -892,7 +892,9 @@ bool out_of_memory(struct oom_control *oc)
> >  		 * Give the killed process a good chance to exit before trying
> >  		 * to allocate memory again.
> >  		 */
> > -		schedule_timeout_killable(1);
> > +		if (!test_thread_flag(TIF_MEMDIE))
> > +			wait_event_timeout(oom_victims_wait,
> > +					   !atomic_read(&oom_victims), HZ);
> >  	}
> >  	return true;
> >  }
> 
> Yes this makes sense to me

I think schedule_timeout_killable(1) was used for handling cases
where current thread did not get TIF_MEMDIE but got SIGKILL due to
sharing the victim's memory. If current thread is blocking TIF_MEMDIE
thread, this can become a needless delay.

Also, I don't know whether using wait_event_*() helps handling a
problem that schedule_timeout_killable(1) can sleep for many minutes
with oom_lock held when there are a lot of tasks. Detail is explained
in my proposed patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
