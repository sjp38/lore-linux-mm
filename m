Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C7A1D6B0253
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:40:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id v127so19237wma.3
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:40:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p35si1275383edd.510.2017.10.31.09.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 31 Oct 2017 09:40:18 -0700 (PDT)
Date: Tue, 31 Oct 2017 12:40:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RESEND v12 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171031164008.GA32246@cmpxchg.org>
References: <20171019185218.12663-1-guro@fb.com>
 <20171019185218.12663-4-guro@fb.com>
 <CALvZod7V1iNACeDJuuSDrMMGMo7YX+gZ87gq=S4rP=Eh9Wh5kQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7V1iNACeDJuuSDrMMGMo7YX+gZ87gq=S4rP=Eh9Wh5kQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 31, 2017 at 08:04:19AM -0700, Shakeel Butt wrote:
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
> > +               if (memcg_has_children(iter) && iter != root_mem_cgroup)
> > +                       continue;
> > +
> 
> Cgroup v2 does not support charge migration between memcgs. So, there
> can be intermediate nodes which may contain the major charge of the
> processes in their leave descendents. Skipping such intermediate nodes
> will kind of protect such processes from oom-killer (lower on the list
> to be killed). Is it ok to not handle such scenario? If yes, shouldn't
> we document it?

Tasks cannot be in intermediate nodes, so the only way you can end up
in a situation like this is to start tasks fully, let them fault in
their full workingset, then create child groups and move them there.

That has attribution problems much wider than the OOM killer: any
local limits you would set on a leaf cgroup like this ALSO won't
control the memory of its tasks - as it's all sitting in the parent.

We created the "no internal competition" rule exactly to prevent this
situation. To be consistent with that rule, we might want to disallow
the creation of child groups once a cgroup has local memory charges.

It's trivial to change the setup sequence to create the leaf cgroup
first, then launch the workload from within.

Either way, this is nothing specific about the OOM killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
