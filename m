Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAIJIDCB443060
	for <linux-mm@kvack.org>; Thu, 18 Nov 2004 14:18:14 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAIJIACQ225770
	for <linux-mm@kvack.org>; Thu, 18 Nov 2004 12:18:13 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAIJIAv6017149
	for <linux-mm@kvack.org>; Thu, 18 Nov 2004 12:18:10 -0700
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: keith <kmannth@us.ibm.com>
In-Reply-To: <1100744644.17510.8.camel@localhost>
References: <1100659057.26335.125.camel@knk>
	 <1100711519.5838.2.camel@localhost>  <1100743722.26335.644.camel@knk>
	 <1100744644.17510.8.camel@localhost>
Content-Type: text/plain
Message-Id: <1100805488.26335.684.camel@knk>
Mime-Version: 1.0
Date: Thu, 18 Nov 2004 11:18:08 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-11-17 at 18:24, Dave Hansen wrote:
> On Wed, 2004-11-17 at 18:08, keith wrote:
> >   I am not anticipating to support hot-add without config_nonlinear or
> > something similar which should provide more flexibility in allocation of
> > smaller section mem_maps.  This is only a issue when booted as a
> > discontig system.  We don't even consult the SRAT when we boot flat
> > (contiguous address space) so it is a non-issue.
> 
> Once a system has been running for any length of time, finding any
> multi-order pages gets somewhat hard.  For a 16M section, you're still
> talking about ~128k of mem_map, which is still an order 5 allocation. 
> Nick's kswapd higher-order patches should help with this, though.

I think it is safe to deal with this issue later.  I think i386 hot add
is going to be confined to a very small pool of boxes.  


> >   Wasting 500k of lowmem for memory that "might" be there is no good.  I
> > don't think having to preallocate the mem_map for a hot-add is really
> > that good.  What if the system never adds memory?  What if it only adds
> > 8gig not 49g?  The system is crippled because it reserves the lmem_map
> > it "might" do a hot add with?  
> 
> I have the feeling we'll eventually need a boot-time option for this
> reservation.  Your patch, of course will work for now.  Do you want me
> to pick it up in my tree?

I agree a boot time option to reserve a chunk of virtual address space
may be the way to go for i386.  I would hate to reserve too much space
that ends up just being wasted.  I think this can be save off for future
work.  I would like to get it into mm, I'll ping Andrew.    

> 
> >   I forgot the mention that without this patch my system does not boot
> > with the hot-add support enabled in the bios.  
> 
> Why not?  I'm just curious what caused the actual failure.
> 
> -- Dave

(snip)
Summit chipset: Starting Cyclone Counter.
Detected 1997.351 MHz processor.
Using cyclone for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
Initializing HighMem for node 0
Initializing HighMem for node 1
Bad page state at free_hot_cold_page (in process 'swapper', page
d8e0d000)
flags:0xfffff7ff mapping:00000000 mapcount:0 count:266321921
Backtrace:
 [<c0140e09>] bad_page+0x81/0xb4
 [<c01415fd>] free_hot_cold_page+0x7e/0x100
 [<c0492849>] one_highpage_init+0xda/0x172
 [<c0493842>] set_highmem_pages_init+0xb0/0xf5
 [<c03691eb>] _etext+0x0/0x10d5
 [<c0492dcb>] mem_init+0x14f/0x2ba
 [<c0495c78>] alloc_large_system_hash+0x128/0x173
 [<c04827c7>] start_kernel+0x118/0x221
 [<c048231a>] unknown_bootoption+0x0/0x145
Trying to fix it up, but a reboot is needed
Bad page state at free_hot_cold_page (in process 'swapper', page
d8e0d020)
flags:0xfffff7ff mapping:00000000 mapcount:0 count:-523233279
Backtrace:
 [<c0140e09>] bad_page+0x81/0xb4
 [<c01415fd>] free_hot_cold_page+0x7e/0x100
 [<c0492849>] one_highpage_init+0xda/0x172
 [<c0493842>] set_highmem_pages_init+0xb0/0xf5
 [<c03691eb>] _etext+0x0/0x10d5
 [<c0492dcb>] mem_init+0x14f/0x2ba
 [<c0495c78>] alloc_large_system_hash+0x128/0x173
 [<c04827c7>] start_kernel+0x118/0x221
 [<c048231a>] unknown_bootoption+0x0/0x145
Trying to fix it up, but a reboot is needed
Bad page state at free_hot_cold_page (in process 'swapper', page
d8e0d040)
flags:0xfffff7ff mapping:00000000 mapcount:0 count:-523233279
Backtrace:
 [<c0140e09>] bad_page+0x81/0xb4
 [<c01415fd>] free_hot_cold_page+0x7e/0x100
 [<c0492849>] one_highpage_init+0xda/0x172

(and on and on and on)

Thanks,
  Keith Mannthey 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
