Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 04C806B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 01:07:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w189so35828788pfb.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 22:07:34 -0800 (PST)
Received: from dggrg01-dlp.huawei.com ([45.249.212.187])
        by mx.google.com with ESMTPS id 32si6597261plf.34.2017.03.01.22.07.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 22:07:34 -0800 (PST)
Subject: Re: [PATCH] mm: free reserved area's memmap if possiable
References: <1486987349-58711-1-git-send-email-zhouxianrong@huawei.com>
 <1487055180-128750-1-git-send-email-zhouxianrong@huawei.com>
 <CAKv+Gu9NF3dS_EWi4k42Ke+aagTScu-yk+UFZ_6sG6tK5zHP2Q@mail.gmail.com>
 <04630153-bc82-ac1f-2f80-344c90200732@huawei.com>
 <CAKv+Gu_X3fNhfUZ9+4Q_jdt2J12d9sxj1cgOq82HaQ8Gw_QaQA@mail.gmail.com>
 <a9c03f7d-355b-76c4-2a3a-771d57af1591@huawei.com>
 <20170301184140.7ac9de0a@xhacker>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <dd26d083-2a9c-615f-efde-007f0405c37c@huawei.com>
Date: Thu, 2 Mar 2017 14:00:27 +0800
MIME-Version: 1.0
In-Reply-To: <20170301184140.7ac9de0a@xhacker>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jisheng Zhang <jszhang@marvell.com>, Chen Feng <puck.chen@hisilicon.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mark Rutland <mark.rutland@arm.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, srikar@linux.vnet.ibm.com, Mi.Sophia.Wang@huawei.com, Will Deacon <will.deacon@arm.com>, zhangshiming5@huawei.com, zijun_hu@htc.com, won.ho.park@huawei.com, Alexander Kuleshov <kuleshovmail@gmail.com>, chengang@emindsoft.com.cn, zhouxiyu@huawei.com, tj@kernel.org, weidu.du@huawei.com, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Steve Capper <steve.capper@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Dennis Chen <dennis.chen@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>



On 2017/3/1 18:41, Jisheng Zhang wrote:
> Add Chen, Catalin
>
> On Thu, 16 Feb 2017 09:11:29 +0800 zhouxianrong wrote:
>>
>>
>> On 2017/2/15 15:10, Ard Biesheuvel wrote:
>>> On 15 February 2017 at 01:44, zhouxianrong wrote:
>>>>
>>>>
>>>> On 2017/2/14 17:03, Ard Biesheuvel wrote:
>>>>>
>>>>> On 14 February 2017 at 06:53,  <zhouxianrong@huawei.com> wrote:
>>>>>>
>>>>>> From: zhouxianrong <zhouxianrong@huawei.com>
>>>>>>
>>>>>> just like freeing no-map area's memmap (gaps of memblock.memory)
>>>>>> we could free reserved area's memmap (areas of memblock.reserved)
>>>>>> as well only when user of reserved area indicate that we can do
>>>>>> this in drivers. that is, user of reserved area know how to
>>>>>> use the reserved area who could not memblock_free or free_reserved_xxx
>>>>>> the reserved area and regard the area as raw pfn usage by kernel.
>>>>>> the patch supply a way to users who want to utilize the memmap
>>>>>> memory corresponding to raw pfn reserved areas as many as possible.
>>>>>> users can do this by memblock_mark_raw_pfn interface which mark the
>>>>>> reserved area as raw pfn and tell free_unused_memmap that this area's
>>>>>> memmap could be freeed.
>>>>>>
>>>>>
>>>>> Could you give an example how much memory we actually recover by doing
>>>>> this? I understand it depends on the size of the reserved regions, but
>>>>> I'm sure you have an actual example that inspired you to write this
>>>>> patch.
>>>>
>>>>
>>>> i did statistics in our platform, the memmap of reserved region that can be
>>>> freed
>>>> is about 6MB. it's fewer.
>
> <...>
>
>>>>> In any case, it is good to emphasize that on 4 KB pagesize kernels, we
>>>>> will only free multiples of 8 MB that are 8 MB aligned, resulting in
>>>>> 128 KB of memmap backing to be released.
>>>>
>>>>
>>>>
>>>>>
>>>>>
>>>>>> +               if (start < end)
>>>>>> +                       free_memmap(start, end);
>>>>>> +       }
>>>>>>  }
>>>>>>  #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
>>>>>>
>>>>>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>>>>>> index 5b759c9..9f8d277 100644
>>>>>> --- a/include/linux/memblock.h
>>>>>> +++ b/include/linux/memblock.h
>>>>>> @@ -26,6 +26,7 @@ enum {
>>>>>>         MEMBLOCK_HOTPLUG        = 0x1,  /* hotpluggable region */
>>>>>>         MEMBLOCK_MIRROR         = 0x2,  /* mirrored region */
>>>>>>         MEMBLOCK_NOMAP          = 0x4,  /* don't add to kernel direct
>>>>>> mapping */
>>>>>> +       MEMBLOCK_RAW_PFN        = 0x8,  /* region whose memmap never be
>>>>>> used */
>>>>>
>>>>>
>>>>> I think we should be *very* careful about the combinatorial explosion
>>>>> that results when combining all these flags, given that this is not a
>>>>> proper enum but a bit field.
>>>>>
>>>>> In any case, the generic memblock change should be in a separate patch
>>>>> from the arm64 change.
>>>>
>>>>
>>>> MEMBLOCK_RAW_PFN and MEMBLOCK_NOMAP can not be set at the same time
>>>>
>>>
>>> They should not. But if I call  memblock_mark_raw_pfn() on a
>>> MEMBLOCK_NOMAP region, it will have both flags set.
>>>
>>> In summary, I don't think we need this patch. And if you can convince
>>> us otherwise, you should really be more methodical and explicit in
>>> implementing this RAW_PFN flag, not add it as a byproduct of the arch
>>> code that uses it. Also, you should explain how RAW_PFN relates to
>>> NOMAP, and ensure that RAW_PFN and NOMAP regions don't intersect if
>>> that is an unsupported combination.
>>
>> yes, setting both MEMBLOCK_RAW_PFN and MEMBLOCK_NOMAP could meet some problems
>> when gaps of memblock.memory intersect memblock.reserved. if they do not intersect,
>> that's ok. so as you said this should be carefully considered.
>>
>> as you think this patch is not needed because, i have showed my idea, it's enough, thanks!
>
> we are also interested in this area.
>
> Just curious, is this patch to "free the vmemmap holes" mentioned by
> by Catalin in [1]?

free the vmemmap of reserved memblock (other than no-map regions) whose driver owner know
it is never be used.

>
> [1]http://lkml.iu.edu/hypermail/linux/kernel/1604.1/03036.html
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
