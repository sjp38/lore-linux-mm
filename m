Date: Thu, 8 Mar 2007 17:40:04 +0000
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
Message-ID: <20070308174004.GB12958@skynet.ie>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie> <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On (08/03/07 08:48), Christoph Lameter didst pronounce:
> On Thu, 8 Mar 2007, Mel Gorman wrote:
> 
> > On x86_64, it completed successfully and looked reliable. There was a 5%
> > performance loss on kernbench and aim9 figures were way down. However, with
> > slub_debug enabled, I would expect that so it's not a fair comparison
> > performance wise. I'll rerun the tests without debug and see what it looks
> > like if you're interested and do not think it's too early to worry about
> > performance instead of clarity. This is what I have for bl6-13 (machine
> > appears on test.kernel.org so additional details are there).
> 
> No its good to start worrying about performance now. There are still some 
> performance issues to be ironed out in particular on NUMA. I am not sure
> f.e. how the reduction of partial lists affect performance.
> 

Ok, I've sent off a bunch of tests - two of which are on NUMA (numaq and
x86_64). It'll take them a long time to complete though as there is a
lot of testing going on right now.

> > IA64 (machine not visible on TKO) curiously did not exhibit the same problems
> > on kernbench for Total CPU time which is very unexpected but you can see the
> > System CPU times. The AIM9 figures were a bit of an upset but again, I blame
> > slub_debug being enabled
> 
> This was a single node box?

Yes, memory looks like this;

Zone PFN ranges:
  DMA          1024 ->   262144
  Normal     262144 ->   262144
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0:     1024 ->    30719
    0:    32768 ->    65413
    0:    65440 ->    65505
On node 0 totalpages: 62405
Node 0 memmap at 0xe000000001126000 size 3670016 first pfn 0xe000000001134000
  DMA zone: 220 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 62185 pages, LIFO batch:7
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap

> Note that the 16kb page size has a major 
> impact on SLUB performance. On IA64 slub will use only 1/4th the locking 
> overhead as on 4kb platforms.
> 

It'll be interesting to see the kernbench tests then with debugging
disabled.

> > (as an aside, the succes rates for high-order allocations are lower with SLUB.
> > Again, I blame slub_debug. I know that enabling SLAB_DEBUG has similar effects
> > because of red-zoning and the like)
> 
> We have some additional patches here that reduce the max order for some 
> allocs. I believe the task_struct gets to be an order 2 alloc with V4,
> 

Should make a difference for slab fragmentation

> > Now, the bad news. This exploded on ppc64. It started going wrong early in the
> > boot process and got worse. I haven't looked closely as to why yet as there is
> > other stuff on my plate but I've included a console log that might be some use
> > to you. If you think you have a fix for it, feel free to send it on and I'll
> > give it a test.
> 
> Hmmm... Looks like something is zapping an object. Try to rerun with 
> a kernel compiled with CONFIG_SLAB_DEBUG. I would expect similar results.
> 

I've queued up a few tests. One completed as I wrote this and it didn't
explode with SLAB_DEBUG set. Maybe the others will be different. I'll
kick it around for a bit.

It could be a real bug that slab is just not catuching.

> > Brought up 4 CPUs
> > Node 0 CPUs: 0-3
> > mm/memory.c:111: bad pud c0000000050e4480.
> > could not vmalloc 20971520 bytes for cache!
> 
> Hmmm... a bad pud? I need to look at how the puds are managed on power.
> 
> > migration_cost=0,1000
> > *** SLUB: Redzone Inactive check fails in kmalloc-64@c0000000050de0f0 Slab
> 
> An object was overwritten with zeros after it was freed.

> > RTAS daemon started
> > RTAS: event: 1, Type: Platform Error, Severity: 2
> > audit: initializing netlink socket (disabled)
> > audit(1173335571.256:1): initialized
> > Total HugeTLB memory allocated, 0
> > VFS: Disk quotas dquot_6.5.1
> > Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> > JFS: nTxBlock = 8192, nTxLock = 65536
> > SELinux:  Registering netfilter hooks
> > io scheduler noop registered
> > io scheduler anticipatory registered (default)
> > io scheduler deadline registered
> > io scheduler cfq registered
> > pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> > rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
> > rpaphp: Slot [0000:00:02.2](PCI location=U7879.001.DQD0T7T-P1-C4) registered
> > vio_register_driver: driver hvc_console registering
> > ------------[ cut here ]------------
> > Badness at mm/slub.c:1701
> 
> Someone did a kmalloc(0, ...). Zero sized allocation are not flagged
> by SLAB but SLUB does.
> 

I'll chase up what's happening here. It will be "reproducable" independent
of SLUB by adding a similar check.

> > Call Trace:
> > [C00000000506B730] [C000000000011188] .show_stack+0x6c/0x1a0 (unreliable)
> > [C00000000506B7D0] [C0000000001EE9F4] .report_bug+0x94/0xe8
> > [C00000000506B860] [C00000000038C85C] .program_check_exception+0x16c/0x5f4
> > [C00000000506B930] [C0000000000046F4] program_check_common+0xf4/0x100
> > --- Exception: 700 at .get_slab+0xbc/0x18c
> >     LR = .__kmalloc+0x28/0x104
> > [C00000000506BC20] [C00000000506BCC0] 0xc00000000506bcc0 (unreliable)
> > [C00000000506BCD0] [C0000000000CE2EC] .__kmalloc+0x28/0x104
> > [C00000000506BD60] [C00000000022E724] .tty_register_driver+0x5c/0x23c
> > [C00000000506BE10] [C000000000477910] .hvsi_init+0x154/0x1b4
> > [C00000000506BEC0] [C000000000451B7C] .init+0x1c4/0x2f8
> > [C00000000506BF90] [C0000000000275D0] .kernel_thread+0x4c/0x68
> > mm/memory.c:111: bad pud c000000005762900.
> > mm/memory.c:111: bad pud c000000005762480.
> > ------------[ cut here ]------------
> > kernel BUG at mm/mmap.c:1999!
> 
> More page table trouble.

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
