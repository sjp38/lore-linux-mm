Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 111876B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 08:24:00 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so329138lab.15
        for <linux-mm@kvack.org>; Tue, 20 May 2014 05:24:00 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id oc9si2830537lbb.57.2014.05.20.05.23.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 05:23:59 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so322691lbi.27
        for <linux-mm@kvack.org>; Tue, 20 May 2014 05:23:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <537B3EA5.2040302@samsung.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
	<20140513030057.GC32092@bbox>
	<20140515015301.GA10116@js1304-P5Q-DELUXE>
	<5375C619.8010501@lge.com>
	<xa1tppjdfwif.fsf@mina86.com>
	<537962A0.4090600@lge.com>
	<20140519055527.GA24099@js1304-P5Q-DELUXE>
	<xa1td2f91qw5.fsf@mina86.com>
	<537AA6C7.1040506@lge.com>
	<537B3EA5.2040302@samsung.com>
Date: Tue, 20 May 2014 21:23:58 +0900
Message-ID: <CANc8B5OCN+rq3n8c=8cxFifkYapGFsqQhVa-VYz39=Aq0bPttw@mail.gmail.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to
 non-zero value
From: Gi-Oh Kim <gurugio@gmail.com>
Content-Type: multipart/alternative; boundary=001a113367ac44bf8604f9d3f4a5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Gioh Kim <gioh.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>

--001a113367ac44bf8604f9d3f4a5
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

2014-05-20 20:38 GMT+09:00 Marek Szyprowski <m.szyprowski@samsung.com>:

> Hello,
>
>
> On 2014-05-20 02:50, Gioh Kim wrote:
>
>>
>>
>> 2014-05-20 =EC=98=A4=EC=A0=84 4:59, Michal Nazarewicz =EC=93=B4 =EA=B8=
=80:
>>
>>> On Sun, May 18 2014, Joonsoo Kim wrote:
>>>
>>>> I think that this problem is originated from atomic_pool_init().
>>>> If configured coherent_pool size is larger than default cma size,
>>>> it can be failed even if this patch is applied.
>>>>
>>>
>> The coherent_pool size (atomic_pool.size) should be restricted smaller
>> than cma size.
>>
>> This is another issue, however I think the default atomic pool size is
>> too small.
>> Only one port of USB host needs at most 256Kbytes coherent memory
>> (according to the USB host spec).
>>
>
> This pool is used only for allocation done in atomic context (allocations
> done with GFP_ATOMIC flag), otherwise the standard allocation path is use=
d.
> Are you sure that each usb host port really needs so much memory allocate=
d
> in atomic context?


http://lxr.free-electrons.com/source/drivers/usb/host/ehci-mem.c#L210
dma_alloc_coherent<http://lxr.free-electrons.com/ident?i=3Ddma_alloc_cohere=
nt> is
called with gfp as zero, no GFP_ATOMIC flag.

If CMA is turned on and size is zero, ehci driver occurs panic.


>
>
>  If a platform has several ports, it needs more than 1MB.
>> Therefore the default atomic pool size should be at least 1MB.
>>
>>
>>>> How about below patch?
>>>> It uses fallback allocation if CMA is failed.
>>>>
>>>
>>> Yes, I thought about it, but __dma_alloc uses similar code:
>>>
>>>     else if (!IS_ENABLED(CONFIG_DMA_CMA))
>>>         addr =3D __alloc_remap_buffer(dev, size, gfp, prot, &page, call=
er);
>>>     else
>>>         addr =3D __alloc_from_contiguous(dev, size, prot, &page, caller=
);
>>>
>>> so it probably needs to be changed as well.
>>>
>>
>> If CMA option is not selected, __alloc_from_contiguous would not be
>> called.
>> We don't need to the fallback allocation.
>>
>> And if CMA option is selected and initialized correctly,
>> the cma allocation can fail in case of no-CMA-memory situation.
>> I thinks in that case we don't need to the fallback allocation also,
>> because it is normal case.
>>
>> Therefore I think the restriction of CMA size option and make CMA work
>> can cover every cases.
>>
>> I think below patch is also good choice.
>> If both of you, Michal and Joonsoo, do not agree with me, please inform
>> me.
>> I will make a patch including option restriction and fallback allocation=
.
>>
>
> I'm not sure if we need a fallback for failed CMA allocation. The only
> issue that
> have been mentioned here and needs to be resolved is support for disablin=
g
> cma by
> kernel command line. Right now it will fails completely.



>
> Best regards
> --
> Marek Szyprowski, PhD
> Samsung R&D Institute Poland
>
>


--=20
----
Love and Serve make me happy
blog - http://gurugio.blogspot.com/
homepage - CalciumOS http://code.google.com/p/caoskernel/

--001a113367ac44bf8604f9d3f4a5
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">2014-05-20 20:38 GMT+09:00 Marek Szyprowski <span dir=3D"ltr">&lt;<=
a href=3D"mailto:m.szyprowski@samsung.com" target=3D"_blank">m.szyprowski@s=
amsung.com</a>&gt;</span>:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">Hello,<div class=3D""><br>
<br>
On 2014-05-20 02:50, Gioh Kim wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
<br>
<br>
2014-05-20 =EC=98=A4=EC=A0=84 4:59, Michal Nazarewicz =EC=93=B4 =EA=B8=80:<=
br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
On Sun, May 18 2014, Joonsoo Kim wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
I think that this problem is originated from atomic_pool_init().<br>
If configured coherent_pool size is larger than default cma size,<br>
it can be failed even if this patch is applied.<br>
</blockquote></blockquote>
<br>
The coherent_pool size (atomic_pool.size) should be restricted smaller than=
 cma size.<br>
<br>
This is another issue, however I think the default atomic pool size is too =
small.<br>
Only one port of USB host needs at most 256Kbytes coherent memory (accordin=
g to the USB host spec).<br>
</blockquote>
<br></div>
This pool is used only for allocation done in atomic context (allocations<b=
r>
done with GFP_ATOMIC flag), otherwise the standard allocation path is used.=
<br>
Are you sure that each usb host port really needs so much memory allocated<=
br>
in atomic context?</blockquote><div><br></div><div><a href=3D"http://lxr.fr=
ee-electrons.com/source/drivers/usb/host/ehci-mem.c#L210">http://lxr.free-e=
lectrons.com/source/drivers/usb/host/ehci-mem.c#L210</a></div><div><a href=
=3D"http://lxr.free-electrons.com/ident?i=3Ddma_alloc_coherent" style=3D"fo=
nt-family:Monaco,&#39;Courier New&#39;,Courier,monospace;font-size:14px;fon=
t-weight:bold;text-decoration:none;border-bottom-width:1px;border-bottom-st=
yle:dotted;border-bottom-color:rgb(153,153,153);color:black">dma_alloc_cohe=
rent</a>=C2=A0is called with gfp as zero, no GFP_ATOMIC flag.</div>
<div><br></div><div>If CMA is turned on and size is zero, ehci driver occur=
s panic.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204=
,204);border-left-style:solid;padding-left:1ex">
<div class=3D""><br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">
If a platform has several ports, it needs more than 1MB.<br>
Therefore the default atomic pool size should be at least 1MB.<br>
<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex"><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px =
0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-l=
eft-style:solid;padding-left:1ex">

<br>
How about below patch?<br>
It uses fallback allocation if CMA is failed.<br>
</blockquote>
<br>
Yes, I thought about it, but __dma_alloc uses similar code:<br>
<br>
=C2=A0 =C2=A0 else if (!IS_ENABLED(CONFIG_DMA_CMA))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D __alloc_remap_buffer(dev, size, gfp, p=
rot, &amp;page, caller);<br>
=C2=A0 =C2=A0 else<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 addr =3D __alloc_from_contiguous(dev, size, pro=
t, &amp;page, caller);<br>
<br>
so it probably needs to be changed as well.<br>
</blockquote>
<br>
If CMA option is not selected, __alloc_from_contiguous would not be called.=
<br>
We don&#39;t need to the fallback allocation.<br>
<br>
And if CMA option is selected and initialized correctly,<br>
the cma allocation can fail in case of no-CMA-memory situation.<br>
I thinks in that case we don&#39;t need to the fallback allocation also,<br=
>
because it is normal case.<br>
<br>
Therefore I think the restriction of CMA size option and make CMA work can =
cover every cases.<br>
<br>
I think below patch is also good choice.<br>
If both of you, Michal and Joonsoo, do not agree with me, please inform me.=
<br>
I will make a patch including option restriction and fallback allocation.<b=
r>
</blockquote>
<br></div>
I&#39;m not sure if we need a fallback for failed CMA allocation. The only =
issue that<br>
have been mentioned here and needs to be resolved is support for disabling =
cma by<br>
kernel command line. Right now it will fails completely.</blockquote><div>=
=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-s=
tyle:solid;padding-left:1ex">

<br>
Best regards<span class=3D""><font color=3D"#888888"><br>
-- <br>
Marek Szyprowski, PhD<br>
Samsung R&amp;D Institute Poland<br>
<br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r>----<br>Love and Serve make me happy<br>blog - <a href=3D"http://gurugio.=
blogspot.com/">http://gurugio.blogspot.com/</a><br>homepage - CalciumOS <a =
href=3D"http://code.google.com/p/caoskernel/">http://code.google.com/p/caos=
kernel/</a>
</div></div>

--001a113367ac44bf8604f9d3f4a5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
