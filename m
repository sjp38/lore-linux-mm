Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4EB696B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:29:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d24so13894533wmi.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:29:28 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w16si5501131wrc.86.2017.08.14.05.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 05:29:26 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:28:32 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v4 4/4] mm, oom, docs: describe the cgroup-aware OOM killer
Message-ID: <20170814122832.GB24393@castle.DHCP.thefacebook.com>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-5-guro@fb.com>
 <alpine.DEB.2.10.1708081615110.54505@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708081615110.54505@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 08, 2017 at 04:24:32PM -0700, David Rientjes wrote:
> On Wed, 26 Jul 2017, Roman Gushchin wrote:
> 
> > +Cgroup-aware OOM Killer
> > +~~~~~~~~~~~~~~~~~~~~~~~
> > +
> > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > +It means that it treats memory cgroups as first class OOM entities.
> > +
> > +Under OOM conditions the memory controller tries to make the best
> > +choise of a victim, hierarchically looking for the largest memory
> > +consumer. By default, it will look for the biggest task in the
> > +biggest leaf cgroup.
> > +
> > +Be default, all cgroups have oom_priority 0, and OOM killer will
> > +chose the largest cgroup recursively on each level. For non-root
> > +cgroups it's possible to change the oom_priority, and it will cause
> > +the OOM killer to look athe the priority value first, and compare
> > +sizes only of cgroups with equal priority.
> > +
> > +But a user can change this behavior by enabling the per-cgroup
> > +oom_kill_all_tasks option. If set, it causes the OOM killer treat
> > +the whole cgroup as an indivisible memory consumer. In case if it's
> > +selected as on OOM victim, all belonging tasks will be killed.
> > +
> > +Tasks in the root cgroup are treated as independent memory consumers,
> > +and are compared with other memory consumers (e.g. leaf cgroups).
> > +The root cgroup doesn't support the oom_kill_all_tasks feature.
> > +
> > +This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
> > +the memory controller considers only cgroups belonging to the sub-tree
> > +of the OOM'ing cgroup.
> > +
> >  IO
> >  --
> 
> Thanks very much for following through with this.
> 
> As described in http://marc.info/?l=linux-kernel&m=149980660611610 this is 
> very similar to what we do for priority based oom killing.
> 
> I'm wondering your comments on extending it one step further, however: 
> include process priority as part of the selection rather than simply memcg 
> priority.
> 
> memory.oom_priority will dictate which memcg the kill will originate from, 
> but processes have no ability to specify that they should actually be 
> killed as opposed to a leaf memcg.  I'm not sure how important this is for 
> your usecase, but we have found it useful to be able to specify process 
> priority as part of the decisionmaking.
> 
> At each level of consideration, we simply kill a process with lower 
> /proc/pid/oom_priority if there are no memcgs with a lower 
> memory.oom_priority.  This allows us to define the exact process that will 
> be oom killed, absent oom_kill_all_tasks, and not require that the process 
> be attached to leaf memcg.  Most notably these are processes that are best 
> effort: stats collection, logging, etc.

I'm focused on cgroup v2 interface, that means, that there are no processes
belonging to non-leaf cgroups. So, cgroups are compared only with root-cgroup
processes, and I'm not sure we really need a way to prioritize them.

> 
> Do you think it would be helpful to introduce per-process oom priority as 
> well?

I'm not against per-process oom_priority, and it might be a good idea
to replace the existing oom_score_adj with it at some point. I might be wrong,
but I think users mostly using the extereme oom_score_adj values;
no one really needs the tiebreaking based on some percentages
of the total memory. And oom_priority will be just a simpler and more clear
way to express the same intention.

But it's not directly related to this patchset, and it's more arguable,
so I think it can be done later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
