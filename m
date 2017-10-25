Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 501D26B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 02:51:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id l196so22341104itl.15
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 23:51:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u133sor1130232ita.146.2017.10.24.23.51.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 23:51:33 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
In-Reply-To: <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
References: <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz> <20171012190312.GA5075@cmpxchg.org> <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz> <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz> <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz> <20171024160637.GB32340@cmpxchg.org> <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz> <20171024172330.GA3973@cmpxchg.org> <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz> <20171024185854.GA6154@cmpxchg.org> <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
Date: Tue, 24 Oct 2017 23:51:30 -0700
Message-ID: <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 24-10-17 14:58:54, Johannes Weiner wrote:
>> On Tue, Oct 24, 2017 at 07:55:58PM +0200, Michal Hocko wrote:
>> > On Tue 24-10-17 13:23:30, Johannes Weiner wrote:
>> > > On Tue, Oct 24, 2017 at 06:22:13PM +0200, Michal Hocko wrote:
>> > [...]
>> > > > What would prevent a runaway in case the only process in the memcg is
>> > > > oom unkillable then?
>> > > 
>> > > In such a scenario, the page fault handler would busy-loop right now.
>> > > 
>> > > Disabling oom kills is a privileged operation with dire consequences
>> > > if used incorrectly. You can panic the kernel with it. Why should the
>> > > cgroup OOM killer implement protective semantics around this setting?
>> > > Breaching the limit in such a setup is entirely acceptable.
>> > > 
>> > > Really, I think it's an enormous mistake to start modeling semantics
>> > > based on the most contrived and non-sensical edge case configurations.
>> > > Start the discussion with what is sane and what most users should
>> > > optimally experience, and keep the cornercases simple.
>> > 
>> > I am not really seeing your concern about the semantic. The most
>> > important property of the hard limit is to protect from runaways and
>> > stop them if they happen. Users can use the softer variant (high limit)
>> > if they are not afraid of those scenarios. It is not so insane to
>> > imagine that a master task (which I can easily imagine would be oom
>> > disabled) has a leak and runaway as a result.
>> 
>> Then you're screwed either way. Where do you return -ENOMEM in a page
>> fault path that cannot OOM kill anything? Your choice is between
>> maintaining the hard limit semantics or going into an infinite loop.
>
> in the PF path yes. And I would argue that this is a reasonable
> compromise to provide the gurantee the hard limit is giving us (and
> the resulting isolation which is the whole point). Btw. we are already
> having that behavior. All we are talking about is the non-PF path which
> ENOMEMs right now and the meta-patch tried to handle it more gracefully
> and only ENOMEM when there is no other option.
>
>> I fail to see how this setup has any impact on the semantics we pick
>> here. And even if it were real, it's really not what most users do.
>
> sure, such a scenario is really on the edge but my main point was that
> the hard limit is an enforcement of an isolation guarantee (as much as
> possible of course).
>
>> > We are not talking only about the page fault path. There are other
>> > allocation paths to consume a lot of memory and spill over and break
>> > the isolation restriction. So it makes much more sense to me to fail
>> > the allocation in such a situation rather than allow the runaway to
>> > continue. Just consider that such a situation shouldn't happen in
>> > the first place because there should always be an eligible task to
>> > kill - who would own all the memory otherwise?
>> 
>> Okay, then let's just stick to the current behavior.
>
> I am definitely not pushing that thing right now. It is good to discuss
> it, though. The more kernel allocations we will track the more careful we
> will have to be. So maybe we will have to reconsider the current
> approach. I am not sure we need it _right now_ but I feel we will
> eventually have to reconsider it.

The kernel already attempts to charge radix_tree_nodes.  If they fail
then we fallback to unaccounted memory.  So the memcg limit already
isn't an air tight constraint.

I agree that unchecked overcharging could be bad, but wonder if we could
overcharge kmem so long as there is a pending oom kill victim.  If
current is the victim or no victim, then fail allocations (as is
currently done).  The current thread can loop in syscall exit until
usage is reconciled (either via reclaim or kill).  This seems consistent
with pagefault oom handling and compatible with overcommit use case.

Here's an example of an overcommit case we've found quite useful.  Memcg A has
memory which is shared between children B and C.  B is more important the C.
B and C are unprivileged, neither has the authority to kill the other.

    /A(limit=100MB) - B(limit=80MB,prio=high)
                     \ C(limit=80MB,prio=low)

If memcg charge drives B.usage+C.usage>=A.limit, then C should be killed due to
its low priority.  B pagefault can kill, but if a syscall returns ENOMEM then B
can't do anything useful with it.

I know there are related oom killer victim selections discussions afoot.
Even with classic oom_score_adj killing it's possible to heavily bias
oom killer to select C over B.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
