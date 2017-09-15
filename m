Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 246C26B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 06:58:31 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g50so2095722wra.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 03:58:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y2si996657edy.370.2017.09.15.03.58.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 03:58:29 -0700 (PDT)
Date: Fri, 15 Sep 2017 12:58:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170914160548.GA30441@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 14-09-17 09:05:48, Roman Gushchin wrote:
> On Thu, Sep 14, 2017 at 03:40:14PM +0200, Michal Hocko wrote:
> > On Wed 13-09-17 14:56:07, Roman Gushchin wrote:
> > > On Wed, Sep 13, 2017 at 02:29:14PM +0200, Michal Hocko wrote:
> > [...]
> > > > I strongly believe that comparing only leaf memcgs
> > > > is more straightforward and it doesn't lead to unexpected results as
> > > > mentioned before (kill a small memcg which is a part of the larger
> > > > sub-hierarchy).
> > > 
> > > One of two main goals of this patchset is to introduce cgroup-level
> > > fairness: bigger cgroups should be affected more than smaller,
> > > despite the size of tasks inside. I believe the same principle
> > > should be used for cgroups.
> > 
> > Yes bigger cgroups should be preferred but I fail to see why bigger
> > hierarchies should be considered as well if they are not kill-all. And
> > whether non-leaf memcgs should allow kill-all is not entirely clear to
> > me. What would be the usecase?
> 
> We definitely want to support kill-all for non-leaf cgroups.
> A workload can consist of several cgroups and we want to clean up
> the whole thing on OOM.

Could you be more specific about such a workload? E.g. how can be such a
hierarchy handled consistently when its sub-tree gets killed due to
internal memory pressure? Or do you expect that none of the subtree will
have hard limit configured?

> I don't see any reasons to limit this functionality to leaf cgroups
> only.

Well, I wanted to start simple first and extend on top. Memcg v1 is full
of seemingly interesting and very generic concepts which turned out
being a headache long term.

> Hierarchies are memory consumers, we do account their usage,
> we do apply limits and guarantees for the hierarchies. The same is
> with OOM victim selection: we are reclaiming memory from the
> biggest consumer. Kill-all knob only defines the way _how_ we do that:
> by killing one or all processes.

But then you just enforce a structural restriction on your configuration
because
	root
        /  \
       A    D
      /\   
     B  C

is a different thing than
	root
        / | \
       B  C  D

And consider that the sole purpose of A might be a control over
a non-memory resource (e.g. a cpu share distribution). Why should we
discriminate B and C in such a case?

> Just for example, we might want to take memory.low into account at
> some point: prefer cgroups which are above their guarantees, avoid
> killing those who fit. It would be hard if we're comparing cgroups
> from different hierarchies.

This can be reflected in the memcg oom score calculation I believe. We
already do something similar during the reclaim.

> The same will be with introducing oom_priorities, which is much more
> required functionality.

More on that below.

> > Consider that it might be not your choice (as a user) how deep is your
> > leaf memcg. I can already see how people complain that their memcg has
> > been killed just because it was one level deeper in the hierarchy...
> 
> The kill-all functionality is enforced by parent, and it seems to be
> following the overall memcg design. The parent cgroup enforces memory
> limit, memory low limit, etc.

And the same is true for the memcg oom killer. It enforces the selection
to the out-of-memory subtree. We are trying to be proportional on the
size of the _reclaimable_ memory in that scope. Same way as with the
LRU reclaim. We do not prefer larger hierarchies over smaller. We just
iterate over those that have pages on LRUs (leaf memcgs with v2) and
scan/reclaim proportionally to their size. Why should the oom killer
decision be any different in that regards?

> I don't know why OOM control should be different.

I am not arguing that kill-all functionality on non-leaf is wrong. I
just haven't heard the usecase for it yet. I am also not opposed to
consider the cumulative size of non-leaf memcg if it is kill-all as the
cumulative size will be reclaimed then. But I fail to see why we should
prefer larger hierarchies when the resulting memcg victim is much
smaller in the end.

> > I would really start simple and only allow kill-all on leaf memcgs and
> > only compare leaf memcgs & root. If we ever need to kill whole
> > hierarchies then allow kill-all on intermediate memcgs as well and then
> > consider cumulative consumptions only on those that have kill-all
> > enabled.
> 
> This sounds hacky to me: the whole thing is depending on cgroup v2 and
> is additionally explicitly opt-in.
> 
> Why do we need to introduce such incomplete functionality first,
> and then suffer trying to extend it and provide backward compatibility?

Why would a backward compatibility be a problem? kill-all on non-leaf
memcgs should be seamless. We would simply allow setting the knob. Adding
a priority shouldn't be a problem either. A new knob would be added. Any
memcg with a non-zero priority would be considered during selection for
example (cumulative size would be considered as a tie-breaker for
non-leaf memcgs and a victim selected from the largest hierarchy/leaf
memcg - but that really needs to be thought through and hear about
specific usecases).
 
> Also, I think we should compare root cgroup with top-level cgroups,
> rather than leaf cgroups. A process in the root cgroup is definitely
> system-level entity, and we should compare it with other top-level
> entities (other containerized workloads), rather then some random
> leaf cgroup deep inside the tree. If we decided, that we're not comparing
> random tasks from different cgroups, why should we do this for leaf
> cgroups? Is sounds like making only one step towards right direction,
> while we can do more.

The main problem I have with that is mentioned above. A single hierarchy
enforces some structural constrains when multiple controllers are in
place.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
