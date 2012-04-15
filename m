Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id F30206B004A
	for <linux-mm@kvack.org>; Sat, 14 Apr 2012 21:57:38 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so3993444vcb.14
        for <linux-mm@kvack.org>; Sat, 14 Apr 2012 18:57:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334181627-26942-1-git-send-email-yinghan@google.com>
References: <1334181627-26942-1-git-send-email-yinghan@google.com>
Date: Sun, 15 Apr 2012 09:57:37 +0800
Message-ID: <CAJd=RBAr4tiCb2i94XNz9YkuzVZPCj8B=1LQTOmBF3tKkRtSJQ@mail.gmail.com>
Subject: Re: [PATCH V2 5/5] memcg: change the target nr_to_reclaim for each
 memcg under kswapd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 6:00 AM, Ying Han <yinghan@google.com> wrote:
> Under global background reclaim, the sc->nr_to_reclaim is set to
> ULONG_MAX. Now we are iterating all memcgs under the zone and we
> shouldn't pass the pressure from kswapd for each memcg.
>
> After all, the balance_pgdat() breaks after reclaiming SWAP_CLUSTER_MAX
> pages to prevent building up reclaim priorities.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 12 ++++++++++--
> =C2=A01 files changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d65eae4..ca70ec6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2083,9 +2083,18 @@ static void shrink_mem_cgroup_zone(int priority, s=
truct mem_cgroup_zone *mz,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_to_scan;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0enum lru_list lru;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed, nr_scanned;
> - =C2=A0 =C2=A0 =C2=A0 unsigned long nr_to_reclaim =3D sc->nr_to_reclaim;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr_to_reclaim;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct blk_plug plug;
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Under global background reclaim, the sc->n=
r_to_reclaim is set to
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* ULONG_MAX. Now we are iterating all memcgs=
 under the zone and we
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* shouldn't pass the pressure from kswapd fo=
r each memcg. After all,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* the balance_pgdat() breaks after reclaimin=
g SWAP_CLUSTER_MAX pages
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* to prevent building up reclaim priorities.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 nr_to_reclaim =3D min_t(unsigned long,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_to_reclaim, SWAP_CLUSTER_MAX);
> =C2=A0restart:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_reclaimed =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_scanned =3D sc->nr_scanned;
>
Since priority is one of the factors used in computing scan count, we could
change how to select a memcg for reclaim,

	return target_mem_cgroup ||
		mem_cgroup_soft_limit_exceeded(memcg) ||
		priority !=3D DEF_PRIORITY;

where detection of all mem groups under softlimit happens at DEF_PRIORITY-1=
.

Then selected mem groups are reclaimed in the current manner without change
in nr_to_reclaim, and sc->nr_reclaimed is distributed evenly among mem grou=
ps,
no matter softlimt is exceeded or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
