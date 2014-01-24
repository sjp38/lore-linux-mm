Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1C1836B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:23:01 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id i8so3926338qcq.32
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:23:00 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id hi9si4267980qcb.102.2014.01.23.23.22.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 23:23:00 -0800 (PST)
Message-ID: <52E214C7.9050309@ti.com>
Date: Fri, 24 Jan 2014 02:22:47 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com> <CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com> <52E20A56.1000507@ti.com> <52E20E98.7010703@ti.com> <CAE9FiQWRkP1Hir6UFuPRGu6bXNd_SHonuaC-MG1UD-tSeE0teQ@mail.gmail.com>
In-Reply-To: <CAE9FiQWRkP1Hir6UFuPRGu6bXNd_SHonuaC-MG1UD-tSeE0teQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Friday 24 January 2014 02:04 AM, Yinghai Lu wrote:
> On Thu, Jan 23, 2014 at 10:56 PM, Santosh Shilimkar
> <santosh.shilimkar@ti.com> wrote:
>> On Friday 24 January 2014 01:38 AM, Santosh Shilimkar wrote:
> 
>> The patch which is now commit 457ff1d {lib/swiotlb.c: use
>> memblock apis for early memory allocations} was the breaking the
>> boot on Andrew's machine. Now if I look back the patch, based on your
>> above description, I believe below hunk waS/is the culprit.
>>
>> @@ -172,8 +172,9 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
>>         /*
>>          * Get the overflow emergency buffer
>>          */
>> -       v_overflow_buffer = alloc_bootmem_low_pages_nopanic(
>> -                                               PAGE_ALIGN(io_tlb_overflow));
>> +       v_overflow_buffer = memblock_virt_alloc_nopanic(
>> +                                               PAGE_ALIGN(io_tlb_overflow),
>> +                                               PAGE_SIZE);
>>         if (!v_overflow_buffer)
>>                 return -ENOMEM;
>>
>>
>> Looks like 'v_overflow_buffer' must be allocated from low memory in this
>> case. Is that correct ?
> 
> yes.
> 
> but should the change like following
> 
> commit 457ff1de2d247d9b8917c4664c2325321a35e313
> Author: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Date:   Tue Jan 21 15:50:30 2014 -0800
> 
>     lib/swiotlb.c: use memblock apis for early memory allocations
> 
> 
> @@ -215,13 +220,13 @@ swiotlb_init(int verbose)
>         bytes = io_tlb_nslabs << IO_TLB_SHIFT;
> 
>         /* Get IO TLB memory from the low pages */
> -       vstart = alloc_bootmem_low_pages_nopanic(PAGE_ALIGN(bytes));
> +       vstart = memblock_virt_alloc_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
>         if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
>                 return;
> 
OK. So we need '__alloc_bootmem_low()' equivalent memblock API. We will try
to come up with a patch for the same. Thanks for inputs.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
