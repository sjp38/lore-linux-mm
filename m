Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B56886B004F
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 16:22:23 -0400 (EDT)
Received: by pzk16 with SMTP id 16so839050pzk.18
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 13:22:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090902145621.83c8a79c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090902093551.c8b171fb.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090902145621.83c8a79c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 3 Sep 2009 01:45:06 +0530
Message-ID: <661de9470909021315m3af0de32h29f1ac8fd574249d@mail.gmail.com>
Subject: Re: [mmotm][PATCH 2/2 v2] memcg: reduce calls for soft limit excess
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 2, 2009 at 11:26 AM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> In charge/uncharge/reclaim path, usage_in_excess is calculated repeatedly=
 and
> it takes res_counter's spin_lock every time.
>

I think the changelog needs to mention some refactoring you've done
below as well, like change new_charge_in_excess to excess.



> This patch removes unnecessary calls for res_count_soft_limit_excess.
>
> Changelog:
> =A0- fixed description.
> =A0- fixed unsigned long to be unsigned long long (Thanks, Nishimura)
>
> Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0 31 +++++++++++++++----------------
> =A01 file changed, 15 insertions(+), 16 deletions(-)
>
> Index: mmotm-2.6.31-Aug27/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Aug27.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Aug27/mm/memcontrol.c
> @@ -313,7 +313,8 @@ soft_limit_tree_from_page(struct page *p
> =A0static void
> =A0__mem_cgroup_insert_exceeded(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct mem=
_cgroup_per_zone *mz,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_=
cgroup_tree_per_zone *mctz,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng long new_usage_in_excess)
> =A0{
> =A0 =A0 =A0 =A0struct rb_node **p =3D &mctz->rb_root.rb_node;
> =A0 =A0 =A0 =A0struct rb_node *parent =3D NULL;
> @@ -322,7 +323,9 @@ __mem_cgroup_insert_exceeded(struct mem_
> =A0 =A0 =A0 =A0if (mz->on_tree)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 mz->usage_in_excess =3D res_counter_soft_limit_excess(&mem-=
>res);
> + =A0 =A0 =A0 mz->usage_in_excess =3D new_usage_in_excess;
> + =A0 =A0 =A0 if (!mz->usage_in_excess)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> =A0 =A0 =A0 =A0while (*p) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0parent =3D *p;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz_node =3D rb_entry(parent, struct mem_cg=
roup_per_zone,
> @@ -382,7 +385,7 @@ static bool mem_cgroup_soft_limit_check(
>
> =A0static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page=
 *page)
> =A0{
> - =A0 =A0 =A0 unsigned long long new_usage_in_excess;
> + =A0 =A0 =A0 unsigned long long excess;
> =A0 =A0 =A0 =A0struct mem_cgroup_per_zone *mz;
> =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_zone *mctz;
> =A0 =A0 =A0 =A0int nid =3D page_to_nid(page);
> @@ -395,25 +398,21 @@ static void mem_cgroup_update_tree(struc
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0for (; mem; mem =3D parent_mem_cgroup(mem)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz =3D mem_cgroup_zoneinfo(mem, nid, zid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_usage_in_excess =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_soft_limit_exce=
ss(&mem->res);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
em->res);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We have to update the tree if mz is on =
RB-tree or
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * mem is over its softlimit.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_usage_in_excess || mz->on_tree) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (excess || mz->on_tree) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&mctz->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* if on-tree, remove it *=
/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mz->on_tree)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgro=
up_remove_exceeded(mem, mz, mctz);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if over soft limit, in=
sert again. mz->usage_in_excess
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will be updated proper=
ly.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Insert again. mz->usag=
e_in_excess will be updated.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If excess is 0, no tre=
e ops.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgrou=
p_insert_exceeded(mem, mz, mctz);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_i=
n_excess =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceede=
d(mem, mz, mctz, excess);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&mctz->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> @@ -2216,6 +2215,7 @@ unsigned long mem_cgroup_soft_limit_recl
> =A0 =A0 =A0 =A0unsigned long reclaimed;
> =A0 =A0 =A0 =A0int loop =3D 0;
> =A0 =A0 =A0 =A0struct mem_cgroup_tree_per_zone *mctz;
> + =A0 =A0 =A0 unsigned long long excess;
>
> =A0 =A0 =A0 =A0if (order > 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> @@ -2260,9 +2260,8 @@ unsigned long mem_cgroup_soft_limit_recl
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgro=
up_largest_soft_limit_node(mctz);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} while (next_mz =3D=3D mz=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz->usage_in_excess =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_soft_limit_exce=
ss(&mz->mem->res);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_remove_exceeded(mz->mem, mz, =
mctz);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 excess =3D res_counter_soft_limit_excess(&m=
z->mem->res);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * One school of thought says that we shou=
ld not add
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * back the node to the tree if reclaim re=
turns 0.
> @@ -2271,8 +2270,8 @@ unsigned long mem_cgroup_soft_limit_recl
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * memory to reclaim from. Consider this a=
s a longer
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * term TODO.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mz->usage_in_excess)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceede=
d(mz->mem, mz, mctz);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If excess =3D=3D 0, no tree ops */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_insert_exceeded(mz->mem, mz, m=
ctz, excess);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&mctz->lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&mz->mem->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loop++;

OK.. so everytime we call __mem_cgroup_insert_exceeded we save one
res_counter operation.

Looks good

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
