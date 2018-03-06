Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7796B002F
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 15:48:30 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id d18so326715iob.23
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 12:48:30 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id e66si3770397ita.57.2018.03.06.12.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 12:48:29 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w26KlwgT196488
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 20:48:28 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2gj234g3r9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 06 Mar 2018 20:48:28 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w26KmRhU017644
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 20:48:27 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w26KmRJd021030
	for <linux-mm@kvack.org>; Tue, 6 Mar 2018 20:48:27 GMT
Received: by mail-ot0-f181.google.com with SMTP id t2so19687037otj.4
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 12:48:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
References: <20180306192022.28289-1-pasha.tatashin@oracle.com> <20180306123655.957e5b6b20b200505544ea7a@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 6 Mar 2018 15:48:26 -0500
Message-ID: <CAGM2rea1raxsXDkqZgmmdBiuywp1M3y1p++=J893VJDgGDWLnQ@mail.gmail.com>
Subject: Re: [PATCH] mm: might_sleep warning
Content-Type: multipart/alternative; boundary="001a113b082c6f21690566c4909c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

--001a113b082c6f21690566c4909c
Content-Type: text/plain; charset="UTF-8"

[CCed everyone]

Hi Andrew,

I afraid we cannot change this spinlock to mutex
because deferred_grow_zone() might be called from an interrupt context if
interrupt thread needs to allocate memory.

Thank you,
Pavel


On Tue, Mar 6, 2018 at 3:36 PM, Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Tue,  6 Mar 2018 14:20:22 -0500 Pavel Tatashin <
> pasha.tatashin@oracle.com> wrote:
>
> > Robot reported this issue:
> > https://lkml.org/lkml/2018/2/27/851
> >
> > That is introduced by:
> > mm: initialize pages on demand during boot
> >
> > The problem is caused by changing static branch value within spin lock.
> > Spin lock disables preemption, and changing static branch value takes
> > mutex lock in its path, and thus may sleep.
> >
> > The fix is to add another boolean variable to avoid the need to change
> > static branch within spinlock.
> >
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1579,6 +1579,7 @@ static int __init deferred_init_memmap(void *data)
> >   * page_alloc_init_late() soon after smp_init() is complete.
> >   */
> >  static __initdata DEFINE_SPINLOCK(deferred_zone_grow_lock);
> > +static bool deferred_zone_grow __initdata = true;
> >  static DEFINE_STATIC_KEY_TRUE(deferred_pages);
> >
> >  /*
> > @@ -1616,7 +1617,7 @@ deferred_grow_zone(struct zone *zone, unsigned int
> order)
> >        * Bail if we raced with another thread that disabled on demand
> >        * initialization.
> >        */
> > -     if (!static_branch_unlikely(&deferred_pages)) {
> > +     if (!static_branch_unlikely(&deferred_pages) ||
> !deferred_zone_grow) {
> >               spin_unlock_irqrestore(&deferred_zone_grow_lock, flags);
> >               return false;
> >       }
> > @@ -1683,10 +1684,15 @@ void __init page_alloc_init_late(void)
> >       /*
> >        * We are about to initialize the rest of deferred pages,
> permanently
> >        * disable on-demand struct page initialization.
> > +      *
> > +      * Note: it is prohibited to modify static branches in
> non-preemptible
> > +      * context. Since, spin_lock() disables preemption, we must use an
> > +      * extra boolean deferred_zone_grow.
> >        */
> >       spin_lock(&deferred_zone_grow_lock);
> > -     static_branch_disable(&deferred_pages);
> > +     deferred_zone_grow = false;
> >       spin_unlock(&deferred_zone_grow_lock);
> > +     static_branch_disable(&deferred_pages);
> >
> >       /* There will be num_node_state(N_MEMORY) threads */
> >       atomic_set(&pgdat_init_n_undone, num_node_state(N_MEMORY));
>
> Kinda ugly, but I can see the logic behind the decisions.
>
> Can we instead turn deferred_zone_grow_lock into a mutex?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113b082c6f21690566c4909c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><span style=3D"color:rgb(34,34,34);font-family:arial,=
sans-serif;font-size:12.8px;font-style:normal;font-variant-ligatures:normal=
;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:=
start;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0=
px;background-color:rgb(255,255,255);text-decoration-style:initial;text-dec=
oration-color:initial;float:none;display:inline">[CCed everyone]</span></di=
v><span style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size=
:12.8px;font-style:normal;font-variant-ligatures:normal;font-variant-caps:n=
ormal;font-weight:400;letter-spacing:normal;text-align:start;text-indent:0p=
x;text-transform:none;white-space:normal;word-spacing:0px;background-color:=
rgb(255,255,255);text-decoration-style:initial;text-decoration-color:initia=
l;float:none;display:inline"><div><span style=3D"color:rgb(34,34,34);font-f=
amily:arial,sans-serif;font-size:12.8px;font-style:normal;font-variant-liga=
tures:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal=
;text-align:start;text-indent:0px;text-transform:none;white-space:normal;wo=
rd-spacing:0px;background-color:rgb(255,255,255);text-decoration-style:init=
ial;text-decoration-color:initial;float:none;display:inline"><br></span></d=
iv>Hi Andrew,</span><div style=3D"color:rgb(34,34,34);font-family:arial,san=
s-serif;font-size:12.8px;font-style:normal;font-variant-ligatures:normal;fo=
nt-variant-caps:normal;font-weight:400;letter-spacing:normal;text-align:sta=
rt;text-indent:0px;text-transform:none;white-space:normal;word-spacing:0px;=
background-color:rgb(255,255,255);text-decoration-style:initial;text-decora=
tion-color:initial"><br></div><div style=3D"color:rgb(34,34,34);font-family=
:arial,sans-serif;font-size:12.8px;font-style:normal;font-variant-ligatures=
:normal;font-variant-caps:normal;font-weight:400;letter-spacing:normal;text=
-align:start;text-indent:0px;text-transform:none;white-space:normal;word-sp=
acing:0px;background-color:rgb(255,255,255);text-decoration-style:initial;t=
ext-decoration-color:initial">I afraid we cannot change this spinlock to mu=
tex because=C2=A0deferred_grow_zone() might be called from an interrupt con=
text if interrupt thread needs to allocate memory.</div><div style=3D"color=
:rgb(34,34,34);font-family:arial,sans-serif;font-size:12.8px;font-style:nor=
mal;font-variant-ligatures:normal;font-variant-caps:normal;font-weight:400;=
letter-spacing:normal;text-align:start;text-indent:0px;text-transform:none;=
white-space:normal;word-spacing:0px;background-color:rgb(255,255,255);text-=
decoration-style:initial;text-decoration-color:initial"><br></div><div styl=
e=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-size:12.8px;font=
-style:normal;font-variant-ligatures:normal;font-variant-caps:normal;font-w=
eight:400;letter-spacing:normal;text-align:start;text-indent:0px;text-trans=
form:none;white-space:normal;word-spacing:0px;background-color:rgb(255,255,=
255);text-decoration-style:initial;text-decoration-color:initial">Thank you=
,</div><div style=3D"color:rgb(34,34,34);font-family:arial,sans-serif;font-=
size:12.8px;font-style:normal;font-variant-ligatures:normal;font-variant-ca=
ps:normal;font-weight:400;letter-spacing:normal;text-align:start;text-inden=
t:0px;text-transform:none;white-space:normal;word-spacing:0px;background-co=
lor:rgb(255,255,255);text-decoration-style:initial;text-decoration-color:in=
itial">Pavel</div><br></div><div class=3D"gmail_extra"><br><div class=3D"gm=
ail_quote">On Tue, Mar 6, 2018 at 3:36 PM, Andrew Morton <span dir=3D"ltr">=
&lt;<a href=3D"mailto:akpm@linux-foundation.org" target=3D"_blank">akpm@lin=
ux-foundation.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><=
span class=3D"">On Tue,=C2=A0 6 Mar 2018 14:20:22 -0500 Pavel Tatashin &lt;=
<a href=3D"mailto:pasha.tatashin@oracle.com">pasha.tatashin@oracle.com</a>&=
gt; wrote:<br>
<br>
&gt; Robot reported this issue:<br>
&gt; <a href=3D"https://lkml.org/lkml/2018/2/27/851" rel=3D"noreferrer" tar=
get=3D"_blank">https://lkml.org/lkml/2018/2/<wbr>27/851</a><br>
&gt;<br>
&gt; That is introduced by:<br>
&gt; mm: initialize pages on demand during boot<br>
&gt;<br>
&gt; The problem is caused by changing static branch value within spin lock=
.<br>
&gt; Spin lock disables preemption, and changing static branch value takes<=
br>
&gt; mutex lock in its path, and thus may sleep.<br>
&gt;<br>
&gt; The fix is to add another boolean variable to avoid the need to change=
<br>
&gt; static branch within spinlock.<br>
&gt;<br>
</span>&gt; ...<br>
<div><div class=3D"h5">&gt;<br>
&gt; --- a/mm/page_alloc.c<br>
&gt; +++ b/mm/page_alloc.c<br>
&gt; @@ -1579,6 +1579,7 @@ static int __init deferred_init_memmap(void *dat=
a)<br>
&gt;=C2=A0 =C2=A0* page_alloc_init_late() soon after smp_init() is complete=
.<br>
&gt;=C2=A0 =C2=A0*/<br>
&gt;=C2=A0 static __initdata DEFINE_SPINLOCK(deferred_zone_<wbr>grow_lock);=
<br>
&gt; +static bool deferred_zone_grow __initdata =3D true;<br>
&gt;=C2=A0 static DEFINE_STATIC_KEY_TRUE(<wbr>deferred_pages);<br>
&gt;<br>
&gt;=C2=A0 /*<br>
&gt; @@ -1616,7 +1617,7 @@ deferred_grow_zone(struct zone *zone, unsigned i=
nt order)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Bail if we raced with another thread that=
 disabled on demand<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * initialization.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (!static_branch_unlikely(&amp;<wbr>deferred_pa=
ges)) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!static_branch_unlikely(&amp;<wbr>deferred_pa=
ges) || !deferred_zone_grow) {<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irqr=
estore(&amp;<wbr>deferred_zone_grow_lock, flags);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return false;<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; @@ -1683,10 +1684,15 @@ void __init page_alloc_init_late(void)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * We are about to initialize the rest of de=
ferred pages, permanently<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 * disable on-demand struct page initializat=
ion.<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 *<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * Note: it is prohibited to modify static branch=
es in non-preemptible<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * context. Since, spin_lock() disables preemptio=
n, we must use an<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 * extra boolean deferred_zone_grow.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&amp;deferred_zone_grow_<wbr>lock)=
;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0static_branch_disable(&amp;<wbr>deferred_pages);<=
br>
&gt; +=C2=A0 =C2=A0 =C2=A0deferred_zone_grow =3D false;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&amp;deferred_zone_<wbr>grow_loc=
k);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0static_branch_disable(&amp;<wbr>deferred_pages);<=
br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* There will be num_node_state(N_MEMORY) th=
reads */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_set(&amp;pgdat_init_n_<wbr>undone, nu=
m_node_state(N_MEMORY));<br>
<br>
</div></div>Kinda ugly, but I can see the logic behind the decisions.<br>
<br>
Can we instead turn deferred_zone_grow_lock into a mutex?<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br></div>

--001a113b082c6f21690566c4909c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
