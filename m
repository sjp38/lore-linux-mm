Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 3416F6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 13:29:58 -0400 (EDT)
Received: by lagz14 with SMTP id z14so6536979lag.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 10:29:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F86BC71.9070403@jp.fujitsu.com>
References: <4F86B9BE.8000105@jp.fujitsu.com>
	<4F86BC71.9070403@jp.fujitsu.com>
Date: Tue, 17 Apr 2012 10:29:55 -0700
Message-ID: <CALWz4iwYX4r5dJmcKFuc+zj_rjMB76dtpbvArdzySF+dyxMohg@mail.gmail.com>
Subject: Re: [PATCH 5/7] memcg: divide force_empty into 2 functions, avoid
 memory reclaim at rmdir
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Apr 12, 2012 at 4:28 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Now, at rmdir, memory cgroup's charge will be moved to
> =A0- parent if use_hierarchy=3D1
> =A0- root =A0 if use_hierarchy=3D0
>
> Then, we don't have to have memory reclaim code at destroying memcg.
>
> This patch divides force_empty to 2 functions as
>
> =A0- memory_cgroup_recharge() ... try to move all charges to ancestors.
> =A0- memory_cgroup_force_empty().. try to reclaim all memory.
>
> After this patch, memory.force_empty will _not_ move charges to ancestors
> but just reclaim all pages. (This meets documenation.)

Not sure why it matches the documentation:
"
memory.force_empty>---->------- # trigger forced move charge to parent
"

and
"
  # echo 0 > memory.force_empty

  Almost all pages tracked by this memory cgroup will be unmapped and freed=
.
  Some pages cannot be freed because they are locked or in-use. Such pages =
are
  moved to parent and this cgroup will be empty. This may return -EBUSY if
  VM is too busy to free/move all pages immediately.
"

--Ying

>
> rmdir() will not reclaim any memory but moves charge to other cgroup,
> parent or root.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0 59 +++++++++++++++++++++++++++------------------=
----------
> =A01 files changed, 29 insertions(+), 30 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9ac7984..22c8faa 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3619,10 +3619,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct=
 zone *zone, int order,
> =A0}
>
> =A0/*
> - * This routine traverse page_cgroup in given list and drop them all.
> - * *And* this routine doesn't reclaim page itself, just removes page_cgr=
oup.
> + * This routine traverse page in given list and move them all.
> =A0*/
> -static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> +static int mem_cgroup_recharge_lru(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int node, =
int zid, enum lru_list lru)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> @@ -3678,24 +3677,12 @@ static int mem_cgroup_force_empty_list(struct mem=
_cgroup *memcg,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -/*
> - * make mem_cgroup's charge to be 0 if there is no task.
> - * This enables deleting this mem_cgroup.
> - */
> -static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_al=
l)
> +
> +static int mem_cgroup_recharge(struct mem_cgroup *memcg)
> =A0{
> - =A0 =A0 =A0 int ret;
> - =A0 =A0 =A0 int node, zid, shrink;
> - =A0 =A0 =A0 int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
> + =A0 =A0 =A0 int ret, node, zid;
> =A0 =A0 =A0 =A0struct cgroup *cgrp =3D memcg->css.cgroup;
>
> - =A0 =A0 =A0 css_get(&memcg->css);
> -
> - =A0 =A0 =A0 shrink =3D 0;
> - =A0 =A0 =A0 /* should free all ? */
> - =A0 =A0 =A0 if (free_all)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto try_to_free;
> -move_account:
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgrp) || !list_empty=
(&cgrp->children))
> @@ -3712,7 +3699,7 @@ move_account:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (zid =3D 0; !ret && zi=
d < MAX_NR_ZONES; zid++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0enum lru_l=
ist lru;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_l=
ru(lru) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ret =3D mem_cgroup_force_empty_list(memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ret =3D mem_cgroup_recharge_lru(memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0node, zid, lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0break;
> @@ -3722,24 +3709,33 @@ move_account:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_end_move(memcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_oom_recover(memcg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
> =A0 =A0 =A0 =A0/* "ret" should also be checked to ensure all lists are em=
pty. */
> =A0 =A0 =A0 =A0} while (memcg->res.usage > 0 || ret);
> =A0out:
> - =A0 =A0 =A0 css_put(&memcg->css);
> =A0 =A0 =A0 =A0return ret;
> +}
> +
> +
> +/*
> + * make mem_cgroup's charge to be 0 if there is no task. This is only ca=
lled
> + * by memory.force_empty file, an user request.
> + */
> +static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 int ret =3D 0;
> + =A0 =A0 =A0 int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
> + =A0 =A0 =A0 struct cgroup *cgrp =3D memcg->css.cgroup;
> +
> + =A0 =A0 =A0 css_get(&memcg->css);
>
> -try_to_free:
> =A0 =A0 =A0 =A0/* returns EBUSY if there is a task or if we come here twi=
ce. */
> - =A0 =A0 =A0 if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children)=
 || shrink) {
> + =A0 =A0 =A0 if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children)=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* we call try-to-free pages for make this cgroup empty */
> =A0 =A0 =A0 =A0lru_add_drain_all();
> - =A0 =A0 =A0 /* try to free all pages in this cgroup */
> - =A0 =A0 =A0 shrink =3D 1;
> =A0 =A0 =A0 =A0while (nr_retries && memcg->res.usage > 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int progress;
>
> @@ -3754,16 +3750,19 @@ try_to_free:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* maybe some writeback is=
 necessary */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0congestion_wait(BLK_RW_ASY=
NC, HZ/10);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> -
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 lru_add_drain();
> + =A0 =A0 =A0 if (!nr_retries)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> +out:
> + =A0 =A0 =A0 memcg_oom_recover(memcg);
> + =A0 =A0 =A0 css_put(&memcg->css);
> =A0 =A0 =A0 =A0/* try move_account...there may be some *locked* pages. */
> - =A0 =A0 =A0 goto move_account;
> + =A0 =A0 =A0 return ret;
> =A0}
>
> =A0int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int eve=
nt)
> =A0{
> - =A0 =A0 =A0 return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), t=
rue);
> + =A0 =A0 =A0 return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
> =A0}
>
>
> @@ -4987,7 +4986,7 @@ static int mem_cgroup_pre_destroy(struct cgroup *co=
nt)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cont);
>
> - =A0 =A0 =A0 return mem_cgroup_force_empty(memcg, false);
> + =A0 =A0 =A0 return mem_cgroup_recharge(memcg);
> =A0}
>
> =A0static void mem_cgroup_destroy(struct cgroup *cont)
> --
> 1.7.4.1
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
