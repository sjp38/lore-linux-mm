Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 44DD46B0069
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 12:10:44 -0400 (EDT)
Received: by mail-yk0-f172.google.com with SMTP id 142so309357ykq.17
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 09:10:44 -0700 (PDT)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id j3si1110900yhc.175.2014.06.24.09.10.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 09:10:43 -0700 (PDT)
Date: Tue, 24 Jun 2014 11:10:34 -0500
From: Felipe Balbi <balbi@ti.com>
Subject: Re: [memcontrol] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28
 res_counter_uncharge_locked()
Message-ID: <20140624161034.GA29463@saruman.home>
Reply-To: <balbi@ti.com>
References: <20140620102704.GA8912@localhost>
 <20140620154209.GI7331@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8t9RHnE3ZwKMSgU+"
Content-Disposition: inline
In-Reply-To: <20140620154209.GI7331@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Jet Chen <jet.chen@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 20, 2014 at 11:42:10AM -0400, Johannes Weiner wrote:
> On Fri, Jun 20, 2014 at 06:27:04PM +0800, Fengguang Wu wrote:
> > Greetings,
> >=20
> > 0day kernel testing robot got the below dmesg and the first bad commit =
is
> >=20
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
>=20
> Thanks for the bisect.
>=20
> > commit ddc5bfec501f4be3f9e89084c2db270c0c45d1d6
> > Author:     Johannes Weiner <hannes@cmpxchg.org>
> > AuthorDate: Fri Jun 20 10:27:58 2014 +1000
> > Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> > CommitDate: Fri Jun 20 10:27:58 2014 +1000
> >=20
> >     mm: memcontrol: rewrite uncharge API
> >    =20
> >     The memcg uncharging code that is involved towards the end of a pag=
e's
> >     lifetime - truncation, reclaim, swapout, migration - is impressively
> >     complicated and fragile.
> >    =20
> >     Because anonymous and file pages were always charged before they ha=
d their
> >     page->mapping established, uncharges had to happen when the page ty=
pe
> >     could still be known from the context; as in unmap for anonymous, p=
age
> >     cache removal for file and shmem pages, and swap cache truncation f=
or swap
> >     pages.  However, these operations happen well before the page is ac=
tually
> >     freed, and so a lot of synchronization is necessary:
> >    =20
> >     - Charging, uncharging, page migration, and charge migration all ne=
ed
> >       to take a per-page bit spinlock as they could race with unchargin=
g.
> >    =20
> >     - Swap cache truncation happens during both swap-in and swap-out, a=
nd
> >       possibly repeatedly before the page is actually freed.  This means
> >       that the memcg swapout code is called from many contexts that make
> >       no sense and it has to figure out the direction from page state to
> >       make sure memory and memory+swap are always correctly charged.
> >    =20
> >     - On page migration, the old page might be unmapped but then reused,
> >       so memcg code has to prevent untimely uncharging in that case.
> >       Because this code - which should be a simple charge transfer - is=
 so
> >       special-cased, it is not reusable for replace_page_cache().
> >    =20
> >     But now that charged pages always have a page->mapping, introduce
> >     mem_cgroup_uncharge(), which is called after the final put_page(), =
when we
> >     know for sure that nobody is looking at the page anymore.
> >    =20
> >     For page migration, introduce mem_cgroup_migrate(), which is called=
 after
> >     the migration is successful and the new page is fully rmapped.  Bec=
ause
> >     the old page is no longer uncharged after migration, prevent double
> >     charges by decoupling the page's memcg association (PCG_USED and
> >     pc->mem_cgroup) from the page holding an actual charge.  The new bi=
ts
> >     PCG_MEM and PCG_MEMSW represent the respective charges and are tran=
sferred
> >     to the new page during migration.
> >    =20
> >     mem_cgroup_migrate() is suitable for replace_page_cache() as well, =
which
> >     gets rid of mem_cgroup_replace_page_cache().
> >    =20
> >     Swap accounting is massively simplified: because the page is no lon=
ger
> >     uncharged as early as swap cache deletion, a new mem_cgroup_swapout=
() can
> >     transfer the page's memory+swap charge (PCG_MEMSW) to the swap entry
> >     before the final put_page() in page reclaim.
> >    =20
> >     Finally, page_cgroup changes are now protected by whatever protecti=
on the
> >     page itself offers: anonymous pages are charged under the page tabl=
e lock,
> >     whereas page cache insertions, swapin, and migration hold the page =
lock.
> >     Uncharging happens under full exclusion with no outstanding referen=
ces.
> >     Charging and uncharging also ensure that the page is off-LRU, which
> >     serializes against charge migration.  Remove the very costly page_c=
group
> >     lock and set pc->flags non-atomically.
> >    =20
> >     Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >     Cc: Michal Hocko <mhocko@suse.cz>
> >     Cc: Hugh Dickins <hughd@google.com>
> >     Cc: Tejun Heo <tj@kernel.org>
> >     Cc: Vladimir Davydov <vdavydov@parallels.com>
> >     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >=20
> > +----------------------------------------------------------------------=
-+------------+------------+---------------+
> > |                                                                      =
 | 5b647620c6 | ddc5bfec50 | next-20140620 |
> > +----------------------------------------------------------------------=
-+------------+------------+---------------+
> > | boot_successes                                                       =
 | 60         | 0          | 0             |
> > | boot_failures                                                        =
 | 0          | 20         | 13            |
> > | WARNING:CPU:PID:at_kernel/res_counter.c:res_counter_uncharge_locked()=
 | 0          | 20         | 13            |
> > | backtrace:vm_munmap                                                  =
 | 0          | 20         | 13            |
> > | backtrace:SyS_munmap                                                 =
 | 0          | 20         | 13            |
> > | backtrace:do_sys_open                                                =
 | 0          | 20         | 13            |
> > | backtrace:SyS_open                                                   =
 | 0          | 20         | 13            |
> > | backtrace:do_execve                                                  =
 | 0          | 20         | 13            |
> > | backtrace:SyS_execve                                                 =
 | 0          | 20         | 13            |
> > | backtrace:do_group_exit                                              =
 | 0          | 20         | 13            |
> > | backtrace:SyS_exit_group                                             =
 | 0          | 20         | 13            |
> > | backtrace:SYSC_renameat2                                             =
 | 0          | 11         | 8             |
> > | backtrace:SyS_rename                                                 =
 | 0          | 11         | 8             |
> > | backtrace:do_munmap                                                  =
 | 0          | 11         | 8             |
> > | backtrace:SyS_brk                                                    =
 | 0          | 11         | 8             |
> > | Out_of_memory:Kill_process                                           =
 | 0          | 1          |               |
> > | backtrace:do_unlinkat                                                =
 | 0          | 9          | 5             |
> > | backtrace:SyS_unlink                                                 =
 | 0          | 9          | 5             |
> > | backtrace:SYSC_umount                                                =
 | 0          | 9          |               |
> > | backtrace:SyS_umount                                                 =
 | 0          | 9          |               |
> > | backtrace:cleanup_mnt_work                                           =
 | 0          | 0          | 5             |
> > +----------------------------------------------------------------------=
-+------------+------------+---------------+
> >=20
> > [    2.747397] debug: unmapping init [mem 0xffff880001a3a000-0xffff8800=
01bfffff]
> > [    2.748630] debug: unmapping init [mem 0xffff8800021ad000-0xffff8800=
021fffff]
> > [    2.752857] ------------[ cut here ]------------
> > [    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_co=
unter_uncharge_locked+0x48/0x74()
> > [    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gd=
dc5bfe #1
> > [    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff=
880012073c88
> > [    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff=
88001200fa50
> > [    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffff=
ffff810bc84b
> > [    2.753355] Call Trace:
> > [    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
> > [    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
> > [    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48=
/0x74
> > [    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
> > [    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0=
x74
> > [    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0x=
a9
> > [    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
> > [    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
> > [    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
> > [    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
> > [    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
> > [    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
> > [    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
> > [    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18=
/0x33
> > [    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
> > [    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
> > [    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
> > [    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
> > [    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
> > [    2.780913] ------------[ cut here ]------------
>=20
> This is an underflow that happens with memcg enabled but memcg-swap
> disabled - the memsw counter is not accounted, but then unaccounted.
>=20
> Andrew, can you please put this in to fix the uncharge rewrite patch
> mentioned above?
>=20
> ---
>=20
> From 29bcfcf54494467008aaf9d4e37771d3b2e2c2c7 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Fri, 20 Jun 2014 11:09:14 -0400
> Subject: [patch] mm: memcontrol: rewrite uncharge API fix
>=20
> It's not entirely clear whether do_swap_account or PCG_MEMSW is the
> authoritative answer to whether a page is swap-accounted or not.  This
> currently leads to the following memsw counter underflow when swap
> accounting is disabled:
>=20
> [    2.753355] WARNING: CPU: 0 PID: 1 at kernel/res_counter.c:28 res_coun=
ter_uncharge_locked+0x48/0x74()
> [    2.753355] CPU: 0 PID: 1 Comm: init Not tainted 3.16.0-rc1-00238-gddc=
5bfe #1
> [    2.753355] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [    2.753355]  0000000000000000 ffff880012073c50 ffffffff81a23b9d ffff88=
0012073c88
> [    2.753355]  ffffffff810bc765 ffffffff8111fac8 0000000000001000 ffff88=
001200fa50
> [    2.753355]  0000000000000001 ffff88001200fa01 ffff880012073c98 ffffff=
ff810bc84b
> [    2.753355] Call Trace:
> [    2.753355]  [<ffffffff81a23b9d>] dump_stack+0x19/0x1b
> [    2.753355]  [<ffffffff810bc765>] warn_slowpath_common+0x73/0x8c
> [    2.753355]  [<ffffffff8111fac8>] ? res_counter_uncharge_locked+0x48/0=
x74
> [    2.753355]  [<ffffffff810bc84b>] warn_slowpath_null+0x1a/0x1c
> [    2.753355]  [<ffffffff8111fac8>] res_counter_uncharge_locked+0x48/0x74
> [    2.753355]  [<ffffffff8111fd02>] res_counter_uncharge_until+0x4e/0xa9
> [    2.753355]  [<ffffffff8111fd70>] res_counter_uncharge+0x13/0x15
> [    2.753355]  [<ffffffff8119499c>] mem_cgroup_uncharge_end+0x73/0x8d
> [    2.753355]  [<ffffffff8115735e>] release_pages+0x1f2/0x20d
> [    2.753355]  [<ffffffff8116cc3a>] tlb_flush_mmu_free+0x28/0x43
> [    2.753355]  [<ffffffff8116d5e5>] tlb_flush_mmu+0x20/0x23
> [    2.753355]  [<ffffffff8116d5fc>] tlb_finish_mmu+0x14/0x39
> [    2.753355]  [<ffffffff811730c1>] unmap_region+0xcd/0xdf
> [    2.753355]  [<ffffffff81172b0e>] ? vma_gap_callbacks_propagate+0x18/0=
x33
> [    2.753355]  [<ffffffff81174bf1>] do_munmap+0x252/0x2e0
> [    2.753355]  [<ffffffff81174cc3>] vm_munmap+0x44/0x5c
> [    2.753355]  [<ffffffff81174cfe>] SyS_munmap+0x23/0x29
> [    2.753355]  [<ffffffff81a31567>] system_call_fastpath+0x16/0x1b
> [    2.753355] ---[ end trace cfeb07101f6fbdfb ]---
>=20
> Don't set PCG_MEMSW when swap accounting is disabled, so that
> uncharging only has to look at this per-page flag.
>=20
> mem_cgroup_swapout() could also fully rely on this flag, but as it can
> bail out before even looking up the page_cgroup, check do_swap_account
> as a performance optimization and only sanity test for PCG_MEMSW.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I was having the same issue with today's linux-next and this patch fixes
it. Before looking at the mailing list I had patched it in a different
way (adding '&& do_swap_account' to mem_cgroup_uncharge_end() check).

Not even enabling swap accounting is a much better approach, indeed.

Tested-by: Felipe Balbi <balbi@ti.com>

> ---
>  mm/memcontrol.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 94d7c40b9f26..d6a20935f9c4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2740,7 +2740,7 @@ static void commit_charge(struct page *page, struct=
 mem_cgroup *memcg,
>  	 *   have the page locked
>  	 */
>  	pc->mem_cgroup =3D memcg;
> -	pc->flags =3D PCG_USED | PCG_MEM | PCG_MEMSW;
> +	pc->flags =3D PCG_USED | PCG_MEM | (do_swap_account ? PCG_MEMSW : 0);
> =20
>  	if (lrucare) {
>  		if (was_on_lru) {
> @@ -6598,7 +6598,7 @@ void mem_cgroup_migrate(struct page *oldpage, struc=
t page *newpage,
>  		return;
> =20
>  	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEM), oldpage);
> -	VM_BUG_ON_PAGE(!(pc->flags & PCG_MEMSW), oldpage);
> +	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
>  	pc->flags &=3D ~(PCG_MEM | PCG_MEMSW);
> =20
>  	if (PageTransHuge(oldpage)) {

--=20
balbi

--8t9RHnE3ZwKMSgU+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTqaL6AAoJEIaOsuA1yqREFcQQAIgterR7DLau3oJ8btGt8GDI
bbXTueF3RGIgRbz6O6Ldo3o4ab3uq63u/fD5E2J+dLwX20Z1UeMSze999+NaL8xQ
GeWOs22t8T+eBJqyltHzvpWH5ReTHwepkKcHXW+yNgfsVqd4ZXNbWSODjn4Osq4m
3pWJXnce1EAv+EDx5Q/lWrSmg9cFyJDBczxTX5PrufWVJzG86Abs/FcpyYj8W6wG
ysak3cqObk8osrXYacoYWHOC5JJvHPtNg/P1hGARCkFCnIXu+1iULRrEUxCCyeId
1rZ8QALvLQ2Bfu9NP0OA+Kmhkynn3jW2z4/nYJ5TxAvTB6VVeIPRO0pvB35iBh9W
ZCHCtN+xHXd9KdkNJPIHHTr28q3MqyoFua/mhSjygA5RrK2Vu5pIuyz2jjPAqiI7
5zQi5WkiczWzWS/JTV1QGy672s/k1LNISbi8nQrS9G6Uup9SsVA2Tm3VsrtRe6Ev
57ySZGLkharef9fI9GCBSmOYz+54egZ7WpeP8vAJle1dAFwP1goat6a1gAHsPOVL
tOKb2mVScN/CdmfkTJ0M9jWcU8OaCWKLiq7gwQPLeEwyFUHiUebH1d5pbpJkhOWu
eUJ/eXenFA9sHQgJjaW8CGe16AjaSRyP07m7QJr7LqsiNg4yE+w1Ro6H37ICWUYo
FN3Km8VFh5/wa1LmHpWr
=AkfY
-----END PGP SIGNATURE-----

--8t9RHnE3ZwKMSgU+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
