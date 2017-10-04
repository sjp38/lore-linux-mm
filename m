Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B093E6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 15:48:05 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w63so14459039qkd.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 12:48:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o4sor775788ybm.180.2017.10.04.12.48.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 12:48:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171004154638.710-4-guro@fb.com>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-4-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 4 Oct 2017 12:48:03 -0700
Message-ID: <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

> +
> +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> +{
> +       struct mem_cgroup *iter;
> +
> +       oc->chosen_memcg = NULL;
> +       oc->chosen_points = 0;
> +
> +       /*
> +        * The oom_score is calculated for leaf memory cgroups (including
> +        * the root memcg).
> +        */
> +       rcu_read_lock();
> +       for_each_mem_cgroup_tree(iter, root) {
> +               long score;
> +
> +               if (memcg_has_children(iter))
> +                       continue;

&& iter != root_mem_cgroup ?

> +
> +               score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);
> +
> +               /*
> +                * Ignore empty and non-eligible memory cgroups.
> +                */
> +               if (score == 0)
> +                       continue;
> +
> +               /*
> +                * If there are inflight OOM victims, we don't need
> +                * to look further for new victims.
> +                */
> +               if (score == -1) {
> +                       oc->chosen_memcg = INFLIGHT_VICTIM;
> +                       mem_cgroup_iter_break(root, iter);
> +                       break;
> +               }
> +

Shouldn't there be a CSS_ONLINE check? Also instead of css_get at the
end why not css_tryget_online() here and css_put for the previous
selected one.

> +               if (score > oc->chosen_points) {
> +                       oc->chosen_points = score;
> +                       oc->chosen_memcg = iter;
> +               }
> +       }
> +
> +       if (oc->chosen_memcg && oc->chosen_memcg != INFLIGHT_VICTIM)
> +               css_get(&oc->chosen_memcg->css);
> +
> +       rcu_read_unlock();
> +}
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
