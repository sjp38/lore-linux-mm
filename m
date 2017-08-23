Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 957002803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:19:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so19111533pgs.4
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:19:14 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id q14si1729608pgr.20.2017.08.23.16.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:19:13 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id u191so6907258pgc.2
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:19:13 -0700 (PDT)
Date: Wed, 23 Aug 2017 16:19:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170823165201.24086-3-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708231614310.68096@chino.kir.corp.google.com>
References: <20170823165201.24086-1-guro@fb.com> <20170823165201.24086-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 23 Aug 2017, Roman Gushchin wrote:

> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers:
> 
> 1) There is no fairness between containers. A small container with
> few large processes will be chosen over a large one with huge
> number of small processes.
> 
> 2) Containers often do not expect that some random process inside
> will be killed. In many cases much safer behavior is to kill
> all tasks in the container. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 
> 3) Per-process oom_score_adj affects global OOM, so it's a breache
> in the isolation.
> 
> To address these issues, cgroup-aware OOM killer is introduced.
> 
> Under OOM conditions, it tries to find the biggest memory consumer,
> and free memory by killing corresponding task(s). The difference
> the "traditional" OOM killer is that it can treat memory cgroups
> as memory consumers as well as single processes.
> 
> By default, it will look for the biggest leaf cgroup, and kill
> the largest task inside.
> 
> But a user can change this behavior by enabling the per-cgroup
> oom_kill_all_tasks option. If set, it causes the OOM killer treat
> the whole cgroup as an indivisible memory consumer. In case if it's
> selected as on OOM victim, all belonging tasks will be killed.
> 

I'm very happy with the rest of the patchset, but I feel that I must renew 
my objection to memory.oom_kill_all_tasks being able to override the 
setting of the admin of setting a process to be oom disabled.  From my 
perspective, setting memory.oom_kill_all_tasks with an oom disabled 
process attached that now becomes killable either (1) overrides the 
CAP_SYS_RESOURCE oom disabled setting or (2) is lazy and doesn't modify 
/proc/pid/oom_score_adj itself.

I'm not sure what is objectionable about allowing 
memory.oom_kill_all_tasks to coexist with oom disabled processes.  Just 
kill everything else so that the oom disabled process can report the oom 
condition after notification, restart the task, etc.  If it's problematic, 
then whomever is declaring everything must be killed shall also modify 
/proc/pid/oom_score_adj of oom disabled processes.  If it doesn't have 
permission to change that, then I think there's a much larger concern.

> Tasks in the root cgroup are treated as independent memory consumers,
> and are compared with other memory consumers (e.g. leaf cgroups).
> The root cgroup doesn't support the oom_kill_all_tasks feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
