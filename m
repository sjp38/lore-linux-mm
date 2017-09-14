Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3783A6B0253
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:06:19 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q8so4029664qtb.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:06:19 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 32si14882421qtu.211.2017.09.14.09.06.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 09:06:17 -0700 (PDT)
Date: Thu, 14 Sep 2017 09:05:48 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170914160548.GA30441@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 14, 2017 at 03:40:14PM +0200, Michal Hocko wrote:
> On Wed 13-09-17 14:56:07, Roman Gushchin wrote:
> > On Wed, Sep 13, 2017 at 02:29:14PM +0200, Michal Hocko wrote:
> [...]
> > > I strongly believe that comparing only leaf memcgs
> > > is more straightforward and it doesn't lead to unexpected results as
> > > mentioned before (kill a small memcg which is a part of the larger
> > > sub-hierarchy).
> > 
> > One of two main goals of this patchset is to introduce cgroup-level
> > fairness: bigger cgroups should be affected more than smaller,
> > despite the size of tasks inside. I believe the same principle
> > should be used for cgroups.
> 
> Yes bigger cgroups should be preferred but I fail to see why bigger
> hierarchies should be considered as well if they are not kill-all. And
> whether non-leaf memcgs should allow kill-all is not entirely clear to
> me. What would be the usecase?

We definitely want to support kill-all for non-leaf cgroups.
A workload can consist of several cgroups and we want to clean up
the whole thing on OOM. I don't see any reasons to limit
this functionality to leaf cgroups only.

Hierarchies are memory consumers, we do account their usage,
we do apply limits and guarantees for the hierarchies. The same is
with OOM victim selection: we are reclaiming memory from the
biggest consumer. Kill-all knob only defines the way _how_ we do that:
by killing one or all processes.

Just for example, we might want to take memory.low into account at
some point: prefer cgroups which are above their guarantees, avoid
killing those who fit. It would be hard if we're comparing cgroups
from different hierarchies. The same will be with introducing
oom_priorities, which is much more required functionality.

> Consider that it might be not your choice (as a user) how deep is your
> leaf memcg. I can already see how people complain that their memcg has
> been killed just because it was one level deeper in the hierarchy...

The kill-all functionality is enforced by parent, and it seems to be
following the overall memcg design. The parent cgroup enforces memory
limit, memory low limit, etc.

I don't know why OOM control should be different.

> 
> I would really start simple and only allow kill-all on leaf memcgs and
> only compare leaf memcgs & root. If we ever need to kill whole
> hierarchies then allow kill-all on intermediate memcgs as well and then
> consider cumulative consumptions only on those that have kill-all
> enabled.

This sounds hacky to me: the whole thing is depending on cgroup v2 and
is additionally explicitly opt-in.

Why do we need to introduce such incomplete functionality first,
and then suffer trying to extend it and provide backward compatibility?

Also, I think we should compare root cgroup with top-level cgroups,
rather than leaf cgroups. A process in the root cgroup is definitely
system-level entity, and we should compare it with other top-level
entities (other containerized workloads), rather then some random
leaf cgroup deep inside the tree. If we decided, that we're not comparing
random tasks from different cgroups, why should we do this for leaf
cgroups? Is sounds like making only one step towards right direction,
while we can do more.

> 
> Or do I miss any reasonable usecase that would suffer from such a
> semantic?

Kill-all for sub-trees is definitely required.
Enforcing oom_priorities for sub-trees is something that I would expect
very useful too. Comparing leaf cgroups system-wide instead of processes
doesn't sound good for me, we're lacking hierarchical fairness, which
was one of two goals of this patchset.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
