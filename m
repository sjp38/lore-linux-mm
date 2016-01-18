Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 313F56B0009
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 13:52:01 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so423718148pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 10:52:01 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id w64si34990083pfi.202.2016.01.18.10.51.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 10:52:00 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id uo6so423717947pac.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 10:51:59 -0800 (PST)
Subject: Re: [BUG]: commit a1c34a3bf00a breaks an out-of-tree MIPS platform
References: <569C88AD.9080607@gentoo.org>
From: Laura Abbott <laura@labbott.name>
Message-ID: <569D344D.50405@labbott.name>
Date: Mon, 18 Jan 2016 10:51:57 -0800
MIME-Version: 1.0
In-Reply-To: <569C88AD.9080607@gentoo.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joshua Kinard <kumba@gentoo.org>, Linux/MIPS <linux-mips@linux-mips.org>, linux-mm@kvack.org
Cc: Tony Luck <tony.luck@intel.com>

On 1/17/16 10:39 PM, Joshua Kinard wrote:
> Hi,
>
> I recently discovered that commit a1c34a3bf00a (mm: Don't offset memmap for
> flatmem) broke an out-of-tree MIPS platform, the IP30 (SGI Octane, a ~late
> 1990's graphics workstation).  Booting up, I get an "unhandled kernel unaligned
> access" when registering one of the IP30-specific serial UART drivers (which
> hangs off of the IOC3 PCI metadevice).
>
> It seems that the specific hunk causing the is this one:
> @@ -5452,9 +5455,9 @@ static void __init_refok alloc_node_mem_map(struct
> pglist_data *pgdat)
>   	 */
>   	if (pgdat == NODE_DATA(0)) {
>   		mem_map = NODE_DATA(0)->node_mem_map;
> -#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
>   		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
> -			mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
> +			mem_map -= offset;
>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>   	}
>   #endif
>
>
> I copied down the Oops message, which is:
> [    2.460398] Unhandled kernel unaligned access[#1]:
> [    2.460715] CPU: 1 PID: 14 Comm: kdevtmpfs Not tainted
> 4.4.0-mipsgit-20160110 #42
> [    2.461079] task: a800000060181f00 ti: a800000060190000 task.ti:
> a800000060190000
> [    2.461437] $ 0   : 0000000000000000 0000000020009fe0 0000000000000000
> 0000000000000000
> [    2.461914] $ 4   : 0000000020223e30 a800000060190000 0000000000000001
> 0000000000000000
> [    2.462386] $ 8   : a80000006019fc40 0000000000000003 0000000000000001
> a80000006044db80
> [    2.462852] $12   : ffffffff9404dce0 000000001000001e 0000000000000000
> ffffffffffffff80
> [    2.463320] $16   : a80000006019faa0 ffffffffdc500000 0000000000000000
> a800000020062664
> [    2.463786] $20   : 28000000205a0400 a800000020062a2c 0000000000000000
> a800000060023280
> [    2.464251] $24   : a80000006044db40 0000000000000000
> [    2.464716] $28   : a800000060190000 a80000006019fa50 0000000000000000
> a800000020009fe0
> [    2.465183] Hi    : fffffffff832db7f
> [    2.465363] Lo    : 000000003f9f7ce5
> [    2.465563] epc   : a800000020012ebc do_ade+0x57c/0x8b0
> [    2.465823] ra    : a800000020009fe0 ret_from_exception+0x0/0x18
> [    2.466107] Status: 9404dce2*KX SX UX KERNEL EXL
> [    2.466446] Cause : 00000010 (ExcCode 04)
> [    2.466642] BadVA : 28000000205a0400
> [    2.466822] PrId  : 00000f24 (R14000)
> [    2.467011] Process kdevtmpfs (pid: 14, threadinfo=a800000060190000,
> task=a800000060181f00, tls=0000000000000000
> [    2.467483] Stack : 0000000000000000 ffffffff00000000 a8000000205a03f8
> a8000000205a0400
> *  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
> *  0000000000000000 a800000020009fe0 0000000000000000 ffffffff9404dce0
> *  28000000205a0400 0000000000010000 a8000000205a03f8 0000000000000003
> *  0000000000000001 0000000000000000 a80000006019fc40 0000000000000003
> *  0000000000000001 a80000006044db80 ffffffffffff0000 000000000000007f
> *  0000000000000000 ffffffffffffff80 a8000000205a03f8 a8000000205a0400
> *  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
> *  0000000000000000 a800000060023280 a80000006044db40 0000000000000000
> *  ffffffffffff0000 000000000000007f a800000060190000 a80000006019fbd0
> *  ...
> [    2.540485] Call Trace:
> [    2.551852] [<a800000020012ebc>] do_ade+0x57c/0x8b0
> [    2.563244] [<a800000020009fe0>] ret_from_exception+0x0/0x18
> [    2.574590] [<a800000020062660>] __wake_up_common+0x30/0xd0
> [    2.586006] [<a800000020062a2c>] __wake_up+0x44/0x68
> [    2.597483] [<a800000020063018>] __wake_up_bit+0x38/0x48
> [    2.608856] [<a80000002010498c>] evict+0x10c/0x1a8
> [    2.620112] [<a8000000200f89d8>] vfs_unlink+0x150/0x188
> [    2.631473] [<a800000020203eb0>] handle_remove+0x1f0/0x358
> [    2.642846] [<a800000020204468>] devtmpfsd+0x1c8/0x258
> [    2.654123] [<a80000002004112c>] kthread+0x10c/0x128
> [    2.665231] [<a80000002000a048>] ret_from_kernel_thread+0x14/0x1c
> [    2.676326]
> [    2.687315]
> Code: 00431024  1440ff12  00000000 <6a960000> 6e960007  24020000  1440ff53
> 00000000  bfb40000
> [    2.709740] ---[ end trace d8580deb2e1d1d4a ]---
> [    2.721069] Fatal exception: panic in 5 seconds
>
>
> The key problem is that BadVA specifies an address of 0x28000000205a0400, which
> is inside the "unused" address space on 64-bit MIPS platforms.  That address
> should really be 0xa8000000205a0400 (which is visible in the stack dump), so
> something is getting mistranslated here it seems.
>
> I'm not really sure what ARCH_PFN_OFFSET is used for, but for IP30 systems, it
> seems important. Reverting both commit b0aeba741b2d (Fix alloc_node_mem_map()
> to work on ia64 again) and this one allows IP30 systems to boot Linux-4.4.0.
> However, I don't think that is the right fix, because it's too high up in
> generic code, and the other SGI platforms (at least SGI IP32/O2 and SGI
> IP27/Origin/Onyx) don't seem to be affected. I'm wondering if there's something
> in the MIPS core code that I probably need to make use of, or probably a change
> within IP30's platform code.
>
> IP30 support in Linux does have some known issues with the current memory
> setup, namely that all memory is currently being assigned to the "DMA" zone,
> and nothing for "Normal" or "DMA32".  IP30 also has an oddity where System RAM
> physically starts 512MB in on the address space.  I am not sure if either has
> any bearing on this specific problem.
>
> Any advice on fixing this properly would be appreciated.
>
> Thanks!
>

What the patch was going for is to make sure that pfn 0 on the system
corresponds to mem_map[0] when pfn <-> page translation functions are
invoked. I'm guessing something is different on this system so the
code is not generating that properly which is giving the BadVA.

I suspect there is a disconnect between node_start_pfn and ARCH_PFN_OFFSET.
Can you share the platform code and .config you are using and also use
this debugging patch to get a bit more info?

Thanks,
Laura

-----8<-----

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9d666df..fb353c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5307,6 +5307,10 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
                         mem_map -= offset;
  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
         }
+       pr_info(">>> ARCH_PFN_OFFSET %lx\n", ARCH_PFN_OFFSET);
+       pr_info(">>> pgdat->node_start_pfn %lx\n", pgdat->node_start_pfn);
+       pr_info(">>> offset %lx\n", offset);
+       pr_info(">>> first pfn %lx\n", page_to_pfn(mem_map));
  #endif
  #endif /* CONFIG_FLAT_NODE_MEM_MAP */
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
