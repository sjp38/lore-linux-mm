Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 6B6A86B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 14:04:07 -0500 (EST)
Received: by qcsg1 with SMTP id g1so744447qcs.14
        for <linux-mm@kvack.org>; Mon, 23 Jan 2012 11:04:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
References: <CAJd=RBBG5X8=vkdRTCZ1bvTaVxPAVun9O+yiX0SM6yDzrxDGDQ@mail.gmail.com>
Date: Mon, 23 Jan 2012 11:04:06 -0800
Message-ID: <CALWz4iyB0oSMBsfLJYD+xrB7ua9bRg5FD=cw4Sc-EdG1iLynow@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: check mem cgroup over reclaimed
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Jan 22, 2012 at 5:55 PM, Hillf Danton <dhillf@gmail.com> wrote:
> To avoid reduction in performance of reclaimee, checking overreclaim is a=
dded
> after shrinking lru list, when pages are reclaimed from mem cgroup.
>
> If over reclaim occurs, shrinking remaining lru lists is skipped, and no =
more
> reclaim for reclaim/compaction.
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
>
> --- a/mm/vmscan.c =A0 =A0 =A0 Mon Jan 23 00:23:10 2012
> +++ b/mm/vmscan.c =A0 =A0 =A0 Mon Jan 23 09:57:20 2012
> @@ -2086,6 +2086,7 @@ static void shrink_mem_cgroup_zone(int p
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed, nr_scanned;
> =A0 =A0 =A0 =A0unsigned long nr_to_reclaim =3D sc->nr_to_reclaim;
> =A0 =A0 =A0 =A0struct blk_plug plug;
> + =A0 =A0 =A0 bool memcg_over_reclaimed =3D false;
>
> =A0restart:
> =A0 =A0 =A0 =A0nr_reclaimed =3D 0;
> @@ -2103,6 +2104,11 @@ restart:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_reclaim=
ed +=3D shrink_list(lru, nr_to_scan,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mz, sc, priority);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_over_=
reclaimed =3D !scanning_global_lru(mz)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 && (nr_reclaimed >=3D nr_to_reclaim);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg_o=
ver_reclaimed)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto out;

Why we need the change here? Do we have number to demonstrate?


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -2116,6 +2122,7 @@ restart:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nr_reclaimed >=3D nr_to_reclaim && pri=
ority < DEF_PRIORITY)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0}
> +out:
> =A0 =A0 =A0 =A0blk_finish_plug(&plug);
> =A0 =A0 =A0 =A0sc->nr_reclaimed +=3D nr_reclaimed;
>
> @@ -2127,7 +2134,8 @@ restart:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_active_list(SWAP_CLUSTER_MAX, mz, s=
c, priority, 0);
>
> =A0 =A0 =A0 =A0/* reclaim/compaction might need reclaim to continue */
> - =A0 =A0 =A0 if (should_continue_reclaim(mz, nr_reclaimed,
> + =A0 =A0 =A0 if (!memcg_over_reclaimed &&
> + =A0 =A0 =A0 =A0 =A0 should_continue_reclaim(mz, nr_reclaimed,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0sc->nr_scanned - nr_scanned, sc))

This changes the existing logic. What if the nr_reclaimed is greater
than nr_to_reclaim, but smaller than pages_for_compaction? The
existing logic is to continue reclaiming.

--Ying

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
