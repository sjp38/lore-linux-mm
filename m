Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 41F686B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 03:15:38 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so1522888gge.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 00:15:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203301744.16762.arnd@arndb.de>
References: <201203301744.16762.arnd@arndb.de>
Date: Fri, 6 Apr 2012 16:15:37 +0900
Message-ID: <CAEwNFnA2GeOayw2sJ_KXv4qOdC50_Nt2KoK796YmQF+YV1GiEA@mail.gmail.com>
Subject: Re: swap on eMMC and other flash
From: Minchan Kim <minchan@kernel.org>
Content-Type: multipart/alternative; boundary=001636c928c054da1204bcfd6c7b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

--001636c928c054da1204bcfd6c7b
Content-Type: text/plain; charset=UTF-8

On Sat, Mar 31, 2012 at 2:44 AM, Arnd Bergmann <arnd@arndb.de> wrote:

> We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
> with Luca joining in on the discussion) about swapping to flash based media
> such as eMMC. This is a summary of what we found and what we think should
> be done. If people agree that this is a good idea, we can start working
> on it.
>
> The basic problem is that Linux without swap is sort of crippled and some
> things either don't work at all (hibernate) or not as efficient as they
> should (e.g. tmpfs). At the same time, the swap code seems to be rather
> inappropriate for the algorithms used in most flash media today, causing
> system performance to suffer drastically, and wearing out the flash
> hardware
> much faster than necessary. In order to change that, we would be
> implementing the following changes:
>
> 1) Try to swap out multiple pages at once, in a single write request. My
> reading of the current code is that we always send pages one by one to
> the swap device, while most flash devices have an optimum write size of
> 32 or 64 kb and some require an alignment of more than a page. Ideally
> we would try to write an aligned 64 kb block all the time. Writing aligned
> 64 kb chunks often gives us ten times the throughput of linear 4kb writes,
> and going beyond 64 kb usually does not give any better performance.
>

It does make sense.
I think we can batch will-be-swapped-out pages in shrink_page_list if they
are located by contiguous swap slots.


> 2) Make variable sized swap clusters. Right now, the swap space is
> organized in clusters of 256 pages (1MB), which is less than the typical
> erase block size of 4 or 8 MB. We should try to make the swap cluster
> aligned to erase blocks and have the size match to avoid garbage collection
> in the drive. The cluster size would typically be set by mkswap as a new
> option and interpreted at swapon time.
>

If we can find such big contiguous swap slots easily, it would be good.
But I am not sure how often we can get such big slots. And maybe we have to
improve search method for getting such big empty cluster.


>
> 3) As Luca points out, some eMMC media would benefit significantly from
> having discard requests issued for every page that gets freed from
> the swap cache, rather than at the time just before we reuse a swap
> cluster. This would probably have to become a configurable option
> as well, to avoid the overhead of sending the discard requests on
> media that don't benefit from this.
>

It's opposite of 2). I don't know how many there are such eMMC media.
Normally, discard per page isn't useful on most eMMC media.
I am not sure we have to implement per-page discard for such minor devices
with increasing code complexity due to locking issue.


>
> Does this all sound appropriate for the Linux memory management people?
>
> Also, does this sound useful to the Android developers? Would you
> start using swap if we make it perform well and not destroy the drives?
>
> Finally, does this plan match up with the capabilities of the
> various eMMC devices? I know more about SD and USB devices and
> I'm quite convinced that it would help there, but eMMC can be
> more like an SSD in some ways, and the current code should be fine
> for real SSDs.
>
>        Arnd
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>



-- 
Kind regards,
Minchan Kim

--001636c928c054da1204bcfd6c7b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">On Sat, Mar 31, 2012 at 2:44 AM, Arnd Be=
rgmann <span dir=3D"ltr">&lt;<a href=3D"mailto:arnd@arndb.de">arnd@arndb.de=
</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin=
:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
We&#39;ve had a discussion in the Linaro storage team (Saugata, Venkat and =
me,<br>
with Luca joining in on the discussion) about swapping to flash based media=
<br>
such as eMMC. This is a summary of what we found and what we think should<b=
r>
be done. If people agree that this is a good idea, we can start working<br>
on it.<br>
<br>
The basic problem is that Linux without swap is sort of crippled and some<b=
r>
things either don&#39;t work at all (hibernate) or not as efficient as they=
<br>
should (e.g. tmpfs). At the same time, the swap code seems to be rather<br>
inappropriate for the algorithms used in most flash media today, causing<br=
>
system performance to suffer drastically, and wearing out the flash hardwar=
e<br>
much faster than necessary. In order to change that, we would be<br>
implementing the following changes:<br>
<br>
1) Try to swap out multiple pages at once, in a single write request. My<br=
>
reading of the current code is that we always send pages one by one to<br>
the swap device, while most flash devices have an optimum write size of<br>
32 or 64 kb and some require an alignment of more than a page. Ideally<br>
we would try to write an aligned 64 kb block all the time. Writing aligned<=
br>
64 kb chunks often gives us ten times the throughput of linear 4kb writes,<=
br>
and going beyond 64 kb usually does not give any better performance.<br></b=
lockquote><div><br></div><div>It does make sense.</div><div>I think we can =
batch will-be-swapped-out pages in shrink_page_list if they are located by =
contiguous swap slots.</div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex">
<br>
2) Make variable sized swap clusters. Right now, the swap space is<br>
organized in clusters of 256 pages (1MB), which is less than the typical<br=
>
erase block size of 4 or 8 MB. We should try to make the swap cluster<br>
aligned to erase blocks and have the size match to avoid garbage collection=
<br>
in the drive. The cluster size would typically be set by mkswap as a new<br=
>
option and interpreted at swapon time.<br></blockquote><div><br></div><div>=
If we can find such big contiguous swap slots easily, it would be good.</di=
v><div>But I am not sure how often we can get such big slots. And maybe we =
have to improve search method for getting such big empty cluster.</div>
<div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8=
ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
3) As Luca points out, some eMMC media would benefit significantly from<br>
having discard requests issued for every page that gets freed from<br>
the swap cache, rather than at the time just before we reuse a swap<br>
cluster. This would probably have to become a configurable option<br>
as well, to avoid the overhead of sending the discard requests on<br>
media that don&#39;t benefit from this.<br></blockquote><div><br></div><div=
>It&#39;s opposite of 2). I don&#39;t know how many there are such eMMC med=
ia.</div><div>Normally, discard per page isn&#39;t useful on most eMMC medi=
a.</div>
<div>I am not sure we have to implement per-page discard for such minor dev=
ices with increasing code complexity due to locking issue.</div><div>=C2=A0=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">

<br>
Does this all sound appropriate for the Linux memory management people?<br>
<br>
Also, does this sound useful to the Android developers? Would you<br>
start using swap if we make it perform well and not destroy the drives?<br>
<br>
Finally, does this plan match up with the capabilities of the<br>
various eMMC devices? I know more about SD and USB devices and<br>
I&#39;m quite convinced that it would help there, but eMMC can be<br>
more like an SSD in some ways, and the current code should be fine<br>
for real SSDs.<br>
<br>
 =C2=A0 =C2=A0 =C2=A0 =C2=A0Arnd<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =C2=A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom internet charges in Canada: sign <a href=3D"http://sto=
pthemeter.ca/" target=3D"_blank">http://stopthemeter.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br>Kind regards=
,<br>Minchan Kim<br>

--001636c928c054da1204bcfd6c7b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
