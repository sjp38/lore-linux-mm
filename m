Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4263E6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:24:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b9so8879621wra.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:24:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si4936646edd.462.2017.09.25.05.24.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 05:24:01 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:24:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920215341.GA5382@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

I would really appreciate some feedback from Tejun, Johannes here.

On Wed 20-09-17 14:53:41, Roman Gushchin wrote:
> On Mon, Sep 18, 2017 at 08:14:05AM +0200, Michal Hocko wrote:
> > On Fri 15-09-17 08:23:01, Roman Gushchin wrote:
> > > On Fri, Sep 15, 2017 at 12:58:26PM +0200, Michal Hocko wrote:
[...]
> > > > But then you just enforce a structural restriction on your configuration
> > > > because
> > > > 	root
> > > >         /  \
> > > >        A    D
> > > >       /\   
> > > >      B  C
> > > > 
> > > > is a different thing than
> > > > 	root
> > > >         / | \
> > > >        B  C  D
> > > >
> > > 
> > > I actually don't have a strong argument against an approach to select
> > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > no much difference.
> 
> I've tried to implement this approach, and it's really arguable.
> Although your example looks reasonable, the opposite example is also valid:
> you might want to compare whole hierarchies, and it's a quite typical usecase.
> 
> Assume, you have several containerized workloads on a machine (probably,
> each will be contained in a memcg with memory.max set), with some hierarchy
> of cgroups inside. Then in case of global memory shortage we want to reclaim
> some memory from the biggest workload, and the selection should not depend
> on group_oom settings. It would be really strange, if setting group_oom will
> higher the chances to be killed.
> 
> In other words, let's imagine processes as leaf nodes in memcg tree. We decided
> to select the biggest memcg and kill one or more processes inside (depending
> on group_oom setting), but the memcg selection doesn't depend on it.
> We do not compare processes from different cgroups, as well as cgroups with
> processes. The same should apply to cgroups: why do we want to compare cgroups
> from different sub-trees?
> 
> While size-based comparison can be implemented with this approach,
> the priority-based is really weird (as David mentioned).
> If priorities have no hierarchical meaning at all, we lack the very important
> ability to enforce hierarchy oom_priority. Otherwise we have to invent some
> complex rules of oom_priority propagation (e.g. is someone is raising
> the oom_priority in parent, should it be applied to children immediately, etc).

I would really forget about the priority at this stage. This needs
really much more thinking and I consider the David's usecase very
specialized to use it as a template for a general purpose oom
prioritization. I might be wrong here of course...

> The oom_group knob meaning also becoms more complex. It affects both
> the victim selection and OOM action. _ANY_ mechanism which allows to affect
> OOM victim selection (either priorities, either bpf-based approach) should
> not have global system-wide meaning, it breaks everything.
> 
> I do understand your point, but the same is true for other stuff, right?
> E.g. cpu time distribution (and io, etc) depends on hierarchy configuration.
> It's a limitation, but it's ok, as user should create a hierarchy which
> reflects some logical relations between processes and groups of processes.
> Otherwise we're going to the configuration hell.

And that is _exactly_ my concern. We surely do not want tell people that
they have to consider their cgroup tree structure to control the global
oom behavior. You simply do not have that constrain with leaf-only
semantic and if kill-all intermediate nodes are used then there is an
explicit opt-in for the hierarchy considerations.

> In any case, OOM is a last resort mechanism. The goal is to reclaim some memory
> and do not crash the system or do not leave it in totally broken state.
> Any really complex mm in userspace should be applied _before_ OOM happens.
> So, I don't think we have to support all possible configurations here,
> if we're able to achieve the main goal (kill some processes and do not leave
> broken systems/containers).

True but we want to have the semantic reasonably understandable. And it
is quite hard to explain that the oom killer hasn't selected the largest
memcg just because it happened to be in a deeper hierarchy which has
been configured to cover a different resource.

I am sorry to repeat my self and I will not argue if there is a
prevalent agreement that level-by-level comparison is considered
desirable and documented behavior but, by all means, do not define this
semantic based on a priority requirements and/or implementation details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
