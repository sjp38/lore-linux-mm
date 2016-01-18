Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 752126B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 01:40:10 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id t15so49249866igr.0
        for <linux-mm@kvack.org>; Sun, 17 Jan 2016 22:40:10 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id gb4si707203igd.71.2016.01.17.22.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 17 Jan 2016 22:40:09 -0800 (PST)
From: Joshua Kinard <kumba@gentoo.org>
Subject: [BUG]: commit a1c34a3bf00a breaks an out-of-tree MIPS platform
Message-ID: <569C88AD.9080607@gentoo.org>
Date: Mon, 18 Jan 2016 01:39:41 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux/MIPS <linux-mips@linux-mips.org>, linux-mm@kvack.org, Laura Abbott <laura@labbott.name>
Cc: Tony Luck <tony.luck@intel.com>

Hi,

I recently discovered that commit a1c34a3bf00a (mm: Don't offset memmap for
flatmem) broke an out-of-tree MIPS platform, the IP30 (SGI Octane, a ~late
1990's graphics workstation).  Booting up, I get an "unhandled kernel unaligned
access" when registering one of the IP30-specific serial UART drivers (which
hangs off of the IOC3 PCI metadevice).

It seems that the specific hunk causing the is this one:
@@ -5452,9 +5455,9 @@ static void __init_refok alloc_node_mem_map(struct
pglist_data *pgdat)
 	 */
 	if (pgdat == NODE_DATA(0)) {
 		mem_map = NODE_DATA(0)->node_mem_map;
-#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+#if defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) || defined(CONFIG_FLATMEM)
 		if (page_to_pfn(mem_map) != pgdat->node_start_pfn)
-			mem_map -= (pgdat->node_start_pfn - ARCH_PFN_OFFSET);
+			mem_map -= offset;
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 	}
 #endif


I copied down the Oops message, which is:
[    2.460398] Unhandled kernel unaligned access[#1]:
[    2.460715] CPU: 1 PID: 14 Comm: kdevtmpfs Not tainted
4.4.0-mipsgit-20160110 #42
[    2.461079] task: a800000060181f00 ti: a800000060190000 task.ti:
a800000060190000
[    2.461437] $ 0   : 0000000000000000 0000000020009fe0 0000000000000000
0000000000000000
[    2.461914] $ 4   : 0000000020223e30 a800000060190000 0000000000000001
0000000000000000
[    2.462386] $ 8   : a80000006019fc40 0000000000000003 0000000000000001
a80000006044db80
[    2.462852] $12   : ffffffff9404dce0 000000001000001e 0000000000000000
ffffffffffffff80
[    2.463320] $16   : a80000006019faa0 ffffffffdc500000 0000000000000000
a800000020062664
[    2.463786] $20   : 28000000205a0400 a800000020062a2c 0000000000000000
a800000060023280
[    2.464251] $24   : a80000006044db40 0000000000000000
[    2.464716] $28   : a800000060190000 a80000006019fa50 0000000000000000
a800000020009fe0
[    2.465183] Hi    : fffffffff832db7f
[    2.465363] Lo    : 000000003f9f7ce5
[    2.465563] epc   : a800000020012ebc do_ade+0x57c/0x8b0
[    2.465823] ra    : a800000020009fe0 ret_from_exception+0x0/0x18
[    2.466107] Status: 9404dce2*KX SX UX KERNEL EXL
[    2.466446] Cause : 00000010 (ExcCode 04)
[    2.466642] BadVA : 28000000205a0400
[    2.466822] PrId  : 00000f24 (R14000)
[    2.467011] Process kdevtmpfs (pid: 14, threadinfo=a800000060190000,
task=a800000060181f00, tls=0000000000000000
[    2.467483] Stack : 0000000000000000 ffffffff00000000 a8000000205a03f8
a8000000205a0400
*  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
*  0000000000000000 a800000020009fe0 0000000000000000 ffffffff9404dce0
*  28000000205a0400 0000000000010000 a8000000205a03f8 0000000000000003
*  0000000000000001 0000000000000000 a80000006019fc40 0000000000000003
*  0000000000000001 a80000006044db80 ffffffffffff0000 000000000000007f
*  0000000000000000 ffffffffffffff80 a8000000205a03f8 a8000000205a0400
*  a80000006019fc40 a800000060018580 a800000020382310 0000000000000001
*  0000000000000000 a800000060023280 a80000006044db40 0000000000000000
*  ffffffffffff0000 000000000000007f a800000060190000 a80000006019fbd0
*  ...
[    2.540485] Call Trace:
[    2.551852] [<a800000020012ebc>] do_ade+0x57c/0x8b0
[    2.563244] [<a800000020009fe0>] ret_from_exception+0x0/0x18
[    2.574590] [<a800000020062660>] __wake_up_common+0x30/0xd0
[    2.586006] [<a800000020062a2c>] __wake_up+0x44/0x68
[    2.597483] [<a800000020063018>] __wake_up_bit+0x38/0x48
[    2.608856] [<a80000002010498c>] evict+0x10c/0x1a8
[    2.620112] [<a8000000200f89d8>] vfs_unlink+0x150/0x188
[    2.631473] [<a800000020203eb0>] handle_remove+0x1f0/0x358
[    2.642846] [<a800000020204468>] devtmpfsd+0x1c8/0x258
[    2.654123] [<a80000002004112c>] kthread+0x10c/0x128
[    2.665231] [<a80000002000a048>] ret_from_kernel_thread+0x14/0x1c
[    2.676326]
[    2.687315]
Code: 00431024  1440ff12  00000000 <6a960000> 6e960007  24020000  1440ff53
00000000  bfb40000
[    2.709740] ---[ end trace d8580deb2e1d1d4a ]---
[    2.721069] Fatal exception: panic in 5 seconds


The key problem is that BadVA specifies an address of 0x28000000205a0400, which
is inside the "unused" address space on 64-bit MIPS platforms.  That address
should really be 0xa8000000205a0400 (which is visible in the stack dump), so
something is getting mistranslated here it seems.

I'm not really sure what ARCH_PFN_OFFSET is used for, but for IP30 systems, it
seems important. Reverting both commit b0aeba741b2d (Fix alloc_node_mem_map()
to work on ia64 again) and this one allows IP30 systems to boot Linux-4.4.0.
However, I don't think that is the right fix, because it's too high up in
generic code, and the other SGI platforms (at least SGI IP32/O2 and SGI
IP27/Origin/Onyx) don't seem to be affected. I'm wondering if there's something
in the MIPS core code that I probably need to make use of, or probably a change
within IP30's platform code.

IP30 support in Linux does have some known issues with the current memory
setup, namely that all memory is currently being assigned to the "DMA" zone,
and nothing for "Normal" or "DMA32".  IP30 also has an oddity where System RAM
physically starts 512MB in on the address space.  I am not sure if either has
any bearing on this specific problem.

Any advice on fixing this properly would be appreciated.

Thanks!

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
6144R/F5C6C943 2015-04-27
177C 1972 1FB8 F254 BAD0 3E72 5C63 F4E3 F5C6 C943

"The past tempts us, the present confuses us, the future frightens us.  And our
lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
