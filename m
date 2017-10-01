Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD46F6B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 19:29:51 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id x64so6043214ywe.0
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 16:29:51 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g12sor375689ybd.68.2017.10.01.16.29.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Oct 2017 16:29:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
References: <20170925181533.GA15918@castle> <20170925202442.lmcmvqwy2jj2tr5h@dhcp22.suse.cz>
 <20170926105925.GA23139@castle.dhcp.TheFacebook.com> <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com> <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org> <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz> <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com> <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 1 Oct 2017 16:29:48 -0700
Message-ID: <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@hockin.org>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>
> Going back to Michal's example, say the user configured the following:
>
>        root
>       /    \
>      A      D
>     / \
>    B   C
>
> A global OOM event happens and we find this:
> - A > D
> - B, C, D are oomgroups
>
> What the user is telling us is that B, C, and D are compound memory
> consumers. They cannot be divided into their task parts from a memory
> point of view.
>
> However, the user doesn't say the same for A: the A subtree summarizes
> and controls aggregate consumption of B and C, but without groupoom
> set on A, the user says that A is in fact divisible into independent
> memory consumers B and C.
>
> If we don't have to kill all of A, but we'd have to kill all of D,
> does it make sense to compare the two?
>

I think Tim has given very clear explanation why comparing A & D makes
perfect sense. However I think the above example, a single user system
where a user has designed and created the whole hierarchy and then
attaches different jobs/applications to different nodes in this
hierarchy, is also a valid scenario. One solution I can think of, to
cater both scenarios, is to introduce a notion of 'bypass oom' or not
include a memcg for oom comparision and instead include its children
in the comparison.

So, in the same above example:
        root
       /       \
      A(b)    D
     /  \
    B   C

A is marked as bypass and thus B and C are to be compared to D. So,
for the single user scenario, all the internal nodes are marked
'bypass oom comparison' and oom_priority of the leaves has to be set
to the same value.

Below is the pseudo code of select_victim_memcg() based on this idea
and David's previous pseudo code. The calculation of size of a memcg
is still not very well baked here yet. I am working on it and I plan
to have a patch based on Roman's v9 "mm, oom: cgroup-aware OOM killer"
patch.


        struct mem_cgroup *memcg = root_mem_cgroup;
        struct mem_cgroup *selected_memcg = root_mem_cgroup;
        struct mem_cgroup *low_memcg;
        unsigned long low_priority;
        unsigned long prev_badness = memcg_oom_badness(memcg); // Roman's code
        LIST_HEAD(queue);

next_level:
        low_memcg = NULL;
        low_priority = ULONG_MAX;

next:
        for_each_child_of_memcg(it, memcg) {
                unsigned long prio = it->oom_priority;
                unsigned long badness = 0;

                if (it->bypass_oom && !it->oom_group &&
memcg_has_children(it)) {
                        list_add(&it->oom_queue, &queue);
                        continue;
                }

                if (prio > low_priority)
                        continue;

                if (prio == low_priority) {
                        badness = mem_cgroup_usage(it); // for
simplicity, need more thinking
                        if (badness < prev_badness)
                                continue;
                }

                low_memcg = it;
                low_priority = prio;
                prev_badness = badness ?: mem_cgroup_usage(it);  //
for simplicity
        }
        if (!list_empty(&queue)) {
                memcg = list_last_entry(&queue, struct mem_cgroup, oom_queue);
                list_del(&memcg->oom_queue);
                goto next;
        }
        if (low_memcg) {
                selected_memcg = memcg = low_memcg;
                prev_badness = 0;
                if (!low_memcg->oom_group)
                        goto next_level;
        }
        if (selected_memcg->oom_group)
                oom_kill_memcg(selected_memcg);
        else
                oom_kill_process_from_memcg(selected_memcg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
