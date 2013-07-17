Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 84B956B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 13:59:45 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1374078950-8o0ev16q-mutt-n-horiguchi@ah.jp.nec.com>
References: <1374012587-whdyhveh-mutt-n-horiguchi@ah.jp.nec.com>
 <1374078950-8o0ev16q-mutt-n-horiguchi@ah.jp.nec.com>
Subject: RE: [PATCH] mm/swap.c: clear PageActive before adding pages onto
 unevictable list (Re: 3.11.0-rc1: kernel BUG at mm/migrate.c:458 in page
 migration)
Content-Transfer-Encoding: 7bit
Message-Id: <20130717180249.19F1BE0090@blue.fi.intel.com>
Date: Wed, 17 Jul 2013 21:02:49 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kirill.shutemov@linux.intel.com

Naoya Horiguchi wrote:
> (CC:ed more)
> 
> On Tue, Jul 16, 2013 at 06:09:47PM -0400, Naoya Horiguchi wrote:
> > Hi,
> > 
> > v3.11-rc1 kernel triggers VM_BUG_ON(PageUnevictable(page)) in migrate_page_copy
> > when I do page migration like the following:
> > 
> >   $ sleep 100 &
> >   $ migratepages $(pgrep sleep) 0 1
> > 
> >   kernel BUG at /src/linux-dev/mm/migrate.c:458!
> >   invalid opcode: 0000 [#1] SMP
> >   Modules linked in: ebtable_nat ebtables xt_CHECKSUM iptable_mangle bridge lockd stp llc sunrpc bnep bluetooth rfkill ip6t_REJECT be2iscsi iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i nf_conntrack_ipv4 nf_conntrack_ipv6 cxgb3 mdio nf_defrag_ipv4 libcxgbi nf_defrag_ipv6 xt_state ib_iser nf_conntrack ip6table_filter ip6_tables rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi igb ptp pps_core ioatdma iTCO_wdt iTCO_vendor_support i2c_algo_bit dca pcspkr i7core_edac edac_core lpc_ich mfd_core i2c_i801 i2c_core acpi_power_meter microcode uinput
> >   CPU: 0 PID: 1443 Comm: migratepages Tainted: G        W    3.11.0-rc1-00009-g3ffee0e #84
> >   Hardware name: NEC NEC Express5800/R120b-1 [N8100-1719F]/MS-91E7-001, BIOS 4.6.3C19 02/10/2011
> >   task: ffff88042566c3e0 ti: ffff88041e760000 task.ti: ffff88041e760000
> >   RIP: 0010:[<ffffffff8118e7e5>]  [<ffffffff8118e7e5>] migrate_page_copy+0x1c5/0x1d0
> >   RSP: 0018:ffff88041e761ad8  EFLAGS: 00010206
> >   RAX: 002ffc000012000d RBX: ffffea0008df6100 RCX: 0000000000000000
> >   RDX: 0000000000000028 RSI: ffff880237d85000 RDI: ffff88041a6be000
> >   RBP: ffff88041e761af8 R08: 0000000000000000 R09: 0000000000000000
> >   R10: 0000000000000000 R11: ffffffffffffffc8 R12: ffffea001069af40
> >   R13: ffff88041e760000 R14: ffffea0008df6100 R15: 0000000000000001
> >   FS:  00007f166e39b740(0000) GS:ffff880237c00000(0000) knlGS:0000000000000000
> >   CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >   CR2: 000000000209f8e0 CR3: 000000021dd3e000 CR4: 00000000000007f0
> >   Stack:
> >    ffffea001069af40 ffffea0008df6100 ffffea001069af40 ffffea001069af40
> >    ffff88041e761b18 ffffffff8118e84b 0000000000000002 ffffea0008df6100
> >    ffff88041e761b48 ffffffff8118ebd5 ffffea001069af40 ffffea0008df6100
> >   Call Trace:
> >    [<ffffffff8118e84b>] migrate_page+0x5b/0x70
> >    [<ffffffff8118ebd5>] buffer_migrate_page+0x135/0x170
> >    [<ffffffff8118e8e8>] move_to_new_page+0x88/0x240
> >    [<ffffffff8118f360>] migrate_pages+0x750/0x7c0
> >    [<ffffffff8117c7e0>] ? sp_insert+0xc0/0xc0
> >    [<ffffffff8117efec>] migrate_to_node+0x9c/0xe0
> >    [<ffffffff8117f2ba>] do_migrate_pages+0x25a/0x2d0
> >    [<ffffffff8117f65d>] SYSC_migrate_pages+0x32d/0x390
> >    [<ffffffff8117f3e9>] ? SYSC_migrate_pages+0xb9/0x390
> >    [<ffffffff8117f6de>] SyS_migrate_pages+0xe/0x10
> >    [<ffffffff816a6482>] system_call_fastpath+0x16/0x1b
> >   Code: 6d 1c 01 41 83 6d 1c 01 e9 a0 fe ff ff 66 0f 1f 84 00 00 00 00 00 4c 89 e7 e8 58 30 fb ff e9 f9 fe ff ff 0f 1f 00 e8 5d 52 50 00 <0f> 0b 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41
> >   RIP  [<ffffffff8118e7e5>] migrate_page_copy+0x1c5/0x1d0
> >    RSP <ffff88041e761ad8>
> >   ---[ end trace 3efe05138cc2e0bb ]---
> > 
> > I think that the behavior of PageUnevictable was changed by commit 13f7f78981e4
> > "mm: pagevec: defer deciding which LRU to add a page to until pagevec drain time"
> > , and we don't need the VM_BUG_ON any more.
> > But I'm not sure whether we need more conclusive fix.
> > 
> > Do you have any comments?
> 
> It seems that some pages can have both of PageActive and PageUnevictable
> set. It looks buggy to me, so my proposal is clearing PageActive before
> adding pages to unevictable list.
> 
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 17 Jul 2013 11:49:56 -0400
> Subject: [PATCH] mm/swap.c: clear PageActive before adding pages onto
>  unevictable list
> 
> As a result of v3.10-3600-g13f7f78 "mm: pagevec: defer deciding which LRU
> to add a page to until pagevec drain time," pages on unevictable lists can
> have both of PageActive and PageUnevictable set. This is not only confusing,
> but also corrupts page migration and shrink_[in]active_list.
> 
> This patch fixes the problem by adding ClearPageActive before adding pages
> into unevictable list. It also cleans up VM_BUG_ONs.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # 3.10

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

One more patch related to the topic:

https://lkml.org/lkml/2013/7/15/140

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
