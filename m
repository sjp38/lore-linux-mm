Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1326B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 14:16:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b195so9379081wmb.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:16:08 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s24si5174126edi.101.2017.09.25.11.16.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 11:16:05 -0700 (PDT)
Date: Mon, 25 Sep 2017 19:15:33 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170925181533.GA15918@castle>
References: <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
 <20170913215607.GA19259@castle>
 <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle>
 <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz>
 <20170915152301.GA29379@castle>
 <20170918061405.pcrf5vauvul4c2nr@dhcp22.suse.cz>
 <20170920215341.GA5382@castle>
 <20170925122400.4e7jh5zmuzvbggpe@dhcp22.suse.cz>
 <20170925170004.GA22704@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170925170004.GA22704@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 25, 2017 at 01:00:04PM -0400, Johannes Weiner wrote:
> On Mon, Sep 25, 2017 at 02:24:00PM +0200, Michal Hocko wrote:
> > I would really appreciate some feedback from Tejun, Johannes here.
> > 
> > On Wed 20-09-17 14:53:41, Roman Gushchin wrote:
> > > On Mon, Sep 18, 2017 at 08:14:05AM +0200, Michal Hocko wrote:
> > > > On Fri 15-09-17 08:23:01, Roman Gushchin wrote:
> > > > > On Fri, Sep 15, 2017 at 12:58:26PM +0200, Michal Hocko wrote:
> > [...]
> > > > > > But then you just enforce a structural restriction on your configuration
> > > > > > because
> > > > > > 	root
> > > > > >         /  \
> > > > > >        A    D
> > > > > >       /\   
> > > > > >      B  C
> > > > > > 
> > > > > > is a different thing than
> > > > > > 	root
> > > > > >         / | \
> > > > > >        B  C  D
> > > > > >
> > > > > 
> > > > > I actually don't have a strong argument against an approach to select
> > > > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > > > no much difference.
> > > 
> > > I've tried to implement this approach, and it's really arguable.
> > > Although your example looks reasonable, the opposite example is also valid:
> > > you might want to compare whole hierarchies, and it's a quite typical usecase.
> > > 
> > > Assume, you have several containerized workloads on a machine (probably,
> > > each will be contained in a memcg with memory.max set), with some hierarchy
> > > of cgroups inside. Then in case of global memory shortage we want to reclaim
> > > some memory from the biggest workload, and the selection should not depend
> > > on group_oom settings. It would be really strange, if setting group_oom will
> > > higher the chances to be killed.
> > > 
> > > In other words, let's imagine processes as leaf nodes in memcg tree. We decided
> > > to select the biggest memcg and kill one or more processes inside (depending
> > > on group_oom setting), but the memcg selection doesn't depend on it.
> > > We do not compare processes from different cgroups, as well as cgroups with
> > > processes. The same should apply to cgroups: why do we want to compare cgroups
> > > from different sub-trees?
> > > 
> > > While size-based comparison can be implemented with this approach,
> > > the priority-based is really weird (as David mentioned).
> > > If priorities have no hierarchical meaning at all, we lack the very important
> > > ability to enforce hierarchy oom_priority. Otherwise we have to invent some
> > > complex rules of oom_priority propagation (e.g. is someone is raising
> > > the oom_priority in parent, should it be applied to children immediately, etc).
> > 
> > I would really forget about the priority at this stage. This needs
> > really much more thinking and I consider the David's usecase very
> > specialized to use it as a template for a general purpose oom
> > prioritization. I might be wrong here of course...
> 
> No, I agree.
> 
> > > In any case, OOM is a last resort mechanism. The goal is to reclaim some memory
> > > and do not crash the system or do not leave it in totally broken state.
> > > Any really complex mm in userspace should be applied _before_ OOM happens.
> > > So, I don't think we have to support all possible configurations here,
> > > if we're able to achieve the main goal (kill some processes and do not leave
> > > broken systems/containers).
> > 
> > True but we want to have the semantic reasonably understandable. And it
> > is quite hard to explain that the oom killer hasn't selected the largest
> > memcg just because it happened to be in a deeper hierarchy which has
> > been configured to cover a different resource.
> 
> Going back to Michal's example, say the user configured the following:
> 
>        root
>       /    \
>      A      D
>     / \
>    B   C
> 
> A global OOM event happens and we find this:
> - A > D
> - B, C, D are oomgroups
> 
> What the user is telling us is that B, C, and D are compound memory
> consumers. They cannot be divided into their task parts from a memory
> point of view.
> 
> However, the user doesn't say the same for A: the A subtree summarizes
> and controls aggregate consumption of B and C, but without groupoom
> set on A, the user says that A is in fact divisible into independent
> memory consumers B and C.
> 
> If we don't have to kill all of A, but we'd have to kill all of D,
> does it make sense to compare the two?
> 
> Let's consider an extreme case of this conundrum:
> 
> 	root
>       /     \
>      A       B
>     /|\      |
>  A1-A1000    B1
> 
> Again we find:
> - A > B
> - A1 to A1000 and B1 are oomgroups
> But:
> - A1 to A1000 individually are tiny, B1 is huge
> 
> Going level by level, we'd pick A as the bigger hierarchy in the
> system, and then kill off one of the tiny groups A1 to A1000.
> 
> Conversely, going for biggest consumer regardless of hierarchy, we'd
> compare A1 to A1000 and B1, then pick B1 as the biggest single atomic
> memory consumer in the system and kill all its tasks.
> 
> Which one of these two fits both the purpose and our historic approach
> to OOM killing better?
> 
> As was noted in this thread, OOM is the last resort to avoid a memory
> deadlock. Killing the biggest consumer is most likely to resolve this
> precarious situation. It is also most likely to catch buggy software
> with memory leaks or runaway allocations, which is a nice bonus.
> 
> Killing a potentially tiny consumer inside the biggest top-level
> hierarchy doesn't achieve this. I think we can all agree on this.
> 
> But also, global OOM in particular means that the hierarchical
> approach to allocating the system's memory among cgroups has
> failed. The user expressed control over memory in a way that wasn't
> sufficient to isolate memory consumption between the different
> hierarchies. IMO what follows from that is that the hierarchy itself
> is a questionable guide to finding a culprit.
> 
> So I'm leaning toward the second model: compare all oomgroups and
> standalone tasks in the system with each other, independent of the
> failed hierarchical control structure. Then kill the biggest of them.

I'm not against this model, as I've said before. It feels logical,
and will work fine in most cases.

In this case we can drop any mount/boot options, because it preserves
the existing behavior in the default configuration. A big advantage.

The only thing, I'm slightly concerned, that due to the way how we calculate
the memory footprint for tasks and memory cgroups, we will have a number
of weird edge cases. For instance, when putting a single process into
the group_oom memcg will alter the oom_score significantly and result
in significantly different chances to be killed. An obvious example will
be a task with oom_score_adj set to any non-extreme (other than 0 and -1000)
value, but it can also happen in case of constrained alloc, for instance.

If it considered to be a minor issue, we can choose this approach.


Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
