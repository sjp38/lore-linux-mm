Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE936B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:29:35 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id b26so15951798qtb.18
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:29:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t9sor14828119qtg.139.2017.12.21.09.29.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 09:29:33 -0800 (PST)
Date: Thu, 21 Dec 2017 09:29:30 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Message-ID: <20171221172930.GF1084507@devbig577.frc2.facebook.com>
References: <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
 <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com>
 <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
 <20171220193741.GD3413940@devbig577.frc2.facebook.com>
 <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
 <20171220233658.GB1084507@devbig577.frc2.facebook.com>
 <CALvZod7eQWrD6LgbUrOvuhf5A1KKxBaK5t-U61gdFqvMeWXuzQ@mail.gmail.com>
 <20171221133726.GD1084507@devbig577.frc2.facebook.com>
 <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

Hello, Shakeel.

On Thu, Dec 21, 2017 at 07:22:20AM -0800, Shakeel Butt wrote:
> I am claiming memory allocations under global pressure will be
> affected by the performance of the underlying swap device. However
> memory allocations under memcg memory pressure, with memsw, will not
> be affected by the performance of the underlying swap device. A job
> having 100 MiB limit running on a machine without global memory
> pressure will never see swap on hitting 100 MiB memsw limit.

But, without global memory pressure, the swap wouldn't be making any
difference to begin with.  Also, when multiple cgroups are hitting
memsw limits, they'd behave as if swappiness is zero increasing load
on the filesystems, which then then of course will affect everyone
under memory pressure whether memsw or not.

> > On top of that, what's the point?
> >
> > 1. As I wrote earlier, given the current OOM killer implementation,
> >    whether OOM kicks in or not is not even that relevant in
> >    determining the health of the workload.  There are frequent failure
> >    modes where OOM killer fails to kick in while the workload isn't
> >    making any meaningful forward progress.
> >
> 
> Deterministic oom-killer is not the point. The point is to
> "consistently limit the anon memory" allocated by the job which only
> memsw can provide. A job owner who has requested 100 MiB for a job
> sees some instances of the job suffer at 100 MiB and other instances
> suffer at 150 MiB, is an inconsistent behavior.

So, the first part, I get.  memsw happens to be be able to limit the
amount of anon memory.  I really don't think that was the intention
but more of a byproduct that some people might find useful.

The example you listed tho doesn't make much sense to me.  Given two
systems with differing level of memory pressures, two instances can
see wildly different performance regardless of memsw.

> > 2. On hitting memsw limit, the OOM decision is dependent on the
> >    performance of the file backing devices.  Why is that necessarily
> >    better than being dependent on swap or both, which would increase
> >    the reclaim efficiency anyway?  You can't avoid being affected by
> >    the underlying hardware one way or the other.
> 
> This is a separate discussion but still the amount of file backed
> pages is known and controlled by the job owner and they have the
> option to use a storage service, providing a consistent performance
> across different data centers, instead of the physical disks of the
> system where the job is running and thus isolating the job's
> performance from the speed of the local disk. This is not possible
> with swap. The swap (and its performance) is and should be transparent
> to the job owners.

And, for your use case, there is a noticeable difference between file
backed and anonymous memories and that's why you want to limit
anonymous memory independently from file backed memory.

It looks like what you actually want is limiting the amount of
anonymous memory independently from file-backed consumptions because,
in your setup, while swap is always on local disk the file storages
are over network and more configurable / flexible.

Assuming I'm not misunderstanding you, here are my thoughts.

* I'm not sure that distinguishing anon and file backed memories like
  that is the direction we want to head.  In fact, the more uniform we
  can behave across them, the more efficient we'd be as we wouldn't
  have that artificial barrier.  It is true that we don't have the
  same level of control for swap tho.

* Even if we want an independent anon limit, memsw isn't the solution.
  It's too conflated.  If you want to have anon limit, the right thing
  to do would be pushing for an independent anon limit, not memsw.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
