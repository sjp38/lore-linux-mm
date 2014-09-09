Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 86D0E6B0036
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 04:17:52 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lf12so16678495vcb.34
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 01:17:52 -0700 (PDT)
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
        by mx.google.com with ESMTPS id vp6si5595911vdc.5.2014.09.09.01.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 01:17:51 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id id10so16655630vcb.16
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 01:17:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140908115718.GL17501@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de> <53E4EC53.1050904@suse.cz>
 <20140811121241.GD7970@suse.de> <53E8B83D.1070004@suse.cz>
 <20140902140116.GD29501@cmpxchg.org> <20140905101451.GF17501@suse.de>
 <CALq1K=JO2b-=iq40RRvK8JFFbrzyH5EyAp5jyS50CeV0P3eQcA@mail.gmail.com> <20140908115718.GL17501@suse.de>
From: Leon Romanovsky <leon@leon.nu>
Date: Tue, 9 Sep 2014 11:17:31 +0300
Message-ID: <CALq1K=K=2n01SkVriJNjALPgbJp973kJXFh7xnafi3dUAq15Rw@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: Fix setting of ZONE_FAIR_DEPLETED on UP v2
Content-Type: multipart/alternative; boundary=bcaec529a0074e481d05029d92b4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

--bcaec529a0074e481d05029d92b4
Content-Type: text/plain; charset=UTF-8

Hi Mel,

On Mon, Sep 8, 2014 at 2:57 PM, Mel Gorman <mgorman@suse.de> wrote:

> Commit 4ffeaf35 (mm: page_alloc: reduce cost of the fair zone allocation
> policy) arguably broke the fair zone allocation policy on UP with these
> hunks.
>
> a/mm/page_alloc.c
> b/mm/page_alloc.c
> @@ -1612,6 +1612,9 @@ again:
>         }
>
>         __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> +       if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
> +           !zone_is_fair_depleted(zone))
> +               zone_set_flag(zone, ZONE_FAIR_DEPLETED);
>
>         __count_zone_vm_events(PGALLOC, zone, 1 << order);
>         zone_statistics(preferred_zone, zone, gfp_flags);
> @@ -1966,8 +1985,10 @@ zonelist_scan:
>                 if (alloc_flags & ALLOC_FAIR) {
>                         if (!zone_local(preferred_zone, zone))
>                                 break;
> -                       if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
> +                       if (zone_is_fair_depleted(zone)) {
> +                               nr_fair_skipped++;
>                                 continue;
> +                       }
>                 }
>
> A <= check was replaced with a ==. On SMP it doesn't matter because
> negative values are returned as zero due to per-CPU drift which is not
> possible in the UP case. Vlastimil Babka correctly pointed out that this
> can wrap negative due to high-order allocations.
>
> However, Leon Romanovsky pointed out that a <= check on zone_page_state
> was never correct as zone_page_state returns unsigned long so the root
> cause of the breakage was the <= check in the first place.
>
> zone_page_state is an API hazard because of the difference in behaviour
> between SMP and UP is very surprising. There is a good reason to allow
> NR_ALLOC_BATCH to go negative -- when the counter is reset the negative
> value takes recent activity into account. This patch makes zone_page_state
> behave the same on SMP and UP as saving one branch on UP is not likely to
> make a measurable performance difference.
>
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Leon Romanovsky <leon@leon.nu>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/vmstat.h | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 82e7db7..cece0f0 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -131,10 +131,8 @@ static inline unsigned long zone_page_state(struct
> zone *zone,
>                                         enum zone_stat_item item)
>  {
>         long x = atomic_long_read(&zone->vm_stat[item]);
> -#ifdef CONFIG_SMP
>         if (x < 0)
>                 x = 0;
> -#endif
>         return x;
>  }
>

Since you are changing vmstat.h, what do you think about change in all
similiar places?

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 82e7db7..88d3d3e 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -120,10 +120,8 @@ static inline void zone_page_state_add(long x, struct
zone *zone,
 static inline unsigned long global_page_state(enum zone_stat_item item)
 {
        long x = atomic_long_read(&vm_stat[item]);
-#ifdef CONFIG_SMP
        if (x < 0)
                x = 0;
-#endif
        return x;
 }

@@ -131,10 +129,8 @@ static inline unsigned long zone_page_state(struct
zone *zone,
                                        enum zone_stat_item item)
 {
        long x = atomic_long_read(&zone->vm_stat[item]);
-#ifdef CONFIG_SMP
        if (x < 0)
                x = 0;
-#endif
        return x;
 }

@@ -153,10 +149,9 @@ static inline unsigned long
zone_page_state_snapshot(struct zone *zone,
        int cpu;
        for_each_online_cpu(cpu)
                x += per_cpu_ptr(zone->pageset, cpu)->vm_stat_diff[item];
-
+#endif
        if (x < 0)
                x = 0;
-#endif
        return x;
 }


-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--bcaec529a0074e481d05029d92b4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Mel,<br><div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">On Mon, Sep 8, 2014 at 2:57 PM, Mel Gorman <span dir=3D"lt=
r">&lt;<a href=3D"mailto:mgorman@suse.de" target=3D"_blank">mgorman@suse.de=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"=
>Commit 4ffeaf35 (mm: page_alloc: reduce cost of the fair zone allocation<b=
r>
policy) arguably broke the fair zone allocation policy on UP with these<br>
hunks.<br>
<br>
a/mm/page_alloc.c<br>
b/mm/page_alloc.c<br>
@@ -1612,6 +1612,9 @@ again:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1=
 &lt;&lt; order));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone_page_state(zone, NR_ALLOC_BATCH) =3D=
=3D 0 &amp;&amp;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0!zone_is_fair_depleted(zone))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_set_flag(zone,=
 ZONE_FAIR_DEPLETED);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __count_zone_vm_events(PGALLOC, zone, 1 &lt;&lt=
; order);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_statistics(preferred_zone, zone, gfp_flags=
);<br>
@@ -1966,8 +1985,10 @@ zonelist_scan:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (alloc_flags &am=
p; ALLOC_FAIR) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (!zone_local(preferred_zone, zone))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (zone_page_state(zone, NR_ALLOC_BATCH) &lt;=3D 0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (zone_is_fair_depleted(zone)) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nr_fair_skipped++;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
A &lt;=3D check was replaced with a =3D=3D. On SMP it doesn&#39;t matter be=
cause<br>
negative values are returned as zero due to per-CPU drift which is not<br>
possible in the UP case. Vlastimil Babka correctly pointed out that this<br=
>
can wrap negative due to high-order allocations.<br>
<br>
However, Leon Romanovsky pointed out that a &lt;=3D check on zone_page_stat=
e<br>
was never correct as zone_page_state returns unsigned long so the root<br>
cause of the breakage was the &lt;=3D check in the first place.<br>
<br>
zone_page_state is an API hazard because of the difference in behaviour<br>
between SMP and UP is very surprising. There is a good reason to allow<br>
NR_ALLOC_BATCH to go negative -- when the counter is reset the negative<br>
value takes recent activity into account. This patch makes zone_page_state<=
br>
behave the same on SMP and UP as saving one branch on UP is not likely to<b=
r>
make a measurable performance difference.<br>
<br>
Reported-by: Vlastimil Babka &lt;<a href=3D"mailto:vbabka@suse.cz">vbabka@s=
use.cz</a>&gt;<br>
Reported-by: Leon Romanovsky &lt;<a href=3D"mailto:leon@leon.nu">leon@leon.=
nu</a>&gt;<br>
Signed-off-by: Mel Gorman &lt;<a href=3D"mailto:mgorman@suse.de">mgorman@su=
se.de</a>&gt;<br>
---<br>
=C2=A0include/linux/vmstat.h | 2 --<br>
=C2=A01 file changed, 2 deletions(-)<br>
<br>
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h<br>
index 82e7db7..cece0f0 100644<br>
--- a/include/linux/vmstat.h<br>
+++ b/include/linux/vmstat.h<br>
@@ -131,10 +131,8 @@ static inline unsigned long zone_page_state(struct zon=
e *zone,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 enum zon=
e_stat_item item)<br>
=C2=A0{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 long x =3D atomic_long_read(&amp;zone-&gt;vm_st=
at[item]);<br>
-#ifdef CONFIG_SMP<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (x &lt; 0)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 x =3D 0;<br>
-#endif<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return x;<br>
=C2=A0}<br>
</blockquote></div><br>Since you are changing vmstat.h, what do you think a=
bout change in all similiar places? <br><br>diff --git a/include/linux/vmst=
at.h b/include/linux/vmstat.h<br>index 82e7db7..88d3d3e 100644<br>--- a/inc=
lude/linux/vmstat.h<br>+++ b/include/linux/vmstat.h<br>@@ -120,10 +120,8 @@=
 static inline void zone_page_state_add(long x, struct zone *zone,<br>=C2=
=A0static inline unsigned long global_page_state(enum zone_stat_item item)<=
br>=C2=A0{<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 long x =3D atomic_=
long_read(&amp;vm_stat[item]);<br>-#ifdef CONFIG_SMP<br>=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 if (x &lt; 0)<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 x =3D 0;<br>-#end=
if<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return x;<br>=C2=A0}<br>=
=C2=A0<br>@@ -131,10 +129,8 @@ static inline unsigned long zone_page_state(=
struct zone *zone,<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 enum zone_stat_item item)<br>=C2=A0{<br>=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 long x =3D atomic_long_read(&amp=
;zone-&gt;vm_stat[item]);<br>-#ifdef CONFIG_SMP<br>=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 if (x &lt; 0)<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 x =3D 0;<br>-#endif<br>=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return x;<br>=C2=A0}<br>=C2=A0<b=
r>@@ -153,10 +149,9 @@ static inline unsigned long zone_page_state_snapshot=
(struct zone *zone,<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int cpu;<=
br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for_each_online_cpu(cpu)<br>=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 x +=3D per_cpu_ptr(zone-&gt;pageset, cpu)-&gt;vm_stat_diff[=
item];<br>-<br>+#endif<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (x =
&lt; 0)<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 x =3D 0;<br>-#endif<br>=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 return x;<br>=C2=A0}<br></div><div class=3D"gmail_extra"=
><br clear=3D"all"><br>-- <br><div dir=3D"ltr"><div>Leon Romanovsky | Indep=
endent Linux Consultant<br><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0<a href=3D=
"http://www.leon.nu" target=3D"_blank">www.leon.nu</a>=C2=A0| <a href=3D"ma=
ilto:leon@leon.nu" target=3D"_blank">leon@leon.nu</a><br></div></div></div>
</div></div></div>

--bcaec529a0074e481d05029d92b4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
