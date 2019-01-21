Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC9E58E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 04:30:57 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id p12so10524149wrt.17
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 01:30:57 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id u3si31514349wmj.166.2019.01.21.01.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 01:30:56 -0800 (PST)
Subject: Re: [PATCH v3 3/3] powerpc/32: Add KASAN support
References: <cover.1547289808.git.christophe.leroy@c-s.fr>
 <935f9f83393affb5d55323b126468ecb90373b88.1547289808.git.christophe.leroy@c-s.fr>
 <e4b343fa-702b-294f-7741-bb85ed877cdf@virtuozzo.com>
 <8d433501-a5a7-8e3b-03f7-ccdd0f8622e1@c-s.fr>
 <CACT4Y+Z+UbN1rjHr3T5rgHpCJUknupPvEPw0SHs1-qjWBDhm3Q@mail.gmail.com>
 <d2f85bee-c551-ec9d-1a13-6d3364788cc1@c-s.fr>
 <CACT4Y+Y9H8LhpODFk6TE00kZWCU_V2QK1CStWxBt4EnWpLuCcQ@mail.gmail.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <b05f9674-daee-bbc6-0ee0-58d056a4f321@c-s.fr>
Date: Mon, 21 Jan 2019 10:30:55 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y9H8LhpODFk6TE00kZWCU_V2QK1CStWxBt4EnWpLuCcQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Alexander Potapenko <glider@google.com>, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>



Le 21/01/2019 à 10:24, Dmitry Vyukov a écrit :
> On Mon, Jan 21, 2019 at 9:37 AM Christophe Leroy
> <christophe.leroy@c-s.fr> wrote:
>>
>>
>>
>> Le 21/01/2019 à 09:30, Dmitry Vyukov a écrit :
>>> On Mon, Jan 21, 2019 at 8:17 AM Christophe Leroy
>>> <christophe.leroy@c-s.fr> wrote:
>>>>
>>>>
>>>>
>>>> Le 15/01/2019 à 18:23, Andrey Ryabinin a écrit :
>>>>>
>>>>>
>>>>> On 1/12/19 2:16 PM, Christophe Leroy wrote:
>>>>>
>>>>>> +KASAN_SANITIZE_early_32.o := n
>>>>>> +KASAN_SANITIZE_cputable.o := n
>>>>>> +KASAN_SANITIZE_prom_init.o := n
>>>>>> +
>>>>>
>>>>> Usually it's also good idea to disable branch profiling - define DISABLE_BRANCH_PROFILING
>>>>> either in top of these files or via Makefile. Branch profiling redefines if() statement and calls
>>>>> instrumented ftrace_likely_update in every if().
>>>>>
>>>>>
>>>>>
>>>>>> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
>>>>>> new file mode 100644
>>>>>> index 000000000000..3edc9c2d2f3e
>>>>>
>>>>>> +void __init kasan_init(void)
>>>>>> +{
>>>>>> +    struct memblock_region *reg;
>>>>>> +
>>>>>> +    for_each_memblock(memory, reg)
>>>>>> +            kasan_init_region(reg);
>>>>>> +
>>>>>> +    pr_info("KASAN init done\n");
>>>>>
>>>>> Without "init_task.kasan_depth = 0;" kasan will not repot bugs.
>>>>>
>>>>> There is test_kasan module. Make sure that it produce reports.
>>>>>
>>>>
>>>> Thanks for the review.
>>>>
>>>> Now I get the following very early in boot, what does that mean ?
>>>
>>> This looks like an instrumented memset call before kasan shadow is
>>> mapped, or kasan shadow is not zeros. Does this happen before or after
>>> mapping of kasan_early_shadow_page?
>>
>> This is after the mapping of kasan_early_shadow_page.
>>
>>> This version seems to miss what x86 code has to clear the early shadow:
>>>
>>> /*
>>> * kasan_early_shadow_page has been used as early shadow memory, thus
>>> * it may contain some garbage. Now we can clear and write protect it,
>>> * since after the TLB flush no one should write to it.
>>> */
>>> memset(kasan_early_shadow_page, 0, PAGE_SIZE);
>>
>> In the early part, kasan_early_shadow_page is mapped read-only so I
>> assumed this reset of its content was unneccessary.
>>
>> I'll try with it.
>>
>> Christophe
> 
> As far as I understand machine memory contains garbage after boot, and
> that page needs to be all 0's so we need to explicitly memset it.

That page is in BSS so it is zeroed before kasan_early_init().

Though as expected, that memset() doesn't fix the issue.

Indeed the problem is in kasan_init() : memblock_phys_alloc() doesn't 
zeroize the allocated memory. I changed it to memblock_alloc() and now 
it works.

Thanks for your help,
Christophe


> 
> 
>>>> [    0.000000] KASAN init done
>>>> [    0.000000]
>>>> ==================================================================
>>>> [    0.000000] BUG: KASAN: unknown-crash in memblock_alloc_try_nid+0xd8/0xf0
>>>> [    0.000000] Write of size 68 at addr c7ff5a90 by task swapper/0
>>>> [    0.000000]
>>>> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted
>>>> 5.0.0-rc2-s3k-dev-00559-g88aa407c4bce #772
>>>> [    0.000000] Call Trace:
>>>> [    0.000000] [c094ded0] [c016c7e4]
>>>> print_address_description+0x1a0/0x2b8 (unreliable)
>>>> [    0.000000] [c094df00] [c016caa0] kasan_report+0xe4/0x168
>>>> [    0.000000] [c094df40] [c016b464] memset+0x2c/0x4c
>>>> [    0.000000] [c094df60] [c08731f0] memblock_alloc_try_nid+0xd8/0xf0
>>>> [    0.000000] [c094df90] [c0861f20] mmu_context_init+0x58/0xa0
>>>> [    0.000000] [c094dfb0] [c085ca70] start_kernel+0x54/0x400
>>>> [    0.000000] [c094dff0] [c0002258] start_here+0x44/0x9c
>>>> [    0.000000]
>>>> [    0.000000]
>>>> [    0.000000] Memory state around the buggy address:
>>>> [    0.000000]  c7ff5980: e2 a1 87 81 bd d4 a5 b5 f8 8d 89 e7 72 bc 20 24
>>>> [    0.000000]  c7ff5a00: e7 b9 c1 c7 17 e9 b4 bd a4 d0 e7 a0 11 15 a5 b5
>>>> [    0.000000] >c7ff5a80: b5 e1 83 a5 2d 65 31 3f f3 e5 a7 ef 34 b5 69 b5
>>>> [    0.000000]                  ^
>>>> [    0.000000]  c7ff5b00: 21 a5 c1 c1 b4 bf 2d e5 e5 c3 f5 91 e3 b8 a1 34
>>>> [    0.000000]  c7ff5b80: ad ef 23 87 3d a6 ad b5 c3 c3 80 b7 ac b1 1f 37
>>>> [    0.000000]
>>>> ==================================================================
>>>> [    0.000000] Disabling lock debugging due to kernel taint
>>>> [    0.000000] MMU: Allocated 76 bytes of context maps for 16 contexts
>>>> [    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 8176
>>>> [    0.000000] Kernel command line: console=ttyCPM0,115200N8
>>>> ip=192.168.2.7:192.168.2.2::255.0.0.0:vgoip:eth0:off kgdboc=ttyCPM0
>>>> [    0.000000] Dentry cache hash table entries: 16384 (order: 2, 65536
>>>> bytes)
>>>> [    0.000000] Inode-cache hash table entries: 8192 (order: 1, 32768 bytes)
>>>> [    0.000000] Memory: 99904K/131072K available (7376K kernel code, 528K
>>>> rwdata, 1168K rodata, 576K init, 4623K bss, 31168K reserved, 0K
>>>> cma-reserved)
>>>> [    0.000000] Kernel virtual memory layout:
>>>> [    0.000000]   * 0xffefc000..0xffffc000  : fixmap
>>>> [    0.000000]   * 0xf7c00000..0xffc00000  : kasan shadow mem
>>>> [    0.000000]   * 0xf7a00000..0xf7c00000  : consistent mem
>>>> [    0.000000]   * 0xf7a00000..0xf7a00000  : early ioremap
>>>> [    0.000000]   * 0xc9000000..0xf7a00000  : vmalloc & ioremap
>>>>
>>>>
>>>> Christophe
