Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9ED6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:10:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so21194954wre.23
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 03:10:07 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h55si39851edb.222.2018.04.24.03.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 03:10:05 -0700 (PDT)
Date: Tue, 24 Apr 2018 11:09:33 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 0/2] memory.low,min reclaim
Message-ID: <20180424100926.GA23745@castle.DHCP.thefacebook.com>
References: <20180320223353.5673-1-guro@fb.com>
 <20180422202612.127760-1-gthelen@google.com>
 <20180423103804.GA12648@castle.DHCP.thefacebook.com>
 <CAHH2K0bDXrs+J3jWB1X7wphRMoLgjVUTAAFNLGFarDeAfRhA7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAHH2K0bDXrs+J3jWB1X7wphRMoLgjVUTAAFNLGFarDeAfRhA7Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 24, 2018 at 12:56:09AM +0000, Greg Thelen wrote:
> On Mon, Apr 23, 2018 at 3:38 AM Roman Gushchin <guro@fb.com> wrote:
> 
> > Hi, Greg!
> 
> > On Sun, Apr 22, 2018 at 01:26:10PM -0700, Greg Thelen wrote:
> > > Roman's previously posted memory.low,min patches add per memcg effective
> > > low limit to detect overcommitment of parental limits.  But if we flip
> > > low,min reclaim to bail if usage<{low,min} at any level, then we don't
> > > need an effective low limit, which makes the code simpler.  When parent
> > > limits are overcommited memory.min will oom kill, which is more drastic but
> > > makes the memory.low a simpler concept.  If memcg a/b wants oom kill before
> > > reclaim, then give it to them.  It seems a bit strange for a/b/memory.low's
> > > behaviour to depend on a/c/memory.low (i.e. a/b.low is strong unless
> > > a/b.low+a/c.low exceed a.low).
> 
> > It's actually not strange: a/b and a/c are sharing a common resource:
> > a/memory.low.
> 
> > Exactly as a/b/memory.max and a/c/memory.max are sharing a/memory.max.
> > If there are sibling cgroups which are consuming memory, a cgroup can't
> > exceed parent's memory.max, even if its memory.max is grater.
> 
> > >
> > > I think there might be a simpler way (ableit it doesn't yet include
> > > Documentation):
> > > - memcg: fix memory.low
> > > - memcg: add memory.min
> > >  3 files changed, 75 insertions(+), 6 deletions(-)
> > >
> > > The idea of this alternate approach is for memory.low,min to avoid
> reclaim
> > > if any portion of under-consideration memcg ancestry is under respective
> > > limit.
> 
> > This approach has a significant downside: it breaks hierarchical
> constraints
> > for memory.low/min. There are two important outcomes:
> 
> > 1) Any leaf's memory.low/min value is respected, even if parent's value
> >           is lower or even 0. It's not possible anymore to limit the amount
> of
> >           protected memory for a sub-tree.
> >           This is especially bad in case of delegation.
> 
> As someone who has been using something like memory.min for a while, I have
> cases where it needs to be a strong protection.  Such jobs prefer oom kill
> to reclaim.  These jobs know they need X MB of memory.  But I guess it's on
> me to avoid configuring machines which overcommit memory.min at such cgroup
> levels all the way to the root.

Absolutely.

> 
> > 2) If a cgroup has an ancestor with the usage under its memory.low/min,
> >           it becomes protection, even if its memory.low/min is 0. So it
> becomes
> >           impossible to have unprotected cgroups in protected sub-tree.
> 
> Fair point.
> 
> One use case is where a non trivial job which has several memory accounting
> subcontainers.  Is there a way to only set memory.low at the top and have
> the offer protection to the job?
> The case I'm thinking of is:
> % cd /cgroup
> % echo +memory > cgroup.subtree_control
> % mkdir top
> % echo +memory > top/cgroup.subtree_control
> % mkdir top/part1 top/part2
> % echo 1GB > top/memory.min
> % (echo $BASHPID > top/part1/cgroup.procs && part1)
> % (echo $BASHPID > top/part2/cgroup.procs && part2)
> 
> Empirically it's been measured that the entire workload (/top) needs 1GB to
> perform well.  But we don't care how the memory is distributed between
> part1,part2.  Is the strategy for that to set /top, /top/part1.min, and
> /top/part2.min to 1GB?

The problem is that right now we don't have an "undefined" value for
memory.min/low. The default value is 0, which means "no protection".
So there is no way how a user can express "whatever parent cgroup wants".
It might be useful to introduce such value, as other controllers
may benefit too. But it's a separate theme to discuss.

In your example, it's possible to achieve the requested behavior by setting
top.min into 1G and part1.min and part2.min into "max".

> 
> What do you think about exposing emin and elow to user space?  I think that
> would reduce admin/user confusion in situations where memory.min is
> internally discounted.

They might be useful in some cases (e.g. a cgroup want's to know how much
actual protection it can get), but at the same time these values are
intentionally racy and don't have a clear semantics.
So, maybe we can show them in memory.stat, but I doubt that they deserve
a separate interface file.

> 
> (tangent) Delegation in v2 isn't something I've been able to fully
> internalize yet.
> The "no interior processes" rule challenges my notion of subdelegation.
> My current model is where a system controller creates a container C with
> C.min and then starts client manager process M in C.  Then M can choose
> to further divide C's resources (e.g. C/S).  This doesn't seem possible
> because v2 doesn't allow for interior processes.  So the system manager
> would need to create C, set C.low, create C/sub_manager, create
> C/sub_resources, set C/sub_manager.low, set C/sub_resources.low, then start
> M in C/sub_manager.  Then sub_manager can create and manage
> C/sub_resources/S.

And this is a good example of a case, when some cgroups in the tree
should be protected to work properly (for example, C/sub_manager/memory.low = 128M),
while an actual workload might be not (C/sub_resources/memory.low = 0).

Thanks!
