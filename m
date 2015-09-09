Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id A9E336B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 14:31:23 -0400 (EDT)
Received: by qgx61 with SMTP id 61so15572532qgx.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 11:31:23 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id 34si9327127qgb.89.2015.09.09.11.31.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 11:31:23 -0700 (PDT)
Received: by qgx61 with SMTP id 61so15572221qgx.3
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 11:31:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F072EA.4000703@redhat.com>
References: <BLU436-SMTP171766343879051ED4CED0A2520@phx.gbl>
	<55F072EA.4000703@redhat.com>
Date: Wed, 9 Sep 2015 20:31:22 +0200
Message-ID: <CAMJBoFNsCuktUC0aZF6Xw05v4g_2eK1G183KkSkhQYkztEVHCA@mail.gmail.com>
Subject: Re: [PATCH/RFC] mm: do not regard CMA pages as free on watermark check
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: multipart/alternative; boundary=001a1135c67883d73e051f54b09f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Vitaly Wool <vwool@hotmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

--001a1135c67883d73e051f54b09f
Content-Type: text/plain; charset=UTF-8

Hi Laura,

On Wed, Sep 9, 2015 at 7:56 PM, Laura Abbott <labbott@redhat.com> wrote:

> (cc-ing linux-mm)
> On 09/09/2015 07:44 AM, Vitaly Wool wrote:
>
>> __zone_watermark_ok() does not corrrectly take high-order
>> CMA pageblocks into account: high-order CMA blocks are not
>> removed from the watermark check. Moreover, CMA pageblocks
>> may suddenly vanish through CMA allocation, so let's not
>> regard these pages as free in __zone_watermark_ok().
>>
>> This patch also adds some primitive testing for the method
>> implemented which has proven that it works as it should.
>>
>>
> The choice to include CMA as part of watermarks was pretty deliberate.
> Do you have a description of the problem you are facing with
> the watermark code as is? Any performance numbers?
>
>
let's start with facing the fact that the calculation in
__zone_watermark_ok() is done incorrectly for the case when ALLOC_CMA is
not set. While going through pages by order it is implicitly considered
that CMA pages can be used and this impacts the result of the function.

This can be solved in a slightly different way compared to what I proposed
but it needs per-order CMA pages accounting anyway. Then it would have
looked like:

        for (o = 0; o < order; o++) {
                /* At the next order, this order's pages become unavailable
*/
                free_pages -= z->free_area[o].nr_free << o;
#ifdef CONFIG_CMA
                if (!(alloc_flags & ALLOC_CMA))
                        free_pages -= z->free_area[o].nr_free_cma << o;
                /* Require fewer higher order pages to be free */
                min >>= 1;
...

But what we have also seen is that CMA pages may suddenly disappear due to
CMA allocator work so the whole watermark checking was still unreliable,
causing compaction to not run when it ought to and thus leading to
(otherwise redundant) low memory killer operations, so I decided to propose
a safer method instead.

Best regards,
   Vitaly

--001a1135c67883d73e051f54b09f
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Laura,<div><br></div><div class=3D"gmail_extra"><div cl=
ass=3D"gmail_quote">On Wed, Sep 9, 2015 at 7:56 PM, Laura Abbott <span dir=
=3D"ltr">&lt;<a href=3D"mailto:labbott@redhat.com" target=3D"_blank">labbot=
t@redhat.com</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" sty=
le=3D"margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(=
204,204,204);border-left-style:solid;padding-left:1ex">(cc-ing linux-mm)<sp=
an class=3D""><br>
On 09/09/2015 07:44 AM, Vitaly Wool wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
__zone_watermark_ok() does not corrrectly take high-order<br>
CMA pageblocks into account: high-order CMA blocks are not<br>
removed from the watermark check. Moreover, CMA pageblocks<br>
may suddenly vanish through CMA allocation, so let&#39;s not<br>
regard these pages as free in __zone_watermark_ok().<br>
<br>
This patch also adds some primitive testing for the method<br>
implemented which has proven that it works as it should.<br>
<br>
</blockquote>
<br></span>
The choice to include CMA as part of watermarks was pretty deliberate.<br>
Do you have a description of the problem you are facing with<br>
the watermark code as is? Any performance numbers?<div class=3D""><div clas=
s=3D"h5"><br></div></div></blockquote><div><br></div><div>let&#39;s start w=
ith facing the fact that the calculation in __zone_watermark_ok() is done i=
ncorrectly for the case when ALLOC_CMA is not set. While going through page=
s by order it is implicitly considered that CMA pages can be used and this =
impacts the result of the function.</div><div><br></div><div>This can be so=
lved in a slightly different way compared to what I proposed but it needs p=
er-order CMA pages accounting anyway. Then it would have looked like:</div>=
<div><br></div><div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (o =3D 0; o &lt; o=
rder; o++) {</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* At the next order, this order&#39;s pages become unavailable */</div=
><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free_pages -=
=3D z-&gt;free_area[o].nr_free &lt;&lt; o;</div><div>#ifdef CONFIG_CMA</div=
><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if=C2=A0(!(al=
loc_flags &amp; ALLOC_CMA))</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free_pages -=3D=C2=A0z-&gt=
;free_area[o].nr_free_cma &lt;&lt; o;</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Require fewer higher order pages to be free=
 */</div><div>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 min &=
gt;&gt;=3D 1;</div><div>...</div><div>=C2=A0 =C2=A0<br></div></div><div>But=
 what we have also seen is that CMA pages may suddenly disappear due to CMA=
 allocator work so the whole watermark checking was still unreliable, causi=
ng compaction to not run when it ought to and thus leading to (otherwise re=
dundant) low memory killer operations, so I decided to propose a safer meth=
od instead.</div><div><br></div><div>Best regards,</div><div>=C2=A0 =C2=A0V=
italy</div></div></div></div>

--001a1135c67883d73e051f54b09f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
