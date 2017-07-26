Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69B236B0292
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 10:06:39 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 77so868326wms.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 07:06:39 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v35si17765017wrb.15.2017.07.26.07.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 07:06:38 -0700 (PDT)
Date: Wed, 26 Jul 2017 15:06:07 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v4 1/4] mm, oom: refactor the TIF_MEMDIE usage
Message-ID: <20170726140607.GA20062@castle.DHCP.thefacebook.com>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-2-guro@fb.com>
 <20170726135622.GS2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170726135622.GS2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 26, 2017 at 03:56:22PM +0200, Michal Hocko wrote:
> On Wed 26-07-17 14:27:15, Roman Gushchin wrote:
> [...]
> > @@ -656,13 +658,24 @@ static void mark_oom_victim(struct task_struct *tsk)
> >  	struct mm_struct *mm = tsk->mm;
> >  
> >  	WARN_ON(oom_killer_disabled);
> > -	/* OOM killer might race with memcg OOM */
> > -	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > +
> > +	if (!cmpxchg(&tif_memdie_owner, NULL, current)) {
> > +		struct task_struct *t;
> > +
> > +		rcu_read_lock();
> > +		for_each_thread(current, t)
> > +			set_tsk_thread_flag(t, TIF_MEMDIE);
> > +		rcu_read_unlock();
> > +	}
> 
> I would realy much rather see we limit the amount of memory reserves oom
> victims can consume rather than build on top of the current hackish
> approach of limiting the number of tasks because the fundamental problem
> is still there (a heavy multithreaded process can still deplete the
> reserves completely).
> 
> Is there really any reason to not go with the existing patch I've
> pointed to the last time around? You didn't seem to have any objects
> back then.

Hi Michal!

I had this patch in mind and mentioned in the commit log, that TIF_MEMDIE
as an memory reserves access indicator will probably be eliminated later.

But that patch is not upstream yet, and it's directly related to the theme.
The proposed refactoring of TIF_MEMDIE usage is not against your approach,
and will not make harder to go this way further.

I'm slightly concerned about an idea to give TIF_MEMDIE to all tasks
in case we're killing a really large cgroup. But it's only a theoretical
concern, maybe it's fine.

So, I'd keep the existing approach for this patchset, and then we can follow
your approach and we will have a better test case for it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
