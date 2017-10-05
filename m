Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25BA26B025E
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:27:54 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id o80so6615504lfg.6
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:27:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t9si8359662lja.339.2017.10.05.03.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 03:27:52 -0700 (PDT)
Date: Thu, 5 Oct 2017 11:27:07 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171005102707.GA12982@castle.dhcp.TheFacebook.com>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com>
 <20171004201524.GA4174@castle>
 <CALvZod45ObeQwq-pKeqyLe2bNwfKAr0majCbNfqPOEJL+AeiNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod45ObeQwq-pKeqyLe2bNwfKAr0majCbNfqPOEJL+AeiNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 04, 2017 at 02:24:26PM -0700, Shakeel Butt wrote:
> >> > +               if (memcg_has_children(iter))
> >> > +                       continue;
> >>
> >> && iter != root_mem_cgroup ?
> >
> > Oh, sure. I had a stupid bug in my test script, which prevented me from
> > catching this. Thanks!
> >
> > This should fix the problem.
> > --
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 2e82625bd354..b3848bce4c86 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2807,7 +2807,8 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> >                  * We don't consider non-leaf non-oom_group memory cgroups
> >                  * as OOM victims.
> >                  */
> > -               if (memcg_has_children(iter) && !mem_cgroup_oom_group(iter))
> > +               if (memcg_has_children(iter) && iter != root_mem_cgroup &&
> > +                   !mem_cgroup_oom_group(iter))
> >                         continue;
> 
> I think you are mixing the 3rd and 4th patch. The root_mem_cgroup
> check should be in 3rd while oom_group stuff should be in 4th.
>

Right. This "patch" should fix them both, it was just confusing to
send two patches. I'll split it before final landing.

> 
> >>
> >> Shouldn't there be a CSS_ONLINE check? Also instead of css_get at the
> >> end why not css_tryget_online() here and css_put for the previous
> >> selected one.
> >
> > Hm, why do we need to check this? I do not see, how we can choose
> > an OFFLINE memcg as a victim, tbh. Please, explain the problem.
> >
> 
> Sorry about the confusion. There are two things. First, should we do a
> css_get on the newly selected memcg within the for loop when we still
> have a reference to it?

We're holding rcu_read_lock, it should be enough. We're bumping css counter
just before releasing rcu lock.

> 
> Second, for the OFFLINE memcg, you are right oom_evaluate_memcg() will
> return 0 for offlined memcgs. Maybe no need to call
> oom_evaluate_memcg() for offlined memcgs.

Sounds like a good optimization, which can be done on top of the current
patchset.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
