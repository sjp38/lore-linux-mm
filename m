Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCE486B0033
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 14:49:14 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id o2so8834765wmf.2
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:49:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b9sor5074208wmc.22.2017.12.27.11.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 11:49:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171221172930.GF1084507@devbig577.frc2.facebook.com>
References: <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
 <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com> <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
 <20171220193741.GD3413940@devbig577.frc2.facebook.com> <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
 <20171220233658.GB1084507@devbig577.frc2.facebook.com> <CALvZod7eQWrD6LgbUrOvuhf5A1KKxBaK5t-U61gdFqvMeWXuzQ@mail.gmail.com>
 <20171221133726.GD1084507@devbig577.frc2.facebook.com> <CALvZod432hzxPZgAypjPsZ33Z==0MxmMdPM3bEBZMea-7GFAVw@mail.gmail.com>
 <20171221172930.GF1084507@devbig577.frc2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 27 Dec 2017 11:49:08 -0800
Message-ID: <CALvZod4pkx8gE7HnFULrkywvH2Z-9zjMvjJY4n7d+NV8xYg18w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

Hi Tejun,

In my previous messages, I think the message "memsw improves the
performance of the job" might have been conveyed. Please ignore that.
The message I want to express is the "memsw provides users the ability
to consistently limit their job's memory (specifically anon memory)
irrespective of the presence of swap".

On Thu, Dec 21, 2017 at 9:29 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Shakeel.
>
> On Thu, Dec 21, 2017 at 07:22:20AM -0800, Shakeel Butt wrote:
>> I am claiming memory allocations under global pressure will be
>> affected by the performance of the underlying swap device. However
>> memory allocations under memcg memory pressure, with memsw, will not
>> be affected by the performance of the underlying swap device. A job
>> having 100 MiB limit running on a machine without global memory
>> pressure will never see swap on hitting 100 MiB memsw limit.
>
> But, without global memory pressure, the swap wouldn't be making any
> difference to begin with.

It would in the current cgroup-v2's swap interface. When a job hits
the memory.max (or memory.high), assuming the availability of swap and
job's swap usage, the kernel will swapout the anon pages of the job.

> Also, when multiple cgroups are hitting
> memsw limits, they'd behave as if swappiness is zero increasing load
> on the filesystems, which then then of course will affect everyone
> under memory pressure whether memsw or not.
>
>> > On top of that, what's the point?
>> >
>> > 1. As I wrote earlier, given the current OOM killer implementation,
>> >    whether OOM kicks in or not is not even that relevant in
>> >    determining the health of the workload.  There are frequent failure
>> >    modes where OOM killer fails to kick in while the workload isn't
>> >    making any meaningful forward progress.
>> >
>>
>> Deterministic oom-killer is not the point. The point is to
>> "consistently limit the anon memory" allocated by the job which only
>> memsw can provide. A job owner who has requested 100 MiB for a job
>> sees some instances of the job suffer at 100 MiB and other instances
>> suffer at 150 MiB, is an inconsistent behavior.
>
> So, the first part, I get.  memsw happens to be be able to limit the
> amount of anon memory.  I really don't think that was the intention
> but more of a byproduct that some people might find useful.
>
> The example you listed tho doesn't make much sense to me.  Given two
> systems with differing level of memory pressures, two instances can
> see wildly different performance regardless of memsw.
>

The word 'suffer' might have given the impression that I am concerned
about performance. Let me clarify, if the amount of memory a job can
allocate differs based on the swap availability of the system where it
ran, is an inconsistent behavior. The 'memsw' interface allows to
overcome that inconsistency.

>> > 2. On hitting memsw limit, the OOM decision is dependent on the
>> >    performance of the file backing devices.  Why is that necessarily
>> >    better than being dependent on swap or both, which would increase
>> >    the reclaim efficiency anyway?  You can't avoid being affected by
>> >    the underlying hardware one way or the other.
>>
>> This is a separate discussion but still the amount of file backed
>> pages is known and controlled by the job owner and they have the
>> option to use a storage service, providing a consistent performance
>> across different data centers, instead of the physical disks of the
>> system where the job is running and thus isolating the job's
>> performance from the speed of the local disk. This is not possible
>> with swap. The swap (and its performance) is and should be transparent
>> to the job owners.
>

Please ignore this "separate discussion" as I do not want to lead the
discussion towards the "performance" of file storages or swap mediums.

> And, for your use case, there is a noticeable difference between file
> backed and anonymous memories and that's why you want to limit
> anonymous memory independently from file backed memory.
>
> It looks like what you actually want is limiting the amount of
> anonymous memory independently from file-backed consumptions because,
> in your setup, while swap is always on local disk the file storages
> are over network and more configurable / flexible.
>

What I want is a job having 100 MiB memory limit should not be able to
allocate anon memory more than 100 MiB irrespective of the
availability of the swap. I can see that a separate anon limit can be
used to achieve my goal but I am failing to see why memsw, which can
also be used to achieve my goal and is already implemented, is not
right direction or solution.

> Assuming I'm not misunderstanding you, here are my thoughts.
>
> * I'm not sure that distinguishing anon and file backed memories like
>   that is the direction we want to head.  In fact, the more uniform we
>   can behave across them, the more efficient we'd be as we wouldn't
>   have that artificial barrier.  It is true that we don't have the
>   same level of control for swap tho.
>

I totally agree about the uniform behavior (& no artificial barriers)
but I don't understand how 'memsw' will lead to opposite direction.
'memsw' is an interface that can simultaneously limit anon, file and
kmem of the job.

> * Even if we want an independent anon limit, memsw isn't the solution.
>   It's too conflated.

I am confused. If we want a solution which has uniform behavior across
file, anon & kmem and without any artificial barrier, how would that
not be conflated?

>   If you want to have anon limit, the right thing
>   to do would be pushing for an independent anon limit, not memsw.
>

Though I agree that a separate anon limit will work for me. I am
hesitant to push for that direction due to:

1. The alternative solution, i.e. 'memsw', already exist.
2. What will be the semantics of memory.high under new anon limit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
