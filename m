Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DC9E26B004F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 13:33:43 -0400 (EDT)
Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts20-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20091006173342.MCDX6916.tomts20-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 6 Oct 2009 13:33:42 -0400
Date: Tue, 6 Oct 2009 13:33:40 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 4/4] vunmap: Fix racy use of rcu_head
Message-ID: <20091006173340.GA25502@Krystal>
References: <20091006143727.868480435@polymtl.ca> <20091006144043.378971387@polymtl.ca> <alpine.DEB.1.10.0910061241250.18309@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0910061241250.18309@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: nickpiggin@yahoo.com.au, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (cl@linux-foundation.org) wrote:
> On Tue, 6 Oct 2009, Mathieu Desnoyers wrote:
> 
> > Simplest fix: directly kfree the data structure rather than doing it lazily.
> 
> The delay is necessary as far as I can tell for performance reasons. But
> Nick was the last one fiddling around with the subsystem as far as I
> remember. CCing him. May be he has a minute to think about a fix that
> preserved performance.
> 

Thanks,

More info on the problem:

I added a check in alloc_vmap_area() at:

        va = kmalloc_node(sizeof(struct vmap_area),
                        gfp_mask & GFP_RECLAIM_MASK, node);
        WARN_ON(va->rcu_head.debug == LIST_POISON1);

(memory allocation debugging is off in my config)

I used this along with my new call rcu debug patch to check if memory is
reallocated before the callback (doing kfree) is executed. It triggers
this:

WARNING: at mm/vmalloc.c:343 alloc_vmap_area+0x305/0x340()
Hardware name: X7DAL
Modules linked in: loop ltt_statedump ltt_userspace_event ipc_tr]
Pid: 5584, comm: ltt-disarmall Not tainted 2.6.30.9-trace #41
Call Trace:
 [<ffffffff802b8665>] ? alloc_vmap_area+0x305/0x340
 [<ffffffff802b8665>] ? alloc_vmap_area+0x305/0x340
 [<ffffffff8023cf29>] ? warn_slowpath_common+0x79/0xd0
 [<ffffffff802b8665>] ? alloc_vmap_area+0x305/0x340
 [<ffffffff80237670>] ? default_wake_function+0x0/0x10
 [<ffffffff802b8769>] ? __get_vm_area_node+0xc9/0x1d0
 [<ffffffff805ae965>] ? sys_getsockopt+0x85/0x160
 [<ffffffff8040f160>] ? ltt_vtrace+0x0/0x8d0
 [<ffffffff802b88dd>] ? get_vm_area_caller+0x2d/0x40
 [<ffffffff8068bc3e>] ? arch_imv_update+0x10e/0x2f0
 [<ffffffff802b93aa>] ? vmap+0x4a/0x80
 [<ffffffff8068bc3e>] ? arch_imv_update+0x10e/0x2f0
 [<ffffffff80283e6d>] ? get_tracepoint+0x25d/0x290
 [<ffffffff80280b93>] ? imv_update_range+0x53/0xa0
 [<ffffffff80284821>] ? tracepoint_update_probes+0x21/0x30
 [<ffffffff802848b3>] ? tracepoint_probe_update_all+0x83/0x100
 [<ffffffff80282ac1>] ? marker_update_probes+0x21/0x40
 [<ffffffff8040f160>] ? ltt_vtrace+0x0/0x8d0
 [<ffffffff80282d5d>] ? marker_probe_unregister+0xad/0x130
 [<ffffffff8040b9dc>] ? ltt_marker_disconnect+0xdc/0x120
 [<ffffffff804121d2>] ? marker_enable_write+0x112/0x120
 [<ffffffff80688dd0>] ? _spin_unlock+0x10/0x30
 [<ffffffff802e6b36>] ? mnt_drop_write+0x76/0x180
 [<ffffffff802d96dd>] ? do_filp_open+0x2cd/0xa00
 [<ffffffff804377c1>] ? tty_write+0x221/0x270
 [<ffffffff802cc6cb>] ? vfs_write+0xcb/0x170
 [<ffffffff802cc914>] ? sys_write+0x64/0x130
 [<ffffffff8020beab>] ? system_call_fastpath+0x16/0x1b
---[ end trace 7ef506680d7a9e26 ]---

Could it be that:

static void __free_vmap_area(struct vmap_area *va)
{
        BUG_ON(RB_EMPTY_NODE(&va->rb_node));
        rb_erase(&va->rb_node, &vmap_area_root);
        RB_CLEAR_NODE(&va->rb_node);
        list_del_rcu(&va->list);

        call_rcu(&va->rcu_head, rcu_free_va);
}

(especially clearing from the rb tree and va list)
allows reallocation of the node by kmalloc_node before its reclamation
(only done later by rcu_free_va) ?

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
