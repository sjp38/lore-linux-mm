Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F22C06B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 05:14:44 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n5U9F64U010018
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:15:06 -0700
Received: from yxe27 (yxe27.prod.google.com [10.190.2.27])
	by zps37.corp.google.com with ESMTP id n5U9F3OK008980
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:15:04 -0700
Received: by yxe27 with SMTP id 27so2554957yxe.0
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:15:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090630180344.d7274644.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 30 Jun 2009 02:15:03 -0700
Message-ID: <6599ad830906300215q56bda5ccnc99862211dc65289@mail.gmail.com>
Subject: Re: [PATCH 2/2] cgroup: exlclude release rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 2:03 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Paul Menage pointed out that css_get()/put() only for avoiding race with
> rmdir() is complicated and these should be treated as it is for.
>
> This adds
> =A0 - cgroup_exclude_rmdir() ....prevent rmdir() for a while.
> =A0 - cgroup_release_rmdir() ....rerun rmdir() if necessary.
> And hides cgroup_wakeup_rmdir_waiter() into kernel/cgroup.c, again.

Wouldn't it be better to merge these into a single patch? Having one
patch that exposes complexity only to take it away in the following
patch seems unnecessary; the combined patch would be simpler than the
constituents.

Paul

>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
> =A0include/linux/cgroup.h | =A0 21 +++++++++++----------
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 17 +++++++++++++++--
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0| =A0 12 ++++--------
> =A03 files changed, 30 insertions(+), 20 deletions(-)
>
> Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
> +++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
> @@ -366,17 +366,18 @@ int cgroup_task_count(const struct cgrou
> =A0int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct=
 *task);
>
> =A0/*
> - * Allow to use CGRP_WAIT_ON_RMDIR flag to check race with rmdir() for s=
ubsys.
> - * Subsys can call this function if it's necessary to call pre_destroy()=
 again
> - * because it adds not-temporary refs to css after or while pre_destroy(=
).
> - * The caller of this function should use css_tryget(), too.
> + * When the subsys has to access css and may add permanent refcnt to css=
,
> + * it should take care of racy conditions with rmdir(). Following set of
> + * functions, is for stop/restart rmdir if necessary.
> + * Because these will call css_get/put, "css" should be alive css.
> + *
> + * =A0cgroup_exclude_rmdir();
> + * =A0...do some jobs which may access arbitrary empty cgroup
> + * =A0cgroup_release_rmdir();
> =A0*/
> -void __cgroup_wakeup_rmdir_waiters(void);
> -static inline void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> -{
> - =A0 =A0 =A0 if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->=
flags)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __cgroup_wakeup_rmdir_waiters();
> -}
> +
> +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
> +void cgroup_release_rmdir(struct cgroup_subsys_state *css);
>
> =A0/*
> =A0* Control Group subsystem type.
> Index: mmotm-2.6.31-Jun25/kernel/cgroup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/kernel/cgroup.c
> +++ mmotm-2.6.31-Jun25/kernel/cgroup.c
> @@ -738,11 +738,24 @@ static void cgroup_d_remove_dir(struct d
> =A0*/
> =A0DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
>
> -void __cgroup_wakeup_rmdir_waiters(void)
> +static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
> =A0{
> - =A0 =A0 =A0 wake_up_all(&cgroup_rmdir_waitq);
> + =A0 =A0 =A0 if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->=
flags)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_all(&cgroup_rmdir_waitq);
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
> Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> @@ -1461,7 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> =A0 =A0 =A0 =A0if (!ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 css_get(&ptr->css);
> + =A0 =A0 =A0 cgroup_exclude_rmdir(&ptr->css);
> =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
> =A0 =A0 =A0 =A0mem_cgroup_lru_del_before_commit_swapcache(page);
> =A0 =A0 =A0 =A0__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1496,9 +1496,7 @@ __mem_cgroup_commit_charge_swapin(struct
> =A0 =A0 =A0 =A0 * So, rmdir()->pre_destroy() can be called while we do th=
is charge.
> =A0 =A0 =A0 =A0 * In that case, we need to call pre_destroy() again. chec=
k it here.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(ptr->css.cgroup);
> - =A0 =A0 =A0 css_put(&ptr->css);
> -
> + =A0 =A0 =A0 cgroup_release_rmdir(&ptr->css);
> =A0}
>
> =A0void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgr=
oup *ptr)
> @@ -1704,7 +1702,7 @@ void mem_cgroup_end_migration(struct mem
>
> =A0 =A0 =A0 =A0if (!mem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> - =A0 =A0 =A0 css_get(&mem->css);
> + =A0 =A0 =A0 cgroup_exclude_rmdir(&mem->css);
> =A0 =A0 =A0 =A0/* at migration success, oldpage->mapping is NULL. */
> =A0 =A0 =A0 =A0if (oldpage->mapping) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0target =3D oldpage;
> @@ -1749,9 +1747,7 @@ void mem_cgroup_end_migration(struct mem
> =A0 =A0 =A0 =A0 * So, rmdir()->pre_destroy() can be called while we do th=
is charge.
> =A0 =A0 =A0 =A0 * In that case, we need to call pre_destroy() again. chec=
k it here.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(mem->css.cgroup);
> - =A0 =A0 =A0 css_put(&mem->css);
> -
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
