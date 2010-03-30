Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B5DCE6B01FC
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 06:17:18 -0400 (EDT)
Received: by pzk6 with SMTP id 6so2414805pzk.1
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 03:17:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100330055304.GA2983@sli10-desk.sh.intel.com>
References: <20100330055304.GA2983@sli10-desk.sh.intel.com>
Date: Tue, 30 Mar 2010 19:17:17 +0900
Message-ID: <28c262361003300317g6df68fc6m4385cfbe3e8a1b04@mail.gmail.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 30, 2010 at 2:53 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> With it, our tmpfs test always oom. The test has a lot of rotated anon
> pages and cause percent[0] zero. Actually the percent[0] is a very small
> value, but our calculation round it to zero. The commit makes vmscan
> completely skip anon pages and cause oops.
> An option is if percent[x] is zero in get_scan_ratio(), forces it
> to 1. See below patch.
> But the offending commit still changes behavior. Without the commit, we s=
can
> all pages if priority is zero, below patch doesn't fix this. Don't know i=
f
> It's required to fix this too.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 79c8098..d5cc34e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1604,6 +1604,18 @@ static void get_scan_ratio(struct zone *zone, stru=
ct scan_control *sc,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Normalize to percentages */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[0] =3D 100 * ap / (ap + fp + 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0percent[1] =3D 100 - percent[0];
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* if percent[x] is small and rounded to 0, t=
his case doesn't mean we
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* should skip scan. Give it at least 1% shar=
e.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (percent[0] =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[0] =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[1] =3D 99;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (percent[1] =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[0] =3D 99;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percent[1] =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0}
>
> =C2=A0/*
>

Yes. It made subtle change.
But we should not depend that change.
Current logic seems to be good and clear than old.
I think you were lucky at that time by not-good and not-clear logic.

BTW, How about this?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 79c8098..f0df563 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1646,11 +1646,6 @@ static void shrink_zone(int priority, struct zone *z=
one,
                int file =3D is_file_lru(l);
                unsigned long scan;

-               if (percent[file] =3D=3D 0) {
-                       nr[l] =3D 0;
-                       continue;
-               }
-
                scan =3D zone_nr_lru_pages(zone, sc, l);
                if (priority) {
                        scan >>=3D priority;




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
