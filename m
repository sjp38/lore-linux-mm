Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 98F67900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 12:21:14 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so78818024qcb.2
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 09:21:14 -0700 (PDT)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id e76si2285561qka.106.2015.04.21.09.21.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 09:21:13 -0700 (PDT)
Received: by qkgx75 with SMTP id x75so204608447qkg.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 09:21:12 -0700 (PDT)
Message-ID: <553678f8.d429370a.07df.ffff8546@mx.google.com>
Date: Tue, 21 Apr 2015 09:21:12 -0700 (PDT)
From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: Re: [PATCH 1/2 V3] memory-hotplug: fix BUG_ON in move_freepages()
In-Reply-To: <55362343.2030907@huawei.com>
References: <55362343.2030907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Xiexiuqi <xiexiuqi@huawei.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


On Tue, 21 Apr 2015 18:15:31 +0800
Xishi Qiu <qiuxishi@huawei.com> wrote:

> Hot remove nodeXX, then hot add nodeXX. If BIOS report cpu first, it will call
> hotadd_new_pgdat(nid, 0), this will set pgdat->node_start_pfn to 0. As nodeXX
> exists at boot time, so pgdat->node_spanned_pages is the same as original. Then
> free_area_init_core()->memmap_init() will pass a wrong start and a nonzero size.
> 
> free_area_init_core()
> 	memmap_init()
> 		memmap_init_zone()
> 			early_pfn_in_nid()
> 			set_page_links()
> 
> "if (!early_pfn_in_nid(pfn, nid))" will skip the pfn(memory in section), but it
> will not skip the pfn(hole in section), this will cover and relink the page to
> zone/nid, so page_zone() from memory and hole in the same section are different.
> 
> The following call trace shows the bug. This patch add/remove memblk when hot
> adding/removing memory, so it will set the node size to 0 when hotadd a new node
> (original or new). init_currently_empty_zone() and memmap_init() will be called
> in add_zone(), so need not to change them.
> 
> [90476.077469] kernel BUG at mm/page_alloc.c:1042!  // move_freepages() -> BUG_ON(page_zone(start_page) != page_zone(end_page));
> [90476.077469] invalid opcode: 0000 [#1] SMP 
> [90476.077469] Modules linked in: iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack fuse btrfs zlib_deflate raid6_pq xor msdos ext4 mbcache jbd2 binfmt_misc bridge stp llc ip6table_filter ip6_tables iptable_filter ip_tables ebtable_nat ebtables cfg80211 rfkill sg iTCO_wdt iTCO_vendor_support intel_powerclamp coretemp intel_rapl kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul glue_helper ablk_helper cryptd pcspkr igb vfat i2c_algo_bit dca fat sb_edac edac_core i2c_i801 lpc_ich i2c_core mfd_core shpchp acpi_pad ipmi_si ipmi_msghandler uinput nfsd auth_rpcgss nfs_acl lockd sunrpc xfs libcrc32c sd_mod crc_t10dif crct10dif_common ahci libahci megaraid_sas tg3 ptp libata pps_core dm_mirror dm_region_hash dm_log dm_mod [last unloaded: rasf]
> [90476.157382] CPU: 2 PID: 322803 Comm: updatedb Tainted: GF       W  O--------------   3.10.0-229.1.2.5.hulk.rc14.x86_64 #1
> [90476.157382] Hardware name: HUAWEI TECHNOLOGIES CO.,LTD. Huawei N1/Huawei N1, BIOS V100R001 04/13/2015
> [90476.157382] task: ffff88006a6d5b00 ti: ffff880068eb8000 task.ti: ffff880068eb8000
> [90476.157382] RIP: 0010:[<ffffffff81159f7f>]  [<ffffffff81159f7f>] move_freepages+0x12f/0x140
> [90476.157382] RSP: 0018:ffff880068ebb640  EFLAGS: 00010002
> [90476.157382] RAX: ffff880002316cc0 RBX: ffffea0001bd0000 RCX: 0000000000000001
> [90476.157382] RDX: ffff880002476e40 RSI: 0000000000000000 RDI: ffff880002316cc0
> [90476.157382] RBP: ffff880068ebb690 R08: 0000000000100000 R09: ffffea0001bd7fc0
> [90476.157382] R10: 000000000006f5ff R11: 0000000000000000 R12: 0000000000000001
> [90476.157382] R13: 0000000000000003 R14: ffff880002316eb8 R15: ffffea0001bd7fc0
> [90476.157382] FS:  00007f4d3ab95740(0000) GS:ffff880033a00000(0000) knlGS:0000000000000000
> [90476.157382] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [90476.157382] CR2: 00007f4d3ae1a808 CR3: 000000018907a000 CR4: 00000000001407e0
> [90476.157382] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [90476.157382] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [90476.157382] Stack:
> [90476.157382]  ffff880068ebb698 ffff880002316cc0 ffffa800b5378098 ffff880068ebb698
> [90476.157382]  ffffffff810b11dc ffff880002316cc0 0000000000000001 0000000000000003
> [90476.157382]  ffff880002316eb8 ffffea0001bd6420 ffff880068ebb6a0 ffffffff8115a003
> [90476.157382] Call Trace:
> [90476.157382]  [<ffffffff810b11dc>] ? update_curr+0xcc/0x150
> [90476.157382]  [<ffffffff8115a003>] move_freepages_block+0x73/0x80
> [90476.157382]  [<ffffffff8115b9ba>] __rmqueue+0x26a/0x460
> [90476.157382]  [<ffffffff8101ba53>] ? native_sched_clock+0x13/0x80
> [90476.157382]  [<ffffffff8115e172>] get_page_from_freelist+0x7f2/0xd30
> [90476.157382]  [<ffffffff81012639>] ? __switch_to+0x179/0x4a0
> [90476.157382]  [<ffffffffa01fc0d7>] ? xfs_iext_bno_to_ext+0xa7/0x1a0 [xfs]
> [90476.157382]  [<ffffffff8115e871>] __alloc_pages_nodemask+0x1c1/0xc90
> [90476.157382]  [<ffffffffa01ab24c>] ? _xfs_buf_ioapply+0x31c/0x420 [xfs]
> [90476.157382]  [<ffffffff8109cb0d>] ? down_trylock+0x2d/0x40
> [90476.157382]  [<ffffffffa01abfff>] ? xfs_buf_trylock+0x1f/0x80 [xfs]
> [90476.157382]  [<ffffffff8119d229>] alloc_pages_current+0xa9/0x170
> [90476.157382]  [<ffffffff811a7225>] new_slab+0x275/0x300
> [90476.157382]  [<ffffffff815faaa2>] __slab_alloc+0x315/0x48f
> [90476.157382]  [<ffffffffa01c59d7>] ? kmem_zone_alloc+0x77/0x100 [xfs]
> [90476.157382]  [<ffffffffa01d21fc>] ? xfs_bmap_search_extents+0x5c/0xc0 [xfs]
> [90476.157382]  [<ffffffff811a9863>] kmem_cache_alloc+0x193/0x1d0
> [90476.157382]  [<ffffffffa01c59d7>] ? kmem_zone_alloc+0x77/0x100 [xfs]
> [90476.157382]  [<ffffffffa01c59d7>] kmem_zone_alloc+0x77/0x100 [xfs]
> [90476.157382]  [<ffffffffa01b46b5>] xfs_inode_alloc+0x25/0x250 [xfs]
> [90476.157382]  [<ffffffffa01b5279>] xfs_iget+0x219/0x680 [xfs]
> [90476.157382]  [<ffffffffa01f83a6>] xfs_lookup+0xf6/0x120 [xfs]
> [90476.157382]  [<ffffffffa01bae1b>] xfs_vn_lookup+0x7b/0xd0 [xfs]
> [90476.157382]  [<ffffffff811ce40d>] lookup_real+0x1d/0x50
> [90476.157382]  [<ffffffff811ced42>] __lookup_hash+0x42/0x60
> [90476.157382]  [<ffffffff815fae0c>] lookup_slow+0x42/0xa7
> [90476.157382]  [<ffffffff811d28cb>] path_lookupat+0x76b/0x7a0
> [90476.157382]  [<ffffffff811d3815>] ? do_last+0x635/0x1260
> [90476.157382]  [<ffffffff811a9705>] ? kmem_cache_alloc+0x35/0x1d0
> [90476.157382]  [<ffffffff811d498f>] ? getname_flags+0x4f/0x190
> [90476.157382]  [<ffffffff811d292b>] filename_lookup+0x2b/0xc0
> [90476.157382]  [<ffffffff811d5807>] user_path_at_empty+0x67/0xc0
> [90476.157382]  [<ffffffff810efaa2>] ? from_kgid_munged+0x12/0x20
> [90476.157382]  [<ffffffff811c991f>] ? cp_new_stat+0x14f/0x180
> [90476.157382]  [<ffffffff811d5871>] user_path_at+0x11/0x20
> [90476.157382]  [<ffffffff811c9413>] vfs_fstatat+0x63/0xc0
> [90476.157382]  [<ffffffff811c99e1>] SYSC_newlstat+0x31/0x60
> [90476.157382]  [<ffffffff810f9b16>] ? __audit_syscall_exit+0x1f6/0x2a0
> [90476.157382]  [<ffffffff811c9c5e>] SyS_newlstat+0xe/0x10
> [90476.157382]  [<ffffffff8160ca69>] system_call_fastpath+0x16/0x1b
> [90476.157382] Code: d0 8b 45 c4 48 c1 e2 06 48 01 d3 01 c8 49 39 df 0f 83 7b ff ff ff 66 0f 1f 44 00 00 48 83 c4 28 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> 0b 66 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 
> [90476.157382] RIP  [<ffffffff81159f7f>] move_freepages+0x12f/0x140
> [90476.157382]  RSP <ffff880068ebb640>
> [90476.157382] ---[ end trace 58557f791c6d66d4 ]---
> [90476.157382] Kernel panic - not syncing: Fatal exception
> 
> log and analyse:
> ...
> [    0.000000] Initmem setup node 0 [mem 0x00000000-0x2000ffffffff]
> [    0.000000]   NODE_DATA [mem 0x02312400-0x023393ff]	// node0
> ...
> [    0.000000] Initmem setup node 9 [mem 0x30000000000-0x3ffffffffff]
> [    0.000000]   NODE_DATA [mem 0x02471400-0x024983ff]	// node9
> ...
> [    0.000000]   node   0: [mem 0x5b880000-0x5baf2fff]
> [    0.000000]   node   0: [mem 0x61382000-0x6148ffff]
> [    0.000000]   node   0: [mem 0x61a90000-0x6f39bfff]  // 1562.56 - 1779.61
> [    0.000000]   node   0: [mem 0x6f51c000-0x6f7c9fff]  // 1781.11 - 1783.79 
> [    0.000000]   node   0: [mem 0x6fb1c000-0x6fb1cfff]
> [    0.000000]   node   0: [mem 0x6fba3000-0x6fffffff]
> ...
> 
> start_page = ffffea0001bd0000 -> pfn=0x6F400 -> 1780M, in node0, right!
> end_page   = ffffea0001bd7fc0 -> pfn=0x6F5FF -> 1782M-4kb, in node0, right!
> page_zone(start_page) = ffff880002476e40, in node9, wrong!
> page_zone(end_page)   = ffff880002316cc0, in node0, right!
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> Suggested-by: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
> ---
>  mm/memory_hotplug.c |    3 +++
>  mm/page_alloc.c     |    8 ++++++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 457bde5..49d7c07 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1268,6 +1268,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
>  
>  	/* create new memmap entry */
>  	firmware_map_add_hotplug(start, start + size, "System RAM");

> +	memblock_add_node(start, size, nid);


My concern is that there is no guarantee of synchronizing memblk operations.
So if these operations run simultaneously, memblk may be broken.

Thanks,
Yasuaki Ishimatsu

>  
>  	goto out;
>  
> @@ -2002,6 +2003,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> +	memblock_free(start, size);
> +	memblock_remove(start, size);
>  
>  	arch_remove_memory(start, size);
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ebffa0e..f8609fa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4667,6 +4667,10 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
>  {
>  	unsigned long zone_start_pfn, zone_end_pfn;
>  
> +	/* When hotadd a new node, the node should be empty */
> +	if (!node_start_pfn && !node_end_pfn)
> +		return 0;
> +
>  	/* Get the start and end of the zone */
>  	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
>  	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> @@ -4730,6 +4734,10 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
>  	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
>  	unsigned long zone_start_pfn, zone_end_pfn;
>  
> +	/* When hotadd a new node, the node should be empty */
> +	if (!node_start_pfn && !node_end_pfn)
> +		return 0;
> +
>  	zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
>  	zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
>  
> -- 
> 1.7.1
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
