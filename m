Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3A60D6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 03:00:16 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so8130797pde.15
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 00:00:13 -0700 (PDT)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id kg8si14966263pad.328.2013.10.29.00.00.11
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 00:00:12 -0700 (PDT)
Received: by mail-wg0-f51.google.com with SMTP id l18so7621341wgh.6
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 00:00:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131029045430.GE17038@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
	<20131029045430.GE17038@bbox>
Date: Tue, 29 Oct 2013 15:00:09 +0800
Message-ID: <CAGT3LeqEzMKeq5PYz+Dv-rCBsTuUAtttyvYZu4UYWsAkUn8urQ@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot page
From: Zhang Mingjun <zhang.mingjun@linaro.org>
Content-Type: multipart/alternative; boundary=f46d0444e8d76ac7cc04e9dbc42d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--f46d0444e8d76ac7cc04e9dbc42d
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Oct 29, 2013 at 12:54 PM, Minchan Kim <minchan@kernel.org> wrote:

> Hello,
>
> On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> >
> > free_contig_range frees cma pages one by one and MIGRATE_CMA pages will
> be
> > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > migration action when these pages reused by CMA.
>
> You are saying about the overhead but I'm not sure how much it is
> because it wouldn't be frequent. Although it's frequent, migration is
> already slow path and CMA migration is worse so I really wonder how much
> pain is and how much this patch improve.
>
> Having said that, it makes CMA allocation policy consistent which
> is that CMA migration type is last fallback to minimize number of migration
> and code peice you are adding is already low hit path so that I think
> it has no problem.
>
problem is when free_contig_range frees cma pages, page's migration type is
MIGRATE_CMA!
I don't know why free_contig_range free pages one by one, but in the end it
calls free_hot_cold_page,
so some of these MIGRATE_CMA pages will be used as MIGRATE_MOVEABLE, this
break the CMA
allocation policy and it's not the low hit path, it's really the hot path,
in fact each time free_contig_range calls
some of these CMA pages will stay on this pcp list.
when filesytem needs a pagecache or page fault exception which alloc one
page using alloc_pages(MOVABLE, 0)
it will get the page from this pcp list, breaking the CMA fallback rules,
that is CMA pages in pcp list using as
page cache or annoymous page very easily.

> >
> > Signed-off-by: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > ---
> >  mm/page_alloc.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 0ee638f..84b9d84 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int
> cold)
> >        * excessively into the page allocator
> >        */
> >       if (migratetype >= MIGRATE_PCPTYPES) {
> > -             if (unlikely(is_migrate_isolate(migratetype))) {
> > +             if (unlikely(is_migrate_isolate(migratetype))
> > +                     || is_migrate_cma(migratetype))
>
> The concern is likely/unlikely usage is proper in this code peice.
> If we don't use memory isolation, the code path is used for only
> MIGRATE_RESERVE which is very rare allocation in normal workload.
>
> Even, in memory isolation environement, I'm not sure how many
> CMA/HOTPLUG is used compared to normal alloc/free.
> So, I think below is more proper?
>
> if (unlikely(migratetype >= MIGRATE_PCPTYPES)) {
>         if (is_migrate_isolate(migratetype) || is_migrate_cma(migratetype))
>
> if CMA is enabled and alloc/free frequently, it will more likely
migratetype >= MIGRATE_PCPTYPES

I know it's an another topic but I'd like to disucss it in this time because
> we will forget such trivial thing later, again.
>
> }
>
> >                       free_one_page(zone, page, 0, migratetype);
> >                       goto out;
> >               }
> > --
> > 1.7.9.5
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim
>

--f46d0444e8d76ac7cc04e9dbc42d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
ue, Oct 29, 2013 at 12:54 PM, Minchan Kim <span dir=3D"ltr">&lt;<a href=3D"=
mailto:minchan@kernel.org" target=3D"_blank">minchan@kernel.org</a>&gt;</sp=
an> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex">Hello,<br>
<div class=3D"im"><br>
On Mon, Oct 28, 2013 at 07:42:49PM +0800, <a href=3D"mailto:zhang.mingjun@l=
inaro.org">zhang.mingjun@linaro.org</a> wrote:<br>
&gt; From: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhangmingjun@linaro.org=
">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt;<br>
&gt; free_contig_range frees cma pages one by one and MIGRATE_CMA pages wil=
l be<br>
&gt; used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary<=
br>
&gt; migration action when these pages reused by CMA.<br>
<br>
</div>You are saying about the overhead but I&#39;m not sure how much it is=
<br>
because it wouldn&#39;t be frequent. Although it&#39;s frequent, migration =
is<br>
already slow path and CMA migration is worse so I really wonder how much<br=
>
pain is and how much this patch improve.<br>
<br>
Having said that, it makes CMA allocation policy consistent which<br>
is that CMA migration type is last fallback to minimize number of migration=
<br>
and code peice you are adding is already low hit path so that I think<br>
it has no problem.=A0<br></blockquote><div>problem is when free_contig_rang=
e frees cma pages, page&#39;s migration type is MIGRATE_CMA!<br>I don&#39;t=
 know why free_contig_range free pages one by one, but in the end it calls =
free_hot_cold_page,<br>
</div><div>so some of these MIGRATE_CMA pages will be used as MIGRATE_MOVEA=
BLE, this break the CMA<br></div><div>allocation policy and it&#39;s not th=
e low hit path, it&#39;s really the hot path, in fact each time free_contig=
_range calls<br>
</div><div>some of these CMA pages will stay on this pcp list. <br></div><d=
iv>when filesytem needs a pagecache or page fault exception which alloc one=
 page using alloc_pages(MOVABLE, 0)<br></div><div>it will get the page from=
 this pcp list, breaking the CMA fallback rules, that is CMA pages in pcp l=
ist using as<br>
</div><div>page cache or annoymous page very easily.<br></div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px soli=
d rgb(204,204,204);padding-left:1ex"><div class=3D"im">
&gt;<br>
&gt; Signed-off-by: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhangmingjun@l=
inaro.org">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt; ---<br>
&gt; =A0mm/page_alloc.c | =A0 =A03 ++-<br>
&gt; =A01 file changed, 2 insertions(+), 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; index 0ee638f..84b9d84 100644<br>
&gt; --- a/mm/page_alloc.c<br>
&gt; +++ b/mm/page_alloc.c<br>
&gt; @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int c=
old)<br>
&gt; =A0 =A0 =A0 =A0* excessively into the page allocator<br>
&gt; =A0 =A0 =A0 =A0*/<br>
&gt; =A0 =A0 =A0 if (migratetype &gt;=3D MIGRATE_PCPTYPES) {<br>
&gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(is_migrate_isolate(migratetype)=
)) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(is_migrate_isolate(migratetype)=
)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || is_migrate_cma(migratetyp=
e))<br>
<br>
</div>The concern is likely/unlikely usage is proper in this code peice.<br=
>
If we don&#39;t use memory isolation, the code path is used for only<br>
MIGRATE_RESERVE which is very rare allocation in normal workload.<br>
<br>
Even, in memory isolation environement, I&#39;m not sure how many<br>
CMA/HOTPLUG is used compared to normal alloc/free.<br>
So, I think below is more proper?<br>
<br>
if (unlikely(migratetype &gt;=3D MIGRATE_PCPTYPES)) {<br>
=A0 =A0 =A0 =A0 if (is_migrate_isolate(migratetype) || is_migrate_cma(migra=
tetype))<br>
<br></blockquote><div>if CMA is enabled and alloc/free frequently, it will =
more likely migratetype &gt;=3D MIGRATE_PCPTYPES<br><br></div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px soli=
d rgb(204,204,204);padding-left:1ex">

I know it&#39;s an another topic but I&#39;d like to disucss it in this tim=
e because<br>
we will forget such trivial thing later, again.<br>
<div class=3D""><div class=3D"h5"><br>
}<br>
<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_one_page(zone, page, =
0, migratetype);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; --<br>
&gt; 1.7.9.5<br>
&gt;<br>
</div></div><span class=3D""><font color=3D"#888888">&gt; --<br>
&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<=
br>
&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org=
</a>. =A0For more info on Linux MM,<br>
&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www=
.linux-mm.org/</a> .<br>
&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvac=
k.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">emai=
l@kvack.org</a> &lt;/a&gt;<br>
<br>
--<br>
Kind regards,<br>
Minchan Kim<br>
</font></span></blockquote></div><br></div></div>

--f46d0444e8d76ac7cc04e9dbc42d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
