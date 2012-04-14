Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D35596B0044
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 10:32:27 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so3767260vcb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 07:32:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334181620-26890-1-git-send-email-yinghan@google.com>
References: <1334181620-26890-1-git-send-email-yinghan@google.com>
Date: Sat, 14 Apr 2012 22:32:26 +0800
Message-ID: <CAJd=RBB5oaPPXqQ0nLpThCFccbOF9vfgRS2+dTnpP4KBVCib6A@mail.gmail.com>
Subject: Re: [PATCH V2 4/5] memcg: detect no memcgs above softlimit under zone reclaim.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 6:00 AM, Ying Han <yinghan@google.com> wrote:
> The function zone_reclaimable() marks zone->all_unreclaimable based on
> per-zone pages_scanned and reclaimable_pages. If all_unreclaimable is tru=
e,
> alloc_pages could go to OOM instead of getting stuck in page reclaim.
>
> In memcg kernel, cgroup under its softlimit is not targeted under global
> reclaim. It could be possible that all memcgs are under their softlimit f=
or
> a particular zone. So the direct reclaim do_try_to_free_pages() will alwa=
ys
> return 1 which causes the caller __alloc_pages_direct_reclaim() enter tig=
ht
> loop.
>
> The reclaim priority check we put in should_reclaim_mem_cgroup() should h=
elp
> this case, but we still don't want to burn cpu cycles for first few prior=
ities
> to get to that point. The idea is from LSF discussion where we detect it =
after
> the first round of scanning and restart the reclaim by not looking at sof=
tlimit
> at all. This allows us to make forward progress on shrink_zone() and free=
 some
> pages on the zone.
>
> In order to do the detection for scanning all the memcgs under shrink_zon=
e(),
> i have to change the mem_cgroup_iter() from shared walk to full walk. Oth=
erwise,
> it would be very easy to skip lots of memcgs above softlimit and it cause=
s the
> flag "ignore_softlimit" being mistakenly set.
>
Perhaps that detection could be covered by

	return target_mem_cgroup ||
		mem_cgroup_soft_limit_exceeded(memcg) ||
		(priority <=3D DEF_PRIORITY - 3);

then consider replacing shared walk with full walk.


> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 23 ++++++++++++++++-------
> =C2=A01 files changed, 16 insertions(+), 7 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2dbc300..d65eae4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2158,21 +2158,25 @@ static void shrink_zone(int priority, struct zone=
 *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct scan_control *sc)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *root =3D sc->target_mem_cgr=
oup;
> - =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup_reclaim_cookie reclaim =3D {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .zone =3D zone,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .priority =3D priority=
,
> - =C2=A0 =C2=A0 =C2=A0 };
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *memcg;
> + =C2=A0 =C2=A0 =C2=A0 int above_softlimit, ignore_softlimit =3D 0;
> +
>
> - =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_iter(root, NULL, &reclaim);
> +restart:
> + =C2=A0 =C2=A0 =C2=A0 above_softlimit =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_iter(root, NULL, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup_=
zone mz =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0.mem_cgroup =3D memcg,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0.zone =3D zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0};
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (should_reclaim_mem=
_cgroup(root, memcg, priority))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ignore_softlimit |=
|
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0should_re=
claim_mem_cgroup(root, memcg, priority)) {
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0shrink_mem_cgroup_zone(priority, &mz, sc);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 above_softlimit =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Limit reclaim h=
as historically picked one memcg and
> @@ -2188,8 +2192,13 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0mem_cgroup_iter_break(root, memcg);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_i=
ter(root, memcg, &reclaim);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg =3D mem_cgroup_i=
ter(root, memcg, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (memcg);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!above_softlimit) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ignore_softlimit =3D 1=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto restart;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0}
>
> =C2=A0/* Returns true if compaction should go ahead for a high-order requ=
est */
> --
> 1.7.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
