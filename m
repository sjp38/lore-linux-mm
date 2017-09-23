Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3C246B0253
	for <linux-mm@kvack.org>; Sat, 23 Sep 2017 04:16:33 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 11so6207948pge.4
        for <linux-mm@kvack.org>; Sat, 23 Sep 2017 01:16:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f67sor755021pgc.21.2017.09.23.01.16.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 23 Sep 2017 01:16:32 -0700 (PDT)
Date: Sat, 23 Sep 2017 01:16:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170922210519.GH828415@devbig577.frc2.facebook.com>
Message-ID: <alpine.DEB.2.10.1709230111250.116512@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170921142107.GA20109@cmpxchg.org> <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com> <20170922154426.GF828415@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1709221316290.68140@chino.kir.corp.google.com> <20170922210519.GH828415@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 22 Sep 2017, Tejun Heo wrote:

> > If you have this low priority maintenance job charging memory to the high 
> > priority hierarchy, you're already misconfigured unless you adjust 
> > /proc/pid/oom_score_adj because it will oom kill any larger process than 
> > itself in today's kernels anyway.
> > 
> > A better configuration would be attach this hypothetical low priority 
> > maintenance job to its own sibling cgroup with its own memory limit to 
> > avoid exactly that problem: it going berserk and charging too much memory 
> > to the high priority container that results in one of its processes 
> > getting oom killed.
> 
> And how do you guarantee that across delegation boundaries?  The
> points you raise on why the priority should be applied level-by-level
> are exactly the same points why this doesn't really work.  OOM killing
> priority isn't something which can be distributed across cgroup
> hierarchy level-by-level.  The resulting decision tree doesn't make
> any sense.
> 

It works very well in practice with real world usecases, and Roman has 
developed the same design independently that we have used for the past 
four years.  Saying it doesn't make any sense doesn't hold a lot of weight 
when we both independently designed and implemented the same solution to 
address our usecases.

> I'm not against adding something which works but strict level-by-level
> comparison isn't the solution.
> 

Each of the eight versions of Roman's cgroup aware oom killer has done 
comparisons between siblings at each level.  Userspace influence on that 
comparison would thus also need to be done at each level.  It's a very 
powerful combination in practice.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
