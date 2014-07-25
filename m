Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1B8FB6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 03:23:14 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so5557540pad.36
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 00:23:13 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id br8si4115433pdb.243.2014.07.25.00.23.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 00:23:13 -0700 (PDT)
Message-ID: <53D204F7.7050800@huawei.com>
Date: Fri, 25 Jul 2014 15:19:19 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: add sysfs zone_index attribute
References: <1406187138-27911-1-git-send-email-zhenzhang.zhang@huawei.com> <53D0B8B6.8040104@huawei.com> <53D14997.7090106@intel.com> <53D1C363.7010802@huawei.com>
In-Reply-To: <53D1C363.7010802@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: mingo@redhat.com, Yinghai Lu <yinghai@kernel.org>, mgorman@suse.de, akpm@linux-foundation.org, zhangyanfei@cn.fujitsu.com, wangnan0@huawei.com, Linux MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2014/7/25 10:39, Zhang Zhen wrote:
> On 2014/7/25 1:59, Dave Hansen wrote:
>> On 07/24/2014 12:41 AM, Zhang Zhen wrote:
>>> Currently memory-hotplug has two limits:
>>> 1. If the memory block is in ZONE_NORMAL, you can change it to
>>> ZONE_MOVABLE, but this memory block must be adjacent to ZONE_MOVABLE.
>>> 2. If the memory block is in ZONE_MOVABLE, you can change it to
>>> ZONE_NORMAL, but this memory block must be adjacent to ZONE_NORMAL.
>>>
>>> Without this patch, we don't know which zone a memory block is in.
>>> So we don't know which memory block is adjacent to ZONE_MOVABLE or
>>> ZONE_NORMAL.
>>>
>>> On the other hand, with this patch, we can easy to know newly added
>>> memory is added as ZONE_NORMAL (for powerpc, ZONE_DMA, for x86_32,
>>> ZONE_HIGHMEM).
>>
>> A section can contain more than one zone.  This interface will lie about
>> such sections, which is quite unfortunate.

Hi Dave,

You are right, i only considered the memory block added after machine booted.
For a x86_64 machine booted with "mem=400M" and with 2GiB memory installed.
Sample output of the sysfs files:
# cat block_size_bytes
8000000
# cat memory0/zone_index
DMA

Here memory0 cantain DMA_ZONE and DMA32_ZONE.
>>
> 1. In arch_add_memory(), x86_64 add the new pages of the new memory block default to
> ZONE_NORMAL (for powerpc, ZONE_DMA, for x86_32, ZONE_HIGHMEM).
> 
> 2. In __offline_pages(), test_pages_in_a_zone() guaranteed the pages of a memory block
> we try to offline are in the same zone. If a section contains more than one zone,
> the memory block can not be offlined.
> 
> Based on the above two points, i think the pages of a memory block are in one zone, and the sections
> of a memory block are in one zone.
> 
> Could you please explain in detail what is the case a section can contain more than one zone ?
> 
> Thanks for your comments!
> 
>> I'd really much rather see an interface that has a section itself
>> enumerate to which zones it may be changed.  The way you have it now,
>> any user has to know the rules that you've laid out above.  If the
>> kernel changed those restrictions, we'd have to teach every application
>> about the change in restrictions.
>>
Here you are right too, we should add an interface to show which zones a memory block may
be changed to. So user doesn't need to know the rules above.
I will send a new version.

Thank you very much !

> 
> This interface is designed to show which zone a memory block is in. If the kernel changed those
> restrictions, this interface doesn't need to change.
> For a x86_64 machine booted with "mem=400M" and with 2GiB memory installed.
> Sample output of the sysfs files:
> # cat block_size_bytes
> 8000000
> # cat memory0/zone_index
> DMA
> # cat memory1/zone_index
> DMA32
> # cat memory2/zone_index
> DMA32
> # cat memory3/zone_index
> DMA32
> # echo 0x20000000 > probe
> # cat memory4/zone_index
> Normal
> # echo online > memory4/state
> # cat memory4/zone_index
> Normal
> 
> # echo offline > memory4/state
> # echo online_movable > memory4/state
> # cat memory4/zone_index
> Movable
> 
> Thanks!
> 
> Best regards!
>>
>>
>>
>> .
>>
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
