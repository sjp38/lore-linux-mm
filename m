Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AF8406B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:36:00 -0500 (EST)
Date: Mon, 21 Nov 2011 18:35:56 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111121173556.GA1673@x4.trippels.de>
References: <20111121080554.GB1625@x4.trippels.de>
 <20111121082445.GD1625@x4.trippels.de>
 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121131531.GA1679@x4.trippels.de>
 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121153621.GA1678@x4.trippels.de>
 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111121161036.GA1679@x4.trippels.de>
 <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org

On 2011.11.21 at 18:15 +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 a 17:52 +0100, Eric Dumazet a ecrit :
> > Le lundi 21 novembre 2011 a 17:10 +0100, Markus Trippelsdorf a ecrit :
> > 
> > > Sure. This one happend with CONFIG_DEBUG_PAGEALLOC=y:
> > > 
> > > [drm] Initialized radeon 2.11.0 20080528 for 0000:01:05.0 on minor 0
> > > loop: module loaded
> > > ahci 0000:00:11.0: version 3.0
> > > ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> > > ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
> > > ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part ccc 
> > > scsi0 : ahci
> > > scsi1 : ahci
> > > =============================================================================
> > > BUG task_struct: Poison overwritten
> > > -----------------------------------------------------------------------------
> > 
> > Unfortunately thats the same problem, not catched by DEBUG_PAGEALLOC
> > because freed page is immediately reused.
> > 
> > We should keep pages in free list longer, to have a bigger window.
> > 
> > Hmm...
> > 
> > Please try following patch :
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 9dd443d..b8932a6 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1196,7 +1196,7 @@ void free_hot_cold_page(struct page *page, int cold)
> >  	}
> >  
> >  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > -	if (cold)
> > +	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) || cold)
> >  		list_add_tail(&page->lru, &pcp->lists[migratetype]);
> >  	else
> >  		list_add(&page->lru, &pcp->lists[migratetype]);
> > 
> 
> 
> Also add "slub_max_order=0" to your boot command, since it will make the
> pool larger...

New one:

=============================================================================
BUG task_xstate: Not a valid slab page
-----------------------------------------------------------------------------

INFO: Slab 0xffffea0000044300 objects=32767 used=65535 fp=0x          (null) flags=0x0401
Pid: 9, comm: ksoftirqd/1 Not tainted 3.2.0-rc2-00274-g6fe4c6d-dirty #75
Call Trace:
 [<ffffffff81101c1d>] slab_err+0x7d/0x90
 [<ffffffff8103e29f>] ? dump_trace+0x16f/0x2e0
 [<ffffffff81044764>] ? free_thread_xstate+0x24/0x40
 [<ffffffff81044764>] ? free_thread_xstate+0x24/0x40
 [<ffffffff81102566>] check_slab+0x96/0xc0
 [<ffffffff814c5c29>] free_debug_processing+0x34/0x19c
 [<ffffffff81101d9a>] ? set_track+0x5a/0x190
 [<ffffffff8110cf2b>] ? sys_open+0x1b/0x20
 [<ffffffff814c5e55>] __slab_free+0x33/0x2d0
 [<ffffffff8110cf2b>] ? sys_open+0x1b/0x20
 [<ffffffff81105134>] kmem_cache_free+0x104/0x120
 [<ffffffff81044764>] free_thread_xstate+0x24/0x40
 [<ffffffff81044794>] free_thread_info+0x14/0x30
 [<ffffffff8106a4ff>] free_task+0x2f/0x50
 [<ffffffff8106a5d0>] __put_task_struct+0xb0/0x110
 [<ffffffff8106eb4b>] delayed_put_task_struct+0x3b/0xa0
 [<ffffffff810aa01a>] __rcu_process_callbacks+0x12a/0x350
 [<ffffffff810aa2a2>] rcu_process_callbacks+0x62/0x140
 [<ffffffff81072e18>] __do_softirq+0xa8/0x200
 [<ffffffff81073077>] run_ksoftirqd+0x107/0x210
 [<ffffffff81072f70>] ? __do_softirq+0x200/0x200
 [<ffffffff8108bb87>] kthread+0x87/0x90
 [<ffffffff814cdcf4>] kernel_thread_helper+0x4/0x10
 [<ffffffff8108bb00>] ? kthread_flush_work_fn+0x10/0x10
 [<ffffffff814cdcf0>] ? gs_change+0xb/0xb
FIX task_xstate: Object at 0xffffffff8110cf2b not freed

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
