Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 639B96B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 18:27:41 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p5HMRbLk031690
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:27:37 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by hpaq6.eem.corp.google.com with ESMTP id p5HMQiwF012657
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:27:36 -0700
Received: by qyk29 with SMTP id 29so1129884qyk.17
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 15:27:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110616124730.d6960b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616125443.23584d78.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 17 Jun 2011 15:27:36 -0700
Message-ID: <BANLkTi=4o-xY46OtsvNCxVKUT-qJBXRMMFZCe-m7eMV-_mesXw@mail.gmail.com>
Subject: Re: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, Jun 15, 2011 at 8:54 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From fcfc6ee9847b0b2571cd6e9847572d7c70e1e2b2 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 16 Jun 2011 09:23:54 +0900
> Subject: [PATCH 5/7] Fix not good check of mem_cgroup_local_usage()
>
> Now, mem_cgroup_local_usage(memcg) is used as hint for scanning memory
> cgroup hierarchy. If it returns true, the memcg has some reclaimable memo=
ry.
>
> But this function doesn't take care of
> =A0- unevictable pages
> =A0- anon pages on swapless system.
>
> This patch fixes the function to use LRU information.
> For NUMA, for avoid scanning, numa scan bitmap is used. If it's
> empty, some more precise check will be done.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0mm/memcontrol.c | =A0 43 +++++++++++++++++++++++++++++++++----------
> =A01 files changed, 33 insertions(+), 10 deletions(-)
>
> Index: mmotm-0615/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-0615.orig/mm/memcontrol.c
> +++ mmotm-0615/mm/memcontrol.c
> @@ -632,15 +632,6 @@ static long mem_cgroup_read_stat(struct
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
> @@ -1713,6 +1704,23 @@ static void mem_cgroup_numascan_init(str
> =A0 =A0 =A0 =A0mutex_init(&mem->numascan_mutex);
> =A0}
>
> +static bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> + =A0 =A0 =A0 if (!nodes_empty(mem->scan_nodes))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 /* slow path */
> + =A0 =A0 =A0 if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;

Wondering if we can simplify this like:

if (mem_cgroup_nr_file_lru_pages(mem))
   return true;


> + =A0 =A0 =A0 if (noswap || !total_swap_pages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 if (mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 if (mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;

the same:
if (mem_cgroup_nr_anon_lru_pages(mem))
   return true;

> + =A0 =A0 =A0 return false;
> +}

The two functions above are part of memory.numa_stat patch which is in
mmotm i believe. Just feel the functionality a bit duplicate except
the noswap parameter and scan_nodes.

--Ying

> =A0#else
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
> =A0{
> @@ -1722,6 +1730,21 @@ static void mem_cgroup_numascan_init(str
> =A0{
> =A0 =A0 =A0 =A0return 0;
> =A0}
> +
> +static bool mem_cgroup_reclaimable(struct mem_cgroup *mem, bool noswap)
> +{
> + =A0 =A0 =A0 if (mem_cgroup_get_zonestat_node(mem, 0, LRU_INACTIVE_FILE)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 if (mem_cgroup_get_zonestat_node(mem, 0, LRU_ACTIVE_FILE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 if (noswap || !total_swap_pages)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 if (mem_cgroup_get_zonestat_node(mem, 0, LRU_INACTIVE_ANON)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 if (mem_cgroup_get_zonestat_node(mem, 0, LRU_ACTIVE_ANON))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 return false;
> +}
> =A0#endif
>
>
> @@ -1811,7 +1834,7 @@ again:
>
> =A0 =A0 =A0 =A0while (visit--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0victim =3D mem_cgroup_select_victim(root_m=
em);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_local_usage(victim)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_reclaimable(victim, noswap)=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* this cgroup's local usa=
ge =3D=3D 0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0css_put(&victim->css);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
