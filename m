Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 59B6C6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 00:32:41 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id lf12so18226283vcb.34
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 21:32:41 -0700 (PDT)
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
        by mx.google.com with ESMTPS id yq20si6608361vdb.38.2014.09.09.21.32.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 21:32:40 -0700 (PDT)
Received: by mail-vc0-f181.google.com with SMTP id ij19so4235165vcb.26
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 21:32:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140909131540.GA10568@cmpxchg.org>
References: <20140909131540.GA10568@cmpxchg.org>
From: Leon Romanovsky <leon@leon.nu>
Date: Wed, 10 Sep 2014 07:32:20 +0300
Message-ID: <CALq1K=LFd_MWYUMGhZxu4yb-u5WcDqb=DvY4N3P+wV0WO3Zq_g@mail.gmail.com>
Subject: Re: [patch resend] mm: page_alloc: fix zone allocation fairness on UP
Content-Type: multipart/alternative; boundary=089e01634bf0d26ed50502ae8a7f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

--089e01634bf0d26ed50502ae8a7f
Content-Type: text/plain; charset=UTF-8

Hi Johaness,


On Tue, Sep 9, 2014 at 4:15 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:

> The zone allocation batches can easily underflow due to higher-order
> allocations or spills to remote nodes.  On SMP that's fine, because
> underflows are expected from concurrency and dealt with by returning
> 0.  But on UP, zone_page_state will just return a wrapped unsigned
> long, which will get past the <= 0 check and then consider the zone
> eligible until its watermarks are hit.
>
> 3a025760fc15 ("mm: page_alloc: spill to remote nodes before waking
> kswapd") already made the counter-resetting use atomic_long_read() to
> accomodate underflows from remote spills, but it didn't go all the way
> with it.  Make it clear that these batches are expected to go negative
> regardless of concurrency, and use atomic_long_read() everywhere.
>
> Fixes: 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> Reported-by: Vlastimil Babka <vbabka@suse.cz>
> Reported-by: Leon Romanovsky <leon@leon.nu>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Cc: "3.12+" <stable@kernel.org>
> ---
>  mm/page_alloc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>
> Sorry I forgot to CC you, Leon.  Resend with updated Tags.
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 18cee0d4c8a2..eee961958021 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1612,7 +1612,7 @@ again:
>         }
>
>         __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> -       if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
> +       if (atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]) <= 0 &&
>             !zone_is_fair_depleted(zone))
>                 zone_set_flag(zone, ZONE_FAIR_DEPLETED);
>
> @@ -5701,9 +5701,8 @@ static void __setup_per_zone_wmarks(void)
>                 zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp
> >> 1);
>
>                 __mod_zone_page_state(zone, NR_ALLOC_BATCH,
> -                                     high_wmark_pages(zone) -
> -                                     low_wmark_pages(zone) -
> -                                     zone_page_state(zone,
> NR_ALLOC_BATCH));
> +                       high_wmark_pages(zone) - low_wmark_pages(zone) -
> +                       atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
>
>                 setup_zone_migrate_reserve(zone);
>                 spin_unlock_irqrestore(&zone->lock, flags);
>

I think the better way will be to apply Mel's patch
https://lkml.org/lkml/2014/9/8/214 which fix zone_page_state shadow casting
issue and convert all atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH])) to
zone_page__state(zone, NR_ALLOC_BATCH). This move will unify access to
vm_stat.



> --
> 2.0.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--089e01634bf0d26ed50502ae8a7f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Johaness,<br><div class=3D"gmail_extra"><br><br><div cl=
ass=3D"gmail_quote">On Tue, Sep 9, 2014 at 4:15 PM, Johannes Weiner <span d=
ir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_blank">hann=
es@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pad=
ding-left:1ex">The zone allocation batches can easily underflow due to high=
er-order<br>
allocations or spills to remote nodes.=C2=A0 On SMP that&#39;s fine, becaus=
e<br>
underflows are expected from concurrency and dealt with by returning<br>
0.=C2=A0 But on UP, zone_page_state will just return a wrapped unsigned<br>
long, which will get past the &lt;=3D 0 check and then consider the zone<br=
>
eligible until its watermarks are hit.<br>
<br>
3a025760fc15 (&quot;mm: page_alloc: spill to remote nodes before waking<br>
kswapd&quot;) already made the counter-resetting use atomic_long_read() to<=
br>
accomodate underflows from remote spills, but it didn&#39;t go all the way<=
br>
with it.=C2=A0 Make it clear that these batches are expected to go negative=
<br>
regardless of concurrency, and use atomic_long_read() everywhere.<br>
<br>
Fixes: 81c0a2bb515f (&quot;mm: page_alloc: fair zone allocator policy&quot;=
)<br>
Reported-by: Vlastimil Babka &lt;<a href=3D"mailto:vbabka@suse.cz">vbabka@s=
use.cz</a>&gt;<br>
Reported-by: Leon Romanovsky &lt;<a href=3D"mailto:leon@leon.nu">leon@leon.=
nu</a>&gt;<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
Acked-by: Mel Gorman &lt;<a href=3D"mailto:mgorman@suse.de">mgorman@suse.de=
</a>&gt;<br>
Cc: &quot;3.12+&quot; &lt;<a href=3D"mailto:stable@kernel.org">stable@kerne=
l.org</a>&gt;<br>
---<br>
=C2=A0mm/page_alloc.c | 7 +++----<br>
=C2=A01 file changed, 3 insertions(+), 4 deletions(-)<br>
<br>
Sorry I forgot to CC you, Leon.=C2=A0 Resend with updated Tags.<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 18cee0d4c8a2..eee961958021 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -1612,7 +1612,7 @@ again:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1=
 &lt;&lt; order));<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (zone_page_state(zone, NR_ALLOC_BATCH) =3D=
=3D 0 &amp;&amp;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (atomic_long_read(&amp;zone-&gt;vm_stat[NR_A=
LLOC_BATCH]) &lt;=3D 0 &amp;&amp;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !zone_is_fair_depleted(zone))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone_set_flag(zone,=
 ZONE_FAIR_DEPLETED);<br>
<br>
@@ -5701,9 +5701,8 @@ static void __setup_per_zone_wmarks(void)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone-&gt;watermark[=
WMARK_HIGH] =3D min_wmark_pages(zone) + (tmp &gt;&gt; 1);<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __mod_zone_page_sta=
te(zone, NR_ALLOC_BATCH,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high_wmark_pages=
(zone) -<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low_wmark_pages(=
zone) -<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_page_state(=
zone, NR_ALLOC_BATCH));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0high_wmark_pages(zone) - low_wmark_pages(zone) -<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0atomic_long_read(&amp;zone-&gt;vm_stat[NR_ALLOC_BATCH]));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 setup_zone_migrate_=
reserve(zone);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrest=
ore(&amp;zone-&gt;lock, flags);<br></blockquote><div><br></div><div>I think=
 the better way will be to apply Mel&#39;s patch <a href=3D"https://lkml.or=
g/lkml/2014/9/8/214">https://lkml.org/lkml/2014/9/8/214</a> which fix zone_=
page_state shadow casting issue and convert all atomic_long_read(&amp;zone-=
&gt;vm_stat[NR_ALLOC_BATCH])) to zone_page__state(zone, NR_ALLOC_BATCH). Th=
is move will unify access to vm_stat.<br><br></div><div>=C2=A0</div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1p=
x solid rgb(204,204,204);padding-left:1ex">
<span class=3D""><font color=3D"#888888">--<br>
2.0.4<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br><br clear=3D"all"><br>-- <br><div dir=
=3D"ltr"><div>Leon Romanovsky | Independent Linux Consultant<br><div>=C2=A0=
 =C2=A0 =C2=A0 =C2=A0=C2=A0<a href=3D"http://www.leon.nu" target=3D"_blank"=
>www.leon.nu</a>=C2=A0| <a href=3D"mailto:leon@leon.nu" target=3D"_blank">l=
eon@leon.nu</a><br></div></div></div>
</div></div>

--089e01634bf0d26ed50502ae8a7f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
