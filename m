Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B73E86B00A2
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 09:47:04 -0500 (EST)
Received: by fxm21 with SMTP id 21so114603fxm.11
        for <linux-mm@kvack.org>; Thu, 11 Mar 2010 06:47:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100311165700.4468ef2a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100311165315.c282d6d2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100311165700.4468ef2a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 11 Mar 2010 16:47:00 +0200
Message-ID: <cc557aab1003110647q1b70c9a0j73867c2c33dd28ce@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/3] memcg: oom notifier
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 11, 2010 at 9:57 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Considering containers or other resource management softwares in userland=
,
> event notification of OOM in memcg should be implemented.
> Now, memcg has "threshold" notifier which uses eventfd, we can make
> use of it for oom notification.
>
> This patch adds oom notification eventfd callback for memcg. The usage
> is very similar to threshold notifier, but control file is
> memory.oom_control and no arguments other than eventfd is required.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0% cgroup_event_notifier /cgroup/A/memory.oom_c=
ontrol dummy
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(About cgroup_event_notifier, see Documentatio=
n/cgroup/)
>
> TODO:
> =C2=A0- add a knob to disable oom-kill under a memcg.
> =C2=A0- add read/write function to oom_control
>
> Changelog: 20100309
> =C2=A0- splitted from threshold functions. use list rather than array.
> =C2=A0- moved all to inside of mutex.
> Changelog: 20100304
> =C2=A0- renewed implemenation.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks great! Two remarks below.

Reviewed-by: Kirill A. Shutemov <kirill@shutemov.name>

> ---
> =C2=A0Documentation/cgroups/memory.txt | =C2=A0 20 +++++++
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0105 ++++++++++++++++++++++++++++++++++++---
> =C2=A02 files changed, 116 insertions(+), 9 deletions(-)
>
> Index: mmotm-2.6.34-Mar9/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.34-Mar9.orig/mm/memcontrol.c
> +++ mmotm-2.6.34-Mar9/mm/memcontrol.c
> @@ -149,6 +149,7 @@ struct mem_cgroup_threshold {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0u64 threshold;
> =C2=A0};
>
> +/* For threshold */
> =C2=A0struct mem_cgroup_threshold_ary {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* An array index points to threshold just bel=
ow usage. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_t current_threshold;
> @@ -157,8 +158,14 @@ struct mem_cgroup_threshold_ary {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Array of thresholds */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold entries[0];
> =C2=A0};
> +/* for OOM */
> +struct mem_cgroup_eventfd_list {
> + =C2=A0 =C2=A0 =C2=A0 struct list_head list;
> + =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *eventfd;
> +};
>
> =C2=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
> +static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> =C2=A0/*
> =C2=A0* The memory controller data structure. The memory controller contr=
ols both
> @@ -220,6 +227,9 @@ struct mem_cgroup {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* thresholds for mem+swap usage. RCU-protecte=
d */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *memsw_thresho=
lds;
>
> + =C2=A0 =C2=A0 =C2=A0 /* For oom notifier event fd */
> + =C2=A0 =C2=A0 =C2=A0 struct list_head oom_notify;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Should we move charges of a task when a tas=
k is moved into this
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * mem_cgroup ? And what type of charges shoul=
d we move ?
> @@ -282,9 +292,12 @@ enum charge_type {
> =C2=A0/* for encoding cft->private value on file */
> =C2=A0#define _MEM =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 (0)
> =C2=A0#define _MEMSWAP =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (=
1)
> +#define _OOM_TYPE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(2)
> =C2=A0#define MEMFILE_PRIVATE(x, val) =C2=A0 =C2=A0 =C2=A0 =C2=A0(((x) <<=
 16) | (val))
> =C2=A0#define MEMFILE_TYPE(val) =C2=A0 =C2=A0 =C2=A0(((val) >> 16) & 0xff=
ff)
> =C2=A0#define MEMFILE_ATTR(val) =C2=A0 =C2=A0 =C2=A0((val) & 0xffff)
> +/* Used for OOM nofiier */
> +#define OOM_CONTROL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(0)
>
> =C2=A0/*
> =C2=A0* Reclaim flags for mem_cgroup_hierarchical_reclaim
> @@ -1351,6 +1364,8 @@ bool mem_cgroup_handle_oom(struct mem_cg
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!locked)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prepare_to_wait(&m=
emcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_oom_notify(=
mem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&memcg_oom_mutex);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (locked)
> @@ -3398,8 +3413,22 @@ static int compare_thresholds(const void
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return _a->threshold - _b->threshold;
> =C2=A0}
>
> -static int mem_cgroup_register_event(struct cgroup *cgrp, struct cftype =
*cft,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *ev=
entfd, const char *args)
> +static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_eventfd_list *ev;
> +
> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(ev, &mem->oom_notify, list)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(ev->eve=
ntfd, 1);
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
> +{
> + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_not=
ify_cb);
> +}
> +
> +static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, struct eventfd_ctx *eventfd, c=
onst char *args)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from_c=
ont(cgrp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *thresholds, *=
thresholds_new;
> @@ -3483,8 +3512,8 @@ unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> -static int mem_cgroup_unregister_event(struct cgroup *cgrp, struct cftyp=
e *cft,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct eventfd_ctx *ev=
entfd)
> +static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, struct eventfd_ctx *eventfd)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from_c=
ont(cgrp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *thresholds, *=
thresholds_new;
> @@ -3568,13 +3597,66 @@ unlock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> +static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, struct eventfd_ctx *eventfd, c=
onst char *args)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *memcg =3D mem_cgroup_from_cont(=
cgrp);
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_eventfd_list *event;
> + =C2=A0 =C2=A0 =C2=A0 int type =3D MEMFILE_TYPE(cft->private);
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D -ENOMEM;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(type !=3D _OOM_TYPE);
> +
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&memcg_oom_mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Allocate memory for new array of thresholds */

Irrelevant comment?

> + =C2=A0 =C2=A0 =C2=A0 event =3D kmalloc(sizeof(*event), GFP_KERNEL);
> + =C2=A0 =C2=A0 =C2=A0 if (!event)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
> + =C2=A0 =C2=A0 =C2=A0 /* Add new threshold */

Ditto.

> + =C2=A0 =C2=A0 =C2=A0 event->eventfd =3D eventfd;
> + =C2=A0 =C2=A0 =C2=A0 list_add(&event->list, &memcg->oom_notify);
> +
> + =C2=A0 =C2=A0 =C2=A0 /* already in OOM ? */
> + =C2=A0 =C2=A0 =C2=A0 if (atomic_read(&memcg->oom_lock))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(eventfd=
, 1);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +unlock:
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&memcg_oom_mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
> + =C2=A0 =C2=A0 =C2=A0 struct cftype *cft, struct eventfd_ctx *eventfd)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *mem =3D mem_cgroup_from_cont(cg=
rp);
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_eventfd_list *ev, *tmp;
> + =C2=A0 =C2=A0 =C2=A0 int type =3D MEMFILE_TYPE(cft->private);
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(type !=3D _OOM_TYPE);
> +
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&memcg_oom_mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(ev, tmp, &mem->oom_notify=
, list) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ev->eventfd =3D=3D=
 eventfd) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 list_del(&ev->list);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kfree(ev);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&memcg_oom_mutex);
> +
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> =C2=A0static struct cftype mem_cgroup_files[] =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "usage_i=
n_bytes",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.private =3D MEMFI=
LE_PRIVATE(_MEM, RES_USAGE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_read,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_register_event,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_unregister_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_usage_register_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_usage_unregister_event,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "max_usa=
ge_in_bytes",
> @@ -3623,6 +3705,12 @@ static struct cftype mem_cgroup_files[]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_move_charge_read,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_move_charge_write,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "oom_control=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_oom_register_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_oom_unregister_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEMFILE_P=
RIVATE(_OOM_TYPE, OOM_CONTROL),
> + =C2=A0 =C2=A0 =C2=A0 },
> =C2=A0};
>
> =C2=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -3631,8 +3719,8 @@ static struct cftype memsw_cgroup_files[
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "memsw.u=
sage_in_bytes",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.private =3D MEMFI=
LE_PRIVATE(_MEMSWAP, RES_USAGE),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_read,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_register_event,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_unregister_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_usage_register_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_usage_unregister_event,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> =C2=A0 =C2=A0 =C2=A0 =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.name =3D "memsw.m=
ax_usage_in_bytes",
> @@ -3876,6 +3964,7 @@ mem_cgroup_create(struct cgroup_subsys *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->last_scanned_child =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(&mem->reclaim_param_lock);
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mem->oom_notify);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (parent)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem->swappiness =
=3D get_swappiness(parent);
> Index: mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.34-Mar9.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.34-Mar9/Documentation/cgroups/memory.txt
> @@ -184,6 +184,9 @@ limits on the root cgroup.
>
> =C2=A0Note2: When panic_on_oom is set to "2", the whole system will panic=
.
>
> +When oom event notifier is registered, event will be delivered.
> +(See oom_control section)
> +
> =C2=A02. Locking
>
> =C2=A0The memory controller uses the following hierarchy
> @@ -488,7 +491,22 @@ threshold in any direction.
>
> =C2=A0It's applicable for root and non-root cgroup.
>
> -10. TODO
> +10. OOM Control
> +
> +Memory controler implements oom notifier using cgroup notification
> +API (See cgroups.txt). It allows to register multiple oom notification
> +delivery and gets notification when oom happens.
> +
> +To register a notifier, application need:
> + - create an eventfd using eventfd(2)
> + - open memory.oom_control file
> + - write string like "<event_fd> <memory.oom_control>" to cgroup.event_c=
ontrol
> +
> +Application will be notifier through eventfd when oom happens.
> +OOM notification doesn't work for root cgroup.
> +
> +
> +11. TODO
>
> =C2=A01. Add support for accounting huge pages (as a separate controller)
> =C2=A02. Make per-cgroup scanner reclaim not-shared pages first
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
