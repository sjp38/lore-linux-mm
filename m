Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 710D16B0069
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 15:27:25 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u60so1237439wrb.10
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 12:27:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor8406624wre.0.2017.12.20.12.27.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 12:27:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
References: <20171219000131.149170-1-shakeelb@google.com> <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
 <20171219152444.GP3919388@devbig577.frc2.facebook.com> <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com> <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com> <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
 <20171220193741.GD3413940@devbig577.frc2.facebook.com> <CALvZod7Z1Yh+ZhU8qxzSiN0Pph2R7O4Mki5E23FbJFAzhyCH8g@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 20 Dec 2017 12:27:22 -0800
Message-ID: <CALvZod5ehycMTpSSaHwSchL_b9E6Ja6uwZB-cPT2KWg2kb=8sQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Wed, Dec 20, 2017 at 12:15 PM, Shakeel Butt <shakeelb@google.com> wrote:
> On Wed, Dec 20, 2017 at 11:37 AM, Tejun Heo <tj@kernel.org> wrote:
>> Hello, Shakeel.
>>
>> On Tue, Dec 19, 2017 at 02:39:19PM -0800, Shakeel Butt wrote:
>>> Suppose a user wants to run multiple instances of a specific job on
>>> different datacenters and s/he has budget of 100MiB for each instance.
>>> The instances are schduled on the requested datacenters and the
>>> scheduler has set the memory limit of those instances to 100MiB. Now,
>>> some datacenters have swap deployed, so, there, let's say, the swap
>>> limit of those instances are set according to swap medium
>>> availability. In this setting the user will see inconsistent memcg OOM
>>> behavior. Some of the instances see OOMs at 100MiB usage (suppose only
>>> anon memory) while some will see OOMs way above 100MiB due to swap.
>>> So, the user is required to know the internal knowledge of datacenters
>>> (like which has swap or not and swap type) and has to set the limits
>>> accordingly and thus increase the chance of config bugs.
>>
>> I don't understand how this invariant is useful across different
>> backing swap devices and availability.  e.g. Our OOM decisions are
>> currently not great in that the kernel can easily thrash for a very
>> long time without making actual progresses.  If you combine that with
>> widely varying types and availability of swaps,
>
> The kernel never swaps out on hitting memsw limit. So, the varying
> types and availability of swaps becomes invariant to the memcg OOM
> behavior of the job.
>
>> whether something is
>> OOMing or not doesn't really tell you much.  The workload could be
>> running completely fine or have been thrashing without making any
>> meaningful forward progress for the past 15 mins.
>>
>> Given that whether or not swap exists, how much is avialable and how
>> fast the backing swap device is all highly influential parameters in
>> how the workload behaves, I don't see what having sum of memory + swap
>> as an invariant actually buys.  And, even that essentially meaningless
>> invariant doesn't really exist - the performance of the swap device
>> absolutely affects when the OOM killer would kick in.
>>
>
> No, as I previously explained, the swap types and availability will be
> transparent to the memcg OOM killer and memcg memory reclaim behavior.
>
>> So, I don't see how the sum of memory+swap makes it possible to ignore
>> the swap type and availability.  Can you please explain that further?
>>
>>> Also different types and sizes of swap mediums in data center will
>>> further complicates the configuration. One datacenter might have SSD
>>> as a swap, another might be doing swap on zram and third might be
>>> doing swap on nvdimm. Each can have different size and can be assigned
>>> to jobs differently. So, it is possible that the instances of the same
>>> job might be assigned different swap limit on different datacenters.
>>
>> Sure, but what does memswap achieve?
>>
>
> 1. memswap provides consistent memcg OOM killer and memcg memory
> reclaim behavior independent to swap.
> 2. With memswap, the job owners do not have to think or worry about swaps.

When I say OOM and memory reclaim behavior, I specifically mean memcg
oom-kill and memcg memory reclaim behavior. These are different from
global oom-killer and global memory reclaim behaviors. The global
behaviors will be affected by the types and availability of swaps and
the jobs can suffer differently based on swap types and availability
on hitting global OOM scenario.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
