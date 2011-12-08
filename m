Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 703F36B004F
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 21:38:40 -0500 (EST)
Received: by qcsd17 with SMTP id d17so1230585qcs.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 18:38:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111205161443.GA20663@tiehlicka.suse.cz>
References: <CAKXJSOHu+sQ1NeMsRvFyp2GYoB6g+50boUu=-QvbxxjcqgOAVA@mail.gmail.com>
	<20111205161443.GA20663@tiehlicka.suse.cz>
Date: Thu, 8 Dec 2011 10:38:39 +0800
Message-ID: <CAKXJSOErX_E9Oq0SHoRepJHy3Mb5ZkPYMJNbS6Z9DuQZXHO6sQ@mail.gmail.com>
Subject: Re: Question about __zone_watermark_ok: why there is a "+ 1" in
 computing free_pages?
From: Wang Sheng-Hui <shhuiw@gmail.com>
Content-Type: multipart/alternative; boundary=0016e686e5aae2217904b38b9036
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

--0016e686e5aae2217904b38b9036
Content-Type: text/plain; charset=ISO-8859-1

Sorry, Michal.

2011/12/6 Michal Hocko <mhocko@suse.cz>

> On Fri 25-11-11 09:21:35, Wang Sheng-Hui wrote:
> > In line 1459, we have "free_pages -= (1 << order) + 1;".
> > Suppose allocating one 0-order page, here we'll get
> >     free_pages -= 1 + 1
> > I wonder why there is a "+ 1"?
>
> Good spot. Check the patch bellow.
> ---
> From 38a1cf351b111e8791d2db538c8b0b912f5df8b8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 5 Dec 2011 17:04:23 +0100
> Subject: [PATCH] mm: fix off-by-two in __zone_watermark_ok
>
> 88f5acf8 [mm: page allocator: adjust the per-cpu counter threshold when
> memory is low] changed the form how free_pages is calculated but it
> forgot that we used to do free_pages - ((1 << order) - 1) so we ended up
> with off-by-two when calculating free_pages.
>
> Spotted-by: Wang Sheng-Hui <shhuiw@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9dd443d..8a2f1b6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1457,7 +1457,7 @@ static bool __zone_watermark_ok(struct zone *z, int
> order, unsigned long mark,
>        long min = mark;
>        int o;
>
> -       free_pages -= (1 << order) + 1;
> +       free_pages -= (1 << order) - 1;
>

I don't understand why there is additional "-1".
Use 0-order allocation as example:
      0-order page ---- one 4K page
free_pages should subtract 1. Here, free_pages will subtract 0?


>        if (alloc_flags & ALLOC_HIGH)
>                 min -= min / 2;
>         if (alloc_flags & ALLOC_HARDER)
> --
> 1.7.7.3
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--0016e686e5aae2217904b38b9036
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Sorry, Michal.<br><br><div class=3D"gmail_quote">2011/12/6 Michal Hocko <sp=
an dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>&gt;=
</span><br><blockquote class=3D"gmail_quote" style=3D"margin:0pt 0pt 0pt 0.=
8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">
<div class=3D"im">On Fri 25-11-11 09:21:35, Wang Sheng-Hui wrote:<br>
&gt; In line 1459, we have &quot;free_pages -=3D (1 &lt;&lt; order) + 1;&qu=
ot;.<br>
&gt; Suppose allocating one 0-order page, here we&#39;ll get<br>
&gt; =A0 =A0 free_pages -=3D 1 + 1<br>
&gt; I wonder why there is a &quot;+ 1&quot;?<br>
<br>
</div>Good spot. Check the patch bellow.<br>
---<br>
>From 38a1cf351b111e8791d2db538c8b0b912f5df8b8 Mon Sep 17 00:00:00 2001<br>
From: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@suse.cz</a>=
&gt;<br>
Date: Mon, 5 Dec 2011 17:04:23 +0100<br>
Subject: [PATCH] mm: fix off-by-two in __zone_watermark_ok<br>
<br>
88f5acf8 [mm: page allocator: adjust the per-cpu counter threshold when<br>
memory is low] changed the form how free_pages is calculated but it<br>
forgot that we used to do free_pages - ((1 &lt;&lt; order) - 1) so we ended=
 up<br>
with off-by-two when calculating free_pages.<br>
<br>
Spotted-by: Wang Sheng-Hui &lt;<a href=3D"mailto:shhuiw@gmail.com">shhuiw@g=
mail.com</a>&gt;<br>
Signed-off-by: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.cz">mhocko@su=
se.cz</a>&gt;<br>
---<br>
=A0mm/page_alloc.c | =A0 =A02 +-<br>
=A01 files changed, 1 insertions(+), 1 deletions(-)<br>
<br>
diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
index 9dd443d..8a2f1b6 100644<br>
--- a/mm/page_alloc.c<br>
+++ b/mm/page_alloc.c<br>
@@ -1457,7 +1457,7 @@ static bool __zone_watermark_ok(struct zone *z, int o=
rder, unsigned long mark,<br>
 =A0 =A0 =A0 =A0long min =3D mark;<br>
 =A0 =A0 =A0 =A0int o;<br>
<br>
- =A0 =A0 =A0 free_pages -=3D (1 &lt;&lt; order) + 1;<br>
+ =A0 =A0 =A0 free_pages -=3D (1 &lt;&lt; order) - 1;<br></blockquote><div>=
<br>I don&#39;t understand why there is additional &quot;-1&quot;.<br>
Use 0-order allocation as example:<br>
=A0=A0=A0=A0=A0 0-order page ---- one 4K page<br>
free_pages should subtract 1. Here, free_pages will subtract 0?<br>=A0</div=
><blockquote class=3D"gmail_quote" style=3D"margin:0pt 0pt 0pt 0.8ex;border=
-left:1px solid rgb(204,204,204);padding-left:1ex">
 =A0 =A0 =A0 =A0if (alloc_flags &amp; ALLOC_HIGH)<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0min -=3D min / 2;<br>
</div> =A0 =A0 =A0 =A0if (alloc_flags &amp; ALLOC_HARDER)<br>
--<br>
1.7.7.3<br>
<font color=3D"#888888"><br>
--<br>
Michal Hocko<br>
SUSE Labs<br>
SUSE LINUX s.r.o.<br>
Lihovarska 1060/12<br>
190 00 Praha 9<br>
Czech Republic<br>
</font></blockquote></div><br>

--0016e686e5aae2217904b38b9036--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
