Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D0476002CC
	for <linux-mm@kvack.org>; Mon, 17 May 2010 16:17:56 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o4HKHp0o031303
	for <linux-mm@kvack.org>; Mon, 17 May 2010 13:17:52 -0700
Received: from gwj20 (gwj20.prod.google.com [10.200.10.20])
	by hpaq11.eem.corp.google.com with ESMTP id o4HKHm8m021124
	for <linux-mm@kvack.org>; Mon, 17 May 2010 13:17:50 -0700
Received: by gwj20 with SMTP id 20so1585802gwj.11
        for <linux-mm@kvack.org>; Mon, 17 May 2010 13:17:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1273363872-8031-1-git-send-email-kirill@shutemov.name>
References: <1273363872-8031-1-git-send-email-kirill@shutemov.name>
Date: Mon, 17 May 2010 13:17:47 -0700
Message-ID: <AANLkTilPPYOQ62mzDA4ttrXnkwxN1sYZWK0M871x4Eso@mail.gmail.com>
Subject: Re: [RFC] [PATCH] memcg: cleanup memory thresholds
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, May 8, 2010 at 5:11 PM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
> Introduce struct mem_cgroup_thresholds. It helps to reduce number of
> checks of thresholds type (memory or mem+swap).
>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Acked-by: Paul Menage <menage@google.com>

Thanks,
Paul

> ---
> =A0mm/memcontrol.c | =A0151 ++++++++++++++++++++++++---------------------=
----------
> =A01 files changed, 66 insertions(+), 85 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a6d2a4c..a6c6268 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -158,6 +158,18 @@ struct mem_cgroup_threshold_ary {
> =A0 =A0 =A0 =A0/* Array of thresholds */
> =A0 =A0 =A0 =A0struct mem_cgroup_threshold entries[0];
> =A0};
> +
> +struct mem_cgroup_thresholds {
> + =A0 =A0 =A0 /* Primary thresholds array */
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *primary;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Spare threshold array.
> + =A0 =A0 =A0 =A0* It needed to make mem_cgroup_unregister_event() "never=
 fail".
> + =A0 =A0 =A0 =A0* It must be able to store at least primary->size - 1 en=
tires.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *spare;
> +};
> +
> =A0/* for OOM */
> =A0struct mem_cgroup_eventfd_list {
> =A0 =A0 =A0 =A0struct list_head list;
> @@ -224,20 +236,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0struct mutex thresholds_lock;
>
> =A0 =A0 =A0 =A0/* thresholds for memory usage. RCU-protected */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds;
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Preallocated buffer to be used in mem_cgroup_unregiste=
r_event()
> - =A0 =A0 =A0 =A0* to make it "never fail".
> - =A0 =A0 =A0 =A0* It must be able to store at least thresholds->size - 1=
 entries.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds thresholds;
>
> =A0 =A0 =A0 =A0/* thresholds for mem+swap usage. RCU-protected */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *memsw_thresholds;
> -
> - =A0 =A0 =A0 /* the same as __thresholds, but for memsw_thresholds */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__memsw_thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds memsw_thresholds;
>
> =A0 =A0 =A0 =A0/* For oom notifier event fd */
> =A0 =A0 =A0 =A0struct list_head oom_notify;
> @@ -3438,9 +3440,9 @@ static void __mem_cgroup_threshold(struct mem_cgrou=
p *memcg, bool swap)
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0if (!swap)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->thresholds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->thresholds.pri=
mary);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->memsw_threshol=
ds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->memsw_threshol=
ds.primary);
>
> =A0 =A0 =A0 =A0if (!t)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unlock;
> @@ -3514,91 +3516,78 @@ static int mem_cgroup_usage_register_event(struct=
 cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd, const cha=
r *args)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds_ne=
w;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds *thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *new;
> =A0 =A0 =A0 =A0int type =3D MEMFILE_TYPE(cft->private);
> =A0 =A0 =A0 =A0u64 threshold, usage;
> - =A0 =A0 =A0 int size;
> - =A0 =A0 =A0 int i, ret;
> + =A0 =A0 =A0 int i, size, ret;
>
> =A0 =A0 =A0 =A0ret =3D res_counter_memparse_write_strategy(args, &thresho=
ld);
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> =A0 =A0 =A0 =A0mutex_lock(&memcg->thresholds_lock);
> +
> =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->thresholds;
> =A0 =A0 =A0 =A0else if (type =3D=3D _MEMSWAP)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->memsw_thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->memsw_thresholds;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> =A0 =A0 =A0 =A0usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEMSWAP);
>
> =A0 =A0 =A0 =A0/* Check if a threshold crossed before adding a new one */
> - =A0 =A0 =A0 if (thresholds)
> + =A0 =A0 =A0 if (thresholds->primary)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_threshold(memcg, type =3D=3D =
_MEMSWAP);
>
> - =A0 =A0 =A0 if (thresholds)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D thresholds->size + 1;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D 1;
> + =A0 =A0 =A0 size =3D thresholds->primary ? thresholds->primary->size + =
1 : 1;
>
> =A0 =A0 =A0 =A0/* Allocate memory for new array of thresholds */
> - =A0 =A0 =A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new) +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size * sizeof(struct mem_cg=
roup_threshold),
> + =A0 =A0 =A0 new =3D kmalloc(sizeof(*new) + size * sizeof(struct mem_cgr=
oup_threshold),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_KERNEL);
> - =A0 =A0 =A0 if (!thresholds_new) {
> + =A0 =A0 =A0 if (!new) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unlock;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 thresholds_new->size =3D size;
> + =A0 =A0 =A0 new->size =3D size;
>
> =A0 =A0 =A0 =A0/* Copy thresholds (if any) to new array */
> - =A0 =A0 =A0 if (thresholds)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(thresholds_new->entries, thresholds-=
>entries,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds-=
>size *
> + =A0 =A0 =A0 if (thresholds->primary) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new->entries, thresholds->primary->e=
ntries, (size - 1) *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(str=
uct mem_cgroup_threshold));
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Add new threshold */
> - =A0 =A0 =A0 thresholds_new->entries[size - 1].eventfd =3D eventfd;
> - =A0 =A0 =A0 thresholds_new->entries[size - 1].threshold =3D threshold;
> + =A0 =A0 =A0 new->entries[size - 1].eventfd =3D eventfd;
> + =A0 =A0 =A0 new->entries[size - 1].threshold =3D threshold;
>
> =A0 =A0 =A0 =A0/* Sort thresholds. Registering of new threshold isn't tim=
e-critical */
> - =A0 =A0 =A0 sort(thresholds_new->entries, size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct mem_cgroup_th=
reshold),
> + =A0 =A0 =A0 sort(new->entries, size, sizeof(struct mem_cgroup_threshold=
),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compare_thresholds, NULL);
>
> =A0 =A0 =A0 =A0/* Find current threshold */
> - =A0 =A0 =A0 thresholds_new->current_threshold =3D -1;
> + =A0 =A0 =A0 new->current_threshold =3D -1;
> =A0 =A0 =A0 =A0for (i =3D 0; i < size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds_new->entries[i].threshold < =
usage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new->entries[i].threshold < usage) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* thresholds_new->curren=
t_threshold will not be used
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* until rcu_assign_point=
er(), so it's safe to increment
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* new->current_threshold=
 will not be used until
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rcu_assign_pointer(), =
so it's safe to increment
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * it here.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++thresholds_new->current_t=
hreshold;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++new->current_threshold;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->thresholds, thres=
holds_new);
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->memsw_thresholds,=
 thresholds_new);
> + =A0 =A0 =A0 /* Free old spare buffer and save old primary buffer as spa=
re */
> + =A0 =A0 =A0 kfree(thresholds->spare);
> + =A0 =A0 =A0 thresholds->spare =3D thresholds->primary;
> +
> + =A0 =A0 =A0 rcu_assign_pointer(thresholds->primary, new);
>
> =A0 =A0 =A0 =A0/* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Free old preallocated buffer and use thresholds as new
> - =A0 =A0 =A0 =A0* preallocated buffer.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (type =3D=3D _MEM) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__thresholds);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__memsw_thresholds);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> - =A0 =A0 =A0 }
> =A0unlock:
> =A0 =A0 =A0 =A0mutex_unlock(&memcg->thresholds_lock);
>
> @@ -3609,17 +3598,17 @@ static void mem_cgroup_usage_unregister_event(str=
uct cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds_ne=
w;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds *thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *new;
> =A0 =A0 =A0 =A0int type =3D MEMFILE_TYPE(cft->private);
> =A0 =A0 =A0 =A0u64 usage;
> - =A0 =A0 =A0 int size =3D 0;
> - =A0 =A0 =A0 int i, j;
> + =A0 =A0 =A0 int i, j, size;
>
> =A0 =A0 =A0 =A0mutex_lock(&memcg->thresholds_lock);
> =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->thresholds;
> =A0 =A0 =A0 =A0else if (type =3D=3D _MEMSWAP)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->memsw_thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->memsw_thresholds;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> @@ -3635,53 +3624,45 @@ static void mem_cgroup_usage_unregister_event(str=
uct cgroup *cgrp,
> =A0 =A0 =A0 =A0__mem_cgroup_threshold(memcg, type =3D=3D _MEMSWAP);
>
> =A0 =A0 =A0 =A0/* Calculate new number of threshold */
> - =A0 =A0 =A0 for (i =3D 0; i < thresholds->size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->entries[i].eventfd !=3D eve=
ntfd)
> + =A0 =A0 =A0 size =3D 0;
> + =A0 =A0 =A0 for (i =3D 0; i < thresholds->primary->size; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->primary->entries[i].eventfd=
 !=3D eventfd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size++;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Use preallocated buffer for new array of thresholds */
> - =A0 =A0 =A0 if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__thresholds;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__memsw_threshold=
s;
> + =A0 =A0 =A0 new =3D thresholds->spare;
>
> =A0 =A0 =A0 =A0/* Set thresholds array to NULL if we don't have threshold=
s */
> =A0 =A0 =A0 =A0if (!size) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(thresholds_new);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(new);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto swap_buffers;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 thresholds_new->size =3D size;
> + =A0 =A0 =A0 new->size =3D size;
>
> =A0 =A0 =A0 =A0/* Copy thresholds and find current threshold */
> - =A0 =A0 =A0 thresholds_new->current_threshold =3D -1;
> - =A0 =A0 =A0 for (i =3D 0, j =3D 0; i < thresholds->size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->entries[i].eventfd =3D=3D e=
ventfd)
> + =A0 =A0 =A0 new->current_threshold =3D -1;
> + =A0 =A0 =A0 for (i =3D 0, j =3D 0; i < thresholds->primary->size; i++) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->primary->entries[i].eventfd=
 =3D=3D eventfd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new->entries[j] =3D thresholds->=
entries[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds_new->entries[j].threshold < =
usage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->entries[j] =3D thresholds->primary->en=
tries[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new->entries[j].threshold < usage) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* thresholds_new->curren=
t_threshold will not be used
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* new->current_threshold=
 will not be used
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * until rcu_assign_pointe=
r(), so it's safe to increment
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * it here.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++thresholds_new->current_t=
hreshold;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++new->current_threshold;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0j++;
> =A0 =A0 =A0 =A0}
>
> =A0swap_buffers:
> - =A0 =A0 =A0 /* Swap thresholds array and preallocated buffer */
> - =A0 =A0 =A0 if (type =3D=3D _MEM) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->thresholds, thres=
holds_new);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->memsw_thresholds,=
 thresholds_new);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* Swap primary and spare array */
> + =A0 =A0 =A0 thresholds->spare =3D thresholds->primary;
> + =A0 =A0 =A0 rcu_assign_pointer(thresholds->primary, new);
>
> =A0 =A0 =A0 =A0/* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
> --
> 1.7.0.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
