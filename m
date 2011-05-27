Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5C3056B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 03:21:36 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p4R7LXvB008127
	for <linux-mm@kvack.org>; Fri, 27 May 2011 00:21:33 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by hpaq1.eem.corp.google.com with ESMTP id p4R7LII5017470
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 27 May 2011 00:21:31 -0700
Received: by qyk29 with SMTP id 29so3653717qyk.10
        for <linux-mm@kvack.org>; Fri, 27 May 2011 00:21:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110526141909.ec42113e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<20110526141909.ec42113e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 27 May 2011 00:21:31 -0700
Message-ID: <BANLkTi=Ado5+B2t02PLq10xhh4310F-S9Q@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 3/10] memcg: a test whether zone is reclaimable or not
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, May 25, 2011 at 10:19 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: Ying Han <yinghan@google.com>
>
> The number of reclaimable pages per zone is an useful information for
> controling memory reclaim schedule. This patch exports it.
>
> Changelog v2->v3:
> =A0- added comments.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A02 ++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 24 ++++++++++++++++++++++=
++
> =A02 files changed, 26 insertions(+)
>
> Index: memcg_async/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg_async.orig/mm/memcontrol.c
> +++ memcg_async/mm/memcontrol.c
> @@ -1240,6 +1240,30 @@ static unsigned long mem_cgroup_nr_lru_p
> =A0}
> =A0#endif /* CONFIG_NUMA */
>
> +/**
> + * mem_cgroup_zone_reclaimable_pages
> + * @memcg: the memcg
> + * @nid =A0: node index to be checked.
> + * @zid =A0: zone index to be checked.
> + *
> + * This function returns the number reclaimable pages on a zone for give=
n memcg.
> + * Reclaimable page includes file caches and anonymous pages if swap is
> + * avaliable and never includes unevictable pages.
> + */
> +unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 int nid, int zid)
> +{
> + =A0 =A0 =A0 unsigned long nr;
> + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(memc=
g, nid, zid);
> +
> + =A0 =A0 =A0 nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE);
> + =A0 =A0 =A0 if (nr_swap_pages > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON=
) +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MEM_CGROUP_ZSTAT(mz, NR_INA=
CTIVE_ANON);
> + =A0 =A0 =A0 return nr;
> +}
> +
> =A0struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgrou=
p *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct zone *zone)
> =A0{
> Index: memcg_async/include/linux/memcontrol.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- memcg_async.orig/include/linux/memcontrol.h
> +++ memcg_async/include/linux/memcontrol.h
> @@ -109,6 +109,8 @@ extern void mem_cgroup_end_migration(str
> =A0*/
> =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
> =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
> +unsigned long
> +mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int=
 zid);
> =A0int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
> =A0unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0struct zone *zone,
>
>

Again, please apply the patch:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6a52699..0b88d71 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1217,7 +1217,7 @@ unsigned long
mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
       struct mem_cgroup_per_zone *mz =3D mem_cgroup_zoneinfo(memcg, nid, z=
id);

       nr =3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
-               MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE);
+               MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
       if (nr_swap_pages > 0)
               nr +=3D MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
                       MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);


Also, you need to move this to up since patch 1/10 needs this.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
