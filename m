Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB0736B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:15:55 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so11543190wmu.2
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:15:55 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 94si8585201edi.394.2017.10.04.13.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 13:15:54 -0700 (PDT)
Date: Wed, 4 Oct 2017 21:15:24 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171004201524.GA4174@castle>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 04, 2017 at 12:48:03PM -0700, Shakeel Butt wrote:
> > +
> > +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> > +{
> > +       struct mem_cgroup *iter;
> > +
> > +       oc->chosen_memcg = NULL;
> > +       oc->chosen_points = 0;
> > +
> > +       /*
> > +        * The oom_score is calculated for leaf memory cgroups (including
> > +        * the root memcg).
> > +        */
> > +       rcu_read_lock();
> > +       for_each_mem_cgroup_tree(iter, root) {
> > +               long score;
> > +
> > +               if (memcg_has_children(iter))
> > +                       continue;
> 
> && iter != root_mem_cgroup ?

Oh, sure. I had a stupid bug in my test script, which prevented me from
catching this. Thanks!

This should fix the problem.
--
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2e82625bd354..b3848bce4c86 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2807,7 +2807,8 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 		 * We don't consider non-leaf non-oom_group memory cgroups
 		 * as OOM victims.
 		 */
-		if (memcg_has_children(iter) && !mem_cgroup_oom_group(iter))
+		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
+		    !mem_cgroup_oom_group(iter))
 			continue;
 
 		/*
@@ -2820,7 +2821,7 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
 			group_score = 0;
 		}
 
-		if (memcg_has_children(iter))
+		if (memcg_has_children(iter) && iter != root_mem_cgroup)
 			continue;
 
 		score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);

--

> 
> > +
> > +               score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);
> > +
> > +               /*
> > +                * Ignore empty and non-eligible memory cgroups.
> > +                */
> > +               if (score == 0)
> > +                       continue;
> > +
> > +               /*
> > +                * If there are inflight OOM victims, we don't need
> > +                * to look further for new victims.
> > +                */
> > +               if (score == -1) {
> > +                       oc->chosen_memcg = INFLIGHT_VICTIM;
> > +                       mem_cgroup_iter_break(root, iter);
> > +                       break;
> > +               }
> > +
> 
> Shouldn't there be a CSS_ONLINE check? Also instead of css_get at the
> end why not css_tryget_online() here and css_put for the previous
> selected one.

Hm, why do we need to check this? I do not see, how we can choose
an OFFLINE memcg as a victim, tbh. Please, explain the problem.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
