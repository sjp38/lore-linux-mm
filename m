Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C09966B0734
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 18:14:37 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f9so2193853pgs.13
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 15:14:37 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c22-v6si8711394pgb.472.2018.11.09.15.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 15:14:36 -0800 (PST)
Message-ID: <18b6634b912af7b4ec01396a2b0f3b31737c9ea2.camel@linux.intel.com>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 09 Nov 2018 15:14:35 -0800
In-Reply-To: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
References: <20181109211521.5ospn33pp552k2xv@xakep.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>, daniel.m.jordan@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mhocko@suse.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Fri, 2018-11-09 at 16:15 -0500, Pavel Tatashin wrote:
> On 18-11-05 13:19:25, Alexander Duyck wrote:
> > This patchset is essentially a refactor of the page initialization logic
> > that is meant to provide for better code reuse while providing a
> > significant improvement in deferred page initialization performance.
> > 
> > In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> > memory per node I have seen the following. In the case of regular memory
> > initialization the deferred init time was decreased from 3.75s to 1.06s on
> > average. For the persistent memory the initialization time dropped from
> > 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> > deferred memory initialization performance, and a 26% improvement in the
> > persistent memory initialization performance.
> 
> Hi Alex,
> 
> Please try to run your persistent memory init experiment with Daniel's
> patches:
> 
> https://lore.kernel.org/lkml/20181105165558.11698-1-daniel.m.jordan@oracle.com/

I've taken a quick look at it. It seems like a bit of a brute force way
to try and speed things up. I would be worried about it potentially
introducing performance issues if the number of CPUs thrown at it end
up exceeding the maximum throughput of the memory.

The data provided with patch 11 seems to point to issues such as that.
In the case of the E7-8895 example cited it is increasing the numbers
of CPUs used from memory initialization from 8 to 72, a 9x increase in
the number of CPUs but it is yeilding only a 3.88x speedup.

> The performance should improve by much more than 26%.

The 26% improvement, or speedup of 1.26x using the ktask approach, was
for persistent memory, not deferred memory init. The ktask patch
doesn't do anything for persistent memory since it is takes the hot-
plug path and isn't handled via the deferred memory init.

I had increased deferred memory init to about 3.53x the original speed
(3.75s to 1.06s) on the system which I was testing. I do agree the two
patches should be able to synergistically boost each other though as
this patch set was meant to make the init much more cache friendly so
as a result it should scale better as you add additional cores. I know
I had done some playing around with fake numa to split up a single node
into 8 logical nodes and I had seen a similar speedup of about 3.85x
with my test memory initializing in about 275ms.

> Overall, your works looks good, but it needs to be considered how easy it will be
> to merge with ktask. I will try to complete the review today.
> 
> Thank you,
> Pasha

Looking over the patches they are still in the RFC stage and the data
is in need of updates since it is referencing 4.15-rc kernels as its
baseline. If anything I really think the ktask patch 11 would be easier
to rebase around my patch set then the other way around. Also, this
series is in Andrew's mmots as of a few days ago, so I think it will be
in the next mmotm that comes out.

The integration with the ktask code should be pretty straight forward.
If anything I think my code would probably make it easier since it gets
rid of the need to do all this in two passes. The only new limitation
it would add is that you would probably want to split up the work along
either max order or section aligned boundaries. What it would
essentially do is make things so that each of the ktask threads would
probably look more like deferred_grow_zone which after my patch set is
actually a fairly simple function.

Thanks.

- Alex
