Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1026B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 13:50:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 4so10066679wrt.8
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 10:50:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 19sor930340wrz.54.2017.10.31.10.50.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 10:50:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031164008.GA32246@cmpxchg.org>
References: <20171019185218.12663-1-guro@fb.com> <20171019185218.12663-4-guro@fb.com>
 <CALvZod7V1iNACeDJuuSDrMMGMo7YX+gZ87gq=S4rP=Eh9Wh5kQ@mail.gmail.com> <20171031164008.GA32246@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 31 Oct 2017 10:50:43 -0700
Message-ID: <CALvZod5tVoX20Lir=4jnWMXzsEGhh1qCbi73j5vs_n6ViR80yw@mail.gmail.com>
Subject: Re: [RESEND v12 3/6] mm, oom: cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Oct 31, 2017 at 9:40 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Oct 31, 2017 at 08:04:19AM -0700, Shakeel Butt wrote:
>> > +
>> > +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>> > +{
>> > +       struct mem_cgroup *iter;
>> > +
>> > +       oc->chosen_memcg = NULL;
>> > +       oc->chosen_points = 0;
>> > +
>> > +       /*
>> > +        * The oom_score is calculated for leaf memory cgroups (including
>> > +        * the root memcg).
>> > +        */
>> > +       rcu_read_lock();
>> > +       for_each_mem_cgroup_tree(iter, root) {
>> > +               long score;
>> > +
>> > +               if (memcg_has_children(iter) && iter != root_mem_cgroup)
>> > +                       continue;
>> > +
>>
>> Cgroup v2 does not support charge migration between memcgs. So, there
>> can be intermediate nodes which may contain the major charge of the
>> processes in their leave descendents. Skipping such intermediate nodes
>> will kind of protect such processes from oom-killer (lower on the list
>> to be killed). Is it ok to not handle such scenario? If yes, shouldn't
>> we document it?
>
> Tasks cannot be in intermediate nodes, so the only way you can end up
> in a situation like this is to start tasks fully, let them fault in
> their full workingset, then create child groups and move them there.
>
> That has attribution problems much wider than the OOM killer: any
> local limits you would set on a leaf cgroup like this ALSO won't
> control the memory of its tasks - as it's all sitting in the parent.
>
> We created the "no internal competition" rule exactly to prevent this
> situation.

Rather than the "no internal competition" restriction I think "charge
migration" would have resolved that situation? Also "no internal
competition" restriction (I am assuming 'no internal competition' is
no tasks in internal nodes, please correct me if I am wrong) has made
"charge migration" hard to implement and thus not added in cgroup v2.

I know this is parallel discussion and excuse my ignorance, what are
other reasons behind "no internal competition" specifically for memory
controller?

> To be consistent with that rule, we might want to disallow
> the creation of child groups once a cgroup has local memory charges.
>
> It's trivial to change the setup sequence to create the leaf cgroup
> first, then launch the workload from within.
>

Only if cgroup hierarchy is centrally controller and each task's whole
hierarchy is known in advance.

> Either way, this is nothing specific about the OOM killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
