Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02B7F6B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 17:05:24 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id b82so2967008qkc.2
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 14:05:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d23sor444916qta.12.2017.09.22.14.05.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 14:05:23 -0700 (PDT)
Date: Fri, 22 Sep 2017 14:05:19 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170922210519.GH828415@devbig577.frc2.facebook.com>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170921142107.GA20109@cmpxchg.org>
 <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com>
 <20170922154426.GF828415@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1709221316290.68140@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709221316290.68140@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Sep 22, 2017 at 01:39:55PM -0700, David Rientjes wrote:
> Current heuristic based on processes is coupled with per-process
> /proc/pid/oom_score_adj.  The proposed 
> heuristic has no ability to be influenced by userspace, and it needs one.  
> The proposed heuristic based on memory cgroups coupled with Roman's 
> per-memcg memory.oom_priority is appropriate and needed.  It is not 

So, this is where we disagree.  I don't think it's a good design.

> "sophisticated intelligence," it merely allows userspace to protect vital 
> memory cgroups when opting into the new features (cgroups compared based 
> on size and memory.oom_group) that we very much want.

which can't achieve that goal very well for wide variety of users.

> > We even change the whole scheduling behaviors and try really hard to
> > not get locked into specific implementation details which exclude
> > future improvements.  Guaranteeing OOM killing selection would be
> > crazy.  Why would we prevent ourselves from doing things better in the
> > future?  We aren't talking about the semantics of read(2) here.  This
> > is a kernel emergency mechanism to avoid deadlock at the last moment.
> 
> We merely want to prefer other memory cgroups are oom killed on system oom 
> conditions before important ones, regardless if the important one is using 
> more memory than the others because of the new heuristic this patchset 
> introduces.  This is exactly the same as /proc/pid/oom_score_adj for the 
> current heuristic.

You were arguing that we should lock into a specific heuristics and
guarantee the same behavior.  We shouldn't.

When we introduce a user visible interface, we're making a lot of
promises.  My point is that we need to be really careful when making
those promises.

> If you have this low priority maintenance job charging memory to the high 
> priority hierarchy, you're already misconfigured unless you adjust 
> /proc/pid/oom_score_adj because it will oom kill any larger process than 
> itself in today's kernels anyway.
> 
> A better configuration would be attach this hypothetical low priority 
> maintenance job to its own sibling cgroup with its own memory limit to 
> avoid exactly that problem: it going berserk and charging too much memory 
> to the high priority container that results in one of its processes 
> getting oom killed.

And how do you guarantee that across delegation boundaries?  The
points you raise on why the priority should be applied level-by-level
are exactly the same points why this doesn't really work.  OOM killing
priority isn't something which can be distributed across cgroup
hierarchy level-by-level.  The resulting decision tree doesn't make
any sense.

I'm not against adding something which works but strict level-by-level
comparison isn't the solution.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
