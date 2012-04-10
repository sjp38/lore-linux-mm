Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 1F3C96B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 11:00:50 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so4231310vbb.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2012 08:00:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334000524-23972-1-git-send-email-yinghan@google.com>
References: <1334000524-23972-1-git-send-email-yinghan@google.com>
Date: Tue, 10 Apr 2012 23:00:48 +0800
Message-ID: <CAJd=RBD6Sb4zmUkMTaT12cgwFLAQYmh6HuK1hLMa_Dda6FHBLQ@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Tue, Apr 10, 2012 at 3:42 AM, Ying Han <yinghan@google.com> wrote:
> This reverts commit c38446cc65e1f2b3eb8630c53943b94c4f65f670.
>
> Before the commit, the code makes senses to me but not after the commit. =
The
> "nr_reclaimed" is the number of pages reclaimed by scanning through the m=
emcg's
> lru lists. The "nr_to_reclaim" is the target value for the whole function=
. For
> example, we like to early break the reclaim if reclaimed 32 pages under d=
irect
> reclaim (not DEF_PRIORITY).
>
> After the reverted commit, the target "nr_to_reclaim" is decremented each=
 time
> by "nr_reclaimed" but we still use it to compare the "nr_reclaimed". It j=
ust
> doesn't make sense to me...
>
I downloaded mm/vmscan.c from the next tree a couple minutes ago, and
see
		.nr_to_reclaim =3D SWAP_CLUSTER_MAX,
and
	nr_reclaimed =3D do_try_to_free_pages(zonelist, &sc, &shrink);

in try_to_free_pages().

I also see
		total_scanned +=3D sc->nr_scanned;
		if (sc->nr_reclaimed >=3D sc->nr_to_reclaim)
			goto out;

in do_try_to_free_pages(),

then would you please say a few words about the sense
of the check of nr_to_reclaim?


> Signed-off-by: Ying Han <yinghan@google.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 =C2=A07 +------
> =C2=A01 files changed, 1 insertions(+), 6 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33c332b..1a51868 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2107,12 +2107,7 @@ restart:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * with multiple p=
rocesses reclaiming pages, the total
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * freeing target =
can get unreasonably large.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nr_reclaimed >=3D =
nr_to_reclaim)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_to_reclaim =3D 0;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nr_to_reclaim -=3D nr_reclaimed;
> -
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!nr_to_reclaim && =
priority < DEF_PRIORITY)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nr_reclaimed >=3D =
nr_to_reclaim && priority < DEF_PRIORITY)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0blk_finish_plug(&plug);
> --
> 1.7.7.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
