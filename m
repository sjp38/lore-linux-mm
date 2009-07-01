Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA366B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 11:55:28 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id n61Fv61S014332
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 16:57:07 +0100
Received: from yxe37 (yxe37.prod.google.com [10.190.2.37])
	by wpaz17.hot.corp.google.com with ESMTP id n61FumOH018242
	for <linux-mm@kvack.org>; Wed, 1 Jul 2009 08:57:04 -0700
Received: by yxe37 with SMTP id 37so1410626yxe.17
        for <linux-mm@kvack.org>; Wed, 01 Jul 2009 08:57:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 1 Jul 2009 08:57:03 -0700
Message-ID: <6599ad830907010857r7fae2215r2e8aadb3003dcc4d@mail.gmail.com>
Subject: Re: [PATCH] memcg: fix cgroup rmdir hang v4
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 6:47 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> ok, here.
>
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> After commit: cgroup: fix frequent -EBUSY at rmdir
> =A0 =A0 =A0 =A0 =A0 =A0 =A0ec64f51545fffbc4cb968f0cea56341a4b07e85a
> cgroup's rmdir (especially against memcg) doesn't return -EBUSY
> by temporal ref counts. That commit expects all refs after pre_destroy()
> is temporary but...it wasn't. Then, rmdir can wait permanently.
> This patch tries to fix that and change followings.
>
> =A0- set CGRP_WAIT_ON_RMDIR flag before pre_destroy().
> =A0- clear CGRP_WAIT_ON_RMDIR flag when the subsys finds racy case.
> =A0 if there are sleeping ones, wakes them up.
> =A0- rmdir() sleeps only when CGRP_WAIT_ON_RMDIR flag is set.
>
> Changelog v4->v5:
> =A0- added cgroup_exclude_rmdir(), cgroup_release_rmdir().
>
> Changelog v3->v4:
> =A0- rewrite/add comments.
> =A0- remane cgroup_wakeup_rmdir_waiters() to cgroup_wakeup_rmdir_waiter()=
.
> Changelog v2->v3:
> =A0- removed retry_rmdir() callback.
> =A0- make use of CGRP_WAIT_ON_RMDIR flag more.
>
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Paul Menage <menage@google.com>

Looks great, thanks.

Paul

> ---
> =A0include/linux/cgroup.h | =A0 14 ++++++++++++
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 55 ++++++++++++++++++++++++++++++=
+++----------------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 23 +++++++++++++++++---
> =A03 files changed, 72 insertions(+), 20 deletions(-)
>
> Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
> +++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
> @@ -366,6 +366,20 @@ int cgroup_task_count(const struct cgrou
> =A0int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct=
 *task);
>
> =A0/*
> + * When the subsys has to access css and may add permanent refcnt to css=
,
> + * it should take care of racy conditions with rmdir(). Following set of
> + * functions, is for stop/restart rmdir if necessary.
> + * Because these will call css_get/put, "css" should be alive css.
> + *
> + * =A0cgroup_exclude_rmdir();
> + * =A0...do some jobs which may access arbitrary empty cgroup
> + * =A0cgroup_release_rmdir();
> + */
> +
> +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
> +void cgroup_release_rmdir(struct cgroup_subsys_state *css);
> +
> +/*
> =A0* Control Group subsystem type.
> =A0* See Documentation/cgroups/cgroups.txt for details
> =A0*/
> Index: mmotm-2.6.31-Jun25/kernel/cgroup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/kernel/cgroup.c
> +++ mmotm-2.6.31-Jun25/kernel/cgroup.c
> @@ -734,16 +734,28 @@ static void cgroup_d_remove_dir(struct d
> =A0* reference to css->refcnt. In general, this refcnt is expected to goe=
s down
> =A0* to zero, soon.
> =A0*
> - * CGRP_WAIT_ON_RMDIR flag is modified under cgroup's inode->i_mutex;
> + * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
> =A0*/
> =A0DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
>
> -static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> =A0{
> - =A0 =A0 =A0 if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> + =A0 =A0 =A0 if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->=
flags)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_up_all(&cgroup_rmdir_waitq);
> =A0}
>
> +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
> +{
> + =A0 =A0 =A0 css_get(css);
> +}
> +
> +void cgroup_release_rmdir(struct cgroup_subsys_state *css)
> +{
> + =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(css->cgroup);
> + =A0 =A0 =A0 css_put(css);
> +}
> +
> +
> =A0static int rebind_subsystems(struct cgroupfs_root *root,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long =
final_bits)
> =A0{
> @@ -1357,7 +1369,7 @@ int cgroup_attach_task(struct cgroup *cg
> =A0 =A0 =A0 =A0 * wake up rmdir() waiter. the rmdir should fail since the=
 cgroup
> =A0 =A0 =A0 =A0 * is no longer empty.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 cgroup_wakeup_rmdir_waiters(cgrp);
> + =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(cgrp);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -2696,33 +2708,42 @@ again:
> =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
>
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* In general, subsystem has no css->refcnt after pre_des=
troy(). But
> + =A0 =A0 =A0 =A0* in racy cases, subsystem may have to get css->refcnt a=
fter
> + =A0 =A0 =A0 =A0* pre_destroy() and it makes rmdir return with -EBUSY. T=
his sometimes
> + =A0 =A0 =A0 =A0* make rmdir return -EBUSY too often. To avoid that, we =
use waitqueue
> + =A0 =A0 =A0 =A0* for cgroup's rmdir. CGRP_WAIT_ON_RMDIR is for synchron=
izing rmdir
> + =A0 =A0 =A0 =A0* and subsystem's reference count handling. Please see c=
ss_get/put
> + =A0 =A0 =A0 =A0* and css_tryget() and cgroup_wakeup_rmdir_waiter() impl=
ementation.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> +
> + =A0 =A0 =A0 /*
> =A0 =A0 =A0 =A0 * Call pre_destroy handlers of subsys. Notify subsystems
> =A0 =A0 =A0 =A0 * that rmdir() request comes.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0ret =3D cgroup_call_pre_destroy(cgrp);
> - =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0mutex_lock(&cgroup_mutex);
> =A0 =A0 =A0 =A0parent =3D cgrp->parent;
> =A0 =A0 =A0 =A0if (atomic_read(&cgrp->count) || !list_empty(&cgrp->childr=
en)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* css_put/get is provided for subsys to grab refcnt to c=
ss. In typical
> - =A0 =A0 =A0 =A0* case, subsystem has no reference after pre_destroy(). =
But, under
> - =A0 =A0 =A0 =A0* hierarchy management, some *temporal* refcnt can be ho=
ld.
> - =A0 =A0 =A0 =A0* To avoid returning -EBUSY to a user, waitqueue is used=
. If subsys
> - =A0 =A0 =A0 =A0* is really busy, it should return -EBUSY at pre_destroy=
(). wake_up
> - =A0 =A0 =A0 =A0* is called when css_put() is called and refcnt goes dow=
n to 0.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> =A0 =A0 =A0 =A0prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPT=
IBLE);
> -
> =A0 =A0 =A0 =A0if (!cgroup_clear_css_refs(cgrp)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Because someone may call cgroup_wakeup=
_rmdir_waiter() before
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* prepare_to_wait(), we need to check th=
is flag.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->fla=
gs))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0finish_wait(&cgroup_rmdir_waitq, &wait);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (signal_pending(current))
> @@ -3294,7 +3315,7 @@ void __css_put(struct cgroup_subsys_stat
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(CGRP_RELEASABLE, &=
cgrp->flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0check_for_release(cgrp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_wakeup_rmdir_waiters(cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(cgrp);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0}
> Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> @@ -1234,6 +1234,12 @@ static int mem_cgroup_move_account(struc
> =A0 =A0 =A0 =A0ret =3D 0;
> =A0out:
> =A0 =A0 =A0 =A0unlock_page_cgroup(pc);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We charges against "to" which may not have any tasks. =
Then, "to"
> + =A0 =A0 =A0 =A0* can be under rmdir(). But in current implementation, c=
aller of
> + =A0 =A0 =A0 =A0* this function is just force_empty() and it's garanteed=
 that
> + =A0 =A0 =A0 =A0* "to" is never removed. So, we don't check rmdir status=
 here.
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> @@ -1455,6 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0if (!ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> + =A0 =A0 =A0 cgroup_exclude_rmdir(&ptr->css);
> =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
> =A0 =A0 =A0 =A0mem_cgroup_lru_del_before_commit_swapcache(page);
> =A0 =A0 =A0 =A0__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1484,8 +1491,12 @@ __mem_cgroup_commit_charge_swapin(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /* add this page(page_cgroup) to the LRU we want. */
> -
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* At swapin, we may charge account against cgroup which =
has no tasks.
> + =A0 =A0 =A0 =A0* So, rmdir()->pre_destroy() can be called while we do t=
his charge.
> + =A0 =A0 =A0 =A0* In that case, we need to call pre_destroy() again. che=
ck it here.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cgroup_release_rmdir(&ptr->css);
> =A0}
>
> =A0void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgr=
oup *ptr)
> @@ -1691,7 +1702,7 @@ void mem_cgroup_end_migration(struct mem
>
> =A0 =A0 =A0 =A0if (!mem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> -
> + =A0 =A0 =A0 cgroup_exclude_rmdir(&mem->css);
> =A0 =A0 =A0 =A0/* at migration success, oldpage->mapping is NULL. */
> =A0 =A0 =A0 =A0if (oldpage->mapping) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0target =3D oldpage;
> @@ -1731,6 +1742,12 @@ void mem_cgroup_end_migration(struct mem
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (ctype =3D=3D MEM_CGROUP_CHARGE_TYPE_MAPPED)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_uncharge_page(target);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* At migration, we may charge account against cgroup whi=
ch has no tasks
> + =A0 =A0 =A0 =A0* So, rmdir()->pre_destroy() can be called while we do t=
his charge.
> + =A0 =A0 =A0 =A0* In that case, we need to call pre_destroy() again. che=
ck it here.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cgroup_release_rmdir(&mem->css);
> =A0}
>
> =A0/*
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
