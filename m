Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C6D846B004A
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:32:57 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o89GWruJ006838
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 09:32:54 -0700
Received: from qyk1 (qyk1.prod.google.com [10.241.83.129])
	by kpbe20.cbf.corp.google.com with ESMTP id o89GW86O008436
	for <linux-mm@kvack.org>; Thu, 9 Sep 2010 09:32:52 -0700
Received: by qyk1 with SMTP id 1so6400005qyk.10
        for <linux-mm@kvack.org>; Thu, 09 Sep 2010 09:32:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100901154138.d234bf60.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com> <20100901154138.d234bf60.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 9 Sep 2010 09:32:32 -0700
Message-ID: <AANLkTimtV+TAmxh6dQnTNsS8vSb93qux+fJGxvX7FJ3G@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: change allocation of css ID placement
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 11:41 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, css'id is allocated after ->create() is called. But to make use of I=
D
> in ->create(), it should be available before ->create().
>
> In another thinking, considering the ID is tightly coupled with "css",
> it should be allocated when "css" is allocated.
> This patch moves alloc_css_id() to css allocation routine. Now, only 2 su=
bsys,
> memory and blkio are using ID. (To support complicated hierarchy walk.)
>
> ID will be used in mem cgroup's ->create(), later.
>
> This patch adds css ID documentation which is not provided.
>
> Note:
> If someone changes rules of css allocation, ID allocation should be chang=
ed.
>
> Changelog: 2010/09/01
> =A0- modified cgroups.txt
>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0Documentation/cgroups/cgroups.txt | =A0 48 +++++++++++++++++++++++++++=
+++++++++
> =A0block/blk-cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 ++++++
> =A0include/linux/cgroup.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 16 ++++++------
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 50 +++++++++=
++---------------------------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +++
> =A05 files changed, 86 insertions(+), 42 deletions(-)
>
> Index: mmotm-0827/kernel/cgroup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0827.orig/kernel/cgroup.c
> +++ mmotm-0827/kernel/cgroup.c
> @@ -289,9 +289,6 @@ struct cg_cgroup_link {
> =A0static struct css_set init_css_set;
> =A0static struct cg_cgroup_link init_css_set_link;
>
> -static int cgroup_init_idr(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys=
_state *css);
> -
> =A0/* css_set_lock protects the list of css_set objects, and the
> =A0* chain of tasks off each css_set. =A0Nests outside task->alloc_lock
> =A0* due to cgroup_iter_start() */
> @@ -770,9 +767,6 @@ static struct backing_dev_info cgroup_ba
> =A0 =A0 =A0 =A0.capabilities =A0 =3D BDI_CAP_NO_ACCT_AND_WRITEBACK,
> =A0};
>
> -static int alloc_css_id(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *parent, stru=
ct cgroup *child);
> -
> =A0static struct inode *cgroup_new_inode(mode_t mode, struct super_block =
*sb)
> =A0{
> =A0 =A0 =A0 =A0struct inode *inode =3D new_inode(sb);
> @@ -3258,7 +3252,8 @@ static void init_cgroup_css(struct cgrou
> =A0 =A0 =A0 =A0css->cgroup =3D cgrp;
> =A0 =A0 =A0 =A0atomic_set(&css->refcnt, 1);
> =A0 =A0 =A0 =A0css->flags =3D 0;
> - =A0 =A0 =A0 css->id =3D NULL;
> + =A0 =A0 =A0 if (!ss->use_id)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css->id =3D NULL;
> =A0 =A0 =A0 =A0if (cgrp =3D=3D dummytop)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(CSS_ROOT, &css->flags);
> =A0 =A0 =A0 =A0BUG_ON(cgrp->subsys[ss->subsys_id]);
> @@ -3343,12 +3338,6 @@ static long cgroup_create(struct cgroup
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_destroy;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_cgroup_css(css, ss, cgrp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->use_id) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D alloc_css_id(ss, pa=
rent, cgrp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_de=
stroy;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* At error, ->destroy() callback has to fr=
ee assigned ID. */
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0cgroup_lock_hierarchy(root);
> @@ -3710,17 +3699,6 @@ int __init_or_module cgroup_load_subsys(
>
> =A0 =A0 =A0 =A0/* our new subsystem will be attached to the dummy hierarc=
hy. */
> =A0 =A0 =A0 =A0init_cgroup_css(css, ss, dummytop);
> - =A0 =A0 =A0 /* init_idr must be after init_cgroup_css because it sets c=
ss->id. */
> - =A0 =A0 =A0 if (ss->use_id) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret =3D cgroup_init_idr(ss, css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dummytop->subsys[ss->subsys=
_id] =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->destroy(ss, dummytop);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 subsys[i] =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cgroup_mutex)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Now we need to entangle the css into the existing css_s=
ets. unlike
> @@ -3889,8 +3867,6 @@ int __init cgroup_init(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys *ss =3D subsys[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!ss->early_init)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cgroup_init_subsys(ss);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->use_id)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_init_idr(ss, init_cs=
s_set.subsys[ss->subsys_id]);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Add init_css_set to the hash table */
> @@ -4604,8 +4580,8 @@ err_out:
>
> =A0}
>
> -static int __init_or_module cgroup_init_idr(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 struct cgroup_subsys_state *rootcss)
> +static int cgroup_init_idr(struct cgroup_subsys *ss,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsy=
s_state *rootcss)
> =A0{
> =A0 =A0 =A0 =A0struct css_id *newid;
>
> @@ -4617,21 +4593,25 @@ static int __init_or_module cgroup_init_
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return PTR_ERR(newid);
>
> =A0 =A0 =A0 =A0newid->stack[0] =3D newid->id;
> - =A0 =A0 =A0 newid->css =3D rootcss;
> - =A0 =A0 =A0 rootcss->id =3D newid;
> + =A0 =A0 =A0 rcu_assign_pointer(newid->css, rootcss);
> + =A0 =A0 =A0 rcu_assign_pointer(rootcss->id, newid);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *parent,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *child)
> +int alloc_css_id(struct cgroup_subsys *ss,
> + =A0 =A0 =A0 struct cgroup *cgrp, struct cgroup_subsys_state *css)
Must also add EXPORT_SYMBOL_GPL(alloc_css_id) to supported CONFIG_BLK_CGROU=
P=3Dm.
> =A0{
> =A0 =A0 =A0 =A0int subsys_id, i, depth =3D 0;
> - =A0 =A0 =A0 struct cgroup_subsys_state *parent_css, *child_css;
> + =A0 =A0 =A0 struct cgroup_subsys_state *parent_css;
> + =A0 =A0 =A0 struct cgroup *parent;
> =A0 =A0 =A0 =A0struct css_id *child_id, *parent_id;
>
> + =A0 =A0 =A0 if (cgrp =3D=3D dummytop)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cgroup_init_idr(ss, css);
> +
> + =A0 =A0 =A0 parent =3D cgrp->parent;
> =A0 =A0 =A0 =A0subsys_id =3D ss->subsys_id;
> =A0 =A0 =A0 =A0parent_css =3D parent->subsys[subsys_id];
> - =A0 =A0 =A0 child_css =3D child->subsys[subsys_id];
> =A0 =A0 =A0 =A0parent_id =3D parent_css->id;
> =A0 =A0 =A0 =A0depth =3D parent_id->depth + 1;
>
> @@ -4646,7 +4626,7 @@ static int alloc_css_id(struct cgroup_su
> =A0 =A0 =A0 =A0 * child_id->css pointer will be set after this cgroup is =
available
> =A0 =A0 =A0 =A0 * see cgroup_populate_dir()
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 rcu_assign_pointer(child_css->id, child_id);
> + =A0 =A0 =A0 rcu_assign_pointer(css->id, child_id);
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> Index: mmotm-0827/include/linux/cgroup.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0827.orig/include/linux/cgroup.h
> +++ mmotm-0827/include/linux/cgroup.h
> @@ -588,9 +588,11 @@ static inline int cgroup_attach_task_cur
> =A0/*
> =A0* CSS ID is ID for cgroup_subsys_state structs under subsys. This only=
 works
> =A0* if cgroup_subsys.use_id =3D=3D true. It can be used for looking up a=
nd scanning.
> - * CSS ID is assigned at cgroup allocation (create) automatically
> - * and removed when subsys calls free_css_id() function. This is because
> - * the lifetime of cgroup_subsys_state is subsys's matter.
> + * CSS ID must be assigned by subsys itself at cgroup creation and delet=
ed
> + * when subsys calls free_css_id() function. This is because the life ti=
me of
To be consistent with document: s/life time/lifetime/
> + * of cgroup_subsys_state is subsys's matter.
> + *
> + * ID->css look up is available after cgroup's directory is populated.
> =A0*
> =A0* Looking up and scanning function should be called under rcu_read_loc=
k().
> =A0* Taking cgroup_mutex()/hierarchy_mutex() is not necessary for followi=
ng calls.
> @@ -598,10 +600,10 @@ static inline int cgroup_attach_task_cur
> =A0* destroyed". The caller should check css and cgroup's status.
> =A0*/
>
> -/*
> - * Typically Called at ->destroy(), or somewhere the subsys frees
> - * cgroup_subsys_state.
> - */
> +/* Should be called in ->create() by subsys itself */
> +int alloc_css_id(struct cgroup_subsys *ss, struct cgroup *newgr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *css);
> +/* Typically Called at ->destroy(), or somewhere the subsys frees css */
s/Called/called/
> =A0void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state =
*css);
>
> =A0/* Find a cgroup_subsys_state which has given ID */
> Index: mmotm-0827/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0827.orig/mm/memcontrol.c
> +++ mmotm-0827/mm/memcontrol.c
> @@ -4141,6 +4141,11 @@ mem_cgroup_create(struct cgroup_subsys *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (alloc_mem_cgroup_per_zone_info(mem, no=
de))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto free_out;
>
> + =A0 =A0 =A0 error =3D alloc_css_id(ss, cont, &mem->css);
> + =A0 =A0 =A0 if (error)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto free_out;
> + =A0 =A0 =A0 /* Here, css_id(&mem->css) works. but css_lookup(id)->mem d=
oesn't */
> +
> =A0 =A0 =A0 =A0/* root ? */
> =A0 =A0 =A0 =A0if (cont->parent =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int cpu;
> Index: mmotm-0827/block/blk-cgroup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0827.orig/block/blk-cgroup.c
> +++ mmotm-0827/block/blk-cgroup.c
> @@ -958,9 +958,13 @@ blkiocg_create(struct cgroup_subsys *sub
> =A0{
> =A0 =A0 =A0 =A0struct blkio_cgroup *blkcg;
> =A0 =A0 =A0 =A0struct cgroup *parent =3D cgroup->parent;
> + =A0 =A0 =A0 int ret;
>
> =A0 =A0 =A0 =A0if (!parent) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blkcg =3D &blkio_root_cgroup;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D alloc_css_id(subsys, cgroup, &blkcg=
->css);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(ret);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto done;
> =A0 =A0 =A0 =A0}
>
> @@ -971,6 +975,11 @@ blkiocg_create(struct cgroup_subsys *sub
> =A0 =A0 =A0 =A0blkcg =3D kzalloc(sizeof(*blkcg), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!blkcg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-ENOMEM);
> + =A0 =A0 =A0 ret =3D alloc_css_id(subsys, cgroup, &blkcg->css);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(blkcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(ret);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0blkcg->weight =3D BLKIO_WEIGHT_DEFAULT;
> =A0done:
> Index: mmotm-0827/Documentation/cgroups/cgroups.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0827.orig/Documentation/cgroups/cgroups.txt
> +++ mmotm-0827/Documentation/cgroups/cgroups.txt
> @@ -621,6 +621,54 @@ and root cgroup. Currently this will onl
> =A0the default hierarchy (which never has sub-cgroups) and a hierarchy
> =A0that is being created/destroyed (and hence has no sub-cgroups).
>
> +3.4 cgroup subsys state IDs.
> +------------
> +When subsystem sets use_id =3D=3D true, an ID per [cgroup, subsys] is ad=
ded
> +and it will be tied to cgroup_subsys_state object.
> +
> +When use_id=3D=3Dtrue can use following interfaces. But please note that
> +allocation/free an ID is subsystem's job because cgroup_subsys_state
> +object's lifetime is subsystem's matter.
> +
> +unsigned short css_id(struct cgroup_subsys_state *css)
> +
> +Returns ID of cgroup_subsys_state
Please add trailing '.' (period character).

> +
> +unsigend short css_depth(struct cgroup_subsys_state *css)
Typo: s/unsigend/unsigned/
> +
> +Returns the level which "css" is exisiting under hierarchy tree.
> +The root cgroup's depth 0, its children are 1, children's children are
> +2....
> +
> +int alloc_css_id(struct struct cgroup_subsys *ss, struct cgroup *newgr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys_state *css);
> +
> +Attach an new ID to given css under subsystem ([ss, cgroup])
> +should be called in ->create() callback.
> +
> +void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *c=
ss);
> +
> +Free ID attached to "css" under subsystem. Should be called before
> +"css" is freed.
> +
> +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)=
;
> +
> +Look up cgroup_subsys_state via ID. Should be called under rcu_read_lock=
().
> +
> +struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int i=
d,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys_state *root, int *f=
oundid);
> +
> +Returns ID which is under "root" i.e. under sub-directory of "root"
> +cgroup's directory at considering cgroup hierarchy. The order of IDs
> +returned by this function is not sorted. Please be careful.
> +
> +bool css_is_ancestor(struct cgroup_subsys_state *cg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct cgroup_subsys_stat=
e *root);

To match code: s/cg/child/

> +
> +Returns true if "root" and "cs" is under the same hierarchy and
> +"root" can be found when you see all ->parent from "cs" until
This may be more clear: s/see all/walk all/

> +the root cgroup.
As above: s/cs/child/

> +
> =A04. Questions
> =A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
