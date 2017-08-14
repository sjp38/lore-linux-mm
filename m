Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3A66B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:52:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s14so158886719pgs.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:52:29 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id 2si4623891pgb.364.2017.08.14.15.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 15:52:28 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id l64so55768998pge.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:52:28 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:52:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
In-Reply-To: <20170814183213.12319-5-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708141544280.63207@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 Aug 2017, Roman Gushchin wrote:

> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index dec5afdaa36d..22108f31e09d 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -48,6 +48,7 @@ v1 is available under Documentation/cgroup-v1/.
>         5-2-1. Memory Interface Files
>         5-2-2. Usage Guidelines
>         5-2-3. Memory Ownership
> +       5-2-4. Cgroup-aware OOM Killer

Random curiousness, why cgroup-aware oom killer and not memcg-aware oom 
killer?

>       5-3. IO
>         5-3-1. IO Interface Files
>         5-3-2. Writeback
> @@ -1002,6 +1003,37 @@ PAGE_SIZE multiple when read back.
>  	high limit is used and monitored properly, this limit's
>  	utility is limited to providing the final safety net.
>  
> +  memory.oom_kill_all_tasks
> +
> +	A read-write single value file which exits on non-root

s/exits/exists/

> +	cgroups.  The default is "0".
> +
> +	Defines whether the OOM killer should treat the cgroup
> +	as a single entity during the victim selection.

Isn't this true independent of the memory.oom_kill_all_tasks setting?  
The cgroup aware oom killer will consider memcg's as logical units when 
deciding what to kill with or without memory.oom_kill_all_tasks, right?

I think you cover this fact in the cgroup aware oom killer section below 
so this might result in confusion if described alongside a setting of
memory.oom_kill_all_tasks.

> +
> +	If set, OOM killer will kill all belonging tasks in
> +	corresponding cgroup is selected as an OOM victim.

Maybe

"If set, the OOM killer will kill all threads attached to the memcg if 
selected as an OOM victim."

is better?

> +
> +	Be default, OOM killer respect /proc/pid/oom_score_adj value
> +	-1000, and will never kill the task, unless oom_kill_all_tasks
> +	is set.
> +
> +  memory.oom_priority
> +
> +	A read-write single value file which exits on non-root

s/exits/exists/

> +	cgroups.  The default is "0".
> +
> +	An integer number within the [-10000, 10000] range,
> +	which defines the order in which the OOM killer selects victim
> +	memory cgroups.
> +
> +	OOM killer prefers memory cgroups with larger priority if they
> +	are populated with elegible tasks.

s/elegible/eligible/

> +
> +	The oom_priority value is compared within sibling cgroups.
> +
> +	The root cgroup has the oom_priority 0, which cannot be changed.
> +
>    memory.events
>  	A read-only flat-keyed file which exists on non-root cgroups.
>  	The following entries are defined.  Unless specified
> @@ -1206,6 +1238,36 @@ POSIX_FADV_DONTNEED to relinquish the ownership of memory areas
>  belonging to the affected files to ensure correct memory ownership.
>  
>  
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

Maybe some description of "largest" would be helpful here?  I think you 
could briefly describe what is accounted for in the decisionmaking.

s/athe/at the/

Reading through this, it makes me wonder if doing s/cgroup/memcg/ over 
most of it would be better.

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
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
