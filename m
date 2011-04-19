Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 02B678D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 14:02:54 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3JI2p0X018304
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:02:51 -0700
Received: from qyk35 (qyk35.prod.google.com [10.241.83.163])
	by hpaq12.eem.corp.google.com with ESMTP id p3JI2DPq024180
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:02:50 -0700
Received: by qyk35 with SMTP id 35so1805731qyk.13
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 11:02:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303235496-3060-3-git-send-email-yinghan@google.com>
References: <1303235496-3060-1-git-send-email-yinghan@google.com>
	<1303235496-3060-3-git-send-email-yinghan@google.com>
Date: Tue, 19 Apr 2011 11:02:48 -0700
Message-ID: <BANLkTingCh_TEDDtcsOzorxX80WwkAD00Q@mail.gmail.com>
Subject: Re: [PATCH 2/3] change the shrink_slab by passing scan_control.
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00248c6a84cadbe31604a1495052
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

--00248c6a84cadbe31604a1495052
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 19, 2011 at 10:51 AM, Ying Han <yinghan@google.com> wrote:

> This patch consolidates existing parameters to shrink_slab() to
> scan_control struct. This is needed later to pass the same struct
> to shrinkers.
>
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  fs/drop_caches.c   |    7 ++++++-
>  include/linux/mm.h |    4 ++--
>  mm/vmscan.c        |   12 ++++++------
>  3 files changed, 14 insertions(+), 9 deletions(-)
>
> diff --git a/fs/drop_caches.c b/fs/drop_caches.c
> index 816f88e..0e5ef62 100644
> --- a/fs/drop_caches.c
> +++ b/fs/drop_caches.c
> @@ -8,6 +8,7 @@
>  #include <linux/writeback.h>
>  #include <linux/sysctl.h>
>  #include <linux/gfp.h>
> +#include <linux/swap.h>
>
>  /* A global variable is a bit ugly, but it keeps the code simple */
>  int sysctl_drop_caches;
> @@ -36,9 +37,13 @@ static void drop_pagecache_sb(struct super_block *sb,
> void *unused)
>  static void drop_slab(void)
>  {
>        int nr_objects;
> +       struct scan_control sc = {
> +               .gfp_mask = GFP_KERNEL,
> +               .nr_scanned = 1000,
> +       };
>
>        do {
> -               nr_objects = shrink_slab(1000, GFP_KERNEL, 1000);
> +               nr_objects = shrink_slab(&sc, 1000);
>        } while (nr_objects > 10);
>  }
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0716517..42c2bf4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -21,6 +21,7 @@ struct anon_vma;
>  struct file_ra_state;
>  struct user_struct;
>  struct writeback_control;
> +struct scan_control;
>
>  #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly
> */
>  extern unsigned long max_mapnr;
> @@ -1601,8 +1602,7 @@ int in_gate_area_no_task(unsigned long addr);
>
>  int drop_caches_sysctl_handler(struct ctl_table *, int,
>                                        void __user *, size_t *, loff_t *);
> -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -                       unsigned long lru_pages);
> +unsigned long shrink_slab(struct scan_control *sc, unsigned long
> lru_pages);
>
>  #ifndef CONFIG_MMU
>  #define randomize_va_space 0
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 08b1ab5..9662166 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -159,11 +159,12 @@ EXPORT_SYMBOL(unregister_shrinker);
>  *
>  * Returns the number of slab objects which we shrunk.
>  */
> -unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> -                       unsigned long lru_pages)
> +unsigned long shrink_slab(struct scan_control *sc, unsigned long
> lru_pages)
>  {
>        struct shrinker *shrinker;
>        unsigned long ret = 0;
> +       unsigned long scanned = sc->nr_scanned;
> +       gfp_t gfp_mask = sc->gfp_mask;
>
>        if (scanned == 0)
>                scanned = SWAP_CLUSTER_MAX;
> @@ -2005,7 +2006,7 @@ static unsigned long do_try_to_free_pages(struct
> zonelist *zonelist,
>                                lru_pages += zone_reclaimable_pages(zone);
>                        }
>
> -                       shrink_slab(sc->nr_scanned, sc->gfp_mask,
> lru_pages);
> +                       shrink_slab(sc, lru_pages);
>                        if (reclaim_state) {
>                                sc->nr_reclaimed +=
> reclaim_state->reclaimed_slab;
>                                reclaim_state->reclaimed_slab = 0;
> @@ -2371,8 +2372,7 @@ loop_again:
>                                        end_zone, 0))
>                                shrink_zone(priority, zone, &sc);
>                        reclaim_state->reclaimed_slab = 0;
> -                       nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
> -                                               lru_pages);
> +                       nr_slab = shrink_slab(&sc, lru_pages);
>                        sc.nr_reclaimed += reclaim_state->reclaimed_slab;
>                        total_scanned += sc.nr_scanned;
>
> @@ -2949,7 +2949,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t
> gfp_mask, unsigned int order)
>                        unsigned long lru_pages =
> zone_reclaimable_pages(zone);
>
>                        /* No reclaimable slab or very low memory pressure
> */
> -                       if (!shrink_slab(sc.nr_scanned, gfp_mask,
> lru_pages))
> +                       if (!shrink_slab(&sc, lru_pages))
>                                break;
>
>                        /* Freed enough memory */
> --
> 1.7.3.1
>
>

--00248c6a84cadbe31604a1495052
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 19, 2011 at 10:51 AM, Ying H=
an <span dir=3D"ltr">&lt;<a href=3D"mailto:yinghan@google.com">yinghan@goog=
le.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"=
margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
This patch consolidates existing parameters to shrink_slab() to<br>
scan_control struct. This is needed later to pass the same struct<br>
to shrinkers.<br>
<br>
Signed-off-by: Ying Han &lt;<a href=3D"mailto:yinghan@google.com">yinghan@g=
oogle.com</a>&gt;<br>
---<br>
=A0fs/drop_caches.c =A0 | =A0 =A07 ++++++-<br>
=A0include/linux/mm.h | =A0 =A04 ++--<br>
=A0mm/vmscan.c =A0 =A0 =A0 =A0| =A0 12 ++++++------<br>
=A03 files changed, 14 insertions(+), 9 deletions(-)<br>
<br>
diff --git a/fs/drop_caches.c b/fs/drop_caches.c<br>
index 816f88e..0e5ef62 100644<br>
--- a/fs/drop_caches.c<br>
+++ b/fs/drop_caches.c<br>
@@ -8,6 +8,7 @@<br>
=A0#include &lt;linux/writeback.h&gt;<br>
=A0#include &lt;linux/sysctl.h&gt;<br>
=A0#include &lt;linux/gfp.h&gt;<br>
+#include &lt;linux/swap.h&gt;<br>
<br>
=A0/* A global variable is a bit ugly, but it keeps the code simple */<br>
=A0int sysctl_drop_caches;<br>
@@ -36,9 +37,13 @@ static void drop_pagecache_sb(struct super_block *sb, vo=
id *unused)<br>
=A0static void drop_slab(void)<br>
=A0{<br>
 =A0 =A0 =A0 =A0int nr_objects;<br>
+ =A0 =A0 =A0 struct scan_control sc =3D {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 .nr_scanned =3D 1000,<br>
+ =A0 =A0 =A0 };<br>
<br>
 =A0 =A0 =A0 =A0do {<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_objects =3D shrink_slab(1000, GFP_KERNEL, =
1000);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_objects =3D shrink_slab(&amp;sc, 1000);<br=
>
 =A0 =A0 =A0 =A0} while (nr_objects &gt; 10);<br>
=A0}<br>
<br>
diff --git a/include/linux/mm.h b/include/linux/mm.h<br>
index 0716517..42c2bf4 100644<br>
--- a/include/linux/mm.h<br>
+++ b/include/linux/mm.h<br>
@@ -21,6 +21,7 @@ struct anon_vma;<br>
=A0struct file_ra_state;<br>
=A0struct user_struct;<br>
=A0struct writeback_control;<br>
+struct scan_control;<br>
<br>
=A0#ifndef CONFIG_DISCONTIGMEM =A0 =A0 =A0 =A0 =A0/* Don&#39;t use mapnrs, =
do it properly */<br>
=A0extern unsigned long max_mapnr;<br>
@@ -1601,8 +1602,7 @@ int in_gate_area_no_task(unsigned long addr);<br>
<br>
=A0int drop_caches_sysctl_handler(struct ctl_table *, int,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0void __user *, size_t *, loff_t *);<br>
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages);<br>
+unsigned long shrink_slab(struct scan_control *sc, unsigned long lru_pages=
);<br>
<br>
=A0#ifndef CONFIG_MMU<br>
=A0#define randomize_va_space 0<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
index 08b1ab5..9662166 100644<br>
--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
@@ -159,11 +159,12 @@ EXPORT_SYMBOL(unregister_shrinker);<br>
 =A0*<br>
 =A0* Returns the number of slab objects which we shrunk.<br>
 =A0*/<br>
-unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long lru_pages)<br>
+unsigned long shrink_slab(struct scan_control *sc, unsigned long lru_pages=
)<br>
=A0{<br>
 =A0 =A0 =A0 =A0struct shrinker *shrinker;<br>
 =A0 =A0 =A0 =A0unsigned long ret =3D 0;<br>
+ =A0 =A0 =A0 unsigned long scanned =3D sc-&gt;nr_scanned;<br>
+ =A0 =A0 =A0 gfp_t gfp_mask =3D sc-&gt;gfp_mask;<br>
<br>
 =A0 =A0 =A0 =A0if (scanned =3D=3D 0)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scanned =3D SWAP_CLUSTER_MAX;<br>
@@ -2005,7 +2006,7 @@ static unsigned long do_try_to_free_pages(struct zone=
list *zonelist,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lru_pages +=
=3D zone_reclaimable_pages(zone);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab(sc-&gt;nr_scanned=
, sc-&gt;gfp_mask, lru_pages);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink_slab(sc, lru_pages);<b=
r>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (reclaim_state) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc-&gt;nr_r=
eclaimed +=3D reclaim_state-&gt;reclaimed_slab;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_sta=
te-&gt;reclaimed_slab =3D 0;<br>
@@ -2371,8 +2372,7 @@ loop_again:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0end_zone, 0))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone=
(priority, zone, &amp;sc);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_state-&gt;reclaimed=
_slab =3D 0;<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab =3D shrink_slab(sc.nr=
_scanned, GFP_KERNEL,<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 lru_pages);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_slab =3D shrink_slab(&amp;=
sc, lru_pages);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sc.nr_reclaimed +=3D reclai=
m_state-&gt;reclaimed_slab;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_scanned +=3D sc.nr_sc=
anned;<br>
<br>
@@ -2949,7 +2949,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gf=
p_mask, unsigned int order)<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long lru_pages =3D=
 zone_reclaimable_pages(zone);<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* No reclaimable slab or v=
ery low memory pressure */<br>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!shrink_slab(sc.nr_scanne=
d, gfp_mask, lru_pages))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!shrink_slab(&amp;sc, lru=
_pages))<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Freed enough memory */<b=
r>
<font color=3D"#888888">--<br>
1.7.3.1<br>
<br>
</font></blockquote></div><br>

--00248c6a84cadbe31604a1495052--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
