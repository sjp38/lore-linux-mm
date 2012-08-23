Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 40F266B0068
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:48:30 -0400 (EDT)
Date: Thu, 23 Aug 2012 17:48:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/ia64: fix a memory block size bug
Message-ID: <20120823154646.GA10789@dhcp22.suse.cz>
References: <50330482.4070204@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50330482.4070204@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wujianguo <wujianguo106@gmail.com>
Cc: tony.luck@intel.com, kay.sievers@vrfy.org, minchan.kim@gmail.com, mgorman@suse.de, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, wency@cn.fujitsu.com, akpm@linux-foundation.org, yinghai@kernel.org, liuj97@gmail.com, jiang.liu@huawei.com, qiuxishi@huawei.com, wujianguo@huawei.com, guohanjun@huawei.com, Greg KH <greg@kroah.com>

[Fixed gregkh email address]

On Tue 21-08-12 11:46:10, wujianguo wrote:
> From: Jianguo Wu <wujianguo@huawei.com>
> 
> Hi all,
> 	I found following definition in include/linux/memory.h, in my IA64
> platform, SECTION_SIZE_BITS is equal to 32, and MIN_MEMORY_BLOCK_SIZE will be 0.
> 	#define MIN_MEMORY_BLOCK_SIZE     (1 << SECTION_SIZE_BITS)

OK, so I assume you have CONFIG_FORCE_MAX_ZONEORDER 17 and PAGE_SHIFT
16, right? But even CONFIG_FORCE_MAX_ZONEORDER 16 would be a problem.

> 	Because MIN_MEMORY_BLOCK_SIZE is 32bits, so MIN_MEMORY_BLOCK_SIZE(1 << 32)
> will equal to 0. This will cause wrong system memory infomation in sysfs. I think
> it should be:
> 	#define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
> 

I guess the part below is not necessary for the changelog

> linux-drf:/sys/devices/system/memory # ll
> total 0
> -r--r--r-- 1 root root 65536 Aug 20 02:35 block_size_bytes
> drwxr-xr-x 3 root root     0 Aug 20 02:19 memory0
> drwxr-xr-x 2 root root     0 Aug 20 02:35 power
> -rw-r--r-- 1 root root 65536 Aug 20 02:35 uevent
> 
> linux-drf:/sys/devices/system/memory # cat block_size_bytes
> 0
> 
> linux-drf:/sys/devices/system/memory/memory0 # cat *
> 8000000000000000
> cat: node0: Is a directory
> cat: node1: Is a directory
> cat: node2: Is a directory
> cat: node3: Is a directory
> 0
> 8000000000000000
> cat: power: Is a directory
> 1
> online
> cat: subsystem: Is a directory
> 

Up to here.

> 	And "echo offline > memory0/state" will cause following call trace:
> 
> kernel BUG at mm/memory_hotplug.c:885!
> sh[6455]: bugcheck! 0 [1]
> 
> Pid: 6455, CPU 0, comm:                   sh
> psr : 0000101008526030 ifs : 8000000000000fa4 ip  : [<a0000001008c40f0>]    Not tainted (3.6.0-rc1)
> ip is at offline_pages+0x210/0xee0
> unat: 0000000000000000 pfs : 0000000000000fa4 rsc : 0000000000000003
> rnat: a0000001008f2d50 bsps: 0000000000000000 pr  : 65519a96659a9565
> ldrs: 0000000000000000 ccv : 0000010b9263f310 fpsr: 0009804c0270033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a0000001008c40f0 b6  : a000000100473980 b7  : a0000001000106d0
> f6  : 000000000000000000000 f7  : 1003e0000000085c9354c
> f8  : 1003e0044b82fa09b5a53 f9  : 1003e000000d65cd62abf
> f10 : 1003efd02efdec682803d f11 : 1003e0000000000000042
> r1  : a00000010152c2e0 r2  : 0000000000006ada r3  : 000000000000fffe
> r8  : 0000000000000026 r9  : a00000010121cc18 r10 : a0000001013309f0
> r11 : 65519a96659a19e9 r12 : e00000070a91fdf0 r13 : e00000070a910000
> r14 : 0000000000006ada r15 : 0000000000004000 r16 : 000000006ad8356c
> r17 : a0000001019a525e r18 : 0000000000007fff r19 : 0000000000000000
> r20 : 0000000000006ad6 r21 : 0000000000006ad6 r22 : a00000010133bec8
> r23 : 0000000000006ad4 r24 : 0000000000000002 r25 : 8200000000260038
> r26 : 00000000000004f9 r27 : 00000000000004f8 r28 : 000000000001cf98
> r29 : 0000000000000038 r30 : a0000001019a5ae0 r31 : 000000000001cf60
> 
> Call Trace:
>  [<a0000001000163e0>] show_stack+0x80/0xa0
>                                 sp=e00000070a91f9b0 bsp=e00000070a9115e0
>  [<a000000100016a40>] show_regs+0x640/0x920
>                                 sp=e00000070a91fb80 bsp=e00000070a911588
>  [<a000000100040590>] die+0x190/0x2c0
>                                 sp=e00000070a91fb90 bsp=e00000070a911548
>  [<a000000100040710>] die_if_kernel+0x50/0x80
>                                 sp=e00000070a91fb90 bsp=e00000070a911518
>  [<a0000001008f8030>] ia64_bad_break+0x3d0/0x6e0
>                                 sp=e00000070a91fb90 bsp=e00000070a9114f0
>  [<a00000010000c0c0>] ia64_native_leave_kernel+0x0/0x270
>                                 sp=e00000070a91fc20 bsp=e00000070a9114f0
>  [<a0000001008c40f0>] offline_pages+0x210/0xee0
>                                 sp=e00000070a91fdf0 bsp=e00000070a9113c8
>  [<a00000010022d580>] alloc_pages_current+0x180/0x2a0
>                                 sp=e00000070a91fe20 bsp=e00000070a9113a
> 
> This patch is trying to fix the bug.

not just trying ;)

> 
> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memory.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 1ac7f6e..ff9a9f8 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -19,7 +19,7 @@
>  #include <linux/compiler.h>
>  #include <linux/mutex.h>
> 
> -#define MIN_MEMORY_BLOCK_SIZE     (1 << SECTION_SIZE_BITS)
> +#define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
> 
>  struct memory_block {
>  	unsigned long start_section_nr;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
