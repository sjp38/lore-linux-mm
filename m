Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12D2E6B0033
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 14:37:46 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c190so16220012qkb.12
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 11:37:46 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i19sor2734791qke.71.2017.12.20.11.37.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 11:37:44 -0800 (PST)
Date: Wed, 20 Dec 2017 11:37:41 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Message-ID: <20171220193741.GD3413940@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com>
 <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com>
 <20171219152444.GP3919388@devbig577.frc2.facebook.com>
 <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
 <20171219173354.GQ3919388@devbig577.frc2.facebook.com>
 <CALvZod7pbp0fFUPRnC68qdzkCEUg2YTavq6C6OLxqooCU5VeyQ@mail.gmail.com>
 <20171219214107.GR3919388@devbig577.frc2.facebook.com>
 <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5XRhXc3XrQw50Jw_OpRQB2iCCbgG-NMDCa8xRmGNdLrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

Hello, Shakeel.

On Tue, Dec 19, 2017 at 02:39:19PM -0800, Shakeel Butt wrote:
> Suppose a user wants to run multiple instances of a specific job on
> different datacenters and s/he has budget of 100MiB for each instance.
> The instances are schduled on the requested datacenters and the
> scheduler has set the memory limit of those instances to 100MiB. Now,
> some datacenters have swap deployed, so, there, let's say, the swap
> limit of those instances are set according to swap medium
> availability. In this setting the user will see inconsistent memcg OOM
> behavior. Some of the instances see OOMs at 100MiB usage (suppose only
> anon memory) while some will see OOMs way above 100MiB due to swap.
> So, the user is required to know the internal knowledge of datacenters
> (like which has swap or not and swap type) and has to set the limits
> accordingly and thus increase the chance of config bugs.

I don't understand how this invariant is useful across different
backing swap devices and availability.  e.g. Our OOM decisions are
currently not great in that the kernel can easily thrash for a very
long time without making actual progresses.  If you combine that with
widely varying types and availability of swaps, whether something is
OOMing or not doesn't really tell you much.  The workload could be
running completely fine or have been thrashing without making any
meaningful forward progress for the past 15 mins.

Given that whether or not swap exists, how much is avialable and how
fast the backing swap device is all highly influential parameters in
how the workload behaves, I don't see what having sum of memory + swap
as an invariant actually buys.  And, even that essentially meaningless
invariant doesn't really exist - the performance of the swap device
absolutely affects when the OOM killer would kick in.

So, I don't see how the sum of memory+swap makes it possible to ignore
the swap type and availability.  Can you please explain that further?

> Also different types and sizes of swap mediums in data center will
> further complicates the configuration. One datacenter might have SSD
> as a swap, another might be doing swap on zram and third might be
> doing swap on nvdimm. Each can have different size and can be assigned
> to jobs differently. So, it is possible that the instances of the same
> job might be assigned different swap limit on different datacenters.

Sure, but what does memswap achieve?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
