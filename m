Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 442936B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 23:33:04 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n094Wvfb031117
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 10:02:57 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n094X1jS2412786
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 10:03:01 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n094WuZA004297
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 10:02:56 +0530
Date: Fri, 9 Jan 2009 10:02:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/4] memcg: fix for
	mem_cgroup_get_reclaim_stat_from_page
Message-ID: <20090109043257.GB9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108191430.af89e037.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-08 19:14:30]:

> In case of swapin, a new page is added to lru before it is charged,
> so page->pc->mem_cgroup points to NULL or last mem_cgroup the page
> was charged before.
> 
> In the latter case, if the mem_cgroup has already freed by rmdir,
> the area pointed to by page->pc->mem_cgroup may have invalid data.
> 
> Actually, I saw general protection fault.
> 
>     general protection fault: 0000 [#1] SMP
>     last sysfs file: /sys/devices/system/cpu/cpu15/cache/index1/shared_cpu_map
>     CPU 4
>     Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6 autofs4 hidp rfcomm l2cap bluetooth sunrpc dm_mirror dm_region_hash dm_log dm_multipath dm_mod rfkill input_polldev sbs sbshc battery ac lp sg ide_cd_mod cdrom button serio_raw acpi_memhotplug parport_pc e1000 rtc_cmos parport rtc_core rtc_lib i2c_i801 i2c_core shpchp pcspkr ata_piix libata megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd [last unloaded: microcode]
>     Pid: 26038, comm: page01 Tainted: G        W  2.6.28-rc9-mm1-mmotm-2008-12-22-16-14-f2ab3dea #1
>     RIP: 0010:[<ffffffff8028e710>]  [<ffffffff8028e710>] update_page_reclaim_stat+0x2f/0x42
>     RSP: 0000:ffff8801ee457da8  EFLAGS: 00010002
>     RAX: 32353438312021c8 RBX: 0000000000000000 RCX: 32353438312021c8
>     RDX: 0000000000000000 RSI: ffff8800cb0b1000 RDI: ffff8801164d1d28
>     RBP: ffff880110002cb8 R08: ffff88010f2eae23 R09: 0000000000000001
>     R10: ffff8800bc514b00 R11: ffff880110002c00 R12: 0000000000000000
>     R13: ffff88000f484100 R14: 0000000000000003 R15: 00000000001200d2
>     FS:  00007f8a261726f0(0000) GS:ffff88010f2eaa80(0000) knlGS:0000000000000000
>     CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>     CR2: 00007f8a25d22000 CR3: 00000001ef18c000 CR4: 00000000000006e0
>     DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>     DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>     Process page01 (pid: 26038, threadinfo ffff8801ee456000, task ffff8800b585b960)
>     Stack:
>      ffffe200071ee568 ffff880110001f00 0000000000000000 ffffffff8028ea17
>      ffff88000f484100 0000000000000000 0000000000000020 00007f8a25d22000
>      ffff8800bc514b00 ffffffff8028ec34 0000000000000000 0000000000016fd8
>     Call Trace:
>      [<ffffffff8028ea17>] ? ____pagevec_lru_add+0xc1/0x13c
>      [<ffffffff8028ec34>] ? drain_cpu_pagevecs+0x36/0x89
>      [<ffffffff802a4f8c>] ? swapin_readahead+0x78/0x98
>      [<ffffffff8029a37a>] ? handle_mm_fault+0x3d9/0x741
>      [<ffffffff804da654>] ? do_page_fault+0x3ce/0x78c
>      [<ffffffff804d7a42>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>      [<ffffffff804d860f>] ? page_fault+0x1f/0x30
>     Code: cc 55 48 8d af b8 0d 00 00 48 89 f7 53 89 d3 e8 39 85 02 00 48 63 d3 48 ff 44 d5 10 45 85 e4 74 05 48 ff 44 d5 00 48 85 c0 74 0e <48> ff 44 d0 10 45 85 e4 74 04 48 ff 04 d0 5b 5d 41 5c c3 41 54
>     RIP  [<ffffffff8028e710>] update_page_reclaim_stat+0x2f/0x42
>      RSP <ffff8801ee457da8>
> 
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e2996b8..62e69d8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -559,6 +559,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  		return NULL;
> 
>  	pc = lookup_page_cgroup(page);
> +	smp_rmb();

Do you really need the read memory barrier?

> +	if (!PageCgroupUsed(pc))
> +		return NULL;
> +

In this case we've hit a case where the page is valid and the pc is
not. This does fix the problem, but won't this impact us getting
correct reclaim stats and thus indirectly impact the working of
pressure?

>  	mz = page_cgroup_zoneinfo(pc);
>  	if (!mz)
>  		return NULL;
>
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
