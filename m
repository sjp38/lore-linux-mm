Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 6792B6B0038
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 03:26:05 -0400 (EDT)
Received: by wiun10 with SMTP id n10so26599661wiu.1
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 00:26:04 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id v5si6463815wiz.121.2015.04.06.00.26.02
        for <linux-mm@kvack.org>;
        Mon, 06 Apr 2015 00:26:03 -0700 (PDT)
Date: Mon, 6 Apr 2015 10:25:51 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at include/linux/page-flags.h:333! from
 migrate_page_copy(), ... 317! from set_page_dirty()
Message-ID: <20150406072551.GA7539@node.dhcp.inet.fi>
References: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150406062017.GB11515@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Mon, Apr 06, 2015 at 06:20:17AM +0000, Naoya Horiguchi wrote:
> Hi,
> 
> When doing hugepage migration test on mmotm-2015-04-01-14-54, I found 2 cases
> of the VM_BUG_ONs detected by page flag sanitization for compound pages.
> 
> 1)
> 
> [ 3071.845424] page:ffffea0018f08000 count:1 mapcount:0 mapping:ffff88065dcc1a51 index:0x3
> [ 3071.854375] flags: 0x5ffc0000004009(locked|uptodate|head)
> [ 3071.860532] page dumped because: VM_BUG_ON_PAGE(PageCompound(page))
> [ 3071.867560] ------------[ cut here ]------------
> [ 3071.872715] kernel BUG at include/linux/page-flags.h:333!
> [ 3071.878742] invalid opcode: 0000 [#1] SMP
> [ 3071.883336] Modules linked in: xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack bridge stp llc x86_pkg_temp_thermal coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel iTCO_wdt i2c_i801 ghash_clmulni_intel iTCO_vendor_support sb_edac edac_core lpc_ich mfd_core pcspkr ipmi_ssif tpm_tis ipmi_si tpm wmi ipmi_msghandler acpi_power_meter mei_me ioatdma mei shpchp dca nfsd auth_rpcgss nfs_acl lockd grace sunrpc uas usb_storage mgag200 bnx2x i2c_algo_bit drm_kms_helper e1000e ttm mdio libcrc32c drm ptp megaraid_sas pps_core
> [ 3071.946801] CPU: 0 PID: 2796 Comm: test_mbind_fuzz Not tainted 3.19.0 #1
> [ 3071.954282] Hardware name: NEC Express5800/B120e [N8400-221Y]/G7LYN, BIOS 4.6.2106 11/08/2013
> [ 3071.963802] task: ffff88065d068a50 ti: ffff8806621b4000 task.ti: ffff8806621b4000
> [ 3071.972157] RIP: 0010:[<ffffffff8120882a>]  [<ffffffff8120882a>] migrate_page_copy+0x58a/0x7f0
> [ 3071.981781] RSP: 0018:ffff8806621b7c98  EFLAGS: 00010296
> [ 3071.987711] RAX: 0000000000000037 RBX: ffffea0018f08000 RCX: 0000000000000037
> [ 3071.995680] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880667c0e838
> [ 3072.003646] RBP: ffff8806621b7ce8 R08: 0000000000000096 R09: 0000000000000534
> [ 3072.011615] R10: 0000000000000000 R11: 0000000000000534 R12: ffffea0019010000
> [ 3072.019583] R13: 0000000000000200 R14: 0000000018f10000 R15: ffff880000000000
> [ 3072.027551] FS:  00007f674471d740(0000) GS:ffff880667c00000(0000) knlGS:0000000000000000
> [ 3072.036586] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 3072.043001] CR2: 00007fffccc549f8 CR3: 0000000662c05000 CR4: 00000000001407f0
> [ 3072.050968] Stack:
> [ 3072.053224]  0000000000000000 800000063c2000e7 ffff880600000040 0000020000e00000
> [ 3072.061525]  ffffea0001dfddf0 ffffea0018f08000 ffffea0019010000 0000000000000001
> [ 3072.069826]  0000000000000000 00000000fffffff5 ffff8806621b7d18 ffffffff81208acd
> [ 3072.078124] Call Trace:
> [ 3072.080858]  [<ffffffff81208acd>] migrate_page+0x3d/0x60
> [ 3072.086790]  [<ffffffff81208dbd>] move_to_new_page+0x2cd/0x340
> [ 3072.093304]  [<ffffffff811e03e6>] ? try_to_unmap+0x66/0x130
> [ 3072.099527]  [<ffffffff811ddde0>] ? invalid_migration_vma+0x30/0x30
> [ 3072.106527]  [<ffffffff81209817>] migrate_pages+0x8a7/0x9f0
> [ 3072.112752]  [<ffffffff811f7640>] ? alloc_pages_vma+0x220/0x220
> [ 3072.119364]  [<ffffffff811f7e14>] do_mbind+0x504/0x5d0
> [ 3072.125101]  [<ffffffff811f8138>] SyS_mbind+0xa8/0xb0
> [ 3072.130743]  [<ffffffff8177d769>] system_call_fastpath+0x12/0x17
> [ 3072.137448] Code: 0f 0b 0f 1f 80 00 00 00 00 48 8b 43 30 48 8b 13 80 e6 80 48 0f 44 c3 e9 36 fc ff ff 48 c7 c6 48 71 a3 81 48 89 df e8 f6 4c fc ff <0f> 0b 48 c7 c6 48 71 a3 81 4c 89 e7 e8 e5 4c fc ff 0f 0b 48 c7
> [ 3072.159196] RIP  [<ffffffff8120882a>] migrate_page_copy+0x58a/0x7f0
> [ 3072.166217]  RSP <ffff8806621b7c98>
> [ 3073.015139] ---[ end trace f52f8daca3fe12f2 ]---
> 
> migrate_page_copy() always calls ClearPageSwapCache(), but recently calling
> it for compound pages is banned by Kirill's page flag sanitization patch.
> I think that the sanitization made this bug visible, and we need fix the ill
> usage of ClearPageSwapCache.
> I think thp migration should also hit this BUG_ON.
> 
> I'm thinking of one simplest fix like this:
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 25fd7f6291de..5fa399d20435 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -537,7 +537,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
>  	 * Please do not reorder this without considering how mm/ksm.c's
>  	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
>  	 */
> -	ClearPageSwapCache(page);
> +	if (PageSwapCache(page))
> +		ClearPageSwapCache(page);
>  	ClearPagePrivate(page);
>  	set_page_private(page, 0);
> 
> but, this looks a dirty workaround.

I think this change is reasonable for general case: we would avoid atoimic
opration if the bit is not set.

> Creating a migrate_copy_page() variant for compound page is better?
> Or any better idea?
> 
> 
> 2)
> 
> # This is triggered easily by libhugetlbfs functional test.
> 
> [ 2662.212167] page:ffffea0002b38000 count:2 mapcount:1 mapping:ffff8800db8ec380 index:0x0
> [ 2662.213480] flags: 0xbffc0000004008(uptodate|head)
> [ 2662.214252] page dumped because: VM_BUG_ON_PAGE(PageCompound(page))
> [ 2662.215448] ------------[ cut here ]------------
> [ 2662.216135] kernel BUG at /src/linux-dev/include/linux/page-flags.h:317!
> [ 2662.216427] invalid opcode: 0000 [#1] SMP
> [ 2662.216427] Modules linked in: fuse btrfs xor raid6_pq ufs hfsplus hfs minix vfat msdos fat jfs xfs libcrc32c reiserfs cfg80211 rfkill ppdev crc32c_intel virtio_console pcspkr virtio_balloon serio_raw pa
> rport_pc parport pvpanic i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi virtio_pci virtio_ring virtio floppy
> [ 2662.216427] CPU: 1 PID: 12413 Comm: test_mbind_fuzz Not tainted 3.19.0-mmotm-2015-04-01-14-54-150406-1312-00001-gfe6d51b5f154 #36
> [ 2662.216427] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [ 2662.216427] task: ffff88007b39f170 ti: ffff88007b4a4000 task.ti: ffff88007b4a4000
> [ 2662.216427] RIP: 0010:[<ffffffff811837ff>]  [<ffffffff811837ff>] set_page_dirty+0x8f/0xc0
> [ 2662.216427] RSP: 0000:ffff88007b4a7a08  EFLAGS: 00010292
> [ 2662.216427] RAX: 0000000000000037 RBX: ffffea0002b38000 RCX: 0000000000000037
> [ 2662.216427] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88011fc0e838
> [ 2662.216427] RBP: ffff88007b4a7a18 R08: 0000000000000092 R09: 000000000000020c
> [ 2662.216427] R10: 0000000000000000 R11: 000000000000020c R12: ffff8800da599f80
> [ 2662.216427] R13: ffffffff81fbc6c0 R14: ffff8800da065000 R15: ffffea0003681970
> [ 2662.216427] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000) knlGS:0000000000000000
> [ 2662.216427] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [ 2662.216427] CR2: 00007fffe8a99ff8 CR3: 00000000db1be000 CR4: 00000000000006e0
> [ 2662.216427] Stack:
> [ 2662.216427]  ffffffff81fbc6c0 0000700000200000 ffff88007b4a7aa8 ffffffff811cdb39
> [ 2662.216427]  80000000ace000e7 ffffea0002b38000 ffff88007c74f730 ffff88007b4a7c40
> [ 2662.216427]  0000000000000000 ffff8800da599fe4 0000700000000000 0000000000200000
> [ 2662.216427] Call Trace:
> [ 2662.216427]  [<ffffffff811cdb39>] __unmap_hugepage_range+0x329/0x340
> [ 2662.216427]  [<ffffffff811cdb66>] __unmap_hugepage_range_final+0x16/0x30
> [ 2662.216427]  [<ffffffff811acace>] unmap_single_vma+0x51e/0x910
> [ 2662.216427]  [<ffffffff811ad7c4>] unmap_vmas+0x54/0xb0
> [ 2662.216427]  [<ffffffff811b735c>] exit_mmap+0xac/0x180
> [ 2662.216427]  [<ffffffff81074d33>] mmput+0x63/0xf0
> [ 2662.216427]  [<ffffffff8107a41d>] do_exit+0x2ad/0xac0
> [ 2662.216427]  [<ffffffff8107acc7>] do_group_exit+0x47/0xc0
> [ 2662.216427]  [<ffffffff81086c04>] get_signal+0x2a4/0x6b0
> [ 2662.216427]  [<ffffffff810145b7>] do_signal+0x37/0x800
> [ 2662.216427]  [<ffffffff81202365>] ? __sb_end_write+0x35/0x70
> [ 2662.216427]  [<ffffffff811ffc22>] ? vfs_write+0x1b2/0x1f0
> [ 2662.216427]  [<ffffffff81014de9>] do_notify_resume+0x69/0xb0
> [ 2662.216427]  [<ffffffff816dd4e2>] retint_signal+0x48/0x86
> [ 2662.216427] Code: df 48 8b 03 f6 c4 80 75 3f f0 0f ba 2b 04 72 24 b8 01 00 00 00 eb c9 0f 1f 44 00 00 48 c7 c6 e0 d2 a0 81 48 89 df e8 71 59 02 00 <0f> 0b 0f 1f 80 00 00 00 00 31 c0 eb a8 48 8b 43 30 48 
> 8b 13 80
> [ 2662.216427] RIP  [<ffffffff811837ff>] set_page_dirty+0x8f/0xc0
> [ 2662.216427]  RSP <ffff88007b4a7a08>
> 
> set_page_dirty() calls ClearPageReclaim(), which is also banned to call on
> compound pages (but it is called now.)
> thp is not affected by this because page_mapping() is NULL for thp (maybe
> this will not be true when thp supports page cache?).
> As a short term fix, hugetlb had better have its own set_page_dirty?

The same check-before-set should work fine, right?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
