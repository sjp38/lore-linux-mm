Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 535EF6B0022
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 17:20:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s22so1320745pfh.21
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 14:20:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor2782123pfl.90.2018.01.26.14.20.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jan 2018 14:20:26 -0800 (PST)
Date: Fri, 26 Jan 2018 14:20:24 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
In-Reply-To: <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 25 Jan 2018, Andrew Morton wrote:

> > Now that each mem cgroup on the system has a memory.oom_policy tunable to
> > specify oom kill selection behavior, remove the needless "groupoom" mount
> > option that requires (1) the entire system to be forced, perhaps
> > unnecessarily, perhaps unexpectedly, into a single oom policy that
> > differs from the traditional per process selection, and (2) a remount to
> > change.
> > 
> > Instead of enabling the cgroup aware oom killer with the "groupoom" mount
> > option, set the mem cgroup subtree's memory.oom_policy to "cgroup".
> 
> Can we retain the groupoom mount option and use its setting to set the
> initial value of every memory.oom_policy?  That way the mount option
> remains somewhat useful and we're back-compatible?
> 

-ECONFUSED.  We want to have a mount option that has the sole purpose of 
doing echo cgroup > /mnt/cgroup/memory.oom_policy?

Please note that this patchset is not only to remove a mount option, it is 
to allow oom policies to be configured per subtree such that users whom 
you delegate those subtrees to cannot evade the oom policy that is set at 
a higher level.  The goal is to prevent the user from needing to organize 
their hierarchy is a specific way to work around this constraint and use 
things like limiting the number of child cgroups that user is allowed to 
create only to work around the oom policy.  With a cgroup v2 single 
hierarchy it severely limits the amount of control the user has over their 
processes because they are locked into a very specific hierarchy 
configuration solely to not allow the user to evade oom kill.

This, and fixes to fairly compare the root mem cgroup with leaf mem 
cgroups, are essential before the feature is merged otherwise it yields 
wildly unpredictable (and unexpected, since its interaction with 
oom_score_adj isn't documented) results as I already demonstrated where 
cgroups with 1GB of usage are killed instead of 6GB workers outside of 
that subtree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
