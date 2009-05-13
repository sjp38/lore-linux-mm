Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 712476B00C3
	for <linux-mm@kvack.org>; Wed, 13 May 2009 03:42:02 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4D7gdes027680
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 May 2009 16:42:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 132C445DE3E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:42:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E480A45DE3A
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:42:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C8FC3E08001
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:42:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 783E41DB8038
	for <linux-mm@kvack.org>; Wed, 13 May 2009 16:42:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: kernel BUG at mm/slqb.c:1411!
Message-Id: <20090513163826.7232.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 May 2009 16:42:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


Todays test (repeated large file copy) hit kernel panic. mm/slqb.c:1411! mean

----------------------------------------------------------------
static noinline void *__slab_alloc_page(struct kmem_cache *s,
                                gfp_t gfpflags, int node)
{
(snip)

        } else {
#ifdef CONFIG_NUMA
                struct kmem_cache_node *n;

                n = s->node_slab[slqb_page_to_nid(page)];
                l = &n->list;
                page->list = l;

                spin_lock(&n->list_lock);
                l->nr_slabs++;
                l->nr_partial++;
                list_add(&page->lru, &l->partial);
                slqb_stat_inc(l, ALLOC);
                slqb_stat_inc(l, ALLOC_SLAB_NEW);
                object = __cache_list_get_page(s, l);
                spin_unlock(&n->list_lock);
#endif
        }
        VM_BUG_ON(!object);			// here
        return object;
}
----------------------------------------------------------------


Who have any suggestions?



-------------------------------------------------------------------
kernel BUG at mm/slqb.c:1411!
pdflush[324]: bugcheck! 0 [1]
Modules linked in: binfmt_misc nls_iso8859_1 nls_cp437 dm_multipath scsi_dh fan sg processor button container thermal e100 mii dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod lpfc mptspi mptscsih mptbase ehci_hcd ohci_hcd uhci_hcd usbcore

Pid: 324, CPU 1, comm:              pdflush
psr : 00001010085a2010 ifs : 8000000000000916 ip  : [<a0000001001bb960>]    Not tainted (2.6.30-rc4-mm1-g384655e-dirty)
ip is at __slab_alloc_page+0x800/0x9e0
unat: 0000000000000000 pfs : 0000000000000916 rsc : 0000000000000003
rnat: 0000000000000001 bsps: a000000100d5b880 pr  : 005599aa55559599
ldrs: 0000000000000000 ccv : 0000000000000000 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001bb960 b6  : a0000001005a78e0 b7  : a00000010048bac0
f6  : 1003e000005cef074293b f7  : 1003e0000000000000190
f8  : 1003e000005cef07427ab f9  : 1003e0000000000000001
f10 : 1003e0000000000000100 f11 : 1003e0000000000000100
r1  : a000000100f52d40 r2  : a000000100d263a0 r3  : a000000100d53708
r8  : 0000000000000021 r9  : 0000000000000001 r10 : e000000001110000
r11 : ffffffffffff0420 r12 : e0000040c1ccfc20 r13 : e0000040c1cc0000
r14 : a000000100d263b8 r15 : e00001600b91fe18 r16 : ffffffffffff5538
r17 : 00000000dead4ead r18 : a000000100cd222c r19 : a000000100d5b850
r20 : a0000001005a78e0 r21 : a000000101144ae0 r22 : 0000000000099a63
r23 : 00000000000fffff r24 : 0000000000100000 r25 : a0000001009e7a68
r26 : a00000010048bb60 r27 : 0000000000000100 r28 : 0000000000000001
r29 : e0000040c1cc0de4 r30 : a00000010048bac0 r31 : 0000000000000000

Call Trace:
 [<a0000001000179c0>] show_stack+0x80/0xa0
                                sp=e0000040c1ccf7f0 bsp=e0000040c1cc1730
 [<a0000001000182d0>] show_regs+0x890/0x8c0
                                sp=e0000040c1ccf9c0 bsp=e0000040c1cc16d8
 [<a000000100040b50>] die+0x1b0/0x2e0
                                sp=e0000040c1ccf9c0 bsp=e0000040c1cc1690
 [<a000000100040cd0>] die_if_kernel+0x50/0x80
                                sp=e0000040c1ccf9c0 bsp=e0000040c1cc1660
 [<a0000001007cc5f0>] ia64_bad_break+0x4b0/0x700
                                sp=e0000040c1ccf9c0 bsp=e0000040c1cc1638
 [<a00000010000c980>] ia64_native_leave_kernel+0x0/0x270
                                sp=e0000040c1ccfa50 bsp=e0000040c1cc1638
 [<a0000001001bb960>] __slab_alloc_page+0x800/0x9e0
                                sp=e0000040c1ccfc20 bsp=e0000040c1cc1580
 [<a0000001001bd570>] kmem_cache_alloc+0x510/0x700
                                sp=e0000040c1ccfc20 bsp=e0000040c1cc14f0
 [<a000000100149ad0>] mempool_alloc_slab+0x30/0x60
                                sp=e0000040c1ccfc20 bsp=e0000040c1cc14c8
 [<a00000010014a1a0>] mempool_alloc+0xc0/0x360	
                                sp=e0000040c1ccfc20 bsp=e0000040c1cc1440
 [<a00000010022f4d0>] bio_alloc_bioset+0x50/0x240
                                sp=e0000040c1ccfc50 bsp=e0000040c1cc13f0
 [<a00000010022f790>] bio_alloc+0x30/0x80	
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc13c8
 [<a000000100220a90>] submit_bh+0x130/0x3e0
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc1398
 [<a000000100226d90>] __block_write_full_page+0x510/0xbc0
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc1310
 [<a0000001002275f0>] block_write_full_page_endio+0x1b0/0x220
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc12d0
 [<a000000100227690>] block_write_full_page+0x30/0x60
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc12a0
 [<a0000001002a9210>] ext3_writeback_writepage+0x190/0x380
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc1260
 [<a0000001001566b0>] __writepage+0x50/0x1a0
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc1230
 [<a000000100157370>] write_cache_pages+0x530/0x940
                                sp=e0000040c1ccfc60 bsp=e0000040c1cc1140
 [<a0000001001577e0>] generic_writepages+0x60/0x80
                                sp=e0000040c1ccfcf0 bsp=e0000040c1cc1118
 [<a000000100157910>] do_writepages+0x110/0x140
                                sp=e0000040c1ccfcf0 bsp=e0000040c1cc10e8
 [<a000000100214c20>] __writeback_single_inode+0x160/0x9a0
                                sp=e0000040c1ccfcf0 bsp=e0000040c1cc1088
 [<a000000100215d40>] generic_sync_sb_inodes+0x3c0/0xa00
                                sp=e0000040c1ccfd30 bsp=e0000040c1cc1018
 [<a000000100216420>] sync_sb_inodes+0xa0/0xc0
                                sp=e0000040c1ccfd30 bsp=e0000040c1cc0fe8
 [<a000000100216620>] writeback_inodes+0x1e0/0x280
                                sp=e0000040c1ccfd30 bsp=e0000040c1cc0f98
 [<a000000100159ba0>] background_writeout+0x160/0x240
                                sp=e0000040c1ccfd30 bsp=e0000040c1cc0f30
 [<a00000010015b010>] pdflush+0x290/0x500
                                sp=e0000040c1ccfd80 bsp=e0000040c1cc0ec0
 [<a0000001000df800>] kthread+0x100/0x140
                                sp=e0000040c1ccfdf0 bsp=e0000040c1cc0e88
 [<a000000100015970>] kernel_thread_helper+0xd0/0x100
                                sp=e0000040c1ccfe30 bsp=e0000040c1cc0e60
 [<a00000010000a580>] start_kernel_thread+0x20/0x40
                                sp=e0000040c1ccfe30 bsp=e0000040c1cc0e60
Disabling lock debugging due to kernel taint
Kernel panic - not syncing: Fatal exception
Rebooting in 1 seconds..





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
