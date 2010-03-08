Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 746866B0088
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 03:33:02 -0500 (EST)
Received: by wwg30 with SMTP id 30so2354606wwg.14
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 00:32:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100308162544.e7372b38.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100308162414.faaa9c5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100308162544.e7372b38.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 8 Mar 2010 10:32:59 +0200
Message-ID: <cc557aab1003080032u3451fb53u8ece3abf2d3f4852@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/2] memcg: oom notifier
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 8, 2010 at 9:25 AM, KAMEZAWA Hiroyuki
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

Nice idea!

But I don't think that sharing mem_cgroup_(un)register_event()
with thresholds is a good idea. There are too many
"if (type !=3D _OOM_TYPE)". Probably, it's cleaner to create separate
register/unregister for oom events, since oom event is quite different
from threshold. We, also, don't need RCU for oom events. It's not
a critical path.

> TODO:
> =C2=A0- add a knob to disable oom-kill under a memcg.
> =C2=A0- add read/write function to oom_control
>
> Changelog: 20100304
> =C2=A0- renewed implemnation.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0Documentation/cgroups/memory.txt | =C2=A0 20 ++++-
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0| =C2=A0155 ++++++++++++++++++++++++++++-----------
> =C2=A02 files changed, 131 insertions(+), 44 deletions(-)
>
> Index: mmotm-2.6.33-Mar5/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.33-Mar5.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Mar5/mm/memcontrol.c
> @@ -159,6 +159,7 @@ struct mem_cgroup_threshold_ary {
> =C2=A0};
>
> =C2=A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
> +static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
>
> =C2=A0/*
> =C2=A0* The memory controller data structure. The memory controller contr=
ols both
> @@ -220,6 +221,9 @@ struct mem_cgroup {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* thresholds for mem+swap usage. RCU-protecte=
d */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *memsw_thresho=
lds;
>
> + =C2=A0 =C2=A0 =C2=A0 /* For oom notifier event fd */
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *oom_notify;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Should we move charges of a task when a tas=
k is moved into this
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * mem_cgroup ? And what type of charges shoul=
d we move ?
> @@ -282,9 +286,12 @@ enum charge_type {
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
> @@ -1313,9 +1320,10 @@ bool mem_cgroup_handle_oom(struct mem_cg
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0prepare_to_wait(&m=
emcg_oom_waitq, &wait, TASK_KILLABLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&memcg_oom_mutex);
>
> - =C2=A0 =C2=A0 =C2=A0 if (locked)
> + =C2=A0 =C2=A0 =C2=A0 if (locked) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_oom_notify(=
mem);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mem_cgroup_out_of_=
memory(mem, mask);
> - =C2=A0 =C2=A0 =C2=A0 else {
> + =C2=A0 =C2=A0 =C2=A0 } else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0schedule();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0finish_wait(&memcg=
_oom_waitq, &wait);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -3363,33 +3371,65 @@ static int compare_thresholds(const void
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return _a->threshold - _b->threshold;
> =C2=A0}
>
> +static int mem_cgroup_oom_notify_cb(struct mem_cgroup *mem, void *data)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_threshold_ary *x;
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
> + =C2=A0 =C2=A0 =C2=A0 x =3D rcu_dereference(mem->oom_notify);
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; x && i < x->size; i++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(x->entr=
ies[i].eventfd, 1);
> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static void mem_cgroup_oom_notify(struct mem_cgroup *mem)
> +{
> + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_walk_tree(mem, NULL, mem_cgroup_oom_not=
ify_cb);
> +}
> +
> =C2=A0static int mem_cgroup_register_event(struct cgroup *cgrp, struct cf=
type *cft,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct eventfd_ctx=
 *eventfd, const char *args)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from_c=
ont(cgrp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *thresholds, *=
thresholds_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int type =3D MEMFILE_TYPE(cft->private);
> - =C2=A0 =C2=A0 =C2=A0 u64 threshold, usage;
> + =C2=A0 =C2=A0 =C2=A0 u64 threshold;
> + =C2=A0 =C2=A0 =C2=A0 u64 usage =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int size;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i, ret;
>
> - =C2=A0 =C2=A0 =C2=A0 ret =3D res_counter_memparse_write_strategy(args, =
&threshold);
> - =C2=A0 =C2=A0 =C2=A0 if (ret)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYPE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D res_counter_me=
mparse_write_strategy(args, &threshold);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ret)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 } else if (mem_cgroup_is_root(memcg)) /* root cgro=
up ? */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOTSUPP;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&memcg->thresholds_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
> + =C2=A0 =C2=A0 =C2=A0 /* For waiting OOM notify, "-1" is passed */
> +
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case _MEM:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds =3D mem=
cg->thresholds;
> - =C2=A0 =C2=A0 =C2=A0 else if (type =3D=3D _MEMSWAP)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _MEMSWAP:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds =3D mem=
cg->memsw_thresholds;
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _OOM_TYPE:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->=
oom_notify;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> + =C2=A0 =C2=A0 =C2=A0 }
>
> - =C2=A0 =C2=A0 =C2=A0 usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEM=
SWAP);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* Check if a threshold crossed before adding a ne=
w one */
> - =C2=A0 =C2=A0 =C2=A0 if (thresholds)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_threshold=
(memcg, type =3D=3D _MEMSWAP);
> + =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYPE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usage =3D mem_cgroup_u=
sage(memcg, type =3D=3D _MEMSWAP);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check if a threshol=
d crossed before adding a new one */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 __mem_cgroup_threshold(memcg, type =3D=3D _MEMSWAP);
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (thresholds)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size =3D threshold=
s->size + 1;
> @@ -3416,27 +3456,34 @@ static int mem_cgroup_register_event(str
> =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds_new->entries[size - 1].threshold =
=3D threshold;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Sort thresholds. Registering of new thresho=
ld isn't time-critical */
> - =C2=A0 =C2=A0 =C2=A0 sort(thresholds_new->entries, size,
> + =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYPE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sort(thresholds_new->e=
ntries, size,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0sizeof(struct mem_cgroup_threshold),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0compare_thresholds, NULL);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* Find current threshold */
> - =C2=A0 =C2=A0 =C2=A0 atomic_set(&thresholds_new->current_threshold, -1)=
;
> - =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < size; i++) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds_new->en=
tries[i].threshold < usage) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* thresholds_new->current_threshold will not be used
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* until rcu_assign_pointer(), so it's safe to increment
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* it here.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 atomic_inc(&thresholds_new->current_threshold);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Find current thresh=
old */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_set(&thresholds=
_new->current_threshold, -1);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < size=
; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (thresholds_new->entries[i].threshold < usage) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* thresholds_new->current_threshol=
d will not
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* be used until rcu_assign_pointer=
(), so it's
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* safe to increment it here.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&thresholds_new->current_thre=
shold);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> -
> - =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case _MEM:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointer=
(memcg->thresholds, thresholds_new);
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _MEMSWAP:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointer=
(memcg->memsw_thresholds, thresholds_new);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _OOM_TYPE:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(mem=
cg->oom_notify, thresholds_new);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* To be sure that nobody uses thresholds befo=
re freeing it */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0synchronize_rcu();
> @@ -3454,17 +3501,25 @@ static int mem_cgroup_unregister_event(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg =3D mem_cgroup_from_c=
ont(cgrp);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_threshold_ary *thresholds, *=
thresholds_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int type =3D MEMFILE_TYPE(cft->private);
> - =C2=A0 =C2=A0 =C2=A0 u64 usage;
> + =C2=A0 =C2=A0 =C2=A0 u64 usage =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int size =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i, j, ret;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_lock(&memcg->thresholds_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
> + =C2=A0 =C2=A0 =C2=A0 /* check eventfd is for OOM check or not */
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case _MEM:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds =3D mem=
cg->thresholds;
> - =C2=A0 =C2=A0 =C2=A0 else if (type =3D=3D _MEMSWAP)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _MEMSWAP:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds =3D mem=
cg->memsw_thresholds;
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _OOM_TYPE:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 thresholds =3D memcg->=
oom_notify;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 default:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Something went wrong if we trying to unregi=
ster a threshold
> @@ -3472,11 +3527,11 @@ static int mem_cgroup_unregister_event(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!thresholds);
>
> - =C2=A0 =C2=A0 =C2=A0 usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEM=
SWAP);
> -
> - =C2=A0 =C2=A0 =C2=A0 /* Check if a threshold crossed before removing */
> - =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_threshold(memcg, type =3D=3D _MEMSWAP=
);
> -
> + =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYPE) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usage =3D mem_cgroup_u=
sage(memcg, type =3D=3D _MEMSWAP);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Check if a threshol=
d crossed before removing */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mem_cgroup_threshold=
(memcg, type =3D=3D _MEMSWAP);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Calculate new number of threshold */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0; i < thresholds->size; i++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (thresholds->en=
tries[i].eventfd !=3D eventfd)
> @@ -3500,13 +3555,15 @@ static int mem_cgroup_unregister_event(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds_new->size =3D size;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Copy thresholds and find current threshold =
*/
> - =C2=A0 =C2=A0 =C2=A0 atomic_set(&thresholds_new->current_threshold, -1)=
;
> + =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYPE)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_set(&thresholds=
_new->current_threshold, -1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (i =3D 0, j =3D 0; i < thresholds->size; i=
++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (thresholds->en=
tries[i].eventfd =3D=3D eventfd)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0thresholds_new->en=
tries[j] =3D thresholds->entries[i];
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (thresholds_new->en=
tries[j].threshold < usage) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (type !=3D _OOM_TYP=
E &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 thresholds_new->entries[j].threshold < usage) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * thresholds_new->current_threshold will not be used
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 * until rcu_assign_pointer(), so it's safe to increment
> @@ -3518,11 +3575,17 @@ static int mem_cgroup_unregister_event(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0assign:
> - =C2=A0 =C2=A0 =C2=A0 if (type =3D=3D _MEM)
> + =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 case _MEM:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointer=
(memcg->thresholds, thresholds_new);
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _MEMSWAP:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_assign_pointer=
(memcg->memsw_thresholds, thresholds_new);
> -
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 case _OOM_TYPE:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_assign_pointer(mem=
cg->oom_notify, thresholds_new);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* To be sure that nobody uses thresholds befo=
re freeing it */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0synchronize_rcu();
>
> @@ -3588,6 +3651,12 @@ static struct cftype mem_cgroup_files[]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.read_u64 =3D mem_=
cgroup_move_charge_read,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.write_u64 =3D mem=
_cgroup_move_charge_write,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0},
> + =C2=A0 =C2=A0 =C2=A0 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .name =3D "oom_control=
",
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .register_event =3D me=
m_cgroup_register_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .unregister_event =3D =
mem_cgroup_unregister_event,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .private =3D MEMFILE_P=
RIVATE(_OOM_TYPE, OOM_CONTROL),
> + =C2=A0 =C2=A0 =C2=A0 },
> =C2=A0};
>
> =C2=A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> Index: mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.33-Mar5.orig/Documentation/cgroups/memory.txt
> +++ mmotm-2.6.33-Mar5/Documentation/cgroups/memory.txt
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
> @@ -486,7 +489,22 @@ threshold in any direction.
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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
