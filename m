Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 33D026B0011
	for <linux-mm@kvack.org>; Mon,  2 May 2011 12:52:27 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p42GqN0V008614
	for <linux-mm@kvack.org>; Mon, 2 May 2011 09:52:23 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by hpaq5.eem.corp.google.com with ESMTP id p42Gpiwp007494
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 2 May 2011 09:52:22 -0700
Received: by qwf7 with SMTP id 7so3609223qwf.24
        for <linux-mm@kvack.org>; Mon, 02 May 2011 09:52:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1304355025-1421-2-git-send-email-yinghan@google.com>
References: <1304355025-1421-1-git-send-email-yinghan@google.com>
	<1304355025-1421-2-git-send-email-yinghan@google.com>
Date: Mon, 2 May 2011 09:52:22 -0700
Message-ID: <BANLkTik5mGyYdZtjuHKtksmA3qB3xBT8zg@mail.gmail.com>
Subject: Re: [PATCH V2 1/2] Add the soft_limit reclaim in global direct reclaim.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>

On Mon, May 2, 2011 at 9:50 AM, Ying Han <yinghan@google.com> wrote:
> We recently added the change in global background reclaim which
> counts the return value of soft_limit reclaim. Now this patch adds
> the similar logic on global direct reclaim.
>
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim
> does enough work. This is the first step where we start with counting
> the nr_scanned and nr_reclaimed from soft_limit reclaim into global
> scan_control.
>
> no change since v1.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =A0mm/vmscan.c | =A0 16 ++++++++++++++--
> =A01 files changed, 14 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3a569f..84003cc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1959,11 +1959,14 @@ restart:
> =A0* If a zone is deemed to be full of pinned pages then just give it a l=
ight
> =A0* scan then give up on it.
> =A0*/
> -static void shrink_zones(int priority, struct zonelist *zonelist,
> +static unsigned long shrink_zones(int priority, struct zonelist *zonelis=
t,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct scan_control *sc)
> =A0{
> =A0 =A0 =A0 =A0struct zoneref *z;
> =A0 =A0 =A0 =A0struct zone *zone;
> + =A0 =A0 =A0 unsigned long nr_soft_reclaimed;
> + =A0 =A0 =A0 unsigned long nr_soft_scanned;
> + =A0 =A0 =A0 unsigned long total_scanned =3D 0;
>
> =A0 =A0 =A0 =A0for_each_zone_zonelist_nodemask(zone, z, zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0gfp_zone(sc->gfp_mask), sc->nodemask) {
> @@ -1980,8 +1983,17 @@ static void shrink_zones(int priority, struct zone=
list *zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue; =
=A0 =A0 =A0 /* Let kswapd poll it */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_scanned =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_cgroup_soft_limit=
_reclaim(zone,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->order, sc->gfp_mask,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_soft_scanned);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->nr_reclaimed +=3D nr_soft_reclaimed;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D nr_soft_scanned;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(priority, zone, sc);
> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 return total_scanned;
> =A0}
>
> =A0static bool zone_reclaimable(struct zone *zone)
> @@ -2045,7 +2057,7 @@ static unsigned long do_try_to_free_pages(struct zo=
nelist *zonelist,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc->nr_scanned =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!priority)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0disable_swap_token();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_zones(priority, zonelist, sc);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_scanned +=3D shrink_zones(priority, z=
onelist, sc);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Don't shrink slabs when reclaiming memo=
ry from
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * over limit cgroups
> --
> 1.7.3.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
