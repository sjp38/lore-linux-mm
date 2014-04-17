Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8784E6B0068
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 00:06:41 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so11854148wgh.27
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:06:40 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ni13si455167wic.94.2014.04.16.21.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 21:06:40 -0700 (PDT)
Message-ID: <534F5307.1030707@huawei.com>
Date: Thu, 17 Apr 2014 12:05:27 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] ARM: mm: support big-endian page tables
References: <5301B4AF.1040305@huawei.com> <5327F75F.1010406@huawei.com> <20140414104300.GA3530@arm.com> <534BC31A.7060705@arm.com> <534DEEDD.5030203@huawei.com> <534E777C.1090605@arm.com>
In-Reply-To: <534E777C.1090605@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: Will Deacon <Will.Deacon@arm.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Wang Nan <wangnan0@huawei.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Ben Dooks <ben.dooks@codethink.co.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2014/4/16 20:28, Marc Zyngier wrote:

> On 16/04/14 03:45, Jianguo Wu wrote:
>> On 2014/4/14 19:14, Marc Zyngier wrote:
>>
>>> On 14/04/14 11:43, Will Deacon wrote:
>>>> (catching up on old email)
>>>>
>>>> On Tue, Mar 18, 2014 at 07:35:59AM +0000, Jianguo Wu wrote:
>>>>> Cloud you please take a look at this?
>>>>
>>>> [...]
>>>>
>>>>> On 2014/2/17 15:05, Jianguo Wu wrote:
>>>>>> When enable LPAE and big-endian in a hisilicon board, while specify
>>>>>> mem=384M mem=512M@7680M, will get bad page state:
>>>>>>
>>>>>> Freeing unused kernel memory: 180K (c0466000 - c0493000)
>>>>>> BUG: Bad page state in process init  pfn:fa442
>>>>>> page:c7749840 count:0 mapcount:-1 mapping:  (null) index:0x0
>>>>>> page flags: 0x40000400(reserved)
>>>>>> Modules linked in:
>>>>>> CPU: 0 PID: 1 Comm: init Not tainted 3.10.27+ #66
>>>>>> [<c000f5f0>] (unwind_backtrace+0x0/0x11c) from [<c000cbc4>] (show_stack+0x10/0x14)
>>>>>> [<c000cbc4>] (show_stack+0x10/0x14) from [<c009e448>] (bad_page+0xd4/0x104)
>>>>>> [<c009e448>] (bad_page+0xd4/0x104) from [<c009e520>] (free_pages_prepare+0xa8/0x14c)
>>>>>> [<c009e520>] (free_pages_prepare+0xa8/0x14c) from [<c009f8ec>] (free_hot_cold_page+0x18/0xf0)
>>>>>> [<c009f8ec>] (free_hot_cold_page+0x18/0xf0) from [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8)
>>>>>> [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8) from [<c00b6458>] (handle_mm_fault+0xf4/0x120)
>>>>>> [<c00b6458>] (handle_mm_fault+0xf4/0x120) from [<c0013754>] (do_page_fault+0xfc/0x354)
>>>>>> [<c0013754>] (do_page_fault+0xfc/0x354) from [<c0008400>] (do_DataAbort+0x2c/0x90)
>>>>>> [<c0008400>] (do_DataAbort+0x2c/0x90) from [<c0008fb4>] (__dabt_usr+0x34/0x40)
>>>>
>>>> [...]
>>>>
>>>>>> The bug is happened in cpu_v7_set_pte_ext(ptep, pte):
>>>>>> when pte is 64-bit, for little-endian, will store low 32-bit in r2,
>>>>>> high 32-bit in r3; for big-endian, will store low 32-bit in r3,
>>>>>> high 32-bit in r2, this will cause wrong pfn stored in pte,
>>>>>> so we should exchange r2 and r3 for big-endian.
>>>>
>>
>> Hi Marc,
>> How about this:
>>
>> The bug is happened in cpu_v7_set_pte_ext(ptep, pte):
>> - It tests the L_PTE_NONE in one word on the other, and possibly clear L_PTE_VALID
>>   tst	r3, #1 << (57 - 32)		@ L_PTE_NONE
>>   bicne	r2, #L_PTE_VALID
>> - Same for L_PTE_DIRTY, respectively setting L_PTE_RDONLY
>>
>> As for LPAE, the pte is 64-bits, and the value of r2/r3 is depending on the endianness,
>> for little-endian, will store low 32-bit in r2, high 32-bit in r3,
>> for big-endian, will store low 32-bit in r3, high 32-bit in r2, 
>> this will cause wrong bit is cleared or set, and get wrong pfn.
>> So we should exchange r2 and r3 for big-endian.
> 
> May I suggest the following instead:
> 
> "An LPAE PTE is a 64bit quantity, passed to cpu_v7_set_pte_ext in the
>  r2 and r3 registers.
>  On an LE kernel, r2 contains the LSB of the PTE, and r3 the MSB.
>  On a BE kernel, the assignment is reversed.
> 
>  Unfortunately, the current code always assumes the LE case,
>  leading to corruption of the PTE when clearing/setting bits.
> 
>  This patch fixes this issue much like it has been done already in the
>  cpu_v7_switch_mm case."
> 

OK, I will sent a new version, thanks!

> Cheers,
> 
> 	M.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
