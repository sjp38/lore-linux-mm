Date: Wed, 22 Aug 2007 13:48:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.23-rc3-mm1 kernel BUG at mm/page_alloc.c:2876!
Message-Id: <20070822134800.ce5a5a69.akpm@linux-foundation.org>
In-Reply-To: <46CC9A7A.2030404@linux.vnet.ibm.com>
References: <46CC9A7A.2030404@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007 01:50:10 +0530
Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:

> Hi Andrew,
> 
> I see call trace followed by the kernel bug with the 2.6.23-rc3-mm1
> kernel and have attached the boot log and config file.
> 
> =======================================================
> SLUB: Genslabs=12, HWalign=128, Order=0-1, MinObjects=4, CPUs=4, Nodes=16
> Bad page state in process 'swapper'
> page:cf00000000015818 flags:0x0000020000000400 mapping:0000000000000000 
> mapcount:0 count:0
> Trying to fix it up, but a reboot is needed
> Backtrace:
> Call Trace:
> [c0000000005cbab0] [c000000000010344] .show_stack+0x68/0x1b4 (unreliable)
> [c0000000005cbb60] [c0000000000a6c54] .bad_page+0x84/0x138
> [c0000000005cbbf0] [c0000000000aa9e0] .free_hot_cold_page+0xdc/0x21c
> [c0000000005cbc90] [c0000000000ad7ec] .put_page+0x158/0x180
> [c0000000005cbd30] [c0000000000d4de8] .kfree+0x74/0xf0
> [c0000000005cbdb0] [c0000000000a866c] .process_zones+0x1a8/0x1f8
> [c0000000005cbe60] [c0000000004b5160] .setup_per_cpu_pageset+0x24/0x48
> [c0000000005cbee0] [c0000000004978d8] .start_kernel+0x304/0x3f4
> [c0000000005cbf90] [c0000000003bef10] .start_here_common+0x54/0x58
> Hexdump:
> 000: cf 00 00 00 00 01 57 d0 00 00 02 00 00 00 04 00
> 010: 00 00 00 01 ff ff ff ff 00 00 00 00 00 00 00 00
> 020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 030: cf 00 00 00 00 01 58 08 cf 00 00 00 00 01 58 08
> 040: 00 00 02 00 00 00 04 00 00 00 00 00 ff ff ff ff
> 050: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 060: 00 00 00 00 00 00 00 00 cf 00 00 00 00 01 58 40
> 070: cf 00 00 00 00 01 58 40 00 00 02 00 00 00 04 00
> 080: 00 00 00 01 ff ff ff ff 00 00 00 00 00 00 00 00
> 090: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 0a0: cf 00 00 00 00 01 58 78 cf 00 00 00 00 01 58 78
> 0b0: 00 00 02 00 00 00 04 00 00 00 00 01 ff ff ff ff
> ------------[ cut here ]------------
> kernel BUG at mm/page_alloc.c:2876!
> cpu 0x0: Vector: 700 (Program Check) at [c0000000005cbbe0]
>     pc: c0000000004b5160: .setup_per_cpu_pageset+0x24/0x48
>     lr: c0000000004b5160: .setup_per_cpu_pageset+0x24/0x48
>     sp: c0000000005cbe60
>    msr: 8000000000029032
>   current = 0xc0000000004fd1b0
>   paca    = 0xc0000000004fdd80
>     pid   = 0, comm = swapper
> kernel BUG at mm/page_alloc.c:2876!
> 

Looks like process_zones() got a kmalloc_node() failure and then crashed in
the recovery code.

This:

--- a/mm/page_alloc.c~a
+++ a/mm/page_alloc.c
@@ -2814,6 +2814,8 @@ static int __cpuinit process_zones(int c
 	return 0;
 bad:
 	for_each_zone(dzone) {
+		if (!populated_zone(zone))
+			continue;		
 		if (dzone == zone)
 			break;
 		kfree(zone_pcp(dzone, cpu));
_

might help avoid the crash, but why did kmalloc_node() fail?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
