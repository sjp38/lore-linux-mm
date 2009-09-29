Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 66A476B0055
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 20:19:17 -0400 (EDT)
Date: Tue, 29 Sep 2009 09:24:13 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 8/10] memcg: clean up charge/uncharge anon
Message-Id: <20090929092413.9526de0b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090925172850.265abe78.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090925172850.265abe78.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Sep 2009 17:28:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This may need careful review.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In old codes, this function was used for other purposes rather
> than charginc new anon pages. But now, this function is (ranamed) and
> used only for new pages.
> 
> For the same kind of reason, ucharge_page() should use VM_BUG_ON().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   27 +++++++++++++--------------
>  1 file changed, 13 insertions(+), 14 deletions(-)
> 
> Index: temp-mmotm/mm/memcontrol.c
> ===================================================================
> --- temp-mmotm.orig/mm/memcontrol.c
> +++ temp-mmotm/mm/memcontrol.c
> @@ -1638,15 +1638,8 @@ int mem_cgroup_newpage_charge(struct pag
>  		return 0;
>  	if (PageCompound(page))
>  		return 0;
> -	/*
> -	 * If already mapped, we don't have to account.
> -	 * If page cache, page->mapping has address_space.
> -	 * But page->mapping may have out-of-use anon_vma pointer,
> -	 * detecit it by PageAnon() check. newly-mapped-anon's page->mapping
> -	 * is NULL.
> -  	 */
> -	if (page_mapped(page) || (page->mapping && !PageAnon(page)))
> -		return 0;
> +	/* This function is "newpage_charge" and called right after alloc */
> +	VM_BUG_ON(page_mapped(page) || (page->mapping && !PageAnon(page)));
>  	if (unlikely(!mm))
>  		mm = &init_mm;
>  	return mem_cgroup_charge_common(page, mm, gfp_mask,
I think this VM_BUG_ON() is vaild.

> @@ -1901,11 +1894,11 @@ unlock_out:
>  
>  void mem_cgroup_uncharge_page(struct page *page)
>  {
> -	/* early check. */
> -	if (page_mapped(page))
> -		return;
> -	if (page->mapping && !PageAnon(page))
> -		return;
> +	/*
> + 	 * Called when anonymous page's page->mapcount goes down to zero,
> + 	 * or cancel a charge gotten by newpage_charge().
> +	 */
> +	VM_BUG_ON(page_mapped(page) || (page->mapping && !PageAnon(page)));
>  	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
>  }
>  
> 
I hit this VM_BUG_ON() when I'm testing mmotm-2009-09-25-14-35 + these patches
+ my latest recharge-at-task-move patches(not posted yet).

[ 2966.031815] kernel BUG at mm/memcontrol.c:2014!
[ 2966.031815] invalid opcode: 0000 [#1] SMP
[ 2966.031815] last sysfs file: /sys/devices/pci0000:00/0000:00:07.0/0000:09:00.2/0000:0b:
04.1/irq
[ 2966.031815] CPU 2
[ 2966.031815] Modules linked in: autofs4 lockd sunrpc iscsi_tcp libiscsi_tcp libiscsi scs
i_transport_iscsi dm_mirror dm_multipath video output lp sg ide_cd_mod cdrom serio_raw but
ton parport_pc parport e1000 i2c_i801 i2c_core pata_acpi ata_generic pcspkr dm_region_hash
 dm_log dm_mod ata_piix libata shpchp megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd u
hci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
[ 2966.031815] Pid: 19677, comm: mmapstress10 Not tainted 2.6.31-mmotm-2009-09-25-14-35-35
ace741 #1 Express5800/140Rd-4 [N8100-1065]
[ 2966.031815] RIP: 0010:[<ffffffff800efbe2>]  [<ffffffff800efbe2>] mem_cgroup_uncharge_pa
ge+0x18/0x28
[ 2966.031815] RSP: 0000:ffff880381713da8  EFLAGS: 00010246
[ 2966.031815] RAX: 0000000000000000 RBX: ffffea001668fef0 RCX: ffffea001763afe0
[ 2966.031815] RDX: 0000000000000080 RSI: 0000000000000008 RDI: ffffea001668fef0
[ 2966.031815] RBP: ffff880381713da8 R08: ffffea001763afe0 R09: ffff88039dfafa28
[ 2966.031815] R10: ffff880381617b80 R11: 0000000000000000 R12: ffffea001668fef0
[ 2966.031815] R13: ffffea001668fef0 R14: 0000000000000008 R15: ffff880381617b80
[ 2966.031815] FS:  00007f9a617fa6e0(0000) GS:ffff88002a000000(0000) knlGS:000000000000000
0
[ 2966.031815] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2966.031815] CR2: 000000385021c4b8 CR3: 0000000372107000 CR4: 00000000000006e0
[ 2966.031815] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2966.031815] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2966.031815] Process mmapstress10 (pid: 19677, threadinfo ffff880381712000, task ffff880
3817c2920)
[ 2966.031815] Stack:
[ 2966.031815]  ffff880381713dc8 ffffffff800d6bff 00000003992ec067 00000003992ec067
[ 2966.031815] <0> ffff880381713e58 ffffffff800ce2f3 ffff880381713e18 ffff88038a90c408
[ 2966.031815] <0> 000000385021c4b8 ffff88039dfaf6c0 ffffea000168fef0 ffffea0016c91508
[ 2966.031815] Call Trace:
[ 2966.031815]  [<ffffffff800d6bff>] page_remove_rmap+0x28/0x44
[ 2966.031815]  [<ffffffff800ce2f3>] do_wp_page+0x626/0x73c
[ 2966.031815]  [<ffffffff8005e9e3>] ? __wake_up_bit+0x2c/0x2e
[ 2966.031815]  [<ffffffff800cfbfc>] handle_mm_fault+0x712/0x824
[ 2966.031815]  [<ffffffff8034e6d7>] do_page_fault+0x255/0x2e5
[ 2966.031815]  [<ffffffff8034c59f>] page_fault+0x1f/0x30
[ 2966.031815] Code: 83 7f 18 00 74 04 0f 0b eb fe 31 f6 e8 75 fe ff ff c9 c3 8b 47 0c 55
48 89 e5 85 c0 79 0d 48 8b 47 18 48 85 c0 74 08 a8 01 75 04 <0f> 0b eb fe be 01 00 00 00 e
8 4d fe ff ff c9 c3 55 65 48 8b 04
[ 2966.031815] RIP  [<ffffffff800efbe2>] mem_cgroup_uncharge_page+0x18/0x28
[ 2966.031815]  RSP <ffff880381713da8>

I don't think my patch is the guilt because this also happens even if I don't
set "recharge_at_immigrate".

It might be better that I test w/o my patches, but IIUC, this can happen
in following scenario like:

Assume process A and B has the same swap pte.

          process A                       process B
  do_swap_page()                    do_swap_page()
    read_swap_cache_async()
    lock_page()                       lookup_swap_cache()
    page_add_anon_rmap()
    unlock_page()
                                      lock_page()
    do_wp_page()
      page_remove_rmap()
        atomic_add_negative()
          -> page->_mapcount = -1     page_add_anon_rmap()
                                        atomic_inc_and_test()
                                          -> page->_mapcount = 0
        mem_cgroup_uncharge_page()
          -> hit the VM_BUG_ON()


So, I think this should be like:

void mem_cgroup_uncharge_page(struct page *page)
{
	/*
	 * Called when anonymous page's page->mapcount goes down to zero,
	 * or cancel a charge gotten by newpage_charge().
	 * But there is a small race between page_remove_rmap() and
	 * page_add_anon_rmap(), so we can reach here with page_mapped().
	 */
	VM_BUG_ON(page->mapping && !PageAnon(page))
        if (unlikely(page_mapped(page))
		return;
	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_MAPPED);
}



Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
