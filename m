Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79FBF2802FE
	for <linux-mm@kvack.org>; Wed,  6 Sep 2017 08:35:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q68so12899927pgq.6
        for <linux-mm@kvack.org>; Wed, 06 Sep 2017 05:35:01 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a61si1164188pla.728.2017.09.06.05.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Sep 2017 05:35:00 -0700 (PDT)
Date: Wed, 6 Sep 2017 13:33:45 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170906123345.GA12904@castle>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
 <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
 <20170905202357.GA10535@castle.DHCP.thefacebook.com>
 <20170906083413.4nzwc27fk3bu2ye4@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170906083413.4nzwc27fk3bu2ye4@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 06, 2017 at 10:34:13AM +0200, Michal Hocko wrote:
> On Tue 05-09-17 21:23:57, Roman Gushchin wrote:
> > On Tue, Sep 05, 2017 at 04:57:00PM +0200, Michal Hocko wrote:
> [...]
> > > > @@ -810,6 +810,9 @@ static void __oom_kill_process(struct task_struct *victim)
> > > >  	struct mm_struct *mm;
> > > >  	bool can_oom_reap = true;
> > > >  
> > > > +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD))
> > > > +		return;
> > > > +
> > > 
> > > This will leak a reference to the victim AFACS
> > 
> > Good catch!
> > I didn't fix this after moving reference dropping into __oom_kill_process().
> > Fixed.
> 
> Btw. didn't you want to check
> victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN
> 
> here as well? Maybe I've missed something but you still can kill a task
> which is oom disabled which I thought we agreed is the wrong thing to
> do.

Added. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
