Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD076B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 16:27:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a84so6121533pfk.5
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 13:27:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b10sor1982400plr.21.2017.10.11.13.27.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 13:27:46 -0700 (PDT)
Date: Wed, 11 Oct 2017 13:27:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171011130815.qjw7jfnnqz3gpn4s@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1710111323380.98307@chino.kir.corp.google.com>
References: <20171005130454.5590-1-guro@fb.com> <20171005130454.5590-4-guro@fb.com> <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com> <20171010122306.GA11653@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
 <20171011130815.qjw7jfnnqz3gpn4s@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 11 Oct 2017, Michal Hocko wrote:

> > For these reasons: unfair comparison of root mem cgroup usage to bias 
> > against that mem cgroup from oom kill in system oom conditions, the 
> > ability of users to completely evade the oom killer by attaching all 
> > processes to child cgroups either purposefully or unpurposefully, and the 
> > inability of userspace to effectively control oom victim selection:
> > 
> > Nacked-by: David Rientjes <rientjes@google.com>
> 
> I consider this NACK rather dubious. Evading the heuristic as you
> describe requires root privileges in default configuration because
> normal users are not allowed to create subtrees. If you
> really want to delegate subtree to an untrusted entity then you do not
> have to opt-in for this oom strategy. We can work on an additional means
> which would allow to cover those as well (e.g. priority based one which
> is requested for other usecases).
> 

You're missing the point that the user is trusted and it may be doing 
something to circumvent oom kill unknowingly.  With a single unified 
hierarchy, the user is forced to attach its processes to subcontainers if 
it wants to constrain resources with other controllers.  Doing so ends up 
completely avoiding oom kill because of this implementation detail.  It 
has nothing to do with trust and the admin who is opting-in will not know 
a user has cirumvented oom kill purely because it constrains its processes 
with controllers other than the memory controller.

> A similar argument applies to the root memcg evaluation. While the
> proposed behavior is not optimal it would work for general usecase
> described here where the root memcg doesn't really run any large number
> of tasks. If somebody who explicitly opts-in for the new strategy and it
> doesn't work well for that usecase we can enhance the behavior. That
> alone is not a reason to nack the whole thing.
> 
> I find it really disturbing that you keep nacking this approach just
> because it doesn't suite your specific usecase while it doesn't break
> it. Moreover it has been stated several times already that future
> improvements are possible and cover what you have described already.

This has nothing to do with my specific usecase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
