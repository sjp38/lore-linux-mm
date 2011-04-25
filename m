Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C55D58D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:13:30 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p3PHDRTD008021
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:13:27 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by kpbe17.cbf.corp.google.com with ESMTP id p3PHCFKv003880
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:13:26 -0700
Received: by qwc9 with SMTP id 9so1910179qwc.27
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:13:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425112333.2662.A69D9226@jp.fujitsu.com>
References: <20110422174554.71F2.A69D9226@jp.fujitsu.com>
	<BANLkTinB5tGAH=DE55HnE5krGxx1uoXgLA@mail.gmail.com>
	<20110425112333.2662.A69D9226@jp.fujitsu.com>
Date: Mon, 25 Apr 2011 10:13:25 -0700
Message-ID: <BANLkTikCZpCZdLV7M_38MvnRYbZFS5zQGQ@mail.gmail.com>
Subject: Re: [PATCH] vmscan,memcg: memcg aware swap token
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Sun, Apr 24, 2011 at 7:21 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 sc.priority =3D priority;
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 /* The swap token gets in the way of s=
wapout... */
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 if (!priority)
>> > > > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
>> > > >
>> > > > Why?
>> > > >
>> > > > disable swap token mean "Please devest swap preventation privilege=
 from
>> > > > owner task. Instead we endure swap storm and performance hit".
>> > > > However I doublt memcg memory shortage is good situation to make s=
wap
>> > > > storm.
>> > > >
>> > >
>> > > I am not sure about that either way. we probably can leave as it is =
and
>> > make
>> > > corresponding change if real problem is observed?
>> >
>> > Why?
>> > This is not only memcg issue, but also can lead to global swap ping-po=
ng.
>> >
>> > But I give up. I have no time to persuade you.
>> >
>> > Thank you for pointing that out. I didn't pay much attention on the
>> swap_token but just simply inherited
>> it from the global logic. Now after reading a bit more, i think you were
>> right about it. =A0It would be a bad
>> idea to have memcg kswapds affecting much the global swap token being se=
t.
>>
>> I will remove it from the next post.
>
> The better approach is swap-token recognize memcg and behave clever? :)

Ok, this makes sense for memcg case. Maybe I missed something on the
per-node balance_pgdat, where it seems it will blindly disable the
swap_token_mm if there is a one.

static inline int has_swap_token(struct mm_struct *mm)
{
>-------return (mm =3D=3D swap_token_mm);
}

static inline void put_swap_token(struct mm_struct *mm)
{
>-------if (has_swap_token(mm))
>------->-------__put_swap_token(mm);
}

static inline void disable_swap_token(void)
{
>-------put_swap_token(swap_token_mm);
}


Should I include this patch into the per-memcg kswapd patset?

--Ying

>
>
>
> From 106c21d7f9cf8641592cbfe1416af66470af4f9a Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Mon, 25 Apr 2011 10:57:54 +0900
> Subject: [PATCH] vmscan,memcg: memcg aware swap token
>
> Currently, memcg reclaim can disable swap token even if the swap token
> mm doesn't belong in its memory cgroup. It's slightly riskly. If an
> admin makes very small mem-cgroup and silly guy runs contenious heavy
> memory pressure workloa, whole tasks in the system are going to lose
> swap-token and then system may become unresponsive. That's bad.
>
> This patch adds 'memcg' parameter into disable_swap_token(). and if
> the parameter doesn't match swap-token, VM doesn't put swap-token.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A06 ++++++
> =A0include/linux/swap.h =A0 =A0 =A0 | =A0 24 +++++++++++++++++-------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0mm/thrash.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 +++++++++++++++++
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
> =A05 files changed, 43 insertions(+), 10 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6a0cffd..df572af 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -84,6 +84,7 @@ int task_in_mem_cgroup(struct task_struct *task, const =
struct mem_cgroup *mem);
>
> =A0extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *pa=
ge);
> =A0extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
> +extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *m=
m);
>
> =A0static inline
> =A0int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgrou=
p *cgroup)
> @@ -244,6 +245,11 @@ static inline struct mem_cgroup *try_get_mem_cgroup_=
from_page(struct page *page)
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> +static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_st=
ruct *mm)
> +{
> + =A0 =A0 =A0 return NULL;
> +}
> +
> =A0static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgr=
oup *mem)
> =A0{
> =A0 =A0 =A0 =A0return 1;
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 384eb5f..ccea15d 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -358,21 +358,31 @@ struct backing_dev_info;
> =A0extern struct mm_struct *swap_token_mm;
> =A0extern void grab_swap_token(struct mm_struct *);
> =A0extern void __put_swap_token(struct mm_struct *);
> +extern int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup =
*memcg);
>
> -static inline int has_swap_token(struct mm_struct *mm)
> +static inline
> +int has_swap_token(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 return (mm =3D=3D swap_token_mm);
> + =A0 =A0 =A0 return has_swap_token_memcg(mm, NULL);
> =A0}
>
> -static inline void put_swap_token(struct mm_struct *mm)
> +static inline
> +void put_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg=
)
> =A0{
> - =A0 =A0 =A0 if (has_swap_token(mm))
> + =A0 =A0 =A0 if (has_swap_token_memcg(mm, memcg))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__put_swap_token(mm);
> =A0}
>
> -static inline void disable_swap_token(void)
> +static inline
> +void put_swap_token(struct mm_struct *mm)
> +{
> + =A0 =A0 =A0 return put_swap_token_memcg(mm, NULL);
> +}
> +
> +static inline
> +void disable_swap_token(struct mem_cgroup *memcg)
> =A0{
> - =A0 =A0 =A0 put_swap_token(swap_token_mm);
> + =A0 =A0 =A0 put_swap_token_memcg(swap_token_mm, memcg);
> =A0}
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> @@ -500,7 +510,7 @@ static inline int has_swap_token(struct mm_struct *mm=
)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static inline void disable_swap_token(void)
> +static inline void disable_swap_token(struct mem_cgroup *memcg)
> =A0{
> =A0}
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c2776f1..5683c7a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -735,7 +735,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_s=
truct *p)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem=
_cgroup, css);
> =A0}
>
> -static struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *m=
m)
> +struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D NULL;
>
> diff --git a/mm/thrash.c b/mm/thrash.c
> index 2372d4e..f892a6e 100644
> --- a/mm/thrash.c
> +++ b/mm/thrash.c
> @@ -21,6 +21,7 @@
> =A0#include <linux/mm.h>
> =A0#include <linux/sched.h>
> =A0#include <linux/swap.h>
> +#include <linux/memcontrol.h>
>
> =A0static DEFINE_SPINLOCK(swap_token_lock);
> =A0struct mm_struct *swap_token_mm;
> @@ -75,3 +76,19 @@ void __put_swap_token(struct mm_struct *mm)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0swap_token_mm =3D NULL;
> =A0 =A0 =A0 =A0spin_unlock(&swap_token_lock);
> =A0}
> +
> +int has_swap_token_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 if (memcg) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *swap_token_memcg;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* memcgroup reclaim can disable swap tok=
en only if token task
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is in the same cgroup.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap_token_memcg =3D try_get_mem_cgroup_fro=
m_mm(swap_token_mm);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ((mm =3D=3D swap_token_mm) && (memcg=
 =3D=3D swap_token_memcg));
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (mm =3D=3D swap_token_mm);
> +}
> +
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3a569f..19e179b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2044,7 +2044,7 @@ static unsigned long do_try_to_free_pages(struct zo=
nelist *zonelist,
> =A0 =A0 =A0 =A0for (priority =3D DEF_PRIORITY; priority >=3D 0; priority-=
-) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->nr_scanned =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!priority)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token(sc->mem_=
cgroup);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zones(priority, zonelist, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Don't shrink slabs when reclaiming memo=
ry from
> @@ -2353,7 +2353,7 @@ loop_again:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* The swap token gets in the way of swapo=
ut... */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!priority)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_swap_token(NULL);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0all_zones_ok =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0balanced =3D 0;
> --
> 1.7.3.1
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
