Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A39C06B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:04:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q127so7897773wmd.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:04:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c2sor764022wre.47.2017.10.31.08.04.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 08:04:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171019185218.12663-4-guro@fb.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019185218.12663-4-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 31 Oct 2017 08:04:19 -0700
Message-ID: <CALvZod7V1iNACeDJuuSDrMMGMo7YX+gZ87gq=S4rP=Eh9Wh5kQ@mail.gmail.com>
Subject: Re: [RESEND v12 3/6] mm, oom: cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

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
> +               if (memcg_has_children(iter) && iter != root_mem_cgroup)
> +                       continue;
> +

Cgroup v2 does not support charge migration between memcgs. So, there
can be intermediate nodes which may contain the major charge of the
processes in their leave descendents. Skipping such intermediate nodes
will kind of protect such processes from oom-killer (lower on the list
to be killed). Is it ok to not handle such scenario? If yes, shouldn't
we document it?

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
