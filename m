Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CF4A86B0006
	for <linux-mm@kvack.org>; Sat, 19 Jan 2013 11:25:40 -0500 (EST)
Date: Sat, 19 Jan 2013 17:24:29 +0100
From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130119162429.GB27825@lunn.ch>
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <201301171049.30415.arnd@arndb.de>
 <50F800EB.6040104@web.de>
 <201301172026.45514.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201301172026.45514.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Soeren Moch <smoch@web.de>, Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Thu, Jan 17, 2013 at 08:26:45PM +0000, Arnd Bergmann wrote:
> On Thursday 17 January 2013, Soeren Moch wrote:
> > On 17.01.2013 11:49, Arnd Bergmann wrote:
> > > On Wednesday 16 January 2013, Soeren Moch wrote:
> > >>>> I will see what I can do here. Is there an easy way to track the buffer
> > >>>> usage without having to wait for complete exhaustion?
> > >>>
> > >>> DMA_API_DEBUG
> > >>
> > >> OK, maybe I can try this.

I tried this. Not what i expected. We have at least one problem with
the ethernet driver:

WARNING: at lib/dma-debug.c:933 check_unmap+0x4b8/0x8a8()
mv643xx_eth_port mv643xx_eth_port.0: DMA-API: device driver failed to check map error[device address=0x000000001f22be00] [size=1536 bytes] [mapped as single]
Modules linked in:
[<c000db10>] (unwind_backtrace+0x0/0xf4) from [<c0016c44>] (warn_slowpath_common+0x4c/0x64)
[<c0016c44>] (warn_slowpath_common+0x4c/0x64) from [<c0016cf0>] (warn_slowpath_fmt+0x30/0x40)
[<c0016cf0>] (warn_slowpath_fmt+0x30/0x40) from [<c01ab540>] (check_unmap+0x4b8/0x8a8)
[<c01ab540>] (check_unmap+0x4b8/0x8a8) from [<c01abbb8>] (debug_dma_unmap_page+0x8c/0x98)
[<c01abbb8>] (debug_dma_unmap_page+0x8c/0x98) from [<c025cb1c>] (mv643xx_eth_poll+0x630/0x800)
[<c025cb1c>] (mv643xx_eth_poll+0x630/0x800) from [<c0331d9c>] (net_rx_action+0xcc/0x1d4)
[<c0331d9c>] (net_rx_action+0xcc/0x1d4) from [<c001e1b0>] (__do_softirq+0xa8/0x170)
[<c001e1b0>] (__do_softirq+0xa8/0x170) from [<c001e3e8>] (do_softirq+0x5c/0x6c)
[<c001e3e8>] (do_softirq+0x5c/0x6c) from [<c001e610>] (local_bh_enable+0xcc/0xdc)
[<c001e610>] (local_bh_enable+0xcc/0xdc) from [<c0359c74>] (ip_finish_output+0x1c8/0x39c)
[<c0359c74>] (ip_finish_output+0x1c8/0x39c) from [<c03571a4>] (ip_local_out+0x28/0x2c)
[<c03571a4>] (ip_local_out+0x28/0x2c) from [<c0359564>] (ip_queue_xmit+0x118/0x338)
[<c0359564>] (ip_queue_xmit+0x118/0x338) from [<c036e58c>] (tcp_transmit_skb+0x3fc/0x8e4)
[<c036e58c>] (tcp_transmit_skb+0x3fc/0x8e4) from [<c0371218>] (tcp_write_xmit+0x228/0xb08)
[<c0371218>] (tcp_write_xmit+0x228/0xb08) from [<c0371b6c>] (__tcp_push_pending_frames+0x30/0x9c)
[<c0371b6c>] (__tcp_push_pending_frames+0x30/0x9c) from [<c0362940>] (tcp_sendmsg+0x158/0xdc4)
[<c0362940>] (tcp_sendmsg+0x158/0xdc4) from [<c0386620>] (inet_sendmsg+0x38/0x74)
[<c0386620>] (inet_sendmsg+0x38/0x74) from [<c031f370>] (sock_aio_write+0x12c/0x138)
[<c031f370>] (sock_aio_write+0x12c/0x138) from [<c00a62f4>] (do_sync_write+0xa0/0xd0)
[<c00a62f4>] (do_sync_write+0xa0/0xd0) from [<c00a6f18>] (vfs_write+0x13c/0x144)
[<c00a6f18>] (vfs_write+0x13c/0x144) from [<c00a6ff0>] (sys_write+0x44/0x70)
[<c00a6ff0>] (sys_write+0x44/0x70) from [<c0008ce0>] (ret_fast_syscall+0x0/0x2c)
---[ end trace b75faa8779652e63 ]---

I'm getting about 4 errors reported a second from the ethernet driver.

Before i look at issues with em28xx i will first try to get the noise
from the ethernet driver sorted out.

     Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
