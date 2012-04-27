Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1127A6B010D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 17:28:34 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so576083lbj.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:28:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9A375D.7@jp.fujitsu.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A375D.7@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 14:28:31 -0700
Message-ID: <CALWz4iyiM-CFgVaHiE1Lgd1ZwJzHwY3tx9XX6HeDPUV_wVPAtQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 9/9 v2] memcg: never return error at pre_destroy()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Thu, Apr 26, 2012 at 11:06 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> When force_empty() called by ->pre_destroy(), no memory reclaim happens
> and it doesn't take very long time which requires signal_pending() check.
> And if we return -EINTR from pre_destroy(), cgroup.c show warning.
>
> This patch removes signal check in force_empty(). By this, ->pre_destroy(=
)
> returns success always.
>
> Note: check for 'cgroup is empty' remains for force_empty interface.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/hugetlb.c =A0 =A0| =A0 10 +---------
> =A0mm/memcontrol.c | =A0 14 +++++---------
> =A02 files changed, 6 insertions(+), 18 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4dd6b39..770f1642 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1922,20 +1922,12 @@ int hugetlb_force_memcg_empty(struct cgroup *cgro=
up)
> =A0 =A0 =A0 =A0int ret =3D 0, idx =3D 0;
>
> =A0 =A0 =A0 =A0do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* see memcontrol.c::mem_cgroup_force_empty=
() */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgroup)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|| !list_empty(&cgroup->ch=
ildren)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the task doing the cgroup_rmdir got=
 a signal
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we don't really need to loop till the =
hugetlb resource
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* usage become zero.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (signal_pending(current)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINTR;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_hstate(h) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&hugetlb_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(page, =
&h->hugepage_activelist, lru) {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2715223..ee350c5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3852,8 +3852,6 @@ static int mem_cgroup_force_empty_list(struct mem_c=
group *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc =3D lookup_page_cgroup(page);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_move_parent(page, pc, m=
emcg, GFP_KERNEL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOMEM || ret =3D=3D -EINTR=
)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ret =3D=3D -EBUSY || ret =3D=3D -EINVA=
L) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* found lock contention o=
r "pc" is obsolete. */
> @@ -3863,7 +3861,7 @@ static int mem_cgroup_force_empty_list(struct mem_c=
group *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0busy =3D NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (!ret && !list_empty(list))
> + =A0 =A0 =A0 if (!loop)

This looks a bit strange to me... why we make the change ?

--Ying

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
> =A0 =A0 =A0 =A0return ret;
> =A0}
> @@ -3893,11 +3891,12 @@ static int mem_cgroup_force_empty(struct mem_cgro=
up *memcg, bool free_all)
> =A0move_account:
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This never happens when this is called=
 by ->pre_destroy().
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* But we need to take care of force_empt=
y interface.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cgroup_task_count(cgrp) || !list_empty=
(&cgrp->children))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINTR;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (signal_pending(current))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* This is for making all *used* pages to =
be on LRU. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_add_drain_all();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drain_all_stock_sync(memcg);
> @@ -3918,9 +3917,6 @@ move_account:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_end_move(memcg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcg_oom_recover(memcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* it seems parent cgroup doesn't have enou=
gh mem */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOMEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto try_to_free;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
> =A0 =A0 =A0 =A0/* "ret" should also be checked to ensure all lists are em=
pty. */
> =A0 =A0 =A0 =A0} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 =
|| ret);
> --
> 1.7.4.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
