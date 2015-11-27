Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 47CDA6B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 03:20:14 -0500 (EST)
Received: by wmec201 with SMTP id c201so59348175wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:20:13 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id hp9si46814051wjb.144.2015.11.27.00.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 00:20:13 -0800 (PST)
Received: by wmec201 with SMTP id c201so48418419wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 00:20:12 -0800 (PST)
Date: Fri, 27 Nov 2015 09:20:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.3+: Atheros ethernet fails after resume from s2ram, due to
 order 4 allocation
Message-ID: <20151127082010.GA2500@dhcp22.suse.cz>
References: <20151126163413.GA3816@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126163413.GA3816@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com

On Thu 26-11-15 17:34:13, Pavel Machek wrote:
> Hi!
> 
> ...and dmesg tells us what is going on:
> 
> [ 6961.550240] NetworkManager: page allocation failure: order:4,
> mode:0x2080020

This is GFP_ATOMIC|___GFP_RECLAIMABLE high order request. So something
that the caller should tollerate to fail.

> [ 6961.550249] CPU: 0 PID: 2590 Comm: NetworkManager Tainted: G
> W       4.3.0+ #124
> [ 6961.550250] Hardware name: Acer Aspire 5732Z/Aspire 5732Z, BIOS
> V3.07 02/10/2010
> [ 6961.550252]  00000000 00000000 f2ad1a04 c42ba5b8 00000000 f2ad1a2c
> c40d650a c4d3ee1c
> [ 6961.550260]  f34ef600 00000004 02080020 c4eeef40 00000000 00000010
> 00000000 f2ad1ac8
> [ 6961.550266]  c40d8caa 02080020 00000004 00000000 00000070 f34ef200
> 00000060 00000010
> [ 6961.550272] Call Trace:
> ...[ 6961.550299]  [<c4006811>] dma_generic_alloc_coherent+0x71/0x120
> [ 6961.550301]  [<c40067a0>] ? via_no_dac+0x30/0x30
> [ 6961.550307]  [<c465b16e>] atl1c_open+0x29e/0x300
> [ 6961.550313]  [<c48b96f5>] ? call_netdevice_notifiers_info+0x25/0x50
> [ 6961.550316]  [<c48c081b>] __dev_open+0x7b/0xf0
> [ 6961.550318]  [<c48c0ac9>] __dev_change_flags+0x89/0x140
> [ 6961.550320]  [<c48c0ba3>] dev_change_flags+0x23/0x60
> [ 6961.550325]  [<c48ce416>] do_setlink+0x286/0x7b0
> [ 6961.550328]  [<c42ded02>] ? nla_parse+0x22/0xd0
> [ 6961.550330]  [<c48cf906>] rtnl_newlink+0x5d6/0x860
> [ 6961.550336]  [<c407f8a1>] ? __lock_acquire.isra.24+0x3a1/0xc80
> [ 6961.550342]  [<c4047ae2>] ? ns_capable+0x22/0x60
> [ 6961.550345]  [<c48e7c5d>] ? __netlink_ns_capable+0x2d/0x40
> [ 6961.550351]  [<c49c9c54>] ? xprt_transmit+0x94/0x220
> [ 6961.550354]  [<c48cd9e6>] rtnetlink_rcv_msg+0x76/0x1f0
> [ 6961.550356]  [<c48cd970>] ? rtnetlink_rcv+0x30/0x30
> [ 6961.550359]  [<c48eb35e>] netlink_rcv_skb+0x8e/0xb0
> ...
> [ 6961.550412] Mem-Info:
> [ 6961.550417] active_anon:30319 inactive_anon:25075 isolated_anon:0
>  active_file:327764 inactive_file:152179 isolated_file:16
>   unevictable:0 dirty:6 writeback:0 unstable:0
>    slab_reclaimable:149091 slab_unreclaimable:18973
>     mapped:18100 shmem:4847 pagetables:1538 bounce:0
>      free:57732 free_pcp:10 free_cma:0
> ...
> [ 6961.550492] 485897 total pagecache pages
> [ 6961.550494] 1086 pages in swap cache
> [ 6961.550496] Swap cache stats: add 16738, delete 15652, find
> 6708/8500
> [ 6961.550497] Free swap  = 1656440kB
> [ 6961.550498] Total swap = 1681428kB
> [ 6961.550499] 785914 pages RAM
> [ 6961.550500] 557663 pages HighMem/MovableOnly
> [ 6961.550501] 12639 pages reserved
> [ 6961.550506] atl1c 0000:05:00.0: pci_alloc_consistend failed
> [ 6962.148358] psmouse serio1: synaptics: queried max coordinates: x
> [..5772], y [..5086]
> 
> Order 4 allocation... probably doable during boot, but not really
> suitable during resume.
> 
> I'm not sure how repeatable it is, but it definitely happened more
> than once.
> 
>         /*                                                                      
>          * real ring DMA buffer                                                 
>          * each ring/block may need up to 8 bytes for alignment, hence the      
>          * additional bytes tacked onto the end.                                
>          */
>         ring_header->size = size =
>                 sizeof(struct atl1c_tpd_desc) * tpd_ring->count * 2 +
>                 sizeof(struct atl1c_rx_free_desc) * rx_desc_count +
>                 sizeof(struct atl1c_recv_ret_status) * rx_desc_count +
>                 8 * 4;
> 
>         ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
>                                 &ring_header->dma);

Why is pci_alloc_consistent doing an unconditional GFP_ATOMIC
allocation? atl1_setup_ring_resources already does GFP_KERNEL
allocation in the same function so this should be sleepable
context. I think we should either add pci_alloc_consistent_gfp if
there are no explicit reasons to not do so or you can workaround
that by opencoding it and using dma_alloc_coherent directly with
GFP_KERNEL|__GFP_REPEAT. This doesn't guarantee a success though
because this is > PAGE_ALLOC_COSTLY_ORDER but it would increase chances
considerably. Also a vmalloc fallback can be used then more safely.

>         if (unlikely(!ring_header->desc)) {
>                 dev_err(&pdev->dev, "pci_alloc_consistend failed\n");
>                 goto err_nomem;
>         }
> 
> (Note the typo in dev_err... at least it is easy to grep).
> 
> Ok, so what went on is easy.. any ideas how to fix it?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
