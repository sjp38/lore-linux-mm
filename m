Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9185A6B01F0
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 16:57:04 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o7TKv0CM002628
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 13:57:00 -0700
Received: from qyk5 (qyk5.prod.google.com [10.241.83.133])
	by kpbe18.cbf.corp.google.com with ESMTP id o7TKuTJE020842
	for <linux-mm@kvack.org>; Sun, 29 Aug 2010 13:56:58 -0700
Received: by qyk5 with SMTP id 5so2420873qyk.11
        for <linux-mm@kvack.org>; Sun, 29 Aug 2010 13:56:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4C7ABD14.9050207@redhat.com>
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
	<AANLkTinCKJw2oaNgAvfm0RawbW4zuJMtMb2pUROeY2ij@mail.gmail.com>
	<4C7ABD14.9050207@redhat.com>
Date: Sun, 29 Aug 2010 13:56:14 -0700
Message-ID: <AANLkTikeog-fOq90Ek8qRYg4s_vw6hiG_7_132E1JR6R@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00163630f79f21c939048efc9449
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

--00163630f79f21c939048efc9449
Content-Type: text/plain; charset=ISO-8859-1

On Sun, Aug 29, 2010 at 1:03 PM, Rik van Riel <riel@redhat.com> wrote:

> On 08/29/2010 01:45 PM, Ying Han wrote:
>
>  There are few other places in vmscan where we check nr_swap_pages and
>> inactive_anon_is_low. Are we planning to change them to use
>> total_swap_pages
>> to be consistent ?
>>
>
> If that makes sense, maybe the check can just be moved into
> inactive_anon_is_low itself?
>

That was the initial patch posted, instead we changed to use
total_swap_pages instead. How this patch looks:

@@ -1605,6 +1605,9 @@ static int inactive_anon_is_low(struct zone *zone,
struct scan_control *sc)
 {
        int low;

+       if (total_swap_pages <= 0)
+               return 0;
+
        if (scanning_global_lru(sc))
                low = inactive_anon_is_low_global(zone);
        else
@@ -1856,7 +1859,7 @@ static void shrink_zone(int priority, struct zone
*zone,
         * Even if we did not try to evict anon pages at all, we want to
         * rebalance the anon lru active/inactive ratio.
         */
-       if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
+       if (inactive_anon_is_low(zone, sc))
                shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);

        throttle_vm_writeout(sc->gfp_mask);

--Ying

>
> --
> All rights reversed
>

--00163630f79f21c939048efc9449
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sun, Aug 29, 2010 at 1:03 PM, Rik van=
 Riel <span dir=3D"ltr">&lt;<a href=3D"mailto:riel@redhat.com">riel@redhat.=
com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;">
<div class=3D"im">On 08/29/2010 01:45 PM, Ying Han wrote:<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
There are few other places in vmscan where we check nr_swap_pages and<br>
inactive_anon_is_low. Are we planning to change them to use<br>
total_swap_pages<br>
to be consistent ?<br>
</blockquote>
<br></div>
If that makes sense, maybe the check can just be moved into<br>
inactive_anon_is_low itself?<br></blockquote><div><br></div><div>That was t=
he initial patch posted, instead we changed to use total_swap_pages instead=
. How this patch looks:</div><div><br></div><div><div>@@ -1605,6 +1605,9 @@=
 static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc=
)</div>
<div>=A0{</div><div>=A0=A0 =A0 =A0 =A0int low;</div><div>=A0</div><div>+ =
=A0 =A0 =A0 if (total_swap_pages &lt;=3D 0)</div><div>+ =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return 0;</div><div>+</div><div>=A0=A0 =A0 =A0 =A0if (scanning_glo=
bal_lru(sc))</div><div>=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0low =3D inactive_a=
non_is_low_global(zone);</div>
<div>=A0=A0 =A0 =A0 =A0else</div><div>@@ -1856,7 +1859,7 @@ static void shr=
ink_zone(int priority, struct zone *zone,</div><div>=A0=A0 =A0 =A0 =A0 * Ev=
en if we did not try to evict anon pages at all, we want to</div><div>=A0=
=A0 =A0 =A0 =A0 * rebalance the anon lru active/inactive ratio.</div>
<div>=A0=A0 =A0 =A0 =A0 */</div><div>- =A0 =A0 =A0 if (inactive_anon_is_low=
(zone, sc) &amp;&amp; nr_swap_pages &gt; 0)</div><div>+ =A0 =A0 =A0 if (ina=
ctive_anon_is_low(zone, sc))</div><div>=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sh=
rink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);</div>
<div>=A0</div><div>=A0=A0 =A0 =A0 =A0throttle_vm_writeout(sc-&gt;gfp_mask);=
</div></div><div><br></div><div>--Ying</div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex;"=
><font color=3D"#888888">
<br>
-- <br>
All rights reversed<br>
</font></blockquote></div><br>

--00163630f79f21c939048efc9449--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
