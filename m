Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 972206B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:29:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n8so7946512wmg.4
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:29:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q58si1834198edd.522.2017.10.31.08.29.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 08:29:25 -0700 (PDT)
Date: Tue, 31 Oct 2017 16:29:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND v12 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171031152923.ndyxpdmx3npyqoqf@dhcp22.suse.cz>
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

On Tue 31-10-17 08:04:19, Shakeel Butt wrote:
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

Yes, this is a real problem and the one which is not really solvable
without the charge migration. You simply have no clue _who_ owns the
memory so I assume that admins will need to setup the hierarchy which
allows subgroups to migrate tasks to be oom_group.

Or we might want to allow opt-in for charge migration in v2. To be
honest I wasn't completely happy about removing this functionality
altogether in v2 but there was a strong pushback back then that relying
on the charge migration doesn't have any sound usecase.

Anyway, I agree that documentation should be explicit about that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
