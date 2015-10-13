Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8371A6B0254
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 05:51:56 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so17068498pab.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:51:56 -0700 (PDT)
Received: from mgwkm04.jp.fujitsu.com (mgwkm04.jp.fujitsu.com. [202.219.69.171])
        by mx.google.com with ESMTPS id l11si3891598pbq.245.2015.10.13.02.51.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 02:51:55 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 00BD4AC018F
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:51:52 +0900 (JST)
Subject: Re: [PATCH][RFC] mm: Introduce kernelcore=reliable option
References: <1444402599-15274-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <561762DC.3080608@huawei.com> <561787DA.4040809@jp.fujitsu.com>
 <5617989E.9070700@huawei.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <561CD415.9010804@jp.fujitsu.com>
Date: Tue, 13 Oct 2015 18:51:17 +0900
MIME-Version: 1.0
In-Reply-To: <5617989E.9070700@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, mel@csn.ul.ie, akpm@linux-foundation.org, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, zhongjiang@huawei.com

On 2015/10/09 19:36, Xishi Qiu wrote:
> On 2015/10/9 17:24, Kamezawa Hiroyuki wrote:
>
>> On 2015/10/09 15:46, Xishi Qiu wrote:
>>> On 2015/10/9 22:56, Taku Izumi wrote:
>>>
>>>> Xeon E7 v3 based systems supports Address Range Mirroring
>>>> and UEFI BIOS complied with UEFI spec 2.5 can notify which
>>>> ranges are reliable (mirrored) via EFI memory map.
>>>> Now Linux kernel utilize its information and allocates
>>>> boot time memory from reliable region.
>>>>
>>>> My requirement is:
>>>>     - allocate kernel memory from reliable region
>>>>     - allocate user memory from non-reliable region
>>>>
>>>> In order to meet my requirement, ZONE_MOVABLE is useful.
>>>> By arranging non-reliable range into ZONE_MOVABLE,
>>>> reliable memory is only used for kernel allocations.
>>>>
>>>
>>> Hi Taku,
>>>
>>> You mean set non-mirrored memory to movable zone, and set
>>> mirrored memory to normal zone, right? So kernel allocations
>>> will use mirrored memory in normal zone, and user allocations
>>> will use non-mirrored memory in movable zone.
>>>
>>> My question is:
>>> 1) do we need to change the fallback function?
>>
>> For *our* requirement, it's not required. But if someone want to prevent
>> user's memory allocation from NORMAL_ZONE, we need some change in zonelist
>> walking.
>>
>
> Hi Kame,
>
> So we assume kernel will only use normal zone(mirrored), and users use movable
> zone(non-mirrored) first if the memory is not enough, then use normal zone too.
>

Yes.

>>> 2) the mirrored region should locate at the start of normal
>>> zone, right?
>>
>> Precisely, "not-reliable" range of memory are handled by ZONE_MOVABLE.
>> This patch does only that.
>
> I mean the mirrored region can not at the middle or end of the zone,
> BIOS should report the memory like this,
>
> e.g.
> BIOS
> node0: 0-4G mirrored, 4-8G mirrored, 8-16G non-mirrored
> node1: 16-24G mirrored, 24-32G non-mirrored
>
> OS
> node0: DMA DMA32 are both mirrored, NORMAL(4-8G), MOVABLE(8-16G)
> node1: NORMAL(16-24G), MOVABLE(24-32G)
>

I think zones can be overlapped even while they are aligned to MAX_ORDER.


>>
>>>
>>> I remember Kame has already suggested this idea. In my opinion,
>>> I still think it's better to add a new migratetype or a new zone,
>>> so both user and kernel could use mirrored memory.
>>
>> Hi, Xishi.
>>
>> I and Izumi-san discussed the implementation much and found using "zone"
>> is better approach.
>>
>> The biggest reason is that zone is a unit of vmscan and all statistics and
>> handling the range of memory for a purpose. We can reuse all vmscan and
>> information codes by making use of zones. Introdcing other structure will be messy.
>
> Yes, add a new zone is better, but it will change much code, so reuse ZONE_MOVABLE
> is simpler and easier, right?
>

I think so. If someone feels difficulty with ZONE_MOVABLE, adding zone will be another job.
(*)Taku-san's bootoption is to specify kernelcore to be placed into reliable memory and
    doesn't specify anything about users.


>> His patch is very simple.
>>
>
> The following plan sounds good to me. Shall we rename the zone name when it is
> used for mirrored memory, "movable" is a little confusion.
>

Maybe. I think it should be another discussion. With this patch and his fake-reliable-memory
patch, everyone can give a try.


>> For your requirements. I and Izumi-san are discussing following plan.
>>
>>   - Add a flag to show the zone is reliable or not, then, mark ZONE_MOVABLE as not-reliable.
>>   - Add __GFP_RELIABLE. This will allow alloc_pages() to skip not-reliable zone.
>>   - Add madivse() MADV_RELIABLE and modify page fault code's gfp flag with that flag.
>>
>
> like this?
> user: madvise()/mmap()/or others -> add vma_reliable flag -> add gfp_reliable flag -> alloc_pages
> kernel: use __GFP_RELIABLE flag in buddy allocation/slab/vmalloc...
yes.

>
> Also we can introduce some interfaces in procfs or sysfs, right?
>

It's based on your use case. I think madvise() will be the 1st choice.

Thanks,
-kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
