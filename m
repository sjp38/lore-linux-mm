Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C4E926B0005
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 20:28:23 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so190280760pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:28:23 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id f85si41530041pfj.176.2016.01.19.17.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 17:28:22 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id e65so185312672pfe.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 17:28:22 -0800 (PST)
Subject: Re: [BUG]: commit a1c34a3bf00a breaks an out-of-tree MIPS platform
References: <569C88AD.9080607@gentoo.org> <569D344D.50405@labbott.name>
 <569E011E.50908@gentoo.org>
From: Laura Abbott <laura@labbott.name>
Message-ID: <569EE2B3.1030705@labbott.name>
Date: Tue, 19 Jan 2016 17:28:19 -0800
MIME-Version: 1.0
In-Reply-To: <569E011E.50908@gentoo.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Kinard <kumba@gentoo.org>, Linux/MIPS <linux-mips@linux-mips.org>, linux-mm@kvack.org
Cc: Tony Luck <tony.luck@intel.com>

On 1/19/16 1:25 AM, Joshua Kinard wrote:
> On 01/18/2016 13:51, Laura Abbott wrote:
>> On 1/17/16 10:39 PM, Joshua Kinard wrote:
>>> Hi,
>>>
>>> I recently discovered that commit a1c34a3bf00a (mm: Don't offset memmap for
>>> flatmem) broke an out-of-tree MIPS platform, the IP30 (SGI Octane, a ~late
>>> 1990's graphics workstation).  Booting up, I get an "unhandled kernel unaligned
>>> access" when registering one of the IP30-specific serial UART drivers (which
>>> hangs off of the IOC3 PCI metadevice).
>>>
>>> It seems that the specific hunk causing the is this one:
>>> @@ -5452,9 +5455,9 @@ static void __init_refok alloc_node_mem_map(struct
>>> pglist_data *pgdat)
>>>    	 */
>>>    	if (pgdat == NODE_DATA(0)) {
>>>    		mem_map = NODE_DATA(0)->node_mem_map;
>>> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>>> +#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>>>    		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
>>> -			mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
>>> +			mem_map -= offset;
>>>    #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>>    	}
>>>    #endif
>>>
>>>
>>> I copied down the Oops message, which is:
>>> [    2.460398] Unhandled kernel unaligned access[#1]:
>>> [    2.460715] CPU: 1 PID: 14 Comm: kdevtmpfs Not tainted
>>> 4.4.0-mipsgit-20160110 #42
>>> [    2.461079] task: a800000060181f00 ti: a800000060190000 task.ti:
>>> a800000060190000
>>> [    2.461437] $ 0   : 0000000000000000 0000000020009fe0 0000000000000000
>>> 0000000000000000
>>> [    2.461914] $ 4   : 0000000020223e30 a800000060190000 0000000000000001
>>> 0000000000000000
>>> [    2.462386] $ 8   : a80000006019fc40 0000000000000003 0000000000000001
>>> a80000006044db80
>>> [    2.462852] $12   : ffffffff9404dce0 000000001000001e 0000000000000000
>>> ffffffffffffff80
>>> [    2.463320] $16   : a80000006019faa0 ffffffffdc500000 0000000000000000
>>> a800000020062664
>>> [    2.463786] $20   : 28000000205a0400 a800000020062a2c 0000000000000000
>>> a800000060023280
>>> [    2.464251] $24   : a80000006044db40 0000000000000000
>>> [    2.464716] $28   : a800000060190000 a80000006019fa50 0000000000000000
>>> a800000020009fe0
>>> [    2.465183] Hi    : fffffffff832db7f
>>> [    2.465363] Lo    : 000000003f9f7ce5
>>> [    2.465563] epc   : a800000020012ebc do_ade+0x57c/0x8b0
>>> [    2.465823] ra    : a800000020009fe0 ret_from_exception+0x0/0x18
>>> [    2.466107] Status: 9404dce2*KX SX UX KERNEL EXL
>>> [    2.466446] Cause : 00000010 (ExcCode 04)
>>> [    2.466642] BadVA : 28000000205a0400
>>> [    2.466822] PrId  : 00000f24 (R14000)
>>> [    2.467011] Process kdevtmpfs (pid: 14, threadinfo=a800000060190000,
>>> task=a800000060181f00, tls=0000000000000000
>>> [    2.467483] Stack : 0000000000000000 ffffffff00000000 a8000000205a03f8
>>> a8000000205a0400
>>> *  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
>>> *  0000000000000000 a800000020009fe0 0000000000000000 ffffffff9404dce0
>>> *  28000000205a0400 0000000000010000 a8000000205a03f8 0000000000000003
>>> *  0000000000000001 0000000000000000 a80000006019fc40 0000000000000003
>>> *  0000000000000001 a80000006044db80 ffffffffffff0000 000000000000007f
>>> *  0000000000000000 ffffffffffffff80 a8000000205a03f8 a8000000205a0400
>>> *  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
>>> *  0000000000000000 a800000060023280 a80000006044db40 0000000000000000
>>> *  ffffffffffff0000 000000000000007f a800000060190000 a80000006019fbd0
>>> *  ...
>>> [    2.540485] Call Trace:
>>> [    2.551852] [<a800000020012ebc>] do_ade+0x57c/0x8b0
>>> [    2.563244] [<a800000020009fe0>] ret_from_exception+0x0/0x18
>>> [    2.574590] [<a800000020062660>] __wake_up_common+0x30/0xd0
>>> [    2.586006] [<a800000020062a2c>] __wake_up+0x44/0x68
>>> [    2.597483] [<a800000020063018>] __wake_up_bit+0x38/0x48
>>> [    2.608856] [<a80000002010498c>] evict+0x10c/0x1a8
>>> [    2.620112] [<a8000000200f89d8>] vfs_unlink+0x150/0x188
>>> [    2.631473] [<a800000020203eb0>] handle_remove+0x1f0/0x358
>>> [    2.642846] [<a800000020204468>] devtmpfsd+0x1c8/0x258
>>> [    2.654123] [<a80000002004112c>] kthread+0x10c/0x128
>>> [    2.665231] [<a80000002000a048>] ret_from_kernel_thread+0x14/0x1c
>>> [    2.676326]
>>> [    2.687315]
>>> Code: 00431024  1440ff12  00000000 <6a960000> 6e960007  24020000  1440ff53
>>> 00000000  bfb40000
>>> [    2.709740] ---[ end trace d8580deb2e1d1d4a ]---
>>> [    2.721069] Fatal exception: panic in 5 seconds
>>>
>>>
>>> The key problem is that BadVA specifies an address of 0x28000000205a0400, which
>>> is inside the "unused" address space on 64-bit MIPS platforms.  That address
>>> should really be 0xa8000000205a0400 (which is visible in the stack dump), so
>>> something is getting mistranslated here it seems.
>>>
>>> I'm not really sure what ARCH_PFN_OFFSET is used for, but for IP30 systems, it
>>> seems important. Reverting both commit b0aeba741b2d (Fix alloc_node_mem_map()
>>> to work on ia64 again) and this one allows IP30 systems to boot Linux-4.4.0.
>>> However, I don't think that is the right fix, because it's too high up in
>>> generic code, and the other SGI platforms (at least SGI IP32/O2 and SGI
>>> IP27/Origin/Onyx) don't seem to be affected. I'm wondering if there's something
>>> in the MIPS core code that I probably need to make use of, or probably a change
>>> within IP30's platform code.
>>>
>>> IP30 support in Linux does have some known issues with the current memory
>>> setup, namely that all memory is currently being assigned to the "DMA" zone,
>>> and nothing for "Normal" or "DMA32".  IP30 also has an oddity where System RAM
>>> physically starts 512MB in on the address space.  I am not sure if either has
>>> any bearing on this specific problem.
>>>
>>> Any advice on fixing this properly would be appreciated.
>>>
>>> Thanks!
>>>
>>
>> What the patch was going for is to make sure that pfn 0 on the system
>> corresponds to mem_map[0] when pfn <-> page translation functions are
>> invoked. I'm guessing something is different on this system so the
>> code is not generating that properly which is giving the BadVA.
>>
>> I suspect there is a disconnect between node_start_pfn and ARCH_PFN_OFFSET.
>> Can you share the platform code and .config you are using and also use
>> this debugging patch to get a bit more info?
>>
>> Thanks,
>> Laura
>
> I've placed several files at this location, since I'm not sure which will be
> the most helpful (sorry, don't track this stuff directly in a public git just yet):
> http://dev.gentoo.org/~kumba/ip30/4.4.0/
>
> - 5401_ip30-diffstat.txt
> diffstat of the primary IP30 patch (contains core code), so you can see what
> files are actually changed.
>
> - IP30-config
> .config for IP30/Octane
>
> - IP30-dmesg
> output of 'dmesg'
>
> - linux-4.4.0-20160116.ip30/
> unpacked linux tree created by the 'mips-sources' package in Gentoo if
> USE="ip30".  This is the tree I built my most recent kernel out of (after
> running make clean).  Excludes your debugging patch, and has both commits
> b0aeba741b2d & a1c34a3bf00a reverted.  The main IP30 code is in:
>    * arch/mips/sgi-ip30
>    * arch/mips/include/asm/mach-ip30
>    * arch/mips/pci/pci-ip30.c
>
> - linux-4.4.0-20160116.ip30.tar.xz
> xztar of the above directory
>
> - mips-patches-4.4.0/
> unpacked directory of the "mips-patches" applied by mips-sources.
>
> - mips-sources-4.4.0-patches-v1.tar.xz
> xztar of above
>
>
>> -----8<-----
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 9d666df..fb353c9 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5307,6 +5307,10 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>>                           mem_map -= offset;
>>    #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>           }
>> +       pr_info(">>> ARCH_PFN_OFFSET %lx\n", ARCH_PFN_OFFSET);
>> +       pr_info(">>> pgdat->node_start_pfn %lx\n", pgdat->node_start_pfn);
>> +       pr_info(">>> offset %lx\n", offset);
>> +       pr_info(">>> first pfn %lx\n", page_to_pfn(mem_map));
>>    #endif
>>    #endif /* CONFIG_FLAT_NODE_MEM_MAP */
>>    }
>
> I ran this once with your (and Todd's) patches applied, then reverted both and
> ran it again:
>
> With both b0aeba741b2d & a1c34a3bf00a:
>>>> ARCH_PFN_OFFSET 0
>>>> pgdat->node_start_pfn 2000
>>>> offset 0
>>>> first pfn 0
>
> Without (dropped the 'offset' pr_info, since that var doesn't exist):
>>>> ARCH_PFN_OFFSET 0
>>>> pgdat->node_start_pfn 2000
>>>> first pfn 0
>
> So in both instances, the values are effectively the same...odd.
>
> IP30/Octane is very close, hardware-wise, to the IP27/Origin line, the first
> NUMA-capable machine added to Linux all those years ago.  But Octane itself is
> effectively a non-NUMA platform (not too dissimilar from a single-node Origin
> unit).  That's why it doesn't use any of the MEMBLOCK stuff...which seems to
> only be for NUMA machines.
>
> Octane also has its memory laid out fairly contiguously, starting at that 512MB
> offset, so it uses CONFIG_FLATMEM since I don't think CONFIG_SPARSEMEM really
> helps it out any.  I did rewrite the memory detection code a while back, though
> I don't think that should be an issue....but one never knows.
>
> Let me know if you need anything else.  Thanks!
>
>

So the disconnect here seems to be that previously the mem_map was adjusted by
the start pfn. The patch I did now makes the assumption that ARCH_PFN_OFFSET
is properly set to allow the page translation to work for flatmem. It looks
like your system has memory not starting at 0x0 but doesn't set ARCH_PFN_OFFSET
to do any work, hence the breakage. Based on the discussion to get the patch
in, some details about the motivations for this part of the code have been lost.

I don't know MIPS but at least on ARM if your memory is starting at an offset
from 0x0, the recommendation is to have PHYS_OFFSET be set based on that.
I also noticed in your dmesg there was this

[    0.000000] Wasting 524288 bytes for tracking 8192 unused pages

which is also an indication there is a mismatch between ARCH_PFN_OFFSET and your
memory layout. I'd suggest setting your PHYS_OFFSET to match your layout.
Other boards seem to set this in an include/asm/mach-foo/spaces.h file.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
