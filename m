Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D4F946B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:33:13 -0400 (EDT)
Date: Mon, 2 Jul 2012 12:28:58 +0800
From: Feng Tang <feng.tang@intel.com>
Subject: Re: linux-next BUG: held lock freed!
Message-ID: <20120702122858.029946db@feng-i7>
In-Reply-To: <CA++bM2txX2f=SC3r3bwxLcB8CUCuELW-NhytrKW7-07kysfA2A@mail.gmail.com>
References: <20120626145432.GA15289@localhost>
	<20120626172918.GA16446@localhost>
	<20120627122306.GA19252@localhost>
	<20120702025625.GA6531@localhost>
	<CA++bM2txX2f=SC3r3bwxLcB8CUCuELW-NhytrKW7-07kysfA2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Christoph Lameter <cl@linux.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>, penberg@kernel.org, linux-mm@kvack.org, Stephen Rothwell <sfr@canb.auug.org.au>, bfields@fieldses.org



> From: Fengguang Wu <fengguang.wu@intel.com>
> Date: 2012/7/2
> Subject: linux-next BUG: held lock freed!
> To: Christoph Lameter <cl@linux.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "J. Bruce Fields" <
> bfields@fieldses.org>, linux-nfs@vger.kernel.org, LKML <
> linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, Pekka
> Enberg <penberg@kernel.org>, Linux Memory Management List <
> linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>
> 
> 
> Hi all,
> 
> More observations on this bug:
> 
> The slab tree itself actually boots fine. So Christoph's commit may be
> merely disclosing some bug hidden in another for-next tree which
> happens to be merged before the slab tree..
> 
> Attached are some more back traces related to this bug (obviuosly, not
> only network locks are affected by the bug), as well as the kconfig that
> can relatively easily (but not always) trigger this bug.
> 
> Thanks,
> Fengguang
> 
> On Wed, Jun 27, 2012 at 08:23:06PM +0800, Fengguang Wu wrote:
> > Hi Christoph,
> >
> > It's a surprise that it bisects down to this commit. I confirmed
> > that it boots reliably if reverting this commit on top of linux-next.
> >
> > 8c138bc00925521c4e764269db3a903bd2a51592 is the first bad commit
> > commit 8c138bc00925521c4e764269db3a903bd2a51592
> > Author: Christoph Lameter <cl@linux.com>
> > Date:   Wed Jun 13 10:24:58 2012 -0500
> >
> >     slab: Get rid of obj_size macro
> >
> >     The size of the slab object is frequently needed. Since we now
> >     have a size field directly in the kmem_cache structure there is no
> >     need anymore of the obj_size macro/function.
> >
> >     Signed-off-by: Christoph Lameter <cl@linux.com>
> >     Signed-off-by: Pekka Enberg <penberg@kernel.org>

Seems there is a typo in the original patch 8c138bc0:

@@ -3896,9 +3890,9 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
        unsigned long flags;

        local_irq_save(flags);
-       debug_check_no_locks_freed(objp, obj_size(cachep));
+       debug_check_no_locks_freed(objp, cachep->size);
					====> this should be cachep->object_size				
        if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
-               debug_check_no_obj_freed(objp, obj_size(cachep));
+               debug_check_no_obj_freed(objp, cachep->object_size);


So the following small patch may fix it:

----------------------
diff --git a/mm/slab.c b/mm/slab.c
index 64c3d03..605b3b7 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3890,7 +3890,7 @@ void kmem_cache_free(struct kmem_cache *cachep, void *objp)
        unsigned long flags;
 
        local_irq_save(flags);
-       debug_check_no_locks_freed(objp, cachep->size);
+       debug_check_no_locks_freed(objp, cachep->object_size);
        if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
                debug_check_no_obj_freed(objp, cachep->object_size);
        __cache_free(cachep, objp, __builtin_return_address(0));


Thanks,
Feng

> >
> > :040000 040000 e0418be654b66b2364add59bb469024fd6958791
> f6be0da4d4740844ab8a4c561dbe3815a3f9b8b4 M      mm
> > bisect run success
> >
> > > > [  133.909702] =========================
> > > > [  133.910694] [ BUG: held lock freed! ]
> > > > [  133.911700] 3.5.0-rc4+ #5 Not tainted
> > > > [  133.912672] -------------------------
> > > > [  133.912969] swapper/0/0 is freeing memory
> ffff88001233ce08-ffff88001233de07, with a lock still held there!
> > > > [  133.912969]  (slock-AF_INET-RPC/1){+.-...}, at:
> [<ffffffff82ae84ee>] tcp_v4_rcv+0x28b/0x6fc
> > > > [  133.912969] 3 locks held by swapper/0/0:
> > > > [  133.912969]  #0:  (rcu_read_lock){.+.+..}, at:
> [<ffffffff82a1ea8a>] rcu_lock_acquire+0x0/0x29
> > > > [  133.912969]  #1:  (rcu_read_lock){.+.+..}, at:
> [<ffffffff82aca483>] rcu_lock_acquire.constprop.14+0x0/0x30
> > > > [  133.912969]  #2:  (slock-AF_INET-RPC/1){+.-...}, at:
> [<ffffffff82ae84ee>] tcp_v4_rcv+0x28b/0x6fc
> > > > [  133.912969]
> > > > [  133.912969] stack backtrace:
> > > > [  133.912969] Pid: 0, comm: swapper/0 Not tainted 3.5.0-rc4+ #5
> > > > [  133.912969] Call Trace:
> > > > [  133.912969]  <IRQ>  [<ffffffff810e09ae>]
> debug_check_no_locks_freed+0x109/0x14b
> > > > [  133.912969]  [<ffffffff811774e0>] kmem_cache_free+0x2e/0xa7
> > > > [  133.912969]  [<ffffffff82a191e5>] __kfree_skb+0x7f/0x83
> > > > [  133.912969]  [<ffffffff82adeccd>] tcp_ack+0x45d/0xc6a
> > > > [  133.912969]  [<ffffffff810c22ae>] ? local_clock+0x3b/0x52
> > > > [  133.912969]  [<ffffffff82adff44>] tcp_rcv_state_process+0x15a/0x7c6
> > > > [  133.912969]  [<ffffffff82ae79e7>] tcp_v4_do_rcv+0x341/0x390
> > > > [  133.912969]  [<ffffffff82ae88db>] tcp_v4_rcv+0x678/0x6fc
> > > > [  133.912969]  [<ffffffff82aca618>]
> ip_local_deliver_finish+0x165/0x1e4
> > > > [  133.912969]  [<ffffffff82acab4a>] ip_local_deliver+0x53/0x84
> > > > [  133.912969]  [<ffffffff810c228c>] ? local_clock+0x19/0x52
> > > > [  133.912969]  [<ffffffff82aca9c6>] ip_rcv_finish+0x32f/0x367
> > > > [  133.912969]  [<ffffffff82acad8b>] ip_rcv+0x210/0x269
> > > > [  133.912969]  [<ffffffff82a1eab1>] ? rcu_lock_acquire+0x27/0x29
> > > > [  133.912969]  [<ffffffff82a1ea8a>] ? softnet_seq_show+0x68/0x68
> > > > [  133.912969]  [<ffffffff82a21ede>] __netif_receive_skb+0x3cd/0x464
> > > > [  133.912969]  [<ffffffff82a21fda>] netif_receive_skb+0x65/0x9c
> > > > [  133.912969]  [<ffffffff82a227c5>] ? __napi_gro_receive+0xf2/0xff
> > > > [  133.912969]  [<ffffffff82a2209e>] napi_skb_finish+0x26/0x58
> > > > [  133.912969]  [<ffffffff810c228c>] ? local_clock+0x19/0x52
> > > > [  133.912969]  [<ffffffff82a228c5>] napi_gro_receive+0x2f/0x34
> > > > [  133.912969]  [<ffffffff81e36d12>] e1000_receive_skb+0x57/0x60
> > > > [  133.912969]  [<ffffffff81e39b23>] e1000_clean_rx_irq+0x2f2/0x387
> > > > [  133.912969]  [<ffffffff81e390f3>] e1000_clean+0x541/0x695
> > > > [  133.912969]  [<ffffffff8106c57b>] ? kvm_clock_read+0x2e/0x36
> > > > [  133.912969]  [<ffffffff82a22402>] ? net_rx_action+0x1b3/0x1f8
> > > > [  133.912969]  [<ffffffff82a22302>] net_rx_action+0xb3/0x1f8
> > > > [  133.912969]  [<ffffffff810984ab>] ? __do_softirq+0x76/0x1e8
> > > > [  133.912969]  [<ffffffff81098515>] __do_softirq+0xe0/0x1e8
> > > > [  133.912969]  [<ffffffff81122190>] ? time_hardirqs_off+0x26/0x2a
> > > > [  133.912969]  [<ffffffff82ea7fec>] call_softirq+0x1c/0x30
> > > > [  133.912969]  [<ffffffff81049cc8>] do_softirq+0x4a/0xa2
> > > > [  133.912969]  [<ffffffff8109888e>] irq_exit+0x51/0xbc
> > > > [  133.912969]  [<ffffffff82ea88ae>] do_IRQ+0x8e/0xa5
> > > > [  133.912969]  [<ffffffff82ea002f>] common_interrupt+0x6f/0x6f
> > > > [  133.912969]  <EOI>  [<ffffffff8106c76b>] ? native_safe_halt+0x6/0x8
> > > > [  133.912969]  [<ffffffff810e08a3>] ? trace_hardirqs_on+0xd/0xf
> > > > [  133.912969]  [<ffffffff8104f384>] default_idle+0x53/0x90
> > > > [  133.912969]  [<ffffffff8104fc09>] cpu_idle+0xcc/0x123
> > > > [  133.912969]  [<ffffffff82d1d8dd>] rest_init+0xd1/0xda
> > > > [  133.912969]  [<ffffffff82d1d80c>] ?
> csum_partial_copy_generic+0x16c/0x16c
> > > > [  133.912969]  [<ffffffff8460dbbc>] start_kernel+0x3da/0x3e7
> > > > [  133.912969]  [<ffffffff8460d5ea>] ? repair_env_string+0x5a/0x5a
> > > > [  133.912969]  [<ffffffff8460d2d6>]
> x86_64_start_reservations+0xb1/0xb5
> > > > [  133.912969]  [<ffffffff8460d3d8>] x86_64_start_kernel+0xfe/0x10b
> > > > [  134.024230] VFS: Mounted root (nfs filesystem) on device 0:14.
> >
> > Thanks,
> > Fengguang
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
