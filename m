Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6C1126B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 01:55:54 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id p9so6763043lbv.34
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:55:53 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id ov7si11898118lbb.145.2014.02.11.22.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 22:55:52 -0800 (PST)
Message-ID: <52FB1AAA.9030108@huawei.com>
Date: Wed, 12 Feb 2014 14:54:34 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ARM: mm: support big-endian page tables
References: <52F9EB40.1030703@huawei.com> <52F9FE1A.6000607@codethink.co.uk>
In-Reply-To: <52F9FE1A.6000607@codethink.co.uk>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Dooks <ben.dooks@codethink.co.uk>
Cc: linux@arm.linux.org.uk, will.deacon@arm.com, gregkh@linuxfoundation.org, Catalin Marinas <catalin.marinas@arm.com>, Li
 Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>, linux-arm-kernel@lists.infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2014/2/11 18:40, Ben Dooks wrote:

> On 11/02/14 09:20, Jianguo Wu wrote:
>> When enable LPAE and big-endian in a hisilicon board, while specify
>> mem=384M mem=512M@7680M, will get bad page state:
>>
>> Freeing unused kernel memory: 180K (c0466000 - c0493000)
>> BUG: Bad page state in process init  pfn:fa442
>> page:c7749840 count:0 mapcount:-1 mapping:  (null) index:0x0
>> page flags: 0x40000400(reserved)
>> Modules linked in:
>> CPU: 0 PID: 1 Comm: init Not tainted 3.10.27+ #66
>> [<c000f5f0>] (unwind_backtrace+0x0/0x11c) from [<c000cbc4>] (show_stack+0x10/0x14)
>> [<c000cbc4>] (show_stack+0x10/0x14) from [<c009e448>] (bad_page+0xd4/0x104)
>> [<c009e448>] (bad_page+0xd4/0x104) from [<c009e520>] (free_pages_prepare+0xa8/0x14c)
>> [<c009e520>] (free_pages_prepare+0xa8/0x14c) from [<c009f8ec>] (free_hot_cold_page+0x18/0xf0)
>> [<c009f8ec>] (free_hot_cold_page+0x18/0xf0) from [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8)
>> [<c00b5444>] (handle_pte_fault+0xcf4/0xdc8) from [<c00b6458>] (handle_mm_fault+0xf4/0x120)
>> [<c00b6458>] (handle_mm_fault+0xf4/0x120) from [<c0013754>] (do_page_fault+0xfc/0x354)
>> [<c0013754>] (do_page_fault+0xfc/0x354) from [<c0008400>] (do_DataAbort+0x2c/0x90)
>> [<c0008400>] (do_DataAbort+0x2c/0x90) from [<c0008fb4>] (__dabt_usr+0x34/0x40)
>>
>> The bad pfn:fa442 is not system memory(mem=384M mem=512M@7680M), after debugging,
>> I find in page fault handler, will get wrong pfn from pte just after set pte,
>> as follow:
>> do_anonymous_page()
>> {
>>     ...
>>     set_pte_at(mm, address, page_table, entry);
>>     
>>     //debug code
>>     pfn = pte_pfn(entry);
>>     pr_info("pfn:0x%lx, pte:0x%llx\n", pfn, pte_val(entry));
>>
>>     //read out the pte just set
>>     new_pte = pte_offset_map(pmd, address);
>>     new_pfn = pte_pfn(*new_pte);
>>     pr_info("new pfn:0x%lx, new pte:0x%llx\n", pfn, pte_val(entry));
>>     ...
>> }
> 
> Thanks, must have missed tickling this one.
> 
>>
>> pfn:   0x1fa4f5,     pte:0xc00001fa4f575f
>> new_pfn:0xfa4f5, new_pte:0xc00000fa4f5f5f    //new pfn/pte is wrong.
>>
>> The bug is happened in cpu_v7_set_pte_ext(ptep, pte):
>> when pte is 64-bit, for little-endian, will store low 32-bit in r2,
>> high 32-bit in r3; for big-endian, will store low 32-bit in r3,
>> high 32-bit in r2, this will cause wrong pfn stored in pte,
>> so we should exchange r2 and r3 for big-endian.
>>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>   arch/arm/mm/proc-v7-3level.S |   10 ++++++++++
>>   1 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/arm/mm/proc-v7-3level.S b/arch/arm/mm/proc-v7-3level.S
>> index 6ba4bd9..71b3892 100644
>> --- a/arch/arm/mm/proc-v7-3level.S
>> +++ b/arch/arm/mm/proc-v7-3level.S
>> @@ -65,6 +65,15 @@ ENDPROC(cpu_v7_switch_mm)
>>    */
>>   ENTRY(cpu_v7_set_pte_ext)
>>   #ifdef CONFIG_MMU
>> +#ifdef CONFIG_CPU_ENDIAN_BE8
>> +    tst    r3, #L_PTE_VALID
>> +    beq    1f
>> +    tst    r2, #1 << (57 - 32)        @ L_PTE_NONE
>> +    bicne    r3, #L_PTE_VALID
>> +    bne    1f
>> +    tst    r2, #1 << (55 - 32)        @ L_PTE_DIRTY
>> +    orreq    r3, #L_PTE_RDONLY
>> +#else
>>       tst    r2, #L_PTE_VALID
>>       beq    1f
>>       tst    r3, #1 << (57 - 32)        @ L_PTE_NONE
>> @@ -72,6 +81,7 @@ ENTRY(cpu_v7_set_pte_ext)
>>       bne    1f
>>       tst    r3, #1 << (55 - 32)        @ L_PTE_DIRTY
>>       orreq    r2, #L_PTE_RDONLY
>> +#endif
>>   1:    strd    r2, r3, [r0]
>>       ALT_SMP(W(nop))
>>       ALT_UP (mcr    p15, 0, r0, c7, c10, 1)        @ flush_pte
>> -- 1.7.1
> 
> If possible can we avoid large #ifdef blocks here?
> 
> Two ideas are
> 
> ARM_LE(tst r2, #L_PTE_VALID)
> ARM_BE(tst r3, #L_PTE_VALID)
> 
> or change r2, r3 pair to say rlow, rhi and
> 
> #ifdef  CONFIG_CPU_ENDIAN_BE8
> #define rlow r3
> #define rhi r2
> #else
> #define rlow r2
> #define rhi r3
> #endif
> 

Hi Ben,
Thanks for your suggestion, how about this?

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 arch/arm/mm/proc-v7-3level.S |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mm/proc-v7-3level.S b/arch/arm/mm/proc-v7-3level.S
index 01a719e..22e3ad6 100644
--- a/arch/arm/mm/proc-v7-3level.S
+++ b/arch/arm/mm/proc-v7-3level.S
@@ -64,6 +64,14 @@ ENTRY(cpu_v7_switch_mm)
 	mov	pc, lr
 ENDPROC(cpu_v7_switch_mm)
 
+#ifdef __ARMEB__
+#define rl r3
+#define rh r2
+#else
+#define rl r2
+#define rh r3
+#endif
+
 /*
  * cpu_v7_set_pte_ext(ptep, pte)
  *
@@ -73,13 +81,13 @@ ENDPROC(cpu_v7_switch_mm)
  */
 ENTRY(cpu_v7_set_pte_ext)
 #ifdef CONFIG_MMU
-	tst	r2, #L_PTE_VALID
+	tst	rl, #L_PTE_VALID
 	beq	1f
-	tst	r3, #1 << (57 - 32)		@ L_PTE_NONE
-	bicne	r2, #L_PTE_VALID
+	tst	rh, #1 << (57 - 32)		@ L_PTE_NONE
+	bicne	rl, #L_PTE_VALID
 	bne	1f
-	tst	r3, #1 << (55 - 32)		@ L_PTE_DIRTY
-	orreq	r2, #L_PTE_RDONLY
+	tst	rh, #1 << (55 - 32)		@ L_PTE_DIRTY
+	orreq	rl, #L_PTE_RDONLY
 1:	strd	r2, r3, [r0]
 	ALT_SMP(W(nop))
 	ALT_UP (mcr	p15, 0, r0, c7, c10, 1)		@ flush_pte
-- 
1.7.1

Thanks,
Jianguo Wu

> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
