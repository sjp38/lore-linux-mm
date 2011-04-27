Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6BA9000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:48:21 -0400 (EDT)
Received: by vws4 with SMTP id 4so1637290vws.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:48:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427164708.1143395e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427164708.1143395e.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 17:48:18 +0900
Message-ID: <BANLkTin+rDOWGYq9dg-XcCWs+yT8Yw-VMw@mail.gmail.com>
Subject: Re: [PATCHv3] memcg: fix get_scan_count for small targets
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Apr 27, 2011 at 4:47 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> At memory reclaim, we determine the number of pages to be scanned
> per zone as
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(anon + file) >> priority.
> Assume
> =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D (anon + file) >> priority.
>
> If scan < SWAP_CLUSTER_MAX, the scan will be skipped for this time
> and priority gets higher. This has some problems.
>
> =C2=A01. This increases priority as 1 without any scan.
> =C2=A0 =C2=A0 To do scan in this priority, amount of pages should be larg=
er than 512M.
> =C2=A0 =C2=A0 If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and sc=
an will be
> =C2=A0 =C2=A0 batched, later. (But we lose 1 priority.)
> =C2=A0 =C2=A0 If memory size is below 16M, pages >> priority is 0 and no =
scan in
> =C2=A0 =C2=A0 DEF_PRIORITY forever.
>
> =C2=A02. If zone->all_unreclaimabe=3D=3Dtrue, it's scanned only when prio=
rity=3D=3D0.
> =C2=A0 =C2=A0 So, x86's ZONE_DMA will never be recoverred until the user =
of pages
> =C2=A0 =C2=A0 frees memory by itself.
>
> =C2=A03. With memcg, the limit of memory can be small. When using small m=
emcg,
> =C2=A0 =C2=A0 it gets priority < DEF_PRIORITY-2 very easily and need to c=
all
> =C2=A0 =C2=A0 wait_iff_congested().
> =C2=A0 =C2=A0 For doing scan before priorty=3D9, 64MB of memory should be=
 used.
>
> Then, this patch tries to scan SWAP_CLUSTER_MAX of pages in force...when
>
> =C2=A01. the target is enough small.
> =C2=A02. it's kswapd or memcg reclaim.
>
> Then we can avoid rapid priority drop and may be able to recover
> all_unreclaimable in a small zones. And this patch removes nr_saved_scan.
> This will allow scanning in this priority even when pages >> priority
> is very small.
>
> Changelog v2->v3
> =C2=A0- removed nr_saved_scan completely.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

The patch looks good to me but I have a nitpick about just coding style.
How about this? I think below looks better but it's just my private
opinion and I can't insist on my style. If you don't mind it, ignore.

barrios@barrios-desktop:~/linux-2.6$ git diff
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6771ea7..268e7d4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1817,8 +1817,28 @@ out:
                        scan >>=3D priority;
                        scan =3D div64_u64(scan * fraction[file], denominat=
or);
                }
-               nr[l] =3D nr_scan_try_batch(scan,
-                                         &reclaim_stat->nr_saved_scan[l]);
+
+               nr[l] =3D scan;
+               if (scan)
+                       continue;
+               /*
+                * If zone is small or memcg is small, nr[l] can be 0.
+                * This results no-scan on this priority and priority drop =
down.
+                * For global direct reclaim, it can visit next zone and te=
nd
+                * not to have problems. For global kswapd, it's for zone
+                * balancing and it need to scan a small amounts. When usin=
g
+                * memcg, priority drop can cause big latency. So, it's bet=
ter
+                * to scan small amount. See may_noscan above.
+                */
+               if (((anon + file) >> priority) < SWAP_CLUSTER_MAX) {
+                       /* kswapd does zone balancing and need to scan
this zone */
+                       /* memcg may have small limit and need to
avoid priority drop */
+                       if ((scanning_global_lru(sc) && current_is_kswapd()=
)
+                                       || !scanning_global_lru(sc)) {
+                               if (file || !noswap)
+                                       nr[l] =3D SWAP_CLUSTER_MAX;
+                       }
+               }
        }
 }


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
