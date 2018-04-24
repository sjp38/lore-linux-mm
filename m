Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83D0B6B0006
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 20:56:24 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id x2-v6so10875878ybm.1
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 17:56:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o187-v6sor2712545ybg.145.2018.04.23.17.56.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 17:56:22 -0700 (PDT)
MIME-Version: 1.0
References: <20180320223353.5673-1-guro@fb.com> <20180422202612.127760-1-gthelen@google.com>
 <20180423103804.GA12648@castle.DHCP.thefacebook.com>
In-Reply-To: <20180423103804.GA12648@castle.DHCP.thefacebook.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 24 Apr 2018 00:56:09 +0000
Message-ID: <CAHH2K0bDXrs+J3jWB1X7wphRMoLgjVUTAAFNLGFarDeAfRhA7Q@mail.gmail.com>
Subject: Re: [RFC PATCH 0/2] memory.low,min reclaim
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 23, 2018 at 3:38 AM Roman Gushchin <guro@fb.com> wrote:

> Hi, Greg!

> On Sun, Apr 22, 2018 at 01:26:10PM -0700, Greg Thelen wrote:
> > Roman's previously posted memory.low,min patches add per memcg effective
> > low limit to detect overcommitment of parental limits.  But if we flip
> > low,min reclaim to bail if usage<{low,min} at any level, then we don't
need
> > an effective low limit, which makes the code simpler.  When parent
limits
> > are overcommited memory.min will oom kill, which is more drastic but
makes
> > the memory.low a simpler concept.  If memcg a/b wants oom kill before
> > reclaim, then give it to them.  It seems a bit strange for
a/b/memory.low's
> > behaviour to depend on a/c/memory.low (i.e. a/b.low is strong unless
> > a/b.low+a/c.low exceed a.low).

> It's actually not strange: a/b and a/c are sharing a common resource:
> a/memory.low.

> Exactly as a/b/memory.max and a/c/memory.max are sharing a/memory.max.
> If there are sibling cgroups which are consuming memory, a cgroup can't
> exceed parent's memory.max, even if its memory.max is grater.

> >
> > I think there might be a simpler way (ableit it doesn't yet include
> > Documentation):
> > - memcg: fix memory.low
> > - memcg: add memory.min
> >  3 files changed, 75 insertions(+), 6 deletions(-)
> >
> > The idea of this alternate approach is for memory.low,min to avoid
reclaim
> > if any portion of under-consideration memcg ancestry is under respective
> > limit.

> This approach has a significant downside: it breaks hierarchical
constraints
> for memory.low/min. There are two important outcomes:

> 1) Any leaf's memory.low/min value is respected, even if parent's value
>           is lower or even 0. It's not possible anymore to limit the amount
of
>           protected memory for a sub-tree.
>           This is especially bad in case of delegation.

As someone who has been using something like memory.min for a while, I have
cases where it needs to be a strong protection.  Such jobs prefer oom kill
to reclaim.  These jobs know they need X MB of memory.  But I guess it's on
me to avoid configuring machines which overcommit memory.min at such cgroup
levels all the way to the root.

> 2) If a cgroup has an ancestor with the usage under its memory.low/min,
>           it becomes protection, even if its memory.low/min is 0. So it
becomes
>           impossible to have unprotected cgroups in protected sub-tree.

Fair point.

One use case is where a non trivial job which has several memory accounting
subcontainers.  Is there a way to only set memory.low at the top and have
the offer protection to the job?
The case I'm thinking of is:
% cd /cgroup
% echo +memory > cgroup.subtree_control
% mkdir top
% echo +memory > top/cgroup.subtree_control
% mkdir top/part1 top/part2
% echo 1GB > top/memory.min
% (echo $BASHPID > top/part1/cgroup.procs && part1)
% (echo $BASHPID > top/part2/cgroup.procs && part2)

Empirically it's been measured that the entire workload (/top) needs 1GB to
perform well.  But we don't care how the memory is distributed between
part1,part2.  Is the strategy for that to set /top, /top/part1.min, and
/top/part2.min to 1GB?

What do you think about exposing emin and elow to user space?  I think that
would reduce admin/user confusion in situations where memory.min is
internally discounted.

(tangent) Delegation in v2 isn't something I've been able to fully
internalize yet.
The "no interior processes" rule challenges my notion of subdelegation.
My current model is where a system controller creates a container C with
C.min and then starts client manager process M in C.  Then M can choose
to further divide C's resources (e.g. C/S).  This doesn't seem possible
because v2 doesn't allow for interior processes.  So the system manager
would need to create C, set C.low, create C/sub_manager, create
C/sub_resources, set C/sub_manager.low, set C/sub_resources.low, then start
M in C/sub_manager.  Then sub_manager can create and manage
C/sub_resources/S.

PS: Thanks for the memory.low and memory.min work.  Regardless of how we
proceed it's better than the upstream memory.soft_limit_in_bytes!
