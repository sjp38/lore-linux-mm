Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3BE86B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 12:40:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l188so19807055pfc.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 09:40:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k63si7018049pge.222.2017.10.05.09.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 09:40:12 -0700 (PDT)
Date: Thu, 5 Oct 2017 18:40:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v10 5/6] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171005163857.qiifnaq46aoiq2ga@dhcp22.suse.cz>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-6-guro@fb.com>
 <20171004200453.GE1501@cmpxchg.org>
 <20171005131419.4o6qynsl2qxomekb@dhcp22.suse.cz>
 <20171005144803.GA5733@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005144803.GA5733@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 10:54:01, Johannes Weiner wrote:
> On Thu, Oct 05, 2017 at 03:14:19PM +0200, Michal Hocko wrote:
> > On Wed 04-10-17 16:04:53, Johannes Weiner wrote:
> > [...]
> > > That will silently ignore what the user writes to the memory.oom_group
> > > control files across the system's cgroup tree.
> > > 
> > > We'll have a knob that lets the workload declare itself an indivisible
> > > memory consumer, that it would like to get killed in one piece, and
> > > it's silently ignored because of a mount option they forgot to pass.
> > > 
> > > That's not good from an interface perspective.
> > 
> > Yes and that is why I think a boot time knob would be the most simple
> > way. It will also open doors for more oom policies in future which I
> > believe come sooner or later.
> 
> A boot time knob makes less sense to me than the mount option. It
> doesn't require a reboot to change this behavior, we shouldn't force
> the user to reboot when a runtime configuration is possible.

Do we need such a runtime configurability, though? If yes, what is the
usecase?

> But I don't see how dropping this patch as part of this series would
> prevent adding modular oom policies in the future?

I didn't say that dropping this patch would prevent further oom policies.
My point was that a command line option could be more generic to allow
more policies in future.

> That said, selectable OOM policies sound like a total deadend to
> me. The kernel OOM happens way too late to be useful for any kind of
> resource policy already. Even now it won't prevent you from thrashing
> indefinitely, with only 5% of your workload's time spent productively.
> 
> What kind of service quality do you have at this point?

The OOM killer is a disruptive operation which can be really costly
from the workload perspective (you are losing work) and as such the
victim selection really depends on the workload. Most of them are just
fine with the most rudimentary kill-the-largest approach but think of
workloads where the amount or type of work really matters much more
(think of a long running computational jobs taking weeks). We cannot
really handle all of those so I really expect that we will eventually
have to provide a way to allow different policies _somehow_.

> The *minority* of our OOM situations (in terms of "this isn't making
> real progress anymore due to a lack of memory") is even *seeing* OOM
> kills at this point. And it'll get worse as storage gets faster and
> memory bigger.

This is imho a separate problem which is independent on the oom victim
selection.

> How is that useful as a resource arbitration point?
> 
> Then there is the question of reliability. I mean, we still don't have
> a global OOM killer that is actually free from deadlocks.

Well, I believe that we should be deadlock free now.

> We don't
> have reserves measured to the exact requirements of reclaim that would
> guarantee recovery, the OOM reaper requires a lock that we hope isn't
> taken, etc. I wouldn't want any of my fleet to rely on this for
> regular operation - I'm just glad that, when we do mess up and hit
> this event, we don't have to reboot.
> 
> It makes much more sense to monitor memory pressure from userspace and
> smartly intervene when things turn unproductive, which is a long way
> from the point where the kernel is about to *deadlock* due to memory.

again this is independent on the oom selection policy.
 
> Global OOM kills can still happen, but their goal should really be 1)
> to save the kernel, 2) respect the integrity of a memory consumer and
> 3) be comprehensible to userspace. (These patches are about 2 and 3.)

I agree on these but I would add 4) make sure that the impact on the
system is acceptable/least disruptive possible.

> But abstracting such a rudimentary and fragile deadlock avoidance
> mechanism into higher-level resource management, or co-opting it as a
> policy enforcement tool, is crazy to me.
> 
> And it seems reckless to present it as those things to our users by
> encoding any such elaborate policy interfaces.
> 
> > > On the other hand, the only benefit of this patch is to shield users
> > > from changes to the OOM killing heuristics. Yet, it's really hard to
> > > imagine that modifying the victim selection process slightly could be
> > > called a regression in any way. We have done that many times over,
> > > without a second thought on backwards compatibility:
> > > 
> > > 5e9d834a0e0c oom: sacrifice child with highest badness score for parent
> > > a63d83f427fb oom: badness heuristic rewrite
> > > 778c14affaf9 mm, oom: base root bonus on current usage
> > 
> > yes we have changed that without a deeper considerations. Some of those
> > changes are arguable (e.g. child scarification). The oom badness
> > heuristic rewrite has triggered quite some complains AFAIR (I remember
> > Kosaki has made several attempts to revert it). I think that we are
> > trying to be more careful about user visible changes than we used to be.
> 
> Whatever grumbling might have come up, it has not resulted in a revert
> or a way to switch back to the old behavior. So I don't think this can
> be considered an actual regression.
> 
> We change heuristics in the MM all the time. If you track for example
> allocator behavior over different kernel versions, you can see how
> much our caching policy, our huge page policy etc. fluctuates. The
> impact of that is way bigger to regular workloads than how we go about
> choosing an OOM victim.

And some of those examples have taught me to be much more careful when
imposing features users are not really asking for (remember the THP by
default story?). I have handled many OOM reports last years and I _know_
for fact that people are very sensitive to the oom victim selection.
 
> We don't want to regress anybody, but let's also keep perspective here
> and especially consider the userspace interfaces we are willing to put
> in for at least the next few years, the promises we want to make, the
> further fragmentation of the config space, for such a negligible risk.

Well, I thought the opt-in aspect has been already agreed on and my
ack is based on that assumption. I do not really care what will be
the mechanism to do so but I _strongly_ believe that enabling this feature
automatically just because cgroupv2 is enabled is a wrong approach. I
will not nack the patchset if there is a broader agreement that this is
acceptable but you have to live without my acks.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
