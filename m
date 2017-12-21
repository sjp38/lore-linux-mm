Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05CEF6B025F
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 10:22:24 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w141so4182400wme.1
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 07:22:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m199sor2125942wma.74.2017.12.21.07.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 07:22:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171221133726.GD1084507@devbig577.frc2.facebook.com>
References: <20171219152444.GP3919388@devbig577.frc2.facebook.com>
 <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com> <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com> <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
 <20171220193741.GD3413940@devbig577.frc2.facebook.com> <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
 <20171220233658.GB1084507@devbig577.frc2.facebook.com> <CALvZod7eQWrD6LgbUrOvuhf5A1KKxBaK5t-U61gdFqvMeWXuzQ@mail.gmail.com>
 <20171221133726.GD1084507@devbig577.frc2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 21 Dec 2017 07:22:20 -0800
Message-ID: <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Thu, Dec 21, 2017 at 5:37 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Shakeel.
>
> On Wed, Dec 20, 2017 at 05:15:41PM -0800, Shakeel Butt wrote:
>> Let's say we have a job that allocates 100 MiB memory and suppose 80
>> MiB is anon and 20 MiB is non-anon (file & kmem).
>>
>> [With memsw] Scheduler sets the memsw limit of the job to 100 MiB and
>> memory to max. Now suppose the job tries to allocates memory more than
>> 100 MiB, it will hit the memsw limit and will try to reclaim non-anon
>> memory. The memcg OOM behavior will only depend on the reclaim of
>> non-anon memory and will be independent of the underlying swap device.
>
> Sure, the direct reclaim on memsw limit won't reclaim anon pages, but
> think about how the state at that point would have formed.  You're
> claiming that memsw makes memory allocation and balancing behavior an
> invariant against the performance of the swap device that the machine
> has.  It's simply not possible.
>

I am claiming memory allocations under global pressure will be
affected by the performance of the underlying swap device. However
memory allocations under memcg memory pressure, with memsw, will not
be affected by the performance of the underlying swap device. A job
having 100 MiB limit running on a machine without global memory
pressure will never see swap on hitting 100 MiB memsw limit.

> On top of that, what's the point?
>
> 1. As I wrote earlier, given the current OOM killer implementation,
>    whether OOM kicks in or not is not even that relevant in
>    determining the health of the workload.  There are frequent failure
>    modes where OOM killer fails to kick in while the workload isn't
>    making any meaningful forward progress.
>

Deterministic oom-killer is not the point. The point is to
"consistently limit the anon memory" allocated by the job which only
memsw can provide. A job owner who has requested 100 MiB for a job
sees some instances of the job suffer at 100 MiB and other instances
suffer at 150 MiB, is an inconsistent behavior.

> 2. On hitting memsw limit, the OOM decision is dependent on the
>    performance of the file backing devices.  Why is that necessarily
>    better than being dependent on swap or both, which would increase
>    the reclaim efficiency anyway?  You can't avoid being affected by
>    the underlying hardware one way or the other.
>

This is a separate discussion but still the amount of file backed
pages is known and controlled by the job owner and they have the
option to use a storage service, providing a consistent performance
across different data centers, instead of the physical disks of the
system where the job is running and thus isolating the job's
performance from the speed of the local disk. This is not possible
with swap. The swap (and its performance) is and should be transparent
to the job owners.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
