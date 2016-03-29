Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f179.google.com (mail-yw0-f179.google.com [209.85.161.179])
	by kanga.kvack.org (Postfix) with ESMTP id A3F936B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 01:13:56 -0400 (EDT)
Received: by mail-yw0-f179.google.com with SMTP id g3so5755426ywa.3
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 22:13:56 -0700 (PDT)
Received: from mail-yw0-x235.google.com (mail-yw0-x235.google.com. [2607:f8b0:4002:c05::235])
        by mx.google.com with ESMTPS id s85si8030912ybs.3.2016.03.28.22.13.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 22:13:55 -0700 (PDT)
Received: by mail-yw0-x235.google.com with SMTP id h129so5824000ywb.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 22:13:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160326133708.GA382@gwshan>
References: <1458921929-15264-1-git-send-email-gwshan@linux.vnet.ibm.com>
	<3qXFh60DRNz9sDH@ozlabs.org>
	<20160326133708.GA382@gwshan>
Date: Tue, 29 Mar 2016 13:13:55 +0800
Message-ID: <CAD8of+rA5cbu-HcEUnBTOCkcD+OQps865kdF7Wf85QYeGfh5pw@mail.gmail.com>
Subject: Re: [RFC] mm: Fix memory corruption caused by deferred page initialization
From: Li Zhang <zhlcindy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>, mgorman@suse.de

A problem is found by back porting page parallel initialisation for RHEL7.2.
And CONFIG_NO_BOOTMEM = n. If kernel old version with page parallel needs
to work well, it still needs to fix with BOOTMEM as this patch looks like.

There are some potential bugs with page parallel in RHEL7.2. I will continue
to look at it.

Thanks.

On Sat, Mar 26, 2016 at 9:37 PM, Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
> On Sat, Mar 26, 2016 at 08:47:17PM +1100, Michael Ellerman wrote:
>>Hi Gavin,
>>
>>On Fri, 2016-25-03 at 16:05:29 UTC, Gavin Shan wrote:
>>> During deferred page initialization, the pages are moved from memblock
>>> or bootmem to buddy allocator without checking they were reserved. Those
>>> reserved pages can be reallocated to somebody else by buddy/slab allocator.
>>> It leads to memory corruption and potential kernel crash eventually.
>>
>>Can you give me a bit more detail on what the bug is?
>>
>>I haven't seen any issues on my systems, but I realise now I haven't enabled
>>DEFERRED_STRUCT_PAGE_INIT - I assumed it was enabled by default.
>>
>>How did this get tested before submission?
>>
>
> Michael, I have to reply with same context in another thread in case
> somebody else wants to understand more: Li, who is in the cc list, is
> backporting deferred page initialization (CONFIG_DEFERRED_STRUCT_PAGE_INIT)
> from upstream kernel to RHEL 7.2 or 7.3 kernel (3.10.0-357.el7). RHEL kernel
> has (!CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT), meaning
> bootmem is enabled. She eventually runs into kernel crash and I jumped
> in to help understanding the root cause.
>
> There're two related kernel config options: ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
> and DEFERRED_STRUCT_PAGE_INIT. The former one is enabled on PPC by default.
> The later one isn't enabled by default.
>
> There are two test cases I had:
>
> - With (!CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT)
> on PowerNV platform, upstream kernel (4.5.rc7) and additional patch to support
> bootmem as it was removed on powerpc a while ago.
>
> - With (CONFIG_NO_BOOTMEM && CONFIG_DEFERRED_STRUCT_PAGE_INIT) on PowerNV platform,
> upstream kernel (4.5.rc7), I dumped the reserved memblock regions and added printk
> in function deferred_init_memmap() to check if memblock reserved PFN 0x1fff80 (one
> page in memblock reserved region#31, refer to the below kernel log) is released
> to buddy allocator or not when doing deferred page struct initialization. I did
> see that PFN is released to buddy allocator at that time. However, I didn't see
> kernel crash and it would be luck and the current deferred page struct initialization
> implementation: The pages in region [0, 2GB] except the memblock reserved ones are
> presented to buddy allocator at early stage. It's not deferred. So for the pages in
> [0, 2GB], we don't have consistency issue between memblock and buddy allocator.
> The pages in region [2GB ...] are all presented to buddy allocator despite they're
> reserved in memblock or not. It ensures the kernel text section isn't corrupted
> and we're lucky not seeing program interrupt because of illegal instruction.
>
> Below is the kernel log I got from the printk:
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>  index a762be5..7039bc5 100644
>  --- a/mm/page_alloc.c
>  +++ b/mm/page_alloc.c
>  @@ -1307,6 +1307,9 @@ static int __init deferred_init_memmap(void *data)
>                          }
>
>                          /* Minimise pfn page lookups and scheduler checks */
>  +                       if (pfn == 0x1fff80)
>  +                               pr_info("===> %s: Free PFN 0x%lx\n", __func__, pfn);
>
>
> [    0.000000] Linux version 4.5.0-11790-g4fab991-dirty (gwshan@gwshan) (gcc version 4.9.3 (Buildroot 2016.02-rc2-00093-g5ea3bce) ) #423 SMP Sat Mar 26 23:24:15 AEDT 2016
>         :
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x0000000000000000-0x0000001fffffffff]
> [    0.000000]   DMA32    empty
> [    0.000000]   Normal   empty
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x0000000000000000-0x0000000fffffffff]
> [    0.000000]   node   8: [mem 0x0000001000000000-0x0000001fffffffff]
>         :
> [    0.492855] Brought up 160 CPUs
> [    0.493047] Node 0 CPUs: 0-79
> [    0.493098] Node 8 CPUs: 80-159
> [    0.525746] ===> deferred_init_memmap: Free PFN 0x1fff80     <<<< In memblock reserved region#31
> [    0.525764] node 0 initialised, 1014458 pages in 30ms
> [    0.526005] node 8 initialised, 1012540 pages in 30ms
>         :
> [    8.973599] Dumping memblock [memory]
> [    8.973630]    [0000] [0000000000000000 - 0x0000001000000000, 0000001000000000] [0000000000000000] [0]
> [    8.973698]    [0001] [0000001000000000 - 0x0000002000000000, 0000001000000000] [0000000000000000] [8]
> [    8.973766] Dumping memblock [reserved]
> [    8.973797]    [0000] [0000000000000000 - 0x0000000001540000, 0000000001540000] [0000000000000000] [256]
> [    8.973866]    [0001] [000000000fc40000 - 0x000000000fcb0000, 0000000000070000] [0000000000000000] [256]
> [    8.973935]    [0002] [000000000fe80000 - 0x000000000fea0000, 0000000000020000] [0000000000000000] [256]
> [    8.974004]    [0003] [0000000030000000 - 0x0000000032de0000, 0000000002de0000] [0000000000000000] [256]
> [    8.974073]    [0004] [0000000039c00000 - 0x000000003a780200, 0000000000b80200] [0000000000000000] [256]
> [    8.974144]    [0005] [000000003fb00000 - 0x0000000040000000, 0000000000500000] [0000000000000000] [256]
> [    8.974213]    [0006] [000000007ffe0000 - 0x000000007fffddff, 000000000001ddff] [0000000000000000] [256]
> [    8.974281]    [0007] [0000000ff9c00000 - 0x0000000fff000000, 0000000005400000] [0000000000000000] [256]
> [    8.974351]    [0008] [0000000ffffa8000 - 0x0000000ffffd0000, 0000000000028000] [0000000000000000] [256]
> [    8.974419]    [0009] [0000000ffffde300 - 0x0000001000c40200, 0000000000c61f00] [0000000000000000] [256]
> [    8.974489]    [0010] [0000001ff0000000 - 0x0000001ff8000000, 0000000008000000] [0000000000000000] [256]
> [    8.974556]    [0011] [0000001ff9000000 - 0x0000001ffb000000, 0000000002000000] [0000000000000000] [256]
> [    8.974624]    [0012] [0000001ffd260000 - 0x0000001fff000000, 0000000001da0000] [0000000000000000] [256]
> [    8.974692]    [0013] [0000001fff15b780 - 0x0000001fff15b7f0, 0000000000000070] [0000000000000000] [256]
> [    8.974760]    [0014] [0000001fff15b800 - 0x0000001fff15b910, 0000000000000110] [0000000000000000] [256]
> [    8.974828]    [0015] [0000001fff15b980 - 0x0000001fff15c108, 0000000000000788] [0000000000000000] [256]
> [    8.974904]    [0016] [0000001fff15c180 - 0x0000001fff15c188, 0000000000000008] [0000000000000000] [256]
> [    8.974974]    [0017] [0000001fff174200 - 0x0000001fff17c223, 0000000000008023] [0000000000000000] [256]
> [    8.975042]    [0018] [0000001fff17c280 - 0x0000001fff17c2a3, 0000000000000023] [0000000000000000] [256]
> [    8.975110]    [0019] [0000001fff17c300 - 0x0000001fff1a5ba0, 00000000000298a0] [0000000000000000] [256]
> [    8.975178]    [0020] [0000001fff1a5c00 - 0x0000001fff1b8148, 0000000000012548] [0000000000000000] [256]
> [    8.975247]    [0021] [0000001fff1b8180 - 0x0000001fff1c86a0, 0000000000010520] [0000000000000000] [256]
> [    8.975315]    [0022] [0000001fff1c8700 - 0x0000001fff1dac48, 0000000000012548] [0000000000000000] [256]
> [    8.975385]    [0023] [0000001fff1dac80 - 0x0000001fff1eb0a0, 0000000000010420] [0000000000000000] [256]
> [    8.975454]    [0024] [0000001fff1eb100 - 0x0000001fff1fd3c8, 00000000000122c8] [0000000000000000] [256]
> [    8.975522]    [0025] [0000001fff1fd400 - 0x0000001fff20d820, 0000000000010420] [0000000000000000] [256]
> [    8.975592]    [0026] [0000001fff20d880 - 0x0000001fff21fb48, 00000000000122c8] [0000000000000000] [256]
> [    8.975660]    [0027] [0000001fff21fb80 - 0x0000001fff22ffa0, 0000000000010420] [0000000000000000] [256]
> [    8.975727]    [0028] [0000001fff230000 - 0x0000001fff2422c8, 00000000000122c8] [0000000000000000] [256]
> [    8.975795]    [0029] [0000001fff242300 - 0x0000001fff764b23, 0000000000522823] [0000000000000000] [256]
> [    8.975864]    [0030] [0000001fff764b48 - 0x0000001fff7ffffc, 000000000009b4b4] [0000000000000000] [256]
> [    8.975932]    [0031] [0000001fff800000 - 0x0000002000000000, 0000000000800000] [0000000000000000] [256]
>
>>> This fixes above issue by:
>>>
>>>    * Deferred releasing bootmem bitmap until the completion of deferred
>>>      page initialization.
>>
>>As I said in my other mail, we don't support bootmem anymore. So please resend
>>with just the non-bootmem fixes.
>>
>
> I think this patch is generic one. I guess bootmem might be supported on other
> platforms other than PPC? If that's the case, it would be fine to have the code
> fixing the bootmem bitmap if you agree. If you want me to split the patch into
> two for bootmem and memblock cases separately, I can do it absolutely. Please
> let me know your preference :-)
>
> Thanks,
> Gavin
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev



-- 

Best Regards
-Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
