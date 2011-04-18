Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31EBD900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 20:57:24 -0400 (EDT)
Received: by iyh42 with SMTP id 42so5247612iyh.14
        for <linux-mm@kvack.org>; Sun, 17 Apr 2011 17:57:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1302909815-4362-2-git-send-email-yinghan@google.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-2-git-send-email-yinghan@google.com>
Date: Mon, 18 Apr 2011 09:57:18 +0900
Message-ID: <BANLkTikgoSt4VUY63J+G6mUJJDCL+NWH8Q@mail.gmail.com>
Subject: Re: [PATCH V5 01/10] Add kswapd descriptor
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Hi Ying,

I have some comments and nitpick about coding style.

On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
> There is a kswapd kernel thread for each numa node. We will add a differe=
nt
> kswapd for each memcg. The kswapd is sleeping in the wait queue headed at

Why?

Easily, many kernel developers raise an eyebrow to increase kernel thread.
So you should justify why we need new kernel thread, why we can't
handle it with workqueue.

Maybe you explained it and I didn't know it. If it is, sorry.
But at least, the patch description included _why_ is much mergeable
to maintainers and helpful to review the code to reviewers.

> kswapd_wait field of a kswapd descriptor. The kswapd descriptor stores
> information of node or memcg and it allows the global and per-memcg backg=
round
> reclaim to share common reclaim algorithms.
>
> This patch adds the kswapd descriptor and moves the per-node kswapd to us=
e the
> new structure.
>
> changelog v5..v4:
> 1. add comment on kswapds_spinlock
> 2. remove the kswapds_spinlock. we don't need it here since the kswapd an=
d pgdat
> have 1:1 mapping.
>
> changelog v3..v2:
> 1. move the struct mem_cgroup *kswapd_mem in kswapd sruct to later patch.
> 2. rename thr in kswapd_run to something else.
>
> changelog v2..v1:
> 1. dynamic allocate kswapd descriptor and initialize the wait_queue_head =
of pgdat
> at kswapd_run.
> 2. add helper macro is_node_kswapd to distinguish per-node/per-cgroup ksw=
apd
> descriptor.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0include/linux/mmzone.h | =C2=A0 =C2=A03 +-
> =C2=A0include/linux/swap.h =C2=A0 | =C2=A0 =C2=A07 ++++
> =C2=A0mm/page_alloc.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 -
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 89 ++=
+++++++++++++++++++++++++++++++++------------
> =C2=A04 files changed, 74 insertions(+), 26 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 628f07b..6cba7d2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -640,8 +640,7 @@ typedef struct pglist_data {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long node_spanned_pages; /* total siz=
e of physical page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 range, including holes */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int node_id;
> - =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t kswapd_wait;
> - =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *kswapd_wait;

Personally, I prefer kswapd not kswapd_wait.
It's more readable and straightforward.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0int kswapd_max_order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0enum zone_type classzone_idx;
> =C2=A0} pg_data_t;
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index ed6ebe6..f43d406 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -26,6 +26,13 @@ static inline int current_is_kswapd(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return current->flags & PF_KSWAPD;
> =C2=A0}
>
> +struct kswapd {
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd_task;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t kswapd_wait;
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *kswapd_pgdat;
> +};
> +
> +int kswapd(void *p);
> =C2=A0/*
> =C2=A0* MAX_SWAPFILES defines the maximum number of swaptypes: things whi=
ch can
> =C2=A0* be swapped to. =C2=A0The swap type and the offset into that swap =
type are
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6e1b52a..6340865 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4205,7 +4205,6 @@ static void __paginginit free_area_init_core(struct=
 pglist_data *pgdat,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat_resize_init(pgdat);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->nr_zones =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 init_waitqueue_head(&pgdat->kswapd_wait);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->kswapd_max_order =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat_page_cgroup_init(pgdat);
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 060e4c1..61fb96e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2242,12 +2242,13 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsi=
gned long balanced_pages,
> =C2=A0}
>
> =C2=A0/* is kswapd sleeping prematurely? */
> -static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remai=
ning,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int classzon=
e_idx)
> +static int sleeping_prematurely(struct kswapd *kswapd, int order,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 long remaining, int classzone_idx)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int i;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long balanced =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool all_zones_ok =3D true;
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D kswapd->kswapd_pgdat;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* If a direct reclaimer woke kswapd within HZ=
/10, it's premature */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (remaining)
> @@ -2570,28 +2571,31 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return order;
> =C2=A0}
>
> -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order, int classzo=
ne_idx)
> +static void kswapd_try_to_sleep(struct kswapd *kswapd_p, int order,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int classzone_idx)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0long remaining =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0DEFINE_WAIT(wait);
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D kswapd_p->kswapd_pgdat;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wait_h =3D &kswapd_p->kswapd_wa=
it;

kswapd_p? p means pointer?
wait_h? h means header?
Hmm.. Of course, it's trivial and we can understand easily in such
context but we don't have been used such words so it's rather awkward
to me.

How about kswapd instead of kswapd_p, kswapd_wait instead of wait_h?

>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (freezing(current) || kthread_should_stop()=
)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> - =C2=A0 =C2=A0 =C2=A0 prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_I=
NTERRUPTIBLE);
> + =C2=A0 =C2=A0 =C2=A0 prepare_to_wait(wait_h, &wait, TASK_INTERRUPTIBLE)=
;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Try to sleep for a short interval */
> - =C2=A0 =C2=A0 =C2=A0 if (!sleeping_prematurely(pgdat, order, remaining,=
 classzone_idx)) {
> + =C2=A0 =C2=A0 =C2=A0 if (!sleeping_prematurely(kswapd_p, order, remaini=
ng, classzone_idx)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remaining =3D sche=
dule_timeout(HZ/10);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 finish_wait(&pgdat->ks=
wapd_wait, &wait);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prepare_to_wait(&pgdat=
->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 finish_wait(wait_h, &w=
ait);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 prepare_to_wait(wait_h=
, &wait, TASK_INTERRUPTIBLE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * After a short sleep, check if it was a prem=
ature sleep. If not, then
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * go fully to sleep until explicitly woken up=
.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (!sleeping_prematurely(pgdat, order, remaining,=
 classzone_idx)) {
> + =C2=A0 =C2=A0 =C2=A0 if (!sleeping_prematurely(kswapd_p, order, remaini=
ng, classzone_idx)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0trace_mm_vmscan_ks=
wapd_sleep(pgdat->node_id);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -2611,7 +2615,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, i=
nt order, int classzone_idx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 finish_wait(&pgdat->kswapd_wait, &wait);
> + =C2=A0 =C2=A0 =C2=A0 finish_wait(wait_h, &wait);
> =C2=A0}
>
> =C2=A0/*
> @@ -2627,20 +2631,24 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat,=
 int order, int classzone_idx)
> =C2=A0* If there are applications that are active memory-allocators
> =C2=A0* (most normal use), this basically shouldn't matter.
> =C2=A0*/
> -static int kswapd(void *p)
> +int kswapd(void *p)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int classzone_idx;
> - =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D (pg_data_t*)p;
> + =C2=A0 =C2=A0 =C2=A0 struct kswapd *kswapd_p =3D (struct kswapd *)p;
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D kswapd_p->kswapd_pgdat;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wait_h =3D &kswapd_p->kswapd_wa=
it;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *tsk =3D current;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct reclaim_state reclaim_state =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0.reclaimed_slab =
=3D 0,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0};
> - =C2=A0 =C2=A0 =C2=A0 const struct cpumask *cpumask =3D cpumask_of_node(=
pgdat->node_id);
> + =C2=A0 =C2=A0 =C2=A0 const struct cpumask *cpumask;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lockdep_set_current_reclaim_state(GFP_KERNEL);
>
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(pgdat->kswapd_wait !=3D wait_h);

If we include kswapd instead of kswapd_wait in pgdat, maybe we could
remove the check?

> + =C2=A0 =C2=A0 =C2=A0 cpumask =3D cpumask_of_node(pgdat->node_id);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cpumask_empty(cpumask))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_cpus_allowed_p=
tr(tsk, cpumask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0current->reclaim_state =3D &reclaim_state;
> @@ -2679,7 +2687,7 @@ static int kswapd(void *p)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0order =3D new_order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0classzone_idx =3D new_classzone_idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kswapd_try_to_sleep(pgdat, order, classzone_idx);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kswapd_try_to_sleep(kswapd_p, order, classzone_idx);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0order =3D pgdat->kswapd_max_order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0classzone_idx =3D pgdat->classzone_idx;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pgdat->kswapd_max_order =3D 0;
> @@ -2719,13 +2727,13 @@ void wakeup_kswapd(struct zone *zone, int order, =
enum zone_type classzone_idx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->kswapd_max_=
order =3D order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pgdat->classzone_i=
dx =3D min(pgdat->classzone_idx, classzone_idx);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 if (!waitqueue_active(&pgdat->kswapd_wait))
> + =C2=A0 =C2=A0 =C2=A0 if (!waitqueue_active(pgdat->kswapd_wait))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone_watermark_ok_safe(zone, order, low_wm=
ark_pages(zone), 0, 0))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, =
zone_idx(zone), order);
> - =C2=A0 =C2=A0 =C2=A0 wake_up_interruptible(&pgdat->kswapd_wait);
> + =C2=A0 =C2=A0 =C2=A0 wake_up_interruptible(pgdat->kswapd_wait);
> =C2=A0}
>
> =C2=A0/*
> @@ -2817,12 +2825,21 @@ static int __devinit cpu_callback(struct notifier=
_block *nfb,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for_each_node_stat=
e(nid, N_HIGH_MEMORY) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0pg_data_t *pgdat =3D NODE_DATA(nid);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0const struct cpumask *mask;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct kswapd *kswapd_p;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct task_struct *kswapd_thr;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 wait_queue_head_t *wait;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0mask =3D cpumask_of_node(pgdat->node_id);
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 wait =3D pgdat->kswapd_wait;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kswapd_p =3D container_of(wait, struct kswapd,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 kswapd_wait);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kswapd_thr =3D kswapd_p->kswapd_task;

kswapd_thr? thr means thread?
How about tsk?

> +
If we include kswapd instead of kswapd_wait in pgdat, don't we make this si=
mple?

struct kswapd *kswapd =3D pgdat->kswapd;
struct task_struct *kswapd_tsk =3D kswapd->kswapd_task;


> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* One of our CPUs online: restore ma=
sk */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 set_cpus_allowed_ptr(pgdat->kswapd, mask=
);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (kswapd_thr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 set_cpus_all=
owed_ptr(kswapd_thr, mask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return NOTIFY_OK;
> @@ -2835,18 +2852,31 @@ static int __devinit cpu_callback(struct notifier=
_block *nfb,
> =C2=A0int kswapd_run(int nid)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pg_data_t *pgdat =3D NODE_DATA(nid);
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd_thr;
> + =C2=A0 =C2=A0 =C2=A0 struct kswapd *kswapd_p;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D 0;
>
> - =C2=A0 =C2=A0 =C2=A0 if (pgdat->kswapd)
> + =C2=A0 =C2=A0 =C2=A0 if (pgdat->kswapd_wait)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> - =C2=A0 =C2=A0 =C2=A0 pgdat->kswapd =3D kthread_run(kswapd, pgdat, "kswa=
pd%d", nid);
> - =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(pgdat->kswapd)) {
> + =C2=A0 =C2=A0 =C2=A0 kswapd_p =3D kzalloc(sizeof(struct kswapd), GFP_KE=
RNEL);
> + =C2=A0 =C2=A0 =C2=A0 if (!kswapd_p)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> +
> + =C2=A0 =C2=A0 =C2=A0 init_waitqueue_head(&kswapd_p->kswapd_wait);
> + =C2=A0 =C2=A0 =C2=A0 pgdat->kswapd_wait =3D &kswapd_p->kswapd_wait;
> + =C2=A0 =C2=A0 =C2=A0 kswapd_p->kswapd_pgdat =3D pgdat;
> +
> + =C2=A0 =C2=A0 =C2=A0 kswapd_thr =3D kthread_run(kswapd, kswapd_p, "kswa=
pd%d", nid);
> + =C2=A0 =C2=A0 =C2=A0 if (IS_ERR(kswapd_thr)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* failure at boot=
 is fatal */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(system_stat=
e =3D=3D SYSTEM_BOOTING);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk("Failed to =
start kswapd on node %d\n",nid);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgdat->kswapd_wait =3D=
 NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(kswapd_p);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D -1;
> - =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd_p->kswapd_task =
=3D kswapd_thr;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
> @@ -2855,10 +2885,23 @@ int kswapd_run(int nid)
> =C2=A0*/
> =C2=A0void kswapd_stop(int nid)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd =3D NODE_DATA(nid)->ksw=
apd;
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *kswapd_thr =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 struct kswapd *kswapd_p =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 wait_queue_head_t *wait;
> +
> + =C2=A0 =C2=A0 =C2=A0 pg_data_t *pgdat =3D NODE_DATA(nid);
> +
> + =C2=A0 =C2=A0 =C2=A0 wait =3D pgdat->kswapd_wait;
> + =C2=A0 =C2=A0 =C2=A0 if (wait) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd_p =3D container=
_of(wait, struct kswapd, kswapd_wait);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd_thr =3D kswapd_=
p->kswapd_task;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kswapd_p->kswapd_task =
=3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 if (kswapd_thr)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kthread_stop(kswapd_th=
r);
>
> - =C2=A0 =C2=A0 =C2=A0 if (kswapd)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kthread_stop(kswapd);
> + =C2=A0 =C2=A0 =C2=A0 kfree(kswapd_p);
> =C2=A0}
>
> =C2=A0static int __init kswapd_init(void)
> --
> 1.7.3.1
>
>

Hmm, I don't like kswapd_p, kswapd_thr, wait_h and kswapd_wait of pgdat.
But it's just my personal opinion. :)


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
