Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 111F6440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 16:26:24 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p15so35824346pgs.7
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 13:26:24 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id y75si2557506pfa.339.2017.07.12.13.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 13:26:22 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id q86so18167778pfl.3
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 13:26:22 -0700 (PDT)
Date: Wed, 12 Jul 2017 13:26:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v3 2/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170712121110.GA9017@castle>
Message-ID: <alpine.DEB.2.10.1707121317580.57341@chino.kir.corp.google.com>
References: <1498079956-24467-1-git-send-email-guro@fb.com> <1498079956-24467-3-git-send-email-guro@fb.com> <alpine.DEB.2.10.1707101547010.116811@chino.kir.corp.google.com> <20170711125124.GA12406@castle> <alpine.DEB.2.10.1707111342190.60183@chino.kir.corp.google.com>
 <20170712121110.GA9017@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 12 Jul 2017, Roman Gushchin wrote:

> > It's a no-op if nobody sets up priorities or the system-wide sysctl is 
> > disabled.  Presumably, as in our model, the Activity Manager sets the 
> > sysctl and is responsible for configuring the priorities if present.  All 
> > memcgs at the sibling level or subcontainer level remain the default if 
> > not defined by the chown'd user, so this falls back to an rss model for 
> > backwards compatibility.
> 
> Hm, this is interesting...
> 
> What I'm thinking about, is that we can introduce the following model:
> each memory cgroup has an integer oom priority value, 0 be default.
> Root cgroup priority is always 0, other cgroups can have both positive
> or negative priorities.
> 

For our purposes we use a range of [0, 10000] for the per-process oom 
priority; 10000 implies the process is not oom killable, 5000 is the 
default.  We use a range of [0, 9999] for the per-memcg oom priority since 
memcgs cannot disable themselves from oom killing (although they could oom 
disable all attached processes).  We can obviously remap our priorities to 
whatever we decide here, but I think we should give ourselves more room 
and provide 10000 priorities at the minimum (we have 5000 true priorities 
plus overlimit bias).  I'm not sure that negative priorities make sense in 
this model, is there a strong reason to prefer [-5000, 5000] over 
[0, 10000]?

And, yes, the root memcg remains a constant oom priority and is never 
actually checked.

> During OOM victim selection we compare cgroups on each hierarchy level
> based on priority and size, if there are several cgroups with equal priority.
> Per-task oom_score_adj will affect task selection inside a cgroup if
> oom_kill_all_tasks is not set. -1000 special value will also completely
> protect a task from being killed, if only oom_kill_all_tasks is not set.
> 

If there are several cgroups of equal priority, we prefer the one that was 
created the most recently just to avoid losing work that has been done for 
a long period of time.  But the key in this proposal is that we _always_ 
continue to iterate the memcg hierarchy until we find a process attached 
to a memcg with the lowest priority relative to sibling cgroups, if any.

To adapt your model to this proposal, memory.oom_kill_all_tasks would only 
be effective if there are no descendant memcgs.  In that case, iteration 
stops anyway and in my model we kill the process with the lowest 
per-process priority.  This could trivially check 
memory.oom_kill_all_tasks and kill everything, and I'm happy to support 
that feature since we have had a need for it in the past as well.

We should talk about when this priority-based scoring becomes effective.  
We enable it by default in our kernel, but it could be guarded with a VM 
sysctl if necessary to enact a system-wide policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
