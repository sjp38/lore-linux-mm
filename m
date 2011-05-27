Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7CAFB6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 01:48:01 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p4R5lvwJ016297
	for <linux-mm@kvack.org>; Thu, 26 May 2011 22:47:57 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by wpaz37.hot.corp.google.com with ESMTP id p4R5ltdW003575
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 May 2011 22:47:56 -0700
Received: by qyk29 with SMTP id 29so3645780qyk.17
        for <linux-mm@kvack.org>; Thu, 26 May 2011 22:47:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526141529.53b70097.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526141529.53b70097.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 26 May 2011 22:47:55 -0700
Message-ID: <BANLkTimq7Bd_OQDOPmkM3n38g1pUbT9uYw@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 1/10] check reclaimable in hierarchy walk
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, May 25, 2011 at 10:15 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> I may post this patch as stand alone, later.
> =3D=3D
> Check memcg has reclaimable pages at select_victim().
>
> Now, with help of bitmap as memcg->scan_node, we can check whether memcg =
has
> reclaimable pages with easy test of node_empty(&mem->scan_nodes).
>
> mem->scan_nodes is a bitmap to show whether memcg contains reclaimable
> memory or not, which is updated periodically.
>
> This patch makes use of scan_nodes and modify hierarchy walk at memory
> shrinking in following way.
>
> =A0- check scan_nodes in mem_cgroup_select_victim()
> =A0- mem_cgroup_select_victim() returns NULL if no memcg is reclaimable.
> =A0- force update of scan_nodes.
> =A0- rename mem_cgroup_select_victim() to be mem_cgroup_select_get_victim=
()
> =A0 =A0to show refcnt is +1.
>
> This will make hierarchy walk better.
>
> And this allows to remove mem_cgroup_local_pages() check which was used f=
or
> the same purpose. But this function was wrong because it cannot handle
> information of unevictable pages and tmpfs v.s. swapless information.
>
> Changelog:
> =A0- added since v3.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0165 +++++++++++++++++++++++++++++++++++++--------=
-----------
> =A01 file changed, 110 insertions(+), 55 deletions(-)
>
> Index: memcg_async/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg_async.orig/mm/memcontrol.c
> +++ memcg_async/mm/memcontrol.c
> @@ -584,15 +584,6 @@ static long mem_cgroup_read_stat(struct
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> -static long mem_cgroup_local_usage(struct mem_cgroup *mem)
> -{
> - =A0 =A0 =A0 long ret;
> -
> - =A0 =A0 =A0 ret =3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> - =A0 =A0 =A0 ret +=3D mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
> - =A0 =A0 =A0 return ret;
> -}
> -
> =A0static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 bool charge)
> =A0{
> @@ -1555,43 +1546,6 @@ u64 mem_cgroup_get_limit(struct mem_cgro
> =A0 =A0 =A0 =A0return min(limit, memsw);
> =A0}
>
> -/*
> - * Visit the first child (need not be the first child as per the orderin=
g
> - * of the cgroup list, since we track last_scanned_child) of @mem and us=
e
> - * that to reclaim free pages from.
> - */
> -static struct mem_cgroup *
> -mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> -{
> - =A0 =A0 =A0 struct mem_cgroup *ret =3D NULL;
> - =A0 =A0 =A0 struct cgroup_subsys_state *css;
> - =A0 =A0 =A0 int nextid, found;
> -
> - =A0 =A0 =A0 if (!root_mem->use_hierarchy) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_get(&root_mem->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D root_mem;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 while (!ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nextid =3D root_mem->last_scanned_child + 1=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&mem_cgroup_subsys, ne=
xtid, &root_mem->css,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&fou=
nd);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css && css_tryget(css))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D container_of(css, s=
truct mem_cgroup, css);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Updates scanning parameter */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this means start scan fr=
om ID:1 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D found;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 return ret;
> -}
> -
> =A0#if MAX_NUMNODES > 1
>
> =A0/*
> @@ -1600,11 +1554,11 @@ mem_cgroup_select_victim(struct mem_cgro
> =A0* nodes based on the zonelist. So update the list loosely once per 10 =
secs.
> =A0*
> =A0*/
> -static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
> +static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem, bool =
force)
> =A0{
> =A0 =A0 =A0 =A0int nid;
>
> - =A0 =A0 =A0 if (time_after(mem->next_scan_node_update, jiffies))
> + =A0 =A0 =A0 if (!force && time_after(mem->next_scan_node_update, jiffie=
s))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> =A0 =A0 =A0 =A0mem->next_scan_node_update =3D jiffies + 10*HZ;
> @@ -1641,7 +1595,7 @@ int mem_cgroup_select_victim_node(struct
> =A0{
> =A0 =A0 =A0 =A0int node;
>
> - =A0 =A0 =A0 mem_cgroup_may_update_nodemask(mem);
> + =A0 =A0 =A0 mem_cgroup_may_update_nodemask(mem, false);
> =A0 =A0 =A0 =A0node =3D mem->last_scanned_node;
>
> =A0 =A0 =A0 =A0node =3D next_node(node, mem->scan_nodes);
> @@ -1660,13 +1614,117 @@ int mem_cgroup_select_victim_node(struct
> =A0 =A0 =A0 =A0return node;
> =A0}
>
> +/**
> + * mem_cgroup_has_reclaimable
> + * @mem_cgroup : the mem_cgroup
> + *
> + * The caller can test whether the memcg has reclaimable pages.
> + *
> + * This function checks memcg has reclaimable pages or not with bitmap o=
f
> + * memcg->scan_nodes. This bitmap is updated periodically and indicates
> + * which node has reclaimable memcg memory or not.
> + * Although this is a rough test and result is not very precise but we d=
on't
> + * have to scan all nodes and don't have to use locks.
> + *
> + * For non-NUMA, this cheks reclaimable pages on zones because we don't
> + * update scan_nodes.(see below)
> + */
> +static bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 return !nodes_empty(memcg->scan_nodes);
> +}
> +
> =A0#else
> +
> +static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem, bool =
force)
> +{
> +}
> +
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> =A0}
> +
> +static bool mem_cgroup_has_reclaimable(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 unsigned long nr;
> + =A0 =A0 =A0 int zid;
> +
> + =A0 =A0 =A0 for (zid =3D NODE_DATA(0)->nr_zones - 1; zid >=3D 0; zid--)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_zone_reclaimable_pages(memcg=
, 0, zid))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 if (zid < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 return true;
> +}
> =A0#endif

unused variable "nr".

--Ying
>
> +/**
> + * mem_cgroup_select_get_victim
> + * @root_mem: the root memcg of hierarchy which should be shrinked.
> + *
> + * Visit children of root_mem ony by one. If the routine finds a memcg
> + * which contains reclaimable pages, returns it with refcnt +1. The
> + * scan is done in round-robin and 'the next start point' is saved into
> + * mem->last_scanned_child. If no reclaimable memcg are found, returns N=
ULL.
> + */
> +static struct mem_cgroup *
> +mem_cgroup_select_get_victim(struct mem_cgroup *root_mem)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *ret =3D NULL;
> + =A0 =A0 =A0 struct cgroup_subsys_state *css;
> + =A0 =A0 =A0 int nextid, found;
> + =A0 =A0 =A0 bool second_visit =3D false;
> +
> + =A0 =A0 =A0 if (!root_mem->use_hierarchy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto return_root;
> +
> + =A0 =A0 =A0 while (!ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nextid =3D root_mem->last_scanned_child + 1=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css =3D css_get_next(&mem_cgroup_subsys, ne=
xtid, &root_mem->css,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&fou=
nd);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css && css_tryget(css))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D container_of(css, s=
truct mem_cgroup, css);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Updates scanning parameter */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!css) { /* Indicates we scanned the las=
t node of tree */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If all memcg has no re=
claimable pages, we may enter
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* an infinite loop. Exit=
 here if we reached the end
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of hierarchy tree twic=
e.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (second_visit)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this means start scan fr=
om ID:1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 second_visit =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 root_mem->last_scanned_chil=
d =3D found;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css && ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* check memcg has reclai=
mable memory or not. Update
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* information carefully =
if we might fail with cached
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* bitmask information.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (second_visit)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_=
may_update_nodemask(ret, true);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_has_reclaim=
able(ret)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(css=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D NUL=
L;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return ret;
> +return_root:
> + =A0 =A0 =A0 css_get(&root_mem->css);
> + =A0 =A0 =A0 return root_mem;
> +}
> +
> +
> =A0/*
> =A0* Scan the hierarchy if needed to reclaim memory. We remember the last=
 child
> =A0* we reclaimed from, so that we don't end up penalizing one child exte=
nsively
> @@ -1705,7 +1763,9 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0is_kswapd =3D true;
>
> =A0 =A0 =A0 =A0while (1) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_victim(root_me=
m);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 victim =3D mem_cgroup_select_get_victim(roo=
t_mem);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!victim)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return total;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (victim =3D=3D root_mem) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loop++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (loop >=3D 1)
> @@ -1733,11 +1793,6 @@ static int mem_cgroup_hierarchical_recla
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_local_usage(victim)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* this cgroup's local usag=
e =3D=3D 0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&victim->css);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* we use swappiness of local cgroup */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (check_soft) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_shrink_=
node_zone(victim, gfp_mask,
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
