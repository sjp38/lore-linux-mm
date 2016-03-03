Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f46.google.com (mail-vk0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB8446B0255
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 21:23:04 -0500 (EST)
Received: by mail-vk0-f46.google.com with SMTP id c3so7946090vkb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:23:04 -0800 (PST)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id b135si23921087vke.26.2016.03.02.18.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 18:23:04 -0800 (PST)
Received: by mail-vk0-x232.google.com with SMTP id c3so7945910vkb.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 18:23:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160302173639.GD26701@dhcp22.suse.cz>
References: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
	<20160302173639.GD26701@dhcp22.suse.cz>
Date: Thu, 3 Mar 2016 10:23:03 +0800
Message-ID: <CAKQB+fss2UZOP-39GCpQY3T8MJoErm_0AeDnnAPZZ4MEWLXs7g@mail.gmail.com>
Subject: Re: kswapd consumes 100% CPU when highest zone is small
From: Jerry Lee <leisurelysw24@gmail.com>
Content-Type: multipart/alternative; boundary=001a114314dc9f274b052d1bad63
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

--001a114314dc9f274b052d1bad63
Content-Type: text/plain; charset=UTF-8

On 3 March 2016 at 01:36, Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 02-03-16 14:20:38, Jerry Lee wrote:
> > Hi,
> >
> > I have a x86_64 system with 2G RAM using linux-3.12.x.  During copying
> > large
> > files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is
> > deleted
> > or the page cache is dropped.  With setting the min_free_kbytes from
> 16384
> > to
> > 65536, the symptom is mitigated but I can't totally get rid of the
> problem.
> >
> > After some trial and error, I found that highest zone is always
> unbalanced
> > with
> > order-0 page request so that pgdat_blanaced() continuously return false
> and
> > kswapd can't sleep.
> >
> > Here's the watermarks (min_free_kbytes = 65536) in my system:
> > Node 0, zone      DMA
> >   pages free     2167
> >         min      138
> >         low      172
> >         high     207
> >         scanned  0
> >         spanned  4095
> >         present  3996
> >         managed  3974
> >
> > Node 0, zone    DMA32
> >   pages free     215375
> >         min      16226
> >         low      20282
> >         high     24339
> >         scanned  0
> >         spanned  1044480
> >         present  490971
> >         managed  464223
> >
> > Node 0, zone   Normal
> >   pages free     7
> >         min      18
> >         low      22
> >         high     27
> >         scanned  0
> >         spanned  1536
> >         present  1536
> >         managed  523
>
> The zone Normal is just too small and that confuses the reclaim path.
>
> >
> > Besides, when the kswapd crazily spins, the value of the following
> entries
> > in vmstat increases quickly even when I stop copying file:
> >
> > pgalloc_dma 17719
> > pgalloc_dma32 3262823
> > slabs_scanned 937728
> > kswapd_high_wmark_hit_quickly 54333233
> > pageoutrun 54333235
> >
> > Is there anything I could do to totally get rid of the problem?
>
> I would try to sacrifice those few megs and get rid of zone normal
> completely. AFAIR mem=4G should limit the max_pfn to 4G so DMA32 should
> cover the shole memory.
>

I came up with a patch that seem to work well on my system.  But, I am
afraid
that it breaks the rule that all zones must be balanced for order-0 request
and
It may cause some other side-effect?  I thought that the patch is just a
workaround
(a bad one) and not a cure-all.

BTW, if I upgrade the RAM from 2G to 4G, the problem is gone because the
Normal zone won't confuse the reclaim path as you said before.

Thanks


--- a/linux-3.12.6/mm/vmscan.c
+++ b/linux-3.12.6/mm/vmscan.c
@@ -2755,6 +2755,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int
order, int classzone_idx)
        unsigned long managed_pages = 0;
        unsigned long balanced_pages = 0;
        int i;
+#define HWMARK_THRESHOLD 128

        /* Check the watermark levels */
        for (i = 0; i <= classzone_idx; i++) {
@@ -2779,7 +2780,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, int
order, int classzone_idx)

                if (zone_balanced(zone, order, 0, i))
                        balanced_pages += zone->managed_pages;
-               else if (!order)
+               else if (!order &&
+                        (high_wmark_pages(zone) > HWMARK_THRESHOLD))
                        return false;
        }



> --
> Michal Hocko
> SUSE Labs
>

--001a114314dc9f274b052d1bad63
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On 3 March 2016 at 01:36, Michal Hocko <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.org</a>&gt;</span> w=
rote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8e=
x;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div class=3D"">=
<div class=3D"h5">On Wed 02-03-16 14:20:38, Jerry Lee wrote:<br>
&gt; Hi,<br>
&gt;<br>
&gt; I have a x86_64 system with 2G RAM using linux-3.12.x.=C2=A0 During co=
pying<br>
&gt; large<br>
&gt; files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is<=
br>
&gt; deleted<br>
&gt; or the page cache is dropped.=C2=A0 With setting the min_free_kbytes f=
rom 16384<br>
&gt; to<br>
&gt; 65536, the symptom is mitigated but I can&#39;t totally get rid of the=
 problem.<br>
&gt;<br>
&gt; After some trial and error, I found that highest zone is always unbala=
nced<br>
&gt; with<br>
&gt; order-0 page request so that pgdat_blanaced() continuously return fals=
e and<br>
&gt; kswapd can&#39;t sleep.<br>
&gt;<br>
&gt; Here&#39;s the watermarks (min_free_kbytes =3D 65536) in my system:<br=
>
&gt; Node 0, zone=C2=A0 =C2=A0 =C2=A0 DMA<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A02167<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 138<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 172<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A0207<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 4095<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 3996<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 3974<br>
&gt;<br>
&gt; Node 0, zone=C2=A0 =C2=A0 DMA32<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A0215375<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 16226<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 20282<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A024339<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 1044480<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 490971<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 464223<br>
&gt;<br>
&gt; Node 0, zone=C2=A0 =C2=A0Normal<br>
&gt;=C2=A0 =C2=A0pages free=C2=A0 =C2=A0 =C2=A07<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min=C2=A0 =C2=A0 =C2=A0 18<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0low=C2=A0 =C2=A0 =C2=A0 22<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0high=C2=A0 =C2=A0 =C2=A027<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned=C2=A0 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spanned=C2=A0 1536<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0present=C2=A0 1536<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0managed=C2=A0 523<br>
<br>
</div></div>The zone Normal is just too small and that confuses the reclaim=
 path.<br>
<span class=3D""><br>
&gt;<br>
&gt; Besides, when the kswapd crazily spins, the value of the following ent=
ries<br>
&gt; in vmstat increases quickly even when I stop copying file:<br>
&gt;<br>
&gt; pgalloc_dma 17719<br>
&gt; pgalloc_dma32 3262823<br>
&gt; slabs_scanned 937728<br>
&gt; kswapd_high_wmark_hit_quickly 54333233<br>
&gt; pageoutrun 54333235<br>
&gt;<br>
&gt; Is there anything I could do to totally get rid of the problem?<br>
<br>
</span>I would try to sacrifice those few megs and get rid of zone normal<b=
r>
completely. AFAIR mem=3D4G should limit the max_pfn to 4G so DMA32 should<b=
r>
cover the shole memory.<br></blockquote><div><br></div><div>I came up with =
a patch that seem to work well on my system.=C2=A0 But, I am afraid <br>tha=
t it breaks the rule that all zones must be balanced for order-0 request an=
d <br>It may cause some other side-effect?=C2=A0 I thought that the patch i=
s just a workaround <br>(a bad one) and not a cure-all.<br></div><div><br><=
/div><div>BTW, if I upgrade the RAM from 2G to 4G, the problem is gone beca=
use the <br></div><div>Normal zone won&#39;t confuse the reclaim path as yo=
u said before.<br><br></div><div>Thanks<br></div><div><br></div><div><br>--=
- a/linux-3.12.6/mm/vmscan.c<br>+++ b/linux-3.12.6/mm/vmscan.c<br>@@ -2755,=
6 +2755,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int cl=
asszone_idx)<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned long ma=
naged_pages =3D 0;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 unsigned l=
ong balanced_pages =3D 0;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int=
 i;<br>+#define HWMARK_THRESHOLD 128<br>=C2=A0<br>=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 /* Check the watermark levels */<br>=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 for (i =3D 0; i &lt;=3D classzone_idx; i++) {<br>@=
@ -2779,7 +2780,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order=
, int classzone_idx)<br>=C2=A0<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (zone_balanced(zone,=
 order, 0, i))<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 balanced_pages +=3D zone-&gt;managed_pages;<br>-=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 else if =
(!order)<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 else if (!order &amp;&amp;<br>+=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 (high_wmark_pages(zone) &gt; =
HWMARK_THRESHOLD))<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 return false;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }<=
br></div><div><br></div><div>=C2=A0</div><blockquote class=3D"gmail_quote" =
style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pa=
dding-left:1ex">
<span class=3D""><font color=3D"#888888">--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div></div>

--001a114314dc9f274b052d1bad63--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
