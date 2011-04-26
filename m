Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEB19000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 13:36:59 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p3QHaqDp003002
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:36:54 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by kpbe12.cbf.corp.google.com with ESMTP id p3QHaB17018645
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:36:51 -0700
Received: by qwi2 with SMTP id 2so602894qwi.22
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 10:36:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 26 Apr 2011 10:36:51 -0700
Message-ID: <BANLkTikACmxYqczKtJjO_FVWCy2=rVjUMA@mail.gmail.com>
Subject: Re: [PATCH] fix get_scan_count for working well with small targets
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=000e0ce008bcf4e0e304a1d5c433
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>

--000e0ce008bcf4e0e304a1d5c433
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Apr 26, 2011 at 2:17 AM, KAMEZAWA Hiroyuki <
kamezawa.hiroyu@jp.fujitsu.com> wrote:

> At memory reclaim, we determine the number of pages to be scanned
> per zone as
>        (anon + file) >> priority.
> Assume
>        scan = (anon + file) >> priority.
>
> If scan < SWAP_CLUSTER_MAX, shlink_list will be skipped for this
> priority and results no-sacn.  This has some problems.
>
>  1. This increases priority as 1 without any scan.
>     To do scan in DEF_PRIORITY always, amount of pages should be larger
> than
>     512M. If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan
> will be
>     batched, later. (But we lose 1 priority.)
>     But if the amount of pages is smaller than 16M, no scan at priority==0
>     forever.
>
>  2. If zone->all_unreclaimabe==true, it's scanned only when priority==0.
>     So, x86's ZONE_DMA will never be recoverred until the user of pages
>     frees memory by itself.
>
>  3. With memcg, the limit of memory can be small. When using small memcg,
>     it gets priority < DEF_PRIORITY-2 very easily and need to call
>     wait_iff_congested().
>     For doing scan before priorty=9, 64MB of memory should be used.
>
> This patch tries to scan SWAP_CLUSTER_MAX of pages in force...when
>
>  1. the target is enough small.
>  2. it's kswapd or memcg reclaim.
>
> Then we can avoid rapid priority drop and may be able to recover
> all_unreclaimable in a small zones.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   31 ++++++++++++++++++++++++++-----
>  1 file changed, 26 insertions(+), 5 deletions(-)
>
> Index: memcg/mm/vmscan.c
> ===================================================================
> --- memcg.orig/mm/vmscan.c
> +++ memcg/mm/vmscan.c
> @@ -1737,6 +1737,16 @@ static void get_scan_count(struct zone *
>        u64 fraction[2], denominator;
>        enum lru_list l;
>        int noswap = 0;
> +       int may_noscan = 0;
> +
> +
>
extra line?


> +       anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> +               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> +       file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> +               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> +
> +       if (((anon + file) >> priority) < SWAP_CLUSTER_MAX)
> +               may_noscan = 1;
>
>        /* If we have no swap space, do not bother scanning anon pages. */
>        if (!sc->may_swap || (nr_swap_pages <= 0)) {
> @@ -1747,11 +1757,6 @@ static void get_scan_count(struct zone *
>                goto out;
>        }
>
> -       anon  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +
> -               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON);
> -       file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
> -               zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
> -
>        if (scanning_global_lru(sc)) {
>                free  = zone_page_state(zone, NR_FREE_PAGES);
>                /* If we have very few page cache pages,
> @@ -1814,10 +1819,26 @@ out:
>                unsigned long scan;
>
>                scan = zone_nr_lru_pages(zone, sc, l);
> +
>
extra line?

>                if (priority || noswap) {
>                        scan >>= priority;
>                        scan = div64_u64(scan * fraction[file],
> denominator);
>                }
> +
> +               if (!scan &&
> +                   may_noscan &&
> +                   (current_is_kswapd() || !scanning_global_lru(sc))) {
> +                       /*
> +                        * if we do target scan, the whole amount of memory
> +                        * can be too small to scan with low priority
> value.
> +                        * This raise up priority rapidly without any scan.
> +                        * Avoid that and give some scan.
> +                        */
> +                       if (file)
> +                               scan = SWAP_CLUSTER_MAX;
> +                       else if (!noswap && (fraction[anon] >
> fraction[file]*16))
> +                               scan = SWAP_CLUSTER_MAX;
> +               }
>
Ok, so we are changing the global kswapd, and per-memcg bg and direct
reclaim both. Just to be clear here.
Also, how did we calculated the "16" to be the fraction of anon vs file?

               nr[l] = nr_scan_try_batch(scan,
>                                          &reclaim_stat->nr_saved_scan[l]);
>        }
>
> Thank you

--Ying

--000e0ce008bcf4e0e304a1d5c433
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Tue, Apr 26, 2011 at 2:17 AM, KAMEZAW=
A Hiroyuki <span dir=3D"ltr">&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujit=
su.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;</span> wrote:<br><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex;">
At memory reclaim, we determine the number of pages to be scanned<br>
per zone as<br>
 =A0 =A0 =A0 =A0(anon + file) &gt;&gt; priority.<br>
Assume<br>
 =A0 =A0 =A0 =A0scan =3D (anon + file) &gt;&gt; priority.<br>
<br>
If scan &lt; SWAP_CLUSTER_MAX, shlink_list will be skipped for this<br>
priority and results no-sacn. =A0This has some problems.<br>
<br>
 =A01. This increases priority as 1 without any scan.<br>
 =A0 =A0 To do scan in DEF_PRIORITY always, amount of pages should be large=
r than<br>
 =A0 =A0 512M. If pages&gt;&gt;priority &lt; SWAP_CLUSTER_MAX, it&#39;s rec=
orded and scan will be<br>
 =A0 =A0 batched, later. (But we lose 1 priority.)<br>
 =A0 =A0 But if the amount of pages is smaller than 16M, no scan at priorit=
y=3D=3D0<br>
 =A0 =A0 forever.<br>
<br>
 =A02. If zone-&gt;all_unreclaimabe=3D=3Dtrue, it&#39;s scanned only when p=
riority=3D=3D0.<br>
 =A0 =A0 So, x86&#39;s ZONE_DMA will never be recoverred until the user of =
pages<br>
 =A0 =A0 frees memory by itself.<br>
<br>
 =A03. With memcg, the limit of memory can be small. When using small memcg=
,<br>
 =A0 =A0 it gets priority &lt; DEF_PRIORITY-2 very easily and need to call<=
br>
 =A0 =A0 wait_iff_congested().<br>
 =A0 =A0 For doing scan before priorty=3D9, 64MB of memory should be used.<=
br>
<br>
This patch tries to scan SWAP_CLUSTER_MAX of pages in force...when<br>
<br>
 =A01. the target is enough small.<br>
 =A02. it&#39;s kswapd or memcg reclaim.<br>
<br>
Then we can avoid rapid priority drop and may be able to recover<br>
all_unreclaimable in a small zones.<br>
<br>
Signed-off-by: KAMEZAWA Hiroyuki &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.f=
ujitsu.com">kamezawa.hiroyu@jp.fujitsu.com</a>&gt;<br>
---<br>
=A0mm/vmscan.c | =A0 31 ++++++++++++++++++++++++++-----<br>
=A01 file changed, 26 insertions(+), 5 deletions(-)<br>
<br>
Index: memcg/mm/vmscan.c<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
--- memcg.orig/mm/vmscan.c<br>
+++ memcg/mm/vmscan.c<br>
@@ -1737,6 +1737,16 @@ static void get_scan_count(struct zone *<br>
 =A0 =A0 =A0 =A0u64 fraction[2], denominator;<br>
 =A0 =A0 =A0 =A0enum lru_list l;<br>
 =A0 =A0 =A0 =A0int noswap =3D 0;<br>
+ =A0 =A0 =A0 int may_noscan =3D 0;<br>
+<br>
+<br></blockquote><div>extra line?</div><div>=A0</div><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex;">
+ =A0 =A0 =A0 anon =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON=
);<br>
+ =A0 =A0 =A0 file =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +<br=
>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE=
);<br>
+<br>
+ =A0 =A0 =A0 if (((anon + file) &gt;&gt; priority) &lt; SWAP_CLUSTER_MAX)<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 may_noscan =3D 1;<br>
<br>
 =A0 =A0 =A0 =A0/* If we have no swap space, do not bother scanning anon pa=
ges. */<br>
 =A0 =A0 =A0 =A0if (!sc-&gt;may_swap || (nr_swap_pages &lt;=3D 0)) {<br>
@@ -1747,11 +1757,6 @@ static void get_scan_count(struct zone *<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;<br>
 =A0 =A0 =A0 =A0}<br>
<br>
- =A0 =A0 =A0 anon =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_ANON) +<br=
>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_nr_lru_pages(zone, sc, LRU_INACTIVE_ANON=
);<br>
- =A0 =A0 =A0 file =A0=3D zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +<br=
>
- =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE=
);<br>
-<br>
 =A0 =A0 =A0 =A0if (scanning_global_lru(sc)) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free =A0=3D zone_page_state(zone, NR_FREE_P=
AGES);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* If we have very few page cache pages,<br=
>
@@ -1814,10 +1819,26 @@ out:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scan;<br>
<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scan =3D zone_nr_lru_pages(zone, sc, l);<br=
>
+<br></blockquote><div>extra line?</div><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priority || noswap) {<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scan &gt;&gt;=3D priority;<=
br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scan =3D div64_u64(scan * f=
raction[file], denominator);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}<br>
+<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!scan &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 may_noscan &amp;&amp;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (current_is_kswapd() || !scanning_glo=
bal_lru(sc))) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if we do target scan, th=
e whole amount of memory<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can be too small to scan=
 with low priority value.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This raise up priority r=
apidly without any scan.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Avoid that and give some=
 scan.<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (file)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D SWAP=
_CLUSTER_MAX;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (!noswap &amp;&amp; (=
fraction[anon] &gt; fraction[file]*16))<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 scan =3D SWAP=
_CLUSTER_MAX;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br></blockquote><div>Ok, so we are changing=
 the global kswapd, and per-memcg bg and direct reclaim both. Just to be cl=
ear here.=A0</div><div>Also, how did we calculated the &quot;16&quot; to be=
 the fraction of anon vs file?</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex;">
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr[l] =3D nr_scan_try_batch(scan,<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0&amp;reclaim_stat-&gt;nr_saved_scan[l]);<br>
 =A0 =A0 =A0 =A0}<br>
<br></blockquote><div>Thank you</div><div>=A0</div><div>--Ying=A0</div></di=
v><br>

--000e0ce008bcf4e0e304a1d5c433--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
