Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B30B26B0093
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 16:16:02 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n5QKGQGQ013945
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 13:16:27 -0700
Received: from gxk5 (gxk5.prod.google.com [10.202.11.5])
	by wpaz21.hot.corp.google.com with ESMTP id n5QKG6rx023280
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 13:16:24 -0700
Received: by gxk5 with SMTP id 5so2659129gxk.6
        for <linux-mm@kvack.org>; Fri, 26 Jun 2009 13:16:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090626141020.849a081e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090626141020.849a081e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 26 Jun 2009 13:16:23 -0700
Message-ID: <6599ad830906261316x52d6c115t720b87ba16b3617@mail.gmail.com>
Subject: Re: [PATCH] memcg: cgroup fix rmdir hang
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Kamezawa,

Sorry that I didn't get a chance to look at these patches before now.

On Thu, Jun 25, 2009 at 10:10 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I hope this will be a final bullet..
> I myself think this one is enough simple and good.
> I'm sorry that we need test again.
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
> Changelog v2->v3:
> =A0- removed retry_rmdir() callback.
> =A0- make use of CGRP_WAIT_ON_RMDIR flag more.
>
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/cgroup.h | =A0 13 +++++++++++++
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 38 ++++++++++++++++++++++--------=
--------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 25 +++++++++++++++++++++++--
> =A03 files changed, 58 insertions(+), 18 deletions(-)
>
> Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
> +++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
> @@ -366,6 +366,19 @@ int cgroup_task_count(const struct cgrou
> =A0int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct=
 *task);
>
> =A0/*
> + * Allow to use CGRP_WAIT_ON_RMDIR flag to check race with rmdir() for s=
ubsys.
> + * Subsys can call this function if it's necessary to call pre_destroy()=
 again
> + * because it adds not-temporary refs to css after or while pre_destroy(=
).
> + * The caller of this function should use css_tryget(), too.
> + */
> +void __cgroup_wakeup_rmdir_waiters(void);
> +static inline void cgroup_wakeup_rmdir_waiters(struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->=
flags)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __cgroup_wakeup_rmdir_waiters();
> +}
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
> @@ -734,14 +734,13 @@ static void cgroup_d_remove_dir(struct d
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
> +void __cgroup_wakeup_rmdir_waiters(void)
> =A0{

Maybe we should name this wakeup_rmdir_waiter() to emphasise that fact
that there will only be one waiter (the thread doing the rmdir).

> - =A0 =A0 =A0 if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_all(&cgroup_rmdir_waitq);
> + =A0 =A0 =A0 wake_up_all(&cgroup_rmdir_waitq);
> =A0}
>
> =A0static int rebind_subsystems(struct cgroupfs_root *root,
> @@ -2696,33 +2695,40 @@ again:
> =A0 =A0 =A0 =A0mutex_unlock(&cgroup_mutex);
>
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* css_put/get is provided for subsys to grab refcnt to c=
ss. In typical
> + =A0 =A0 =A0 =A0* case, subsystem has no reference after pre_destroy(). =
But, under
> + =A0 =A0 =A0 =A0* hierarchy management, some *temporal* refcnt can be ho=
ld.

This sentence needs improvement/clarification. (Yes, I know it's just
copied from later in the file, but it wasn't clear there either :-) )


> + =A0 =A0 =A0 =A0* To avoid returning -EBUSY to a user, waitqueue is used=
. If subsys
> + =A0 =A0 =A0 =A0* is really busy, it should return -EBUSY at pre_destroy=
(). wake_up
> + =A0 =A0 =A0 =A0* is called when css_put() is called and refcnt goes dow=
n to 0.
> + =A0 =A0 =A0 =A0* And this WAIT_ON_RMDIR flag is cleared when subsys det=
ect a race
> + =A0 =A0 =A0 =A0* condition under pre_destroy()->rmdir.

What exactly do you mean by pre_destroy()->rmdir ?

> If flag is cleared, we need
> + =A0 =A0 =A0 =A0* to call pre_destroy(), again.
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->fla=
gs))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();

The need for this test_bit() should be commented, I think - at first
sight it doesn't seem necessary since if we've already been woken up,
then the schedule() is logically a no-op anyway. We only need it
because we are worried about the case where someone calls
wakeup_rmdir_waiters() prior to the prepare_to_wait()


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
> + =A0 =A0 =A0 css_get(&ptr->css);
> =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
> =A0 =A0 =A0 =A0mem_cgroup_lru_del_before_commit_swapcache(page);
> =A0 =A0 =A0 =A0__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1484,7 +1491,13 @@ __mem_cgroup_commit_charge_swapin(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /* add this page(page_cgroup) to the LRU we want. */
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* At swapin, we may charge account against cgroup which =
has no tasks.
> + =A0 =A0 =A0 =A0* So, rmdir()->pre_destroy() can be called while we do t=
his charge.
> + =A0 =A0 =A0 =A0* In that case, we need to call pre_destroy() again. che=
ck it here.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cgroup_wakeup_rmdir_waiters(ptr->css.cgroup);
> + =A0 =A0 =A0 css_put(&ptr->css);
>
> =A0}
>
> @@ -1691,7 +1704,7 @@ void mem_cgroup_end_migration(struct mem
>
> =A0 =A0 =A0 =A0if (!mem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> -
> + =A0 =A0 =A0 css_get(&mem->css);
> =A0 =A0 =A0 =A0/* at migration success, oldpage->mapping is NULL. */
> =A0 =A0 =A0 =A0if (oldpage->mapping) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0target =3D oldpage;
> @@ -1731,6 +1744,14 @@ void mem_cgroup_end_migration(struct mem
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
> + =A0 =A0 =A0 cgroup_wakeup_rmdir_waiters(mem->css.cgroup);
> + =A0 =A0 =A0 css_put(&mem->css);

Having to do an extra get/put purely in order to seems unfortunate -
is that purely to force the cgroup_clear_css_refs() to fail?

Maybe we could wrap the get and the wakeup/put inside functions named
"cgroup_exclude_rmdir()" "cgroup_release_rmdir()" so that the mm
cgroup code is more self-explanatory.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
