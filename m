Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 226686B0255
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 06:36:49 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so83719173pab.3
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 03:36:48 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id mk6si1609046pab.21.2015.10.09.03.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 Oct 2015 03:36:48 -0700 (PDT)
Message-ID: <5617989E.9070700@huawei.com>
Date: Fri, 9 Oct 2015 18:36:14 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com> <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com>
In-Reply-To: <561787DA.4040809@jp.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, mel@csn.ul.ie, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, zhongjiang@huawei.com

On 2015/10/9 17:24, Kamezawa Hiroyuki wrote:

> On 2015/10/09 15:46, Xishi Qiu wrote:
>> On 2015/10/9 22:56, Taku Izumi wrote:
>>
>>> Xeon E7 v3 based systems supports Address Range Mirroring
>>> and UEFI BIOS complied with UEFI spec 2.5 can notify which
>>> ranges are reliable (mirrored) via EFI memory map.
>>> Now Linux kernel utilize its information and allocates
>>> boot time memory from reliable region.
>>>
>>> My requirement is:
>>>    - allocate kernel memory from reliable region
>>>    - allocate user memory from non-reliable region
>>>
>>> In order to meet my requirement, ZONE_MOVABLE is useful.
>>> By arranging non-reliable range into ZONE_MOVABLE,
>>> reliable memory is only used for kernel allocations.
>>>
>>
>> Hi Taku,
>>
>> You mean set non-mirrored memory to movable zone, and set
>> mirrored memory to normal zone, right? So kernel allocations
>> will use mirrored memory in normal zone, and user allocations
>> will use non-mirrored memory in movable zone.
>>
>> My question is:
>> 1) do we need to change the fallback function?
> 
> For *our* requirement, it's not required. But if someone want to prevent
> user's memory allocation from NORMAL_ZONE, we need some change in zonelist
> walking.
> 

Hi Kame,

So we assume kernel will only use normal zone(mirrored), and users use movable
zone(non-mirrored) first if the memory is not enough, then use normal zone too. 

>> 2) the mirrored region should locate at the start of normal
>> zone, right?
> 
> Precisely, "not-reliable" range of memory are handled by ZONE_MOVABLE.
> This patch does only that.

I mean the mirrored region can not at the middle or end of the zone,
BIOS should report the memory like this, 

e.g.
BIOS
node0: 0-4G mirrored, 4-8G mirrored, 8-16G non-mirrored
node1: 16-24G mirrored, 24-32G non-mirrored

OS
node0: DMA DMA32 are both mirrored, NORMAL(4-8G), MOVABLE(8-16G)
node1: NORMAL(16-24G), MOVABLE(24-32G)

> 
>>
>> I remember Kame has already suggested this idea. In my opinion,
>> I still think it's better to add a new migratetype or a new zone,
>> so both user and kernel could use mirrored memory.
> 
> Hi, Xishi.
> 
> I and Izumi-san discussed the implementation much and found using "zone"
> is better approach.
> 
> The biggest reason is that zone is a unit of vmscan and all statistics and
> handling the range of memory for a purpose. We can reuse all vmscan and
> information codes by making use of zones. Introdcing other structure will be messy.

Yes, add a new zone is better, but it will change much code, so reuse ZONE_MOVABLE
is simpler and easier, right?

> His patch is very simple.
> 

The following plan sounds good to me. Shall we rename the zone name when it is
used for mirrored memory, "movable" is a little confusion.

> For your requirements. I and Izumi-san are discussing following plan.
> 
>  - Add a flag to show the zone is reliable or not, then, mark ZONE_MOVABLE as not-reliable.
>  - Add __GFP_RELIABLE. This will allow alloc_pages() to skip not-reliable zone.
>  - Add madivse() MADV_RELIABLE and modify page fault code's gfp flag with that flag.
> 

like this?
user: madvise()/mmap()/or others -> add vma_reliable flag -> add gfp_reliable flag -> alloc_pages
kernel: use __GFP_RELIABLE flag in buddy allocation/slab/vmalloc...

Also we can introduce some interfaces in procfs or sysfs, right?

Thanks,
Xishi Qiu

> 
> Thanks,
> -Kame
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
