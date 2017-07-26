Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6796B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:24:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c184so16108667wmd.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:24:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 197si3985713wma.113.2017.07.26.07.24.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 07:24:38 -0700 (PDT)
Date: Wed, 26 Jul 2017 16:24:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Message-ID: <20170726142434.GT2981@dhcp22.suse.cz>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-2-guro@fb.com>
 <20170726135622.GS2981@dhcp22.suse.cz>
 <20170726140607.GA20062@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726140607.GA20062@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-07-17 15:06:07, Roman Gushchin wrote:
> On Wed, Jul 26, 2017 at 03:56:22PM +0200, Michal Hocko wrote:
> > On Wed 26-07-17 14:27:15, Roman Gushchin wrote:
> > [...]
> > > @@ -656,13 +658,24 @@ static void mark_oom_victim(struct task_struct *tsk)
> > >  	struct mm_struct *mm = tsk->mm;
> > >  
> > >  	WARN_ON(oom_killer_disabled);
> > > -	/* OOM killer might race with memcg OOM */
> > > -	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > +
> > > +	if (!cmpxchg(&tif_memdie_owner, NULL, current)) {
> > > +		struct task_struct *t;
> > > +
> > > +		rcu_read_lock();
> > > +		for_each_thread(current, t)
> > > +			set_tsk_thread_flag(t, TIF_MEMDIE);
> > > +		rcu_read_unlock();
> > > +	}
> > 
> > I would realy much rather see we limit the amount of memory reserves oom
> > victims can consume rather than build on top of the current hackish
> > approach of limiting the number of tasks because the fundamental problem
> > is still there (a heavy multithreaded process can still deplete the
> > reserves completely).
> > 
> > Is there really any reason to not go with the existing patch I've
> > pointed to the last time around? You didn't seem to have any objects
> > back then.
> 
> Hi Michal!
> 
> I had this patch in mind and mentioned in the commit log, that TIF_MEMDIE
> as an memory reserves access indicator will probably be eliminated later.
> 
> But that patch is not upstream yet, and it's directly related to the theme.
> The proposed refactoring of TIF_MEMDIE usage is not against your approach,
> and will not make harder to go this way further.

So what is the reason to invent another tricky way to limit access to
memory reserves? The patch is not upstream but nothin prevents you from
picking it up and post along with your series. Or if you prefer I can
post it separately?

> I'm slightly concerned about an idea to give TIF_MEMDIE to all tasks
> in case we're killing a really large cgroup.

Why? There shouldn't be any issue if the access is limited.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
