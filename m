Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 592146B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:16:23 -0400 (EDT)
Received: by wgez8 with SMTP id z8so20215270wge.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:16:22 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id y7si6066796wjr.77.2015.06.12.02.16.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 02:16:21 -0700 (PDT)
Message-ID: <557AA1E0.2030809@huawei.com>
Date: Fri, 12 Jun 2015 17:09:52 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/12] mm: mirrored memory support for page buddy
 allocations
References: <55704A7E.5030507@huawei.com> <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150612084233.GB19075@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, n-horiguchi@ah.nec.com

On 2015/6/12 16:42, Naoya Horiguchi wrote:

> On Thu, Jun 04, 2015 at 08:54:22PM +0800, Xishi Qiu wrote:
>> Intel Xeon processor E7 v3 product family-based platforms introduces support
>> for partial memory mirroring called as 'Address Range Mirroring'. This feature
>> allows BIOS to specify a subset of total available memory to be mirrored (and
>> optionally also specify whether to mirror the range 0-4 GB). This capability
>> allows user to make an appropriate tradeoff between non-mirrored memory range
>> and mirrored memory range thus optimizing total available memory and still
>> achieving highly reliable memory range for mission critical workloads and/or
>> kernel space.
>>
>> Tony has already send a patchset to supprot this feature at boot time.
>> https://lkml.org/lkml/2015/5/8/521
>>
>> This patchset can support the feature after boot time. It introduces mirror_info
>> to save the mirrored memory range. Then use __GFP_MIRROR to allocate mirrored 
>> pages. 
>>
>> I think add a new migratetype is btter and easier than a new zone, so I use
>> MIGRATE_MIRROR to manage the mirrored pages. However it changed some code in the
>> core file, please review and comment, thanks.
>>
>> TBD: 
>> 1) call add_mirror_info() to fill mirrored memory info.
>> 2) add compatibility with memory online/offline.
> 
> Maybe simply disabling memory offlining of memory block including MIGRATE_MIRROR?
> 
>> 3) add more interface? others?
> 
> 4?) I don't have the whole picture of how address ranging mirroring works,
> but I'm curious about what happens when an uncorrected memory error happens
> on the a mirror page. If HW/FW do some useful work invisible from kernel,
> please document it somewhere. And my questions are:

Hi Naoya,

I think the hardware and BIOS will do the work when page corrupted, and it is 
invisible to kernel. The kernel just use the mirrored memory (alloc pages in
special physical address).

Thanks,
Xishi Qiu

>  - can the kernel with this patchset really continue its operation without
>    breaking consistency? More specifically, the corrupted page is replaced with
>    its mirror page, but can any other pages which have references (like struct
>    page or pfn) for the corrupted page properly switch these references to the
>    mirror page? Or no worry about that?  (This is difficult for kernel pages
>    like slab, and that's why currently hwpoison doesn't handle any kernel pages.)
>  - How can we test/confirm that the whole scheme works fine?  Is current memory
>    error injection framework enough?
> 
> It's really nice if any roadmap including testing is shared.
> 
> # And please CC me as n-horiguchi@ah.nec.com (my primary email address :)
> 
> Thanks,
> Naoya Horiguchi
> 
>> Xishi Qiu (12):
>>   mm: add a new config to manage the code
>>   mm: introduce mirror_info
>>   mm: introduce MIGRATE_MIRROR to manage the mirrored pages
>>   mm: add mirrored pages to buddy system
>>   mm: introduce a new zone_stat_item NR_FREE_MIRROR_PAGES
>>   mm: add free mirrored pages info
>>   mm: introduce __GFP_MIRROR to allocate mirrored pages
>>   mm: use mirrorable to switch allocate mirrored memory
>>   mm: enable allocate mirrored memory at boot time
>>   mm: add the buddy system interface
>>   mm: add the PCP interface
>>   mm: let slab/slub/slob use mirrored memory
>>
>>  arch/x86/mm/numa.c     |   3 ++
>>  drivers/base/node.c    |  17 ++++---
>>  fs/proc/meminfo.c      |   6 +++
>>  include/linux/gfp.h    |   5 +-
>>  include/linux/mmzone.h |  23 +++++++++
>>  include/linux/vmstat.h |   2 +
>>  kernel/sysctl.c        |   9 ++++
>>  mm/Kconfig             |   8 +++
>>  mm/page_alloc.c        | 134 ++++++++++++++++++++++++++++++++++++++++++++++---
>>  mm/slab.c              |   3 +-
>>  mm/slob.c              |   2 +-
>>  mm/slub.c              |   2 +-
>>  mm/vmstat.c            |   4 ++
>>  13 files changed, 202 insertions(+), 16 deletions(-)
>>
>> -- 
>> 2.0.0
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
