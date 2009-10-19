Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BB82E6B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 20:36:36 -0400 (EDT)
Received: by fxm20 with SMTP id 20so4324175fxm.38
        for <linux-mm@kvack.org>; Sun, 18 Oct 2009 17:36:35 -0700 (PDT)
Date: Mon, 19 Oct 2009 02:36:31 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/2] Reduce number of GFP_ATOMIC allocation failures
Message-ID: <20091019003631.GA3057@bizet.domek.prywatny>
References: <1255689446-3858-1-git-send-email-mel@csn.ul.ie> <20091017183421.GA3370@bizet.domek.prywatny> <20091018221844.GA2061@bizet.domek.prywatny> <200910190031.23237.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200910190031.23237.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, reinette chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 12:31:15AM +0200, Frans Pop wrote:
> Hi Karol,

Hi,

> > I've tried merging 'akpm' (517d08699b25) into clean 2.6.30 tree and
> > got suspend-breakage which makes it untestable for me.  (I've tried
> > reverting drm, suspend, and other commits... all that failed.)
> >
> > Is there mm-related git tree hidden somewhere?  ... or broken out
> > mm-related patches that were sent to Andrew ... or maybe it's possible
> > to get "git log -p" from Mel's private repo?  Anything?
> 
> Please try reverting 373c0a7e + 8aa7e847 [1] on top of 2.6.31. I've finally 
> been able to solidly trace the main regression to that. I'm doing some 
> final confirmation tests now and will mail detailed results afterwards.
> 
> It would be great if you could confirm if that fixes the issue for you too.

Sadly, reverting these patches didn't fix my problem.  I've just
tested it -- I still get allocation failures.

Thanks.


e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 2390, comm: ifconfig Not tainted 2.6.31+frans-00002-g90702f9 #1
Call Trace:
 [<c015c4c3>] ? __alloc_pages_nodemask+0x405/0x44a
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<d1428b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d1429bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d1429cef>] ? e100_open+0x17/0x41 [e100]
 [<c02f86ff>] ? dev_open+0x8f/0xc5
 [<c02f7eb9>] ? dev_change_flags+0xa2/0x155
 [<c032da86>] ? devinet_ioctl+0x22a/0x51c
 [<c02eba9e>] ? sock_ioctl+0x0/0x1e4
 [<c02ebc5e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02eba9e>] ? sock_ioctl+0x0/0x1e4
 [<c017f21e>] ? vfs_ioctl+0x16/0x4a
 [<c017fae5>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c016811b>] ? handle_mm_fault+0x1e0/0x42c
 [<c0348c4b>] ? do_page_fault+0x2ce/0x2e4
 [<c017fb48>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  37
Active_anon:25140 active_file:4336 inactive_anon:26654
 inactive_file:3697 unevictable:0 dirty:7 writeback:0 unstable:0
 free:981 slab:1766 mapped:4904 pagetables:456 bounce:0
DMA free:1116kB min:124kB low:152kB high:184kB active_anon:4304kB inactive_anon:4944kB active_file:764kB inactive_file:740kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:2808kB min:1908kB low:2384kB high:2860kB active_anon:96256kB inactive_anon:101672kB active_file:16580kB inactive_file:14048kB unevictable:0kB present:243776kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 13*4kB 5*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB 0*2048kB 0*4096kB = 1116kB
Normal: 454*4kB 62*8kB 31*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2808kB
13458 total pagecache pages
5159 pages in swap cache
Swap cache stats: add 34436, delete 29277, find 9023/11337
Free swap  = 465460kB
Total swap = 514040kB
65520 pages RAM
1663 pages reserved
12098 pages shared
55983 pages non-shared
e100 0000:00:03.0: firmware: requesting e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
