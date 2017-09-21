Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B89A16B0033
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 17:17:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so13618524pgn.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 14:17:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 21sor968336pfi.7.2017.09.21.14.17.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 14:17:27 -0700 (PDT)
Date: Thu, 21 Sep 2017 14:17:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170921142107.GA20109@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170921142107.GA20109@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 21 Sep 2017, Johannes Weiner wrote:

> That's a ridiculous nak.
> 
> The fact that this patch series doesn't solve your particular problem
> is not a technical argument to *reject* somebody else's work to solve
> a different problem. It's not a regression when behavior is completely
> unchanged unless you explicitly opt into a new functionality.
> 
> So let's stay reasonable here.
> 

The issue is that if you opt-in to the new feature, then you are forced to 
change /proc/pid/oom_score_adj of all processes attached to a cgroup that 
you do not want oom killed based on size to be oom disabled.  The kernel 
provides no other remedy without oom priorities since the new feature 
would otherwise disregard oom_score_adj.  In that case, userspace is 
racing in two ways: (1) attach of process to a memcg you want to protect 
from oom kill (first class, vital, large memory hog job) to set to oom 
disable and (2) adjustment of other cgroups to make them eligible after 
first oom kill.

It doesn't have anything to do with my particular usecase, but rather the 
ability of userspace to influence the decisions of the kernel.  Previous 
to this patchset, when selection is done based on process size, userspace 
has full control over selection.  After this patchset, userspace has no 
control other than setting all processes to be oom disabled if the largest 
memory consumer is to be protected.  Roman's memory.oom_priority provides 
a perfect solution for userspace to be able to influence this decision 
making and causes no change in behavior for users who choose not to tune 
memory.oom_priority.  The nack originates from the general need for 
userspace influence over oom victim selection and to avoid userspace 
needing to take the rather drastic measure of setting all processes to be 
oom disabled to prevent oom kill in kernels before oom priorities are 
introduced.

> The patch series has merit as it currently stands. It makes OOM
> killing in a cgrouped system fairer and less surprising. Whether you
> have the ability to influence this in a new way is an entirely
> separate discussion. It's one that involves ABI and user guarantees.
> 
> Right now Roman's patches make no guarantees on how the cgroup tree is
> descended. But once we define an interface for prioritization, it
> locks the victim algorithm into place to a certain extent.
> 

The patchset compares memory cgroup size relative to sibling cgroups only, 
the same comparison for memory.oom_priority.  There is a guarantee 
provided on how cgroup size is compared in select_victim_memcg(), it 
hierarchically accumulates the "size" from leaf nodes up to the root memcg 
and then iterates the tree comparing sizes between sibling cgroups to 
choose a victim memcg.  That algorithm could be more elaborately described 
in the documentation, but we simply cannot change the implementation of 
select_victim_memcg() later even without oom priorities since users cannot 
get inconsistent results after opting into a feature between kernel 
versions.  I believe the selection criteria should be implemented to be 
deterministic, as select_victim_memcg() does, and the documentation should 
fully describe what the selection criteria is, and then allow the user to 
decide.

> It also involves a discussion about how much control userspace should
> have over OOM killing in the first place. It's a last-minute effort to
> save the kernel from deadlocking on memory. Whether that is the time
> and place to have userspace make clever resource management decisions
> is an entirely different thing than what Roman is doing.
> 
> But this patch series doesn't prevent any such future discussion and
> implementations, and it's not useless without it. So let's not
> conflate these two things, and hold the priority patch for now.
> 

Roman is planning on introducing memory.oom_priority back into the 
patchset per https://marc.info/?l=linux-kernel&m=150574701126877 and I 
agree with the very clear semantic that it introduces: to have the 
size-based comparison use the same rules as the userspace priority 
comparison.  It's very powerful and I'm happy to ack the final version 
that he plans on posting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
