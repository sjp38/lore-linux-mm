Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7A76B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 03:53:33 -0400 (EDT)
Received: by wifx6 with SMTP id x6so10866490wif.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 00:53:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a16si1614072wiv.96.2015.06.16.00.53.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Jun 2015 00:53:31 -0700 (PDT)
Message-ID: <557FD5F8.10903@suse.cz>
Date: Tue, 16 Jun 2015 09:53:28 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com>
In-Reply-To: <55704A7E.5030507@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/04/2015 02:54 PM, Xishi Qiu wrote:
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
> 
> This patchset can support the feature after boot time. It introduces mirror_info
> to save the mirrored memory range. Then use __GFP_MIRROR to allocate mirrored 
> pages. 
> 
> I think add a new migratetype is btter and easier than a new zone, so I use

If the mirrored memory is in a single reasonably compact (no large holes) range
(per NUMA node) and won't dynamically change its size, then zone might be a
better option. For one thing, it will still allow distinguishing movable and
unmovable allocations within the mirrored memory.

We had enough fun with MIGRATE_CMA and all kinds of checks it added to allocator
hot paths, and even CMA is now considering moving to a separate zone.

> MIGRATE_MIRROR to manage the mirrored pages. However it changed some code in the
> core file, please review and comment, thanks.
> 
> TBD: 
> 1) call add_mirror_info() to fill mirrored memory info.
> 2) add compatibility with memory online/offline.
> 3) add more interface? others?
> 
> Xishi Qiu (12):
>   mm: add a new config to manage the code
>   mm: introduce mirror_info
>   mm: introduce MIGRATE_MIRROR to manage the mirrored pages
>   mm: add mirrored pages to buddy system
>   mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
>   mm: add free mirrored pages info
>   mm: introduce __GFP_MIRROR to allocate mirrored pages
>   mm: use mirrorable to switch allocate mirrored memory
>   mm: enable allocate mirrored memory at boot time
>   mm: add the buddy system interface
>   mm: add the PCP interface
>   mm: let slab/slub/slob use mirrored memory
> 
>  arch/x86/mm/numa.c     |   3 ++
>  drivers/base/node.c    |  17 ++++---
>  fs/proc/meminfo.c      |   6 +++
>  include/linux/gfp.h    |   5 +-
>  include/linux/mmzone.h |  23 +++++++++
>  include/linux/vmstat.h |   2 +
>  kernel/sysctl.c        |   9 ++++
>  mm/Kconfig             |   8 +++
>  mm/page_alloc.c        | 134 ++++++++++++++++++++++++++++++++++++++++++++++---
>  mm/slab.c              |   3 +-
>  mm/slob.c              |   2 +-
>  mm/slub.c              |   2 +-
>  mm/vmstat.c            |   4 ++
>  13 files changed, 202 insertions(+), 16 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
