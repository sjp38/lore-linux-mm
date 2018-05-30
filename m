Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5802B6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 22:57:29 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id u23-v6so11004271ual.4
        for <linux-mm@kvack.org>; Tue, 29 May 2018 19:57:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j62-v6sor3288488vkd.287.2018.05.29.19.57.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 May 2018 19:57:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONA4y+7vzUr2xPa8ZbwCczjJV9EMCOXaCsE94DdfGbrmtA@mail.gmail.com>
References: <20180524095752.17770-1-liwang@redhat.com> <CALZtONA4y+7vzUr2xPa8ZbwCczjJV9EMCOXaCsE94DdfGbrmtA@mail.gmail.com>
From: Li Wang <liwang@redhat.com>
Date: Wed, 30 May 2018 10:57:26 +0800
Message-ID: <CAEemH2c=EWHb1Ua6Fe4g_kF2JC8LKoiySPabZ7xXF43ovrNFmg@mail.gmail.com>
Subject: Re: [PATCH RFC] zswap: reject to compress/store page if
 zswap_max_pool_percent is 0
Content-Type: multipart/alternative; boundary="000000000000d1a445056d63823e"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Huang Ying <huang.ying.caritas@gmail.com>, Yu Zhao <yuzhao@google.com>

--000000000000d1a445056d63823e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Dan,

On Wed, May 30, 2018 at 5:14 AM, Dan Streetman <ddstreet@ieee.org> wrote:

> On Thu, May 24, 2018 at 5:57 AM, Li Wang <liwang@redhat.com> wrote:
> > The '/sys/../zswap/stored_pages:' keep raising in zswap test with
> > "zswap.max_pool_percent=3D0" parameter. But theoretically, it should
> > not compress or store pages any more since there is no space for
> > compressed pool.
> >
> > Reproduce steps:
> >
> >   1. Boot kernel with "zswap.enabled=3D1 zswap.max_pool_percent=3D17"
> >   2. Set the max_pool_percent to 0
> >       # echo 0 > /sys/module/zswap/parameters/max_pool_percent
> >      Confirm this parameter works fine
> >       # cat /sys/kernel/debug/zswap/pool_total_size
> >       0
> >   3. Do memory stress test to see if some pages have been compressed
> >       # stress --vm 1 --vm-bytes $mem_available"M" --timeout 60s
> >      Watching the 'stored_pages' numbers increasing or not
> >
> > The root cause is:
> >
> >   When the zswap_max_pool_percent is set to 0 via kernel parameter, the
> zswap_is_full()
> >   will always return true to shrink the pool size by zswap_shrink(). If
> the pool size
> >   has been shrinked a little success, zswap will do compress/store page=
s
> again. Then we
> >   get fails on that as above.
>
> special casing 0% doesn't make a lot of sense to me, and I'm not
> entirely sure what exactly you are trying to fix here.
>

=E2=80=8BSorry for that confusing, I am a pretty new to zswap.

To specify 0 to max_pool_percent is purpose to verify if zswap stopping
work when there is no space in compressed pool.=E2=80=8B

Another consideration from me is:

[Method A]

--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1021,7 +1021,7 @@ static int zswap_frontswap_store(unsigned type,
pgoff_t offset,
        /* reclaim space if needed */
        if (zswap_is_full()) {
                zswap_pool_limit_hit++;
-               if (zswap_shrink()) {
+               if (!zswap_max_pool_percent || zswap_shrink()) {
                        zswap_reject_reclaim_fail++;
                        ret =3D -ENOMEM;
                        goto reject;

This make sure the compressed pool is enough to do zswap_shrink().



>
> however, zswap does currently do a zswap_is_full() check, and then if
> it's able to reclaim a page happily proceeds to store another page,
> without re-checking zswap_is_full().  If you're trying to fix that,
> then I would ack a patch that adds a second zswap_is_full() check
> after zswap_shrink() to make sure it's now under the max_pool_percent
> (or somehow otherwise fixes that behavior).
>
>
=E2=80=8BOk, it sounds like can also fix the issue. The changes maybe like:

[Method B]

--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1026,6 +1026,15 @@ static int zswap_frontswap_store(unsigned type,
pgoff_t offset,
                        ret =3D -ENOMEM;
                        goto reject;
                }
+
+               /* A second zswap_is_full() check after
+                * zswap_shrink() to make sure it's now
+                * under the max_pool_percent
+                */
+               if (zswap_is_full()) {
+                       ret =3D -ENOMEM;
+                       goto reject;
+               }
        }


So, which one do you think is better, A or B?

--=20
Regards,
Li Wang

--000000000000d1a445056d63823e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D"font-size:small">Hi =
Dan,<br></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On =
Wed, May 30, 2018 at 5:14 AM, Dan Streetman <span dir=3D"ltr">&lt;<a href=
=3D"mailto:ddstreet@ieee.org" target=3D"_blank">ddstreet@ieee.org</a>&gt;</=
span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0=
px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On Thu, M=
ay 24, 2018 at 5:57 AM, Li Wang &lt;<a href=3D"mailto:liwang@redhat.com">li=
wang@redhat.com</a>&gt; wrote:<br>
&gt; The &#39;/sys/../zswap/stored_pages:&#39; keep raising in zswap test w=
ith<br>
&gt; &quot;zswap.max_pool_percent=3D0&quot; parameter. But theoretically, i=
t should<br>
&gt; not compress or store pages any more since there is no space for<br>
&gt; compressed pool.<br>
&gt;<br>
&gt; Reproduce steps:<br>
&gt;<br>
&gt;=C2=A0 =C2=A01. Boot kernel with &quot;zswap.enabled=3D1 zswap.max_pool=
_percent=3D17&quot;<br>
&gt;=C2=A0 =C2=A02. Set the max_pool_percent to 0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0# echo 0 &gt; /sys/module/zswap/parameters/<=
wbr>max_pool_percent<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Confirm this parameter works fine<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0# cat /sys/kernel/debug/zswap/pool_<wbr>tota=
l_size<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A00<br>
&gt;=C2=A0 =C2=A03. Do memory stress test to see if some pages have been co=
mpressed<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0# stress --vm 1 --vm-bytes $mem_available&qu=
ot;M&quot; --timeout 60s<br>
&gt;=C2=A0 =C2=A0 =C2=A0 Watching the &#39;stored_pages&#39; numbers increa=
sing or not<br>
&gt;<br>
&gt; The root cause is:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0When the zswap_max_pool_percent is set to 0 via kernel par=
ameter, the zswap_is_full()<br>
&gt;=C2=A0 =C2=A0will always return true to shrink the pool size by zswap_s=
hrink(). If the pool size<br>
&gt;=C2=A0 =C2=A0has been shrinked a little success, zswap will do compress=
/store pages again. Then we<br>
&gt;=C2=A0 =C2=A0get fails on that as above.<br>
<br>
special casing 0% doesn&#39;t make a lot of sense to me, and I&#39;m not<br=
>
entirely sure what exactly you are trying to fix here.<br></blockquote><div=
><br></div><div><div style=3D"font-size:small" class=3D"gmail_default">=E2=
=80=8BSorry for that confusing, I am a pretty new to zswap.</div><div style=
=3D"font-size:small" class=3D"gmail_default"><br></div><div style=3D"font-s=
ize:small" class=3D"gmail_default">To specify 0 to max_pool_percent is purp=
ose to verify if zswap stopping work when there is no space in compressed p=
ool.=E2=80=8B</div><div style=3D"font-size:small" class=3D"gmail_default"><=
br></div><div style=3D"font-size:small" class=3D"gmail_default">Another con=
sideration from me is:</div><div style=3D"font-size:small" class=3D"gmail_d=
efault"><br></div><div style=3D"font-size:small" class=3D"gmail_default">[M=
ethod A]</div><div style=3D"font-size:small" class=3D"gmail_default"><br></=
div><div style=3D"font-size:small" class=3D"gmail_default">--- a/mm/zswap.c=
<br>+++ b/mm/zswap.c<br>@@ -1021,7 +1021,7 @@ static int zswap_frontswap_st=
ore(unsigned type, pgoff_t offset,<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 /* reclaim space if needed */<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 if (zswap_is_full()) {<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 zswap_pool_limit_hit++;=
<br>-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 if (zswap_shrink()) {<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (!zswap_max_pool_per=
cent || zswap_shrink()) {<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 zswap_reject_reclaim_fail++;<br>=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ret =3D -ENOMEM;<br>=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto reject;<br></div><div=
 style=3D"font-size:small" class=3D"gmail_default"><br></div><div style=3D"=
font-size:small" class=3D"gmail_default">This make sure the compressed pool=
 is enough to do zswap_shrink().<br></div><br></div><div>=C2=A0</div><block=
quote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1=
px solid rgb(204,204,204);padding-left:1ex">
<br>
however, zswap does currently do a zswap_is_full() check, and then if<br>
it&#39;s able to reclaim a page happily proceeds to store another page,<br>
without re-checking zswap_is_full().=C2=A0 If you&#39;re trying to fix that=
,<br>
then I would ack a patch that adds a second zswap_is_full() check<br>
after zswap_shrink() to make sure it&#39;s now under the max_pool_percent<b=
r>
(or somehow otherwise fixes that behavior).<br>
<br></blockquote></div></div><div class=3D"gmail_extra"><br></div><div clas=
s=3D"gmail_extra"><div style=3D"font-size:small" class=3D"gmail_default">=
=E2=80=8BOk, it sounds like can also fix the issue. The changes maybe like:=
<br></div><div style=3D"font-size:small" class=3D"gmail_default"><br></div>=
<div style=3D"font-size:small" class=3D"gmail_default">[Method B]</div><div=
 style=3D"font-size:small" class=3D"gmail_default"><br></div><div style=3D"=
font-size:small" class=3D"gmail_default">--- a/mm/zswap.c<br>+++ b/mm/zswap=
.c<br>@@ -1026,6 +1026,15 @@ static int zswap_frontswap_store(unsigned type=
, pgoff_t offset,<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 ret =3D -ENOMEM;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 goto reject;<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }<br>+<br>+=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /*=
 A second zswap_is_full() check after<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * zswap_shrink() =
to make sure it&#39;s now<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 * under the max_pool_percent<=
br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 */<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (zswap_is_full()) {<br>+=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ret =3D -ENOMEM;<br>+=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto reject;<br>+=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 }<br>=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }<br><br></div><d=
iv style=3D"font-size:small" class=3D"gmail_default"><br></div><div style=
=3D"font-size:small" class=3D"gmail_default">So, which one do you think is =
better, A or B?<br></div></div><div class=3D"gmail_extra"><br>-- <br><div c=
lass=3D"gmail_signature"><div dir=3D"ltr"><div>Regards,<br></div><div>Li Wa=
ng<br></div></div></div>
</div></div>

--000000000000d1a445056d63823e--
