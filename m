Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CAAD66B0292
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 19:24:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 16so49393225pgg.8
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:24:35 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id k15si1708433pln.412.2017.08.08.16.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 16:24:34 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id o86so20379435pfj.1
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 16:24:34 -0700 (PDT)
Date: Tue, 8 Aug 2017 16:24:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v4 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
In-Reply-To: <20170726132718.14806-5-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708081615110.54505@chino.kir.corp.google.com>
References: <20170726132718.14806-1-guro@fb.com> <20170726132718.14806-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 26 Jul 2017, Roman Gushchin wrote:

> +Cgroup-aware OOM Killer
> +~~~~~~~~~~~~~~~~~~~~~~~
> +
> +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> +It means that it treats memory cgroups as first class OOM entities.
> +
> +Under OOM conditions the memory controller tries to make the best
> +choise of a victim, hierarchically looking for the largest memory
> +consumer. By default, it will look for the biggest task in the
> +biggest leaf cgroup.
> +
> +Be default, all cgroups have oom_priority 0, and OOM killer will
> +chose the largest cgroup recursively on each level. For non-root
> +cgroups it's possible to change the oom_priority, and it will cause
> +the OOM killer to look athe the priority value first, and compare
> +sizes only of cgroups with equal priority.
> +
> +But a user can change this behavior by enabling the per-cgroup
> +oom_kill_all_tasks option. If set, it causes the OOM killer treat
> +the whole cgroup as an indivisible memory consumer. In case if it's
> +selected as on OOM victim, all belonging tasks will be killed.
> +
> +Tasks in the root cgroup are treated as independent memory consumers,
> +and are compared with other memory consumers (e.g. leaf cgroups).
> +The root cgroup doesn't support the oom_kill_all_tasks feature.
> +
> +This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
> +the memory controller considers only cgroups belonging to the sub-tree
> +of the OOM'ing cgroup.
> +
>  IO
>  --

Thanks very much for following through with this.

As described in http://marc.info/?l=linux-kernel&m=149980660611610 this is 
very similar to what we do for priority based oom killing.

I'm wondering your comments on extending it one step further, however: 
include process priority as part of the selection rather than simply memcg 
priority.

memory.oom_priority will dictate which memcg the kill will originate from, 
but processes have no ability to specify that they should actually be 
killed as opposed to a leaf memcg.  I'm not sure how important this is for 
your usecase, but we have found it useful to be able to specify process 
priority as part of the decisionmaking.

At each level of consideration, we simply kill a process with lower 
/proc/pid/oom_priority if there are no memcgs with a lower 
memory.oom_priority.  This allows us to define the exact process that will 
be oom killed, absent oom_kill_all_tasks, and not require that the process 
be attached to leaf memcg.  Most notably these are processes that are best 
effort: stats collection, logging, etc.

Do you think it would be helpful to introduce per-process oom priority as 
well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
