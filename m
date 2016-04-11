Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE9D6B0005
	for <linux-mm@kvack.org>; Sun, 10 Apr 2016 22:51:21 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id bg3so102517446obb.1
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 19:51:21 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 7si7413348otr.217.2016.04.10.19.51.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 19:51:20 -0700 (PDT)
Subject: Re: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
References: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
 <20160407142148.GI5657@arm.com>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <570B10B2.2000000@hisilicon.com>
Date: Mon, 11 Apr 2016 10:49:22 +0800
MIME-Version: 1.0
In-Reply-To: <20160407142148.GI5657@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, mhocko@suse.com, Laura Abbott <labbott@redhat.com>
Cc: catalin.marinas@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org, puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

Hi will,
Thanks for review.

On 2016/4/7 22:21, Will Deacon wrote:
> On Tue, Apr 05, 2016 at 04:22:51PM +0800, Chen Feng wrote:
>> We can reduce the memory allocated at mem-map
>> by flatmem.
>>
>> currently, the default memory-model in arm64 is
>> sparse memory. The mem-map array is not freed in
>> this scene. If the physical address is too long,
>> it will reserved too much memory for the mem-map
>> array.
> 
> Can you elaborate a bit more on this, please? We use the vmemmap, so any
> spaces between memory banks only burns up virtual space. What exactly is
> the problem you're seeing that makes you want to use flatmem (which is
> probably unsuitable for the majority of arm64 machines).
> 
The root cause we want to use flat-mem is the mam_map alloced in sparse-mem
is not freed.

take a look at here:
arm64/mm/init.c
void __init mem_init(void)
{
#ifndef CONFIG_SPARSEMEM_VMEMMAP
	free_unused_memmap();
#endif
}

Memory layout (3GB)

 0             1.5G    2G             3.5G            4G
 |              |      |               |              |
 +--------------+------+---------------+--------------+
 |    MEM       | hole |     MEM       |   IO (regs)  |
 +--------------+------+---------------+--------------+


Memory layout (4GB)

 0                                    3.5G            4G    4.5G
 |                                     |              |       |
 +-------------------------------------+--------------+-------+
 |                   MEM               |   IO (regs)  |  MEM  |
 +-------------------------------------+--------------+-------+

Currently, the sparse memory section is 1GB.

3GB ddr: the 1.5 ~2G and 3.5 ~ 4G are holes.
3GB ddr: the 3.5 ~ 4G and 4.5 ~ 5G are holes.

This will alloc 1G/4K * (struct page) memory for mem_map array.

We want to use flat-mem to reduce the alloced mem_map.

I don't know why you tell us the flatmem is unsuitable for the
majority of arm64 machines. Can tell us the reason of it?

And we are not going to limit the memdel in arm64, we just want to
make the flat-mem is an optional item in arm64.


puck,


> Will
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
