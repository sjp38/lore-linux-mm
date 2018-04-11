Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAEBA6B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 23:11:05 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e9so643399ioj.18
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 20:11:05 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r75-v6si323550ith.87.2018.04.10.20.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 20:11:03 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
In-Reply-To: <20180403133115.GA5501@dhcp22.suse.cz>
Date: Tue, 10 Apr 2018 20:10:24 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <502E8C16-DEA1-40A5-85CB-923E3ABE0B45@oracle.com>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
 <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
 <20180403133115.GA5501@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org


> On Apr 3, 2018, at 6:31 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Mon 02-04-18 09:24:22, Buddy Lumpkin wrote:
>> Page replacement is handled in the Linux Kernel in one of two ways:
>>=20
>> 1) Asynchronously via kswapd
>> 2) Synchronously, via direct reclaim
>>=20
>> At page allocation time the allocating task is immediately given a =
page
>> from the zone free list allowing it to go right back to work doing
>> whatever it was doing; Probably directly or indirectly executing =
business
>> logic.
>>=20
>> Just prior to satisfying the allocation, free pages is checked to see =
if
>> it has reached the zone low watermark and if so, kswapd is awakened.
>> Kswapd will start scanning pages looking for inactive pages to evict =
to
>> make room for new page allocations. The work of kswapd allows tasks =
to
>> continue allocating memory from their respective zone free list =
without
>> incurring any delay.
>>=20
>> When the demand for free pages exceeds the rate that kswapd tasks can
>> supply them, page allocation works differently. Once the allocating =
task
>> finds that the number of free pages is at or below the zone min =
watermark,
>> the task will no longer pull pages from the free list. Instead, the =
task
>> will run the same CPU-bound routines as kswapd to satisfy its own
>> allocation by scanning and evicting pages. This is called a direct =
reclaim.
>>=20
>> The time spent performing a direct reclaim can be substantial, often
>> taking tens to hundreds of milliseconds for small order0 allocations =
to
>> half a second or more for order9 huge-page allocations. In fact, =
kswapd is
>> not actually required on a linux system. It exists for the sole =
purpose of
>> optimizing performance by preventing direct reclaims.
>>=20
>> When memory shortfall is sufficient to trigger direct reclaims, they =
can
>> occur in any task that is running on the system. A single aggressive
>> memory allocating task can set the stage for collateral damage to =
occur in
>> small tasks that rarely allocate additional memory. Consider the =
impact of
>> injecting an additional 100ms of latency when nscd allocates memory =
to
>> facilitate caching of a DNS query.
>>=20
>> The presence of direct reclaims 10 years ago was a fairly reliable
>> indicator that too much was being asked of a Linux system. Kswapd was
>> likely wasting time scanning pages that were ineligible for eviction.
>> Adding RAM or reducing the working set size would usually make the =
problem
>> go away. Since then hardware has evolved to bring a new struggle for
>> kswapd. Storage speeds have increased by orders of magnitude while =
CPU
>> clock speeds stayed the same or even slowed down in exchange for more
>> cores per package. This presents a throughput problem for a single
>> threaded kswapd that will get worse with each generation of new =
hardware.
>=20
> AFAIR we used to scale the number of kswapd workers many years ago. It
> just turned out to be not all that great. We have a kswapd reclaim
> window for quite some time and that can allow to tune how much =
proactive
> kswapd should be.

I am not aware of a previous version of Linux that offered more than one =
kswapd
thread per NUMA node.

>=20
> Also please note that the direct reclaim is a way to throttle overly
> aggressive memory consumers. The more we do in the background context
> the easier for them it will be to allocate faster. So I am not really
> sure that more background threads will solve the underlying problem.

A single kswapd thread used to keep up with all of the demand you could
create on a Linux system quite easily provided it didn=E2=80=99t have to =
scan a lot
of pages that were ineligible for eviction. 10 years ago, Fibre Channel =
was
the popular high performance interconnect and if you were lucky enough
to have the latest hardware rated at 10GFC, you could get 1.2GB/s per =
host
bus adapter. Also, most high end storage solutions were still using =
spinning
rust so it took an insane number of spindles behind each host bus =
adapter
to saturate the channel if the access patterns were random. There really
wasn=E2=80=99t a reason to try to thread kswapd, and I am pretty sure =
there hasn=E2=80=99t
been any attempts to do this in the last 10 years.

> It is just a matter of memory hogs tunning to end in the very same
> situtation AFAICS. Moreover the more they are going to allocate the =
more
> less CPU time will _other_ (non-allocating) task get.

Please describe the scenario a bit more clearly. Once you start =
constructing
the workload that can create this scenario, I think you will find that =
you end
up with a mix that is rarely seen in practice.

>=20
>> Test Details
>=20
> I will have to study this more to comment.
>=20
> [...]
>> By increasing the number of kswapd threads, throughput increased by =
~50%
>> while kernel mode CPU utilization decreased or stayed the same, =
likely due
>> to a decrease in the number of parallel tasks at any given time doing =
page
>> replacement.
>=20
> Well, isn't that just an effect of more work being done on behalf of
> other workload that might run along with your tests (and which doesn't
> really need to allocate a lot of memory)? In other words how
> does the patch behaves with a non-artificial mixed workloads?

Still working on this. I will share data as soon as I have it.

>=20
> Please note that I am not saying that we absolutely have to stick with =
the
> current single-thread-per-node implementation but I would really like =
to
> see more background on why we should be allowing heavy memory hogs to
> allocate faster or how to prevent that. I would be also very =
interested
> to see how to scale the number of threads based on how CPUs are =
utilized
> by other workloads.
> --=20
> Michal Hocko
> SUSE Labs
