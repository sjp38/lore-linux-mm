Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3436B0033
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 20:24:55 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e195so15971489itc.20
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 17:24:55 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s20sor3247444ioa.274.2017.10.22.17.24.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Oct 2017 17:24:54 -0700 (PDT)
Date: Sun, 22 Oct 2017 17:24:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
In-Reply-To: <20171019194534.GA5502@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019194534.GA5502@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Thu, 19 Oct 2017, Johannes Weiner wrote:

> David would have really liked for this patchset to include knobs to
> influence how the algorithm picks cgroup victims. The rest of us
> agreed that this is beyond the scope of these patches, that the
> patches don't need it to be useful, and that there is nothing
> preventing anyone from adding configurability later on. David
> subsequently nacked the series as he considers it incomplete. Neither
> Michal nor I see technical merit in David's nack.
> 

The nack is for three reasons:

 (1) unfair comparison of root mem cgroup usage to bias against that mem 
     cgroup from oom kill in system oom conditions,

 (2) the ability of users to completely evade the oom killer by attaching
     all processes to child cgroups either purposefully or unpurposefully,
     and

 (3) the inability of userspace to effectively control oom victim  
     selection.

For (1), the difference in v12 is adding the rss of all processes attached 
to the root mem cgroup as the evaluation.  This is not the same criteria 
that child cgroups are evaluated on, and they are compared using that 
bias.  It is very trivial to provide a fair comparison as was suggested in 
v11.

For (2), users who do

	for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done

can completely evade the oom killer and this may be part of their standard 
operating procedure for restricting resources with other cgroups other 
than the mem cgroup.  Again, it's an unfair comparison to all other 
cgroups on the system.

For (3), users need the ability to protect important cgroups, such as 
protecting a cgroup that is limited to 50% of system memory.  They need 
the ability to kill processes from other cgroups to protect these 
important processes.  This is nothing new: the oom killer has always 
provided the ability to bias against important processes.

There was follow-up email on all of these points where very trivial 
changes were suggested to address all three of these issues, and which 
Roman has implemented in one form or another in previous iterations with 
the bonus that no accounting to the root mem cgroup needs to be done.

> Michal acked the implementation, but on the condition that the new
> behavior be opt-in, to not surprise existing users. I *think* we agree
> that respecting the cgroup topography during global OOM is what we
> should have been doing when cgroups were initially introduced; where
> we disagree is that I think users shouldn't have to opt in to
> improvements. We have done much more invasive changes to the victim
> selection without actual regressions in the past. Further, this change
> only applies to mounts of the new cgroup2. Tejun also wasn't convinced
> of the risk for regression, and too would prefer cgroup-awareness to
> be the default in cgroup2. I would ask for patch 5/6 to be dropped.
> 

I agree with Michal that the new victim selection should be opt-in with 
CGRP_GROUP_OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
