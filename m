Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C61086B004D
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 11:23:37 -0400 (EDT)
Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts5-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20091006152332.NCIR7787.tomts5-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 6 Oct 2009 11:23:32 -0400
Date: Tue, 6 Oct 2009 11:23:29 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [patch 4/4] vunmap: Fix racy use of rcu_head
Message-ID: <20091006152329.GC12530@Krystal>
References: <20091006143727.868480435@polymtl.ca> <20091006144043.378971387@polymtl.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20091006144043.378971387@polymtl.ca>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Mathieu Desnoyers (mathieu.desnoyers@polymtl.ca) wrote:
> Repetitive use of vmap/vunmap on the same address triggers this bug.
>=20
> Simplest fix: directly kfree the data structure rather than doing it lazi=
ly.
>=20

I assumed that call_rcu in vunmap() is only used to postpone kfree()
=66rom the hot path, but I ask for comfirmation/infirmation about that. I
fear delayed reclamation might be there for a reason. Are there rcu read
sides depending on this behavior ?

If yes, then this patch is wrong, and we could change it for

synchronize_rcu();
kfree(....);

Mathieu

> Impact:
> (-) slight slowdown on vunmap
> (+) stop messing up rcu callback lists ;)
>=20
> Caught it with DEBUG_RCU_HEAD, running LTTng armall/disarmall in loops.
> Immediate values (with breakpoint-ipi scheme) are still using vunmap.
>=20
> ------------[ cut here ]------------
> WARNING: at kernel/rcutree.c:1199 __call_rcu+0x181/0x190()
> Hardware name: X7DAL
> Modules linked in: loop ltt_statedump ltt_userspace_event ipc_tr]
> Pid: 4527, comm: ltt-armall Not tainted 2.6.30.9-trace #30
> Call Trace:
>  [<ffffffff8027b181>] ? __call_rcu+0x181/0x190
>  [<ffffffff8027b181>] ? __call_rcu+0x181/0x190
>  [<ffffffff8023a6a9>] ? warn_slowpath_common+0x79/0xd0
>  [<ffffffff802b4890>] ? rcu_free_va+0x0/0x10
>  [<ffffffff8027b181>] ? __call_rcu+0x181/0x190
>  [<ffffffff802b5298>] ? __purge_vmap_area_lazy+0x1a8/0x1e0
>  [<ffffffff802b59d4>] ? free_unmap_vmap_area_noflush+0x74/0x80
>  [<ffffffff802b5a0e>] ? remove_vm_area+0x2e/0x80
>  [<ffffffff802b5b35>] ? __vunmap+0x45/0xf0
>  [<ffffffffa002e826>] ? ltt_statedump_start+0x7b6/0x820 [ltt_sta]
>  [<ffffffff8068978a>] ? arch_imv_update+0x16a/0x2f0
>  [<ffffffff8027dd13>] ? imv_update_range+0x53/0xa0
>  [<ffffffff8026235b>] ? _module_imv_update+0x4b/0x60
>  [<ffffffff80262385>] ? module_imv_update+0x15/0x30
>  [<ffffffff80280049>] ? marker_probe_register+0x149/0xb90
>  [<ffffffff8040c8e0>] ? ltt_vtrace+0x0/0x8c0
>  [<ffffffff80409330>] ? ltt_marker_connect+0xd0/0x150
>  [<ffffffff8040f8dc>] ? marker_enable_write+0xec/0x120
>  [<ffffffff802c6cb8>] ? __dentry_open+0x268/0x350
>  [<ffffffff80280b2c>] ? marker_probe_cb+0x9c/0x170
>  [<ffffffff80280b2c>] ? marker_probe_cb+0x9c/0x170
>  [<ffffffff802c973b>] ? vfs_write+0xcb/0x170
>  [<ffffffff802c9984>] ? sys_write+0x64/0x130
>  [<ffffffff8020beeb>] ? system_call_fastpath+0x16/0x1b
> ---[ end trace ef92443e716fa199 ]---
> ------------[ cut here ]------------
>=20
> Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> CC: cl@linux-foundation.org
> CC: mingo@elte.hu
> CC: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> CC: linux-mm@kvack.org
> CC: akpm@linux-foundation.org
> ---
>  mm/vmalloc.c |   18 ++----------------
>  1 file changed, 2 insertions(+), 16 deletions(-)
>=20
> Index: linux-2.6-lttng/mm/vmalloc.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6-lttng.orig/mm/vmalloc.c	2009-10-06 09:37:04.000000000 -0400
> +++ linux-2.6-lttng/mm/vmalloc.c	2009-10-06 09:37:56.000000000 -0400
> @@ -417,13 +417,6 @@ overflow:
>  	return va;
>  }
> =20
> -static void rcu_free_va(struct rcu_head *head)
> -{
> -	struct vmap_area *va =3D container_of(head, struct vmap_area, rcu_head);
> -
> -	kfree(va);
> -}
> -
>  static void __free_vmap_area(struct vmap_area *va)
>  {
>  	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> @@ -431,7 +424,7 @@ static void __free_vmap_area(struct vmap
>  	RB_CLEAR_NODE(&va->rb_node);
>  	list_del_rcu(&va->list);
> =20
> -	call_rcu(&va->rcu_head, rcu_free_va);
> +	kfree(va);
>  }
> =20
>  /*
> @@ -757,13 +750,6 @@ static struct vmap_block *new_vmap_block
>  	return vb;
>  }
> =20
> -static void rcu_free_vb(struct rcu_head *head)
> -{
> -	struct vmap_block *vb =3D container_of(head, struct vmap_block, rcu_hea=
d);
> -
> -	kfree(vb);
> -}
> -
>  static void free_vmap_block(struct vmap_block *vb)
>  {
>  	struct vmap_block *tmp;
> @@ -778,7 +764,7 @@ static void free_vmap_block(struct vmap_
>  	BUG_ON(tmp !=3D vb);
> =20
>  	free_unmap_vmap_area_noflush(vb->va);
> -	call_rcu(&vb->rcu_head, rcu_free_vb);
> +	kfree(vb);
>  }
> =20
>  static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
>=20
> --=20
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A=
68

--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
