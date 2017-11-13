Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE916B0038
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:51:40 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id b189so12136868oia.10
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 08:51:40 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 81si6831817oid.421.2017.11.13.08.51.38
        for <linux-mm@kvack.org>;
        Mon, 13 Nov 2017 08:51:38 -0800 (PST)
Subject: Re: [PATCH] arm64: mm: Set MAX_PHYSMEM_BITS based on ARM64_VA_BITS
References: <1510268339-21989-1-git-send-email-vdumpa@nvidia.com>
 <9ff1d720-7137-4a9a-7934-1d01ea2ef208@arm.com>
 <20171112175532.GA11262@redhat.com>
 <25114cd5-4a22-f3e2-d9e9-2c1c68193b82@arm.com>
 <52f3f1c9-90ff-b568-9f25-9e0640bd6d29@arm.com>
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Message-ID: <1baf47a9-8939-0f85-bcf3-464dfbe58ce1@arm.com>
Date: Mon, 13 Nov 2017 16:51:34 +0000
MIME-Version: 1.0
In-Reply-To: <52f3f1c9-90ff-b568-9f25-9e0640bd6d29@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, Jerome Glisse <jglisse@redhat.com>
Cc: Krishna Reddy <vdumpa@nvidia.com>, catalin.marinas@arm.com, will.deacon@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-tegra@vger.kernel.org

On 13/11/17 12:56, Robin Murphy wrote:
> On 13/11/17 10:32, Suzuki K Poulose wrote:
>> On 12/11/17 17:55, Jerome Glisse wrote:
>>> On Fri, Nov 10, 2017 at 03:11:15PM +0000, Robin Murphy wrote:
>>>> On 09/11/17 22:58, Krishna Reddy wrote:
>>>>> MAX_PHYSMEM_BITS greater than ARM64_VA_BITS is causing memory
>>>>> access fault, when HMM_DMIRROR test is enabled.
>>>>> In the failing case, ARM64_VA_BITS=39 and MAX_PHYSMEM_BITS=48.
>>>>> HMM_DMIRROR test selects phys memory range from end based on
>>>>> MAX_PHYSMEM_BITS and gets mapped into VA space linearly.
>>>>> As VA space is 39-bit and phys space is 48-bit, this has caused
>>>>> incorrect mapping and leads to memory access fault.
>>>>>
>>>>> Limiting the MAX_PHYSMEM_BITS to ARM64_VA_BITS fixes the issue and is
>>>>> the right thing instead of hard coding it as 48-bit always.
>>>>>
>>>>> [A A A  3.378655] Unable to handle kernel paging request at virtual address 3befd000000
>>>>> [A A A  3.378662] pgd = ffffff800a04b000
>>>>> [A A A  3.378900] [3befd000000] *pgd=0000000081fa3003, *pud=0000000081fa3003, *pmd=0060000268200711
>>>>> [A A A  3.378933] Internal error: Oops: 96000044 [#1] PREEMPT SMP
>>>>> [A A A  3.378938] Modules linked in:
>>>>> [A A A  3.378948] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 4.9.52-tegra-g91402fdc013b-dirty #51
>>>>> [A A A  3.378950] Hardware name: quill (DT)
>>>>> [A A A  3.378954] task: ffffffc1ebac0000 task.stack: ffffffc1eba64000
>>>>> [A A A  3.378967] PC is at __memset+0x1ac/0x1d0
>>>>> [A A A  3.378976] LR is at sparse_add_one_section+0xf8/0x174
>>>>> [A A A  3.378981] pc : [<ffffff80084c212c>] lr : [<ffffff8008eda17c>] pstate: 404000c5
>>>>> [A A A  3.378983] sp : ffffffc1eba67a40
>>>>> [A A A  3.378993] x29: ffffffc1eba67a40 x28: 0000000000000000
>>>>> [A A A  3.378999] x27: 000000000003ffff x26: 0000000000000040
>>>>> [A A A  3.379005] x25: 00000000000003ff x24: ffffffc1e9f6cf80
>>>>> [A A A  3.379010] x23: ffffff8009ecb2d4 x22: 000003befd000000
>>>>> [A A A  3.379015] x21: ffffffc1e9923ff0 x20: 000000000003ffff
>>>>> [A A A  3.379020] x19: 00000000ffffffef x18: ffffffffffffffff
>>>>> [A A A  3.379025] x17: 00000000000024d7 x16: 0000000000000000
>>>>> [A A A  3.379030] x15: ffffff8009cd8690 x14: ffffffc1e9f6c70c
>>>>> [A A A  3.379035] x13: ffffffc1e9f6c70b x12: 0000000000000030
>>>>> [A A A  3.379039] x11: 0000000000000040 x10: 0101010101010101
>>>>> [A A A  3.379044] x9 : 0000000000000000 x8 : 000003befd000000
>>>>> [A A A  3.379049] x7 : 0000000000000000 x6 : 000000000000003f
>>>>> [A A A  3.379053] x5 : 0000000000000040 x4 : 0000000000000000
>>>>> [A A A  3.379058] x3 : 0000000000000004 x2 : 0000000000ffffc0
>>>>> [A A A  3.379063] x1 : 0000000000000000 x0 : 000003befd000000
>>>>> [A A A  3.379064]
>>>>> [A A A  3.379069] Process swapper/0 (pid: 1, stack limit = 0xffffffc1eba64028)
>>>>> [A A A  3.379071] Call trace:
>>>>> [A A A  3.379079] [<ffffff80084c212c>] __memset+0x1ac/0x1d0
>>>>
>>>> What's the deal with this memset? AFAICS we're in __add_pages() from
>>>> hmm_devmem_pages_create() calling add_pages() for private memory which it
>>>> does not expect to be in the linear map anyway :/
> 
> FWIW I did keep looking, and I now see that, thanks to confusing inlining, this is probably the clearing of the vmemmap section in sparse_add_one_section(), rather than any touching of the new memory itself. The fact that the commit message doesn't even try to explain the real problem (seemingly that the index has overflowed the vmemmap area and wrapped past the top of the address space) only emphasises my concern that this is a bit of a hack, though.
> 
>>>> There appears to be a more fundamental problem being papered over here.
> 
> Following some discussion with Suzuki and Catalin, there does seem to be a more general issue of the interaction between vmemmap and memory hotplug. Of course, arm64 doesn't support memory hotplug in mainline (it's something I've started looking at), nor other HMM dependencies, so there's already more going on here than meets the eye.
> 
>>> Yes i think the dummy driver is use badly, if you want to test CDM memory
>>> with dummy driver you need to steal regular memory to act as CDM memory.
>>> You can take a look at following 2 patches:
>>>
>>> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-cdm-next&id=fcc1e94027dbee9525f75b2a9ad88b2e6279558a
>>> https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-cdm-next&id=84204c5be742186236b371ea2f7ad39bf1770fe6
>>>
>>> Note that this is only if your device have its own memory that is not
>>> reported as regular ram to kernel resource and if that memory is
>>> accessible by CPU in cache coherent way.
>>>
>>> For tegra platform i don't think you have any such memory. Thus you
>>> do not need to register any memory to use HMM. But we can talk about
>>> your platform in private mail under NDA if it is not the case.
>>>
>>> Note that no matter what i still think it make sense to properly define
>>> MAX_PHYSMEM_BITS like on x86 or powerpc.
>>
>> Its a bit tricky on arm64. Essentially the VMEMMAP can cover a region
>> of (1 << (VA_BITS - 1)), the size of the linear map. However, it does
>> allow the physical memory to be above VA_BITS. e.g, one can boot a
>> 39bit VA kernel on a system where the RAM is at 40bits. We adjust the
>> "vmemmap" to make sure that it points to the first "valid" pfn (based
>> on the start address of the memory).
>>
>> If we reduce the MAX_PHYSMEM_BITS to VA_BITS, that could break the kernel
>> booting on platforms where the memory is above VA_BITS. I am wondering
>> if we should do an additional check, pfn_valid() before we go ahead
>> and assume that the PFN can be mapped in the cases like above.
> 
> __add_pages() - via __add_section() - is already checking pfn_valid() fairly early on in order to avoid overlapping sections, so it's not entirely clear where an additional check would help. Also, on arm64 the pfn_valid() implementation doesn't know about vmemmap since it just checks physical addresses against memblocks. In fact, this ends up being actively hostile to memory hotplug (via MEMORY_PROBE at least), because it gives us a false positive in the aforementioned check...
> 

Right. May be pfn_valid() is not the right place (which now only checks if the address
is in one of the RAM memory blocks on arm64) and as you rightly said is used by the
__add_section() to check for conflicts. The gist of the problem is that we don't
seem to check if a given PFN could be directly mapped in the linear address space,
given we have a limited linear space. I don't know what the best place to do that.

Btw, regarding the MAX_PHYSMEM_BITS, I could see that, at least on s390, the
end of memory could be less than the defined MAX_PHYSMEM_BITS. So, may be
we could hit a similar problem there.

Suzuki


> Robin.
> 
>>
>> Suzuki
>>
>>>
>>>>
>>>>> [A A A  3.379085] [<ffffff8008ed5100>] __add_pages+0x130/0x2e0
>>>>> [A A A  3.379093] [<ffffff8008211cf4>] hmm_devmem_pages_create+0x20c/0x310
>>>>> [A A A  3.379100] [<ffffff8008211fcc>] hmm_devmem_add+0x1d4/0x270
>>>>> [A A A  3.379128] [<ffffff80087111c8>] dmirror_probe+0x50/0x158
>>>>> [A A A  3.379137] [<ffffff8008732590>] platform_drv_probe+0x60/0xc8
>>>>> [A A A  3.379143] [<ffffff800872fbf4>] driver_probe_device+0x26c/0x420
>>>>> [A A A  3.379149] [<ffffff800872fecc>] __driver_attach+0x124/0x128
>>>>> [A A A  3.379155] [<ffffff800872d388>] bus_for_each_dev+0x88/0xe8
>>>>> [A A A  3.379166] [<ffffff800872f248>] driver_attach+0x30/0x40
>>>>> [A A A  3.379171] [<ffffff800872ec18>] bus_add_driver+0x1f8/0x2b0
>>>>> [A A A  3.379177] [<ffffff8008730e38>] driver_register+0x68/0x100
>>>>> [A A A  3.379183] [<ffffff80087324d4>] __platform_driver_register+0x5c/0x68
>>>>> [A A A  3.379192] [<ffffff800951f918>] hmm_dmirror_init+0x88/0xc4
>>>>> [A A A  3.379200] [<ffffff800808359c>] do_one_initcall+0x5c/0x170
>>>>> [A A A  3.379208] [<ffffff80094e0dd0>] kernel_init_freeable+0x1b8/0x258
>>>>> [A A A  3.379231] [<ffffff8008ed44f0>] kernel_init+0x18/0x108
>>>>> [A A A  3.379236] [<ffffff80080832d0>] ret_from_fork+0x10/0x40
>>>>> [A A A  3.379246] ---[ end trace 578db63bb139b8b8 ]---
>>>>>
>>>>> Signed-off-by: Krishna Reddy <vdumpa@nvidia.com>
>>>>> ---
>>>>> A A  arch/arm64/include/asm/sparsemem.h | 6 ++++++
>>>>> A A  1 file changed, 6 insertions(+)
>>>>>
>>>>> diff --git a/arch/arm64/include/asm/sparsemem.h b/arch/arm64/include/asm/sparsemem.h
>>>>> index 74a9d301819f..19ecd0b0f3a3 100644
>>>>> --- a/arch/arm64/include/asm/sparsemem.h
>>>>> +++ b/arch/arm64/include/asm/sparsemem.h
>>>>> @@ -17,7 +17,13 @@
>>>>> A A  #define __ASM_SPARSEMEM_H
>>>>> A A  #ifdef CONFIG_SPARSEMEM
>>>>> +
>>>>> +#ifdef CONFIG_ARM64_VA_BITS
>>>>> +#define MAX_PHYSMEM_BITSA A A  CONFIG_ARM64_VA_BITS
>>>>> +#else
>>>>> A A  #define MAX_PHYSMEM_BITSA A A  48
>>>>> +#endif
>>>>> +
>>>>> A A  #define SECTION_SIZE_BITSA A A  30
>>>>> A A  #endif
>>>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
