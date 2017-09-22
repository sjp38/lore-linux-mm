Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 383216B0069
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:44:32 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id d6so3315206itc.6
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 08:44:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a187sor56582ite.50.2017.09.22.08.44.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 08:44:30 -0700 (PDT)
Date: Fri, 22 Sep 2017 08:44:27 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170922154426.GF828415@devbig577.frc2.facebook.com>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170921142107.GA20109@cmpxchg.org>
 <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, David.

On Thu, Sep 21, 2017 at 02:17:25PM -0700, David Rientjes wrote:
> It doesn't have anything to do with my particular usecase, but rather the 
> ability of userspace to influence the decisions of the kernel.  Previous 
> to this patchset, when selection is done based on process size, userspace 
> has full control over selection.  After this patchset, userspace has no 
> control other than setting all processes to be oom disabled if the largest 
> memory consumer is to be protected.  Roman's memory.oom_priority provides 
> a perfect solution for userspace to be able to influence this decision 
> making and causes no change in behavior for users who choose not to tune 
> memory.oom_priority.  The nack originates from the general need for 
> userspace influence over oom victim selection and to avoid userspace 
> needing to take the rather drastic measure of setting all processes to be 
> oom disabled to prevent oom kill in kernels before oom priorities are 
> introduced.

Overall, I think that OOM killing is the wrong place to implement
sophisticated intelligence in.  It's too late to be smart - the
workload already has suffered significantly and there's only very
limited amount of computing which can be performed.  That said, if
there's a useful and general enough mechanism to configure OOM killer
behavior from userland, that can definitely be useful.

> The patchset compares memory cgroup size relative to sibling cgroups only, 
> the same comparison for memory.oom_priority.  There is a guarantee 
> provided on how cgroup size is compared in select_victim_memcg(), it 
> hierarchically accumulates the "size" from leaf nodes up to the root memcg 
> and then iterates the tree comparing sizes between sibling cgroups to 
> choose a victim memcg.  That algorithm could be more elaborately described 
> in the documentation, but we simply cannot change the implementation of 
> select_victim_memcg() later even without oom priorities since users cannot 
> get inconsistent results after opting into a feature between kernel 
> versions.  I believe the selection criteria should be implemented to be 
> deterministic, as select_victim_memcg() does, and the documentation should 
> fully describe what the selection criteria is, and then allow the user to 
> decide.

We even change the whole scheduling behaviors and try really hard to
not get locked into specific implementation details which exclude
future improvements.  Guaranteeing OOM killing selection would be
crazy.  Why would we prevent ourselves from doing things better in the
future?  We aren't talking about the semantics of read(2) here.  This
is a kernel emergency mechanism to avoid deadlock at the last moment.

> Roman is planning on introducing memory.oom_priority back into the 
> patchset per https://marc.info/?l=linux-kernel&m=150574701126877 and I 
> agree with the very clear semantic that it introduces: to have the 
> size-based comparison use the same rules as the userspace priority 
> comparison.  It's very powerful and I'm happy to ack the final version 
> that he plans on posting.

To me, the proposed oom_priority mechanism seems too limited and makes
the error of tightly coupling the hierarchical behavior of resource
distribution with OOM victim selection.  They can be related but are
not the same and coupling them together in the kernel interface is
likely a mistake which will lead to long term pains that we can't
easily get out of.

Here's a really simple use case.  Imagine a system which hosts two
containers of services and one is somewhat favored over the other and
wants to set up cgroup hierarchy so that resources are split at the
top level between the two containers.  oom_priority is set accordingly
too.  Let's say a low priority maintenance job in higher priority
container goes berserk, as they oftne do, and pushing the system into
OOM.

With the proposed static oom_priority mechanism, the only
configuration which can be expressed is "kill all of the lower top
level subtree before any of the higher one", which is a silly
restriction leading to silly behavior and a direct result of
conflating resource distribution network with level-by-level OOM
killing decsion.

If we want to allow users to steer OOM killing, I suspect that it
should be aligned at delegation boundaries rather than on cgroup
hierarchy itself.  We can discuss that but it is a separate
discussion.

The mechanism being proposed is fundamentally flawed.  You can't push
that in by nacking other improvements.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
