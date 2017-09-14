Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3D816B0285
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 09:34:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w12so3414002wrc.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 06:34:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j61si11784264edc.285.2017.09.14.06.34.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 06:34:11 -0700 (PDT)
Date: Thu, 14 Sep 2017 15:34:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170914133407.e7gstxssq6j5lo25@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <alpine.DEB.2.10.1709131340020.146292@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709131340020.146292@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 13-09-17 13:46:08, David Rientjes wrote:
> On Wed, 13 Sep 2017, Michal Hocko wrote:
> 
> > > > This patchset makes the OOM killer cgroup-aware.
> > > > 
> > > > v8:
> > > >   - Do not kill tasks with OOM_SCORE_ADJ -1000
> > > >   - Make the whole thing opt-in with cgroup mount option control
> > > >   - Drop oom_priority for further discussions
> > > 
> > > Nack, we specifically require oom_priority for this to function correctly, 
> > > otherwise we cannot prefer to kill from low priority leaf memcgs as 
> > > required.
> > 
> > While I understand that your usecase might require priorities I do not
> > think this part missing is a reason to nack the cgroup based selection
> > and kill-all parts. This can be done on top. The only important part
> > right now is the current selection semantic - only leaf memcgs vs. size
> > of the hierarchy). I strongly believe that comparing only leaf memcgs
> > is more straightforward and it doesn't lead to unexpected results as
> > mentioned before (kill a small memcg which is a part of the larger
> > sub-hierarchy).
> > 
> 
> The problem is that we cannot enable the cgroup-aware oom killer and 
> oom_group behavior because, without oom priorities, we have no ability to 
> influence the cgroup that it chooses.  It is doing two things: providing 
> more fairness amongst cgroups by selecting based on cumulative usage 
> rather than single large process (good!), and effectively is removing all 
> userspace control of oom selection (bad).  We want the former, but it 
> needs to be coupled with support so that we can protect vital cgroups, 
> regardless of their usage.

I understand that your usecase needs a more fine grained control over
the selection but that alone is not a reason to nack the implementation
which doesn't provide it (yet).

> It is certainly possible to add oom priorities on top before it is merged, 
> but I don't see why it isn't part of the patchset.

Because the semantic of the priority for non-leaf memcgs is not fully
clear and I would rather have the core of the functionality merged
before this is sorted out.

> We need it before its 
> merged to avoid users playing with /proc/pid/oom_score_adj to prevent any 
> killing in the most preferable memcg when they could have simply changed 
> the oom priority.

I am sorry but I do not really understand your concern. Are you
suggesting that users would start oom disable all tasks in a memcg to
give it a higher priority? Even if that was the case why should such an
abuse be a blocker for generic memcg aware oom killer being merged?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
