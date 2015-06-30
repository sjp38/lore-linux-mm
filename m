Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9683B6B006C
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:42:00 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so11023403wic.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 02:42:00 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bl10si18407070wib.9.2015.06.30.02.41.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Jun 2015 02:41:59 -0700 (PDT)
Date: Tue, 30 Jun 2015 10:41:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
Message-ID: <20150630094149.GA6812@suse.de>
References: <558E084A.60900@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <558E084A.60900@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Jun 27, 2015 at 10:19:54AM +0800, Xishi Qiu wrote:
> Intel Xeon processor E7 v3 product family-based platforms introduces support
> for partial memory mirroring called as 'Address Range Mirroring'. This feature
> allows BIOS to specify a subset of total available memory to be mirrored (and
> optionally also specify whether to mirror the range 0-4 GB). This capability
> allows user to make an appropriate tradeoff between non-mirrored memory range
> and mirrored memory range thus optimizing total available memory and still
> achieving highly reliable memory range for mission critical workloads and/or
> kernel space.
> 
> Tony has already send a patchset to supprot this feature at boot time.
> https://lkml.org/lkml/2015/5/8/521
> This patchset is based on Tony's, it can support the feature after boot time.
> Use mirrored memory for all kernel allocations.
> 

This is my first time glancing through the series so I'm not aware of any
past discussion. Hopefully there are no repeats. Broadly speaking though
I'm not comfortable with the series.

First and foremost, there is uncontrolled access to the memory because
it's any kernel request. This includes even short-lived ones that do not
need mirroring such as network buffers or caches. Network network traffic
can be retried, caches can be reconstructed from disk etc.  Kernel page
tables, struct page corruption etc are much harder to recover from.

Who are the expected users of this memory and how are they meant to be
prioritised? What happens if they fail to be mirrored? What happens if the
mirrored memory is all used up and a high priority request arrives? Is there
any prioritisation of one subsystem over another? What about boot-memory
allocations, should they ever use mirrored memory? The expected users are
important and this series does not address it.

Callers do not specify the flag, you just assume that kernel allocations
must be mirrored. If the allocation request fails, then you assume it was
MIGRATE_RECLAIMABLE later in the series. This is wrong as it'll break
fragmentation avoidance on machines with mirrored memory. Even if you
were to use migrate types to handle mirrored memory, you need to treat
mirrored memory as a type of reserve or else as a first preference for
allocations requested.

The fact that this will be used by very few machines but affects the memory
footprint of the page allocator is a general concern. When active, it affects
the fast paths for all users whether they care about mirroring or not.

If all free memory is in the MIGRATE_MIRROR then all user-space requests
will be rejected but reclaim will not make any progress if the zone
is balanced. The system may go prematurely OOM as no progress is made.
Getting around this is tricky and affects a few fast paths. Generally, the
easiest approach would be zone-based but I recognise that it has problems
of its own.

Basically, overall I feel this series is the wrong approach but not knowing
who the users are making is much harder to judge. I strongly suspect that
if mirrored memory is to be properly used then it needs to be available
before the page allocator is even active. Once active, there needs to
be controlled access for allocation requests that are really critical
to mirror and not just all kernel allocations. None of that would use a
MIGRATE_TYPE approach. It would be alterations to the bootmem allocator and
access to an explicit reserve that is not accounted for as "free memory"
and accessed via an explicit GFP flag.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
