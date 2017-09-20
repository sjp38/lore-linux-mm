Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFBD96B02C7
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:54:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e64so3968470wmi.0
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:54:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g16si227870edc.164.2017.09.20.14.54.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 14:54:08 -0700 (PDT)
Date: Wed, 20 Sep 2017 14:53:41 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170920215341.GA5382@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 18, 2017 at 08:14:05AM +0200, Michal Hocko wrote:
> On Fri 15-09-17 08:23:01, Roman Gushchin wrote:
> > On Fri, Sep 15, 2017 at 12:58:26PM +0200, Michal Hocko wrote:
> > > On Thu 14-09-17 09:05:48, Roman Gushchin wrote:
> > > > On Thu, Sep 14, 2017 at 03:40:14PM +0200, Michal Hocko wrote:
> > > > > On Wed 13-09-17 14:56:07, Roman Gushchin wrote:
> > > > > > On Wed, Sep 13, 2017 at 02:29:14PM +0200, Michal Hocko wrote:
> > > > > [...]
> > > > > > > I strongly believe that comparing only leaf memcgs
> > > > > > > is more straightforward and it doesn't lead to unexpected results as
> > > > > > > mentioned before (kill a small memcg which is a part of the larger
> > > > > > > sub-hierarchy).
> > > > > > 
> > > > > > One of two main goals of this patchset is to introduce cgroup-level
> > > > > > fairness: bigger cgroups should be affected more than smaller,
> > > > > > despite the size of tasks inside. I believe the same principle
> > > > > > should be used for cgroups.
> > > > > 
> > > > > Yes bigger cgroups should be preferred but I fail to see why bigger
> > > > > hierarchies should be considered as well if they are not kill-all. And
> > > > > whether non-leaf memcgs should allow kill-all is not entirely clear to
> > > > > me. What would be the usecase?
> > > > 
> > > > We definitely want to support kill-all for non-leaf cgroups.
> > > > A workload can consist of several cgroups and we want to clean up
> > > > the whole thing on OOM.
> > > 
> > > Could you be more specific about such a workload? E.g. how can be such a
> > > hierarchy handled consistently when its sub-tree gets killed due to
> > > internal memory pressure?
> > 
> > Or just system-wide OOM.
> > 
> > > Or do you expect that none of the subtree will
> > > have hard limit configured?
> > 
> > And this can also be a case: the whole workload may have hard limit
> > configured, while internal memcgs have only memory.low set for "soft"
> > prioritization.
> > 
> > > 
> > > But then you just enforce a structural restriction on your configuration
> > > because
> > > 	root
> > >         /  \
> > >        A    D
> > >       /\   
> > >      B  C
> > > 
> > > is a different thing than
> > > 	root
> > >         / | \
> > >        B  C  D
> > >
> > 
> > I actually don't have a strong argument against an approach to select
> > largest leaf or kill-all-set memcg. I think, in practice there will be
> > no much difference.

I've tried to implement this approach, and it's really arguable.
Although your example looks reasonable, the opposite example is also valid:
you might want to compare whole hierarchies, and it's a quite typical usecase.

Assume, you have several containerized workloads on a machine (probably,
each will be contained in a memcg with memory.max set), with some hierarchy
of cgroups inside. Then in case of global memory shortage we want to reclaim
some memory from the biggest workload, and the selection should not depend
on group_oom settings. It would be really strange, if setting group_oom will
higher the chances to be killed.

In other words, let's imagine processes as leaf nodes in memcg tree. We decided
to select the biggest memcg and kill one or more processes inside (depending
on group_oom setting), but the memcg selection doesn't depend on it.
We do not compare processes from different cgroups, as well as cgroups with
processes. The same should apply to cgroups: why do we want to compare cgroups
from different sub-trees?

While size-based comparison can be implemented with this approach,
the priority-based is really weird (as David mentioned).
If priorities have no hierarchical meaning at all, we lack the very important
ability to enforce hierarchy oom_priority. Otherwise we have to invent some
complex rules of oom_priority propagation (e.g. is someone is raising
the oom_priority in parent, should it be applied to children immediately, etc).

The oom_group knob meaning also becoms more complex. It affects both
the victim selection and OOM action. _ANY_ mechanism which allows to affect
OOM victim selection (either priorities, either bpf-based approach) should
not have global system-wide meaning, it breaks everything.

I do understand your point, but the same is true for other stuff, right?
E.g. cpu time distribution (and io, etc) depends on hierarchy configuration.
It's a limitation, but it's ok, as user should create a hierarchy which
reflects some logical relations between processes and groups of processes.
Otherwise we're going to the configuration hell.

In any case, OOM is a last resort mechanism. The goal is to reclaim some memory
and do not crash the system or do not leave it in totally broken state.
Any really complex mm in userspace should be applied _before_ OOM happens.
So, I don't think we have to support all possible configurations here,
if we're able to achieve the main goal (kill some processes and do not leave
broken systems/containers).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
