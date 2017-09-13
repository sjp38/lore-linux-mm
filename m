Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 38E276B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 16:46:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 188so2004333pgb.3
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 13:46:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u68sor5953203pgb.328.2017.09.13.13.46.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 13:46:10 -0700 (PDT)
Date: Wed, 13 Sep 2017 13:46:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1709131340020.146292@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 13 Sep 2017, Michal Hocko wrote:

> > > This patchset makes the OOM killer cgroup-aware.
> > > 
> > > v8:
> > >   - Do not kill tasks with OOM_SCORE_ADJ -1000
> > >   - Make the whole thing opt-in with cgroup mount option control
> > >   - Drop oom_priority for further discussions
> > 
> > Nack, we specifically require oom_priority for this to function correctly, 
> > otherwise we cannot prefer to kill from low priority leaf memcgs as 
> > required.
> 
> While I understand that your usecase might require priorities I do not
> think this part missing is a reason to nack the cgroup based selection
> and kill-all parts. This can be done on top. The only important part
> right now is the current selection semantic - only leaf memcgs vs. size
> of the hierarchy). I strongly believe that comparing only leaf memcgs
> is more straightforward and it doesn't lead to unexpected results as
> mentioned before (kill a small memcg which is a part of the larger
> sub-hierarchy).
> 

The problem is that we cannot enable the cgroup-aware oom killer and 
oom_group behavior because, without oom priorities, we have no ability to 
influence the cgroup that it chooses.  It is doing two things: providing 
more fairness amongst cgroups by selecting based on cumulative usage 
rather than single large process (good!), and effectively is removing all 
userspace control of oom selection (bad).  We want the former, but it 
needs to be coupled with support so that we can protect vital cgroups, 
regardless of their usage.

It is certainly possible to add oom priorities on top before it is merged, 
but I don't see why it isn't part of the patchset.  We need it before its 
merged to avoid users playing with /proc/pid/oom_score_adj to prevent any 
killing in the most preferable memcg when they could have simply changed 
the oom priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
