Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C373E6810B7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 06:58:16 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p14so2750611wrg.6
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 03:58:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id m138si1073877wmg.263.2017.08.25.03.58.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 03:58:15 -0700 (PDT)
Date: Fri, 25 Aug 2017 11:57:28 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170825105728.GA10438@castle.DHCP.thefacebook.com>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-3-guro@fb.com>
 <alpine.DEB.2.10.1708231614310.68096@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708231614310.68096@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hi David!

On Wed, Aug 23, 2017 at 04:19:11PM -0700, David Rientjes wrote:
> On Wed, 23 Aug 2017, Roman Gushchin wrote:
> 
> > Traditionally, the OOM killer is operating on a process level.
> > Under oom conditions, it finds a process with the highest oom score
> > and kills it.
> > 
> > This behavior doesn't suit well the system with many running
> > containers:
> > 
> > 1) There is no fairness between containers. A small container with
> > few large processes will be chosen over a large one with huge
> > number of small processes.
> > 
> > 2) Containers often do not expect that some random process inside
> > will be killed. In many cases much safer behavior is to kill
> > all tasks in the container. Traditionally, this was implemented
> > in userspace, but doing it in the kernel has some advantages,
> > especially in a case of a system-wide OOM.
> > 
> > 3) Per-process oom_score_adj affects global OOM, so it's a breache
> > in the isolation.
> > 
> > To address these issues, cgroup-aware OOM killer is introduced.
> > 
> > Under OOM conditions, it tries to find the biggest memory consumer,
> > and free memory by killing corresponding task(s). The difference
> > the "traditional" OOM killer is that it can treat memory cgroups
> > as memory consumers as well as single processes.
> > 
> > By default, it will look for the biggest leaf cgroup, and kill
> > the largest task inside.
> > 
> > But a user can change this behavior by enabling the per-cgroup
> > oom_kill_all_tasks option. If set, it causes the OOM killer treat
> > the whole cgroup as an indivisible memory consumer. In case if it's
> > selected as on OOM victim, all belonging tasks will be killed.
> > 
> 
> I'm very happy with the rest of the patchset, but I feel that I must renew 
> my objection to memory.oom_kill_all_tasks being able to override the 
> setting of the admin of setting a process to be oom disabled.  From my 
> perspective, setting memory.oom_kill_all_tasks with an oom disabled 
> process attached that now becomes killable either (1) overrides the 
> CAP_SYS_RESOURCE oom disabled setting or (2) is lazy and doesn't modify 
> /proc/pid/oom_score_adj itself.

Changed this in v7 (to be posted soon).

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
