Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5886B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 07:17:35 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so8412180pdj.14
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 04:17:35 -0700 (PDT)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id mi5si15574520pab.251.2013.10.29.04.17.27
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 04:17:28 -0700 (PDT)
Received: by mail-wg0-f51.google.com with SMTP id l18so8088914wgh.30
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 04:17:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131029072511.GA6030@bbox>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
	<20131029045430.GE17038@bbox>
	<CAGT3LeqEzMKeq5PYz+Dv-rCBsTuUAtttyvYZu4UYWsAkUn8urQ@mail.gmail.com>
	<20131029072511.GA6030@bbox>
Date: Tue, 29 Oct 2013 19:17:25 +0800
Message-ID: <CAGT3Leqnu0hT3=a=JLFLz5MKH7Nk2s2A4NnBOtO59L5Gty236w@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot page
From: Zhang Mingjun <zhang.mingjun@linaro.org>
Content-Type: multipart/alternative; boundary=089e01227dfe7d96d704e9df5c9c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mingjun Zhang <troy.zhangmingjun@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--089e01227dfe7d96d704e9df5c9c
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Oct 29, 2013 at 3:25 PM, Minchan Kim <minchan@kernel.org> wrote:

> On Tue, Oct 29, 2013 at 03:00:09PM +0800, Zhang Mingjun wrote:
> > On Tue, Oct 29, 2013 at 12:54 PM, Minchan Kim <minchan@kernel.org>
> wrote:
> >
> > > Hello,
> > >
> > > On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.orgwrote:
> > > > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > > >
> > > > free_contig_range frees cma pages one by one and MIGRATE_CMA pages
> will
> > > be
> > > > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > > > migration action when these pages reused by CMA.
> > >
> > > You are saying about the overhead but I'm not sure how much it is
> > > because it wouldn't be frequent. Although it's frequent, migration is
> > > already slow path and CMA migration is worse so I really wonder how
> much
> > > pain is and how much this patch improve.
> > >
> > > Having said that, it makes CMA allocation policy consistent which
> > > is that CMA migration type is last fallback to minimize number of
> migration
> > > and code peice you are adding is already low hit path so that I think
> > > it has no problem.
> > >
> > problem is when free_contig_range frees cma pages, page's migration type
> is
> > MIGRATE_CMA!
> > I don't know why free_contig_range free pages one by one, but in the end
> it
> > calls free_hot_cold_page,
> > so some of these MIGRATE_CMA pages will be used as MIGRATE_MOVEABLE, this
> > break the CMA
> > allocation policy and it's not the low hit path, it's really the hot
> path,
> > in fact each time free_contig_range calls
> > some of these CMA pages will stay on this pcp list.
> > when filesytem needs a pagecache or page fault exception which alloc one
> > page using alloc_pages(MOVABLE, 0)
> > it will get the page from this pcp list, breaking the CMA fallback rules,
> > that is CMA pages in pcp list using as
> > page cache or annoymous page very easily.
>
>
> It seems you misunderstood me. My English was poor?
>
sorry, it's my fault, my poor english.

> I already said that I agree with you.
> Your patch has no impact with hot path and makes CMA allocation policy
> consistent so that there is no objection.
>
> >
> > > >
> > > > Signed-off-by: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > > > ---
> > > >  mm/page_alloc.c |    3 ++-
> > > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 0ee638f..84b9d84 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *page, int
> > > cold)
> > > >        * excessively into the page allocator
> > > >        */
> > > >       if (migratetype >= MIGRATE_PCPTYPES) {
> > > > -             if (unlikely(is_migrate_isolate(migratetype))) {
> > > > +             if (unlikely(is_migrate_isolate(migratetype))
> > > > +                     || is_migrate_cma(migratetype))
> > >
> > > The concern is likely/unlikely usage is proper in this code peice.
> > > If we don't use memory isolation, the code path is used for only
> > > MIGRATE_RESERVE which is very rare allocation in normal workload.
> > >
> > > Even, in memory isolation environement, I'm not sure how many
> > > CMA/HOTPLUG is used compared to normal alloc/free.
> > > So, I think below is more proper?
> > >
> > > if (unlikely(migratetype >= MIGRATE_PCPTYPES)) {
> > >         if (is_migrate_isolate(migratetype) ||
> is_migrate_cma(migratetype))
> > >
> > > if CMA is enabled and alloc/free frequently, it will more likely
> > migratetype >= MIGRATE_PCPTYPES
>
> Until now, I didn't notice there is such workload. Do you have such real
> workload?
>
yes, my test platform using cma for video decoder, it alloc/free cma
frequently.

If so, we should change it with following as?
>
> if (migratetype >= MIGRATE_PCPTYPES) {
>         if (is_migrate_cma(migratetype) ||
> unlikely(is_migrate_isolate(migratetype)))
>
ok.

>
> Because assumption is you insist that there is lots of alloc/free for CMA.
> But since we have had unlikely on memory-hotplug check, it would be less
> than CMA.
>
>
>
> >
> > I know it's an another topic but I'd like to disucss it in this time
> because
> > > we will forget such trivial thing later, again.
> > >
> > > }
> > >
> > > >                       free_one_page(zone, page, 0, migratetype);
> > > >                       goto out;
> > > >               }
> > > > --
> > > > 1.7.9.5
> > > >
> > > > --
> > > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > > see: http://www.linux-mm.org/ .
> > > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > >
> > > --
> > > Kind regards,
> > > Minchan Kim
> > >
>
> --
> Kind regards,
> Minchan Kim
>

--089e01227dfe7d96d704e9df5c9c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
ue, Oct 29, 2013 at 3:25 PM, Minchan Kim <span dir=3D"ltr">&lt;<a href=3D"m=
ailto:minchan@kernel.org" target=3D"_blank">minchan@kernel.org</a>&gt;</spa=
n> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On T=
ue, Oct 29, 2013 at 03:00:09PM +0800, Zhang Mingjun wrote:<br>
&gt; On Tue, Oct 29, 2013 at 12:54 PM, Minchan Kim &lt;<a href=3D"mailto:mi=
nchan@kernel.org">minchan@kernel.org</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Hello,<br>
&gt; &gt;<br>
&gt; &gt; On Mon, Oct 28, 2013 at 07:42:49PM +0800, <a href=3D"mailto:zhang=
.mingjun@linaro.org">zhang.mingjun@linaro.org</a> wrote:<br>
&gt; &gt; &gt; From: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhangmingjun@=
linaro.org">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; free_contig_range frees cma pages one by one and MIGRATE_CMA=
 pages will<br>
&gt; &gt; be<br>
&gt; &gt; &gt; used as MIGRATE_MOVEABLE pages in the pcp list, it causes un=
necessary<br>
&gt; &gt; &gt; migration action when these pages reused by CMA.<br>
&gt; &gt;<br>
&gt; &gt; You are saying about the overhead but I&#39;m not sure how much i=
t is<br>
&gt; &gt; because it wouldn&#39;t be frequent. Although it&#39;s frequent, =
migration is<br>
&gt; &gt; already slow path and CMA migration is worse so I really wonder h=
ow much<br>
&gt; &gt; pain is and how much this patch improve.<br>
&gt; &gt;<br>
&gt; &gt; Having said that, it makes CMA allocation policy consistent which=
<br>
&gt; &gt; is that CMA migration type is last fallback to minimize number of=
 migration<br>
&gt; &gt; and code peice you are adding is already low hit path so that I t=
hink<br>
&gt; &gt; it has no problem.<br>
&gt; &gt;<br>
&gt; problem is when free_contig_range frees cma pages, page&#39;s migratio=
n type is<br>
&gt; MIGRATE_CMA!<br>
&gt; I don&#39;t know why free_contig_range free pages one by one, but in t=
he end it<br>
&gt; calls free_hot_cold_page,<br>
&gt; so some of these MIGRATE_CMA pages will be used as MIGRATE_MOVEABLE, t=
his<br>
&gt; break the CMA<br>
&gt; allocation policy and it&#39;s not the low hit path, it&#39;s really t=
he hot path,<br>
&gt; in fact each time free_contig_range calls<br>
&gt; some of these CMA pages will stay on this pcp list.<br>
&gt; when filesytem needs a pagecache or page fault exception which alloc o=
ne<br>
&gt; page using alloc_pages(MOVABLE, 0)<br>
&gt; it will get the page from this pcp list, breaking the CMA fallback rul=
es,<br>
&gt; that is CMA pages in pcp list using as<br>
&gt; page cache or annoymous page very easily.<br>
<br>
<br>
</div></div>It seems you misunderstood me. My English was poor?<br></blockq=
uote><div>sorry, it&#39;s my fault, my poor english.<br></div><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">

I already said that I agree with you.<br>
Your patch has no impact with hot path and makes CMA allocation policy<br>
consistent so that there is no objection.<br>
<div><div class=3D"h5"><br>
&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Signed-off-by: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhan=
gmingjun@linaro.org">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt; &gt; &gt; ---<br>
&gt; &gt; &gt; =A0mm/page_alloc.c | =A0 =A03 ++-<br>
&gt; &gt; &gt; =A01 file changed, 2 insertions(+), 1 deletion(-)<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; diff --git a/mm/page_alloc.c b/mm/page_alloc.c<br>
&gt; &gt; &gt; index 0ee638f..84b9d84 100644<br>
&gt; &gt; &gt; --- a/mm/page_alloc.c<br>
&gt; &gt; &gt; +++ b/mm/page_alloc.c<br>
&gt; &gt; &gt; @@ -1362,7 +1362,8 @@ void free_hot_cold_page(struct page *p=
age, int<br>
&gt; &gt; cold)<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0* excessively into the page allocator<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0*/<br>
&gt; &gt; &gt; =A0 =A0 =A0 if (migratetype &gt;=3D MIGRATE_PCPTYPES) {<br>
&gt; &gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(is_migrate_isolate(mi=
gratetype))) {<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(is_migrate_isolate(mi=
gratetype))<br>
&gt; &gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 || is_migrate_cma(=
migratetype))<br>
&gt; &gt;<br>
&gt; &gt; The concern is likely/unlikely usage is proper in this code peice=
.<br>
&gt; &gt; If we don&#39;t use memory isolation, the code path is used for o=
nly<br>
&gt; &gt; MIGRATE_RESERVE which is very rare allocation in normal workload.=
<br>
&gt; &gt;<br>
&gt; &gt; Even, in memory isolation environement, I&#39;m not sure how many=
<br>
&gt; &gt; CMA/HOTPLUG is used compared to normal alloc/free.<br>
&gt; &gt; So, I think below is more proper?<br>
&gt; &gt;<br>
&gt; &gt; if (unlikely(migratetype &gt;=3D MIGRATE_PCPTYPES)) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 if (is_migrate_isolate(migratetype) || is_migrate=
_cma(migratetype))<br>
&gt; &gt;<br>
&gt; &gt; if CMA is enabled and alloc/free frequently, it will more likely<=
br>
&gt; migratetype &gt;=3D MIGRATE_PCPTYPES<br>
<br>
</div></div>Until now, I didn&#39;t notice there is such workload. Do you h=
ave such real workload?<br></blockquote><div>yes, my test platform using cm=
a for video decoder, it alloc/free cma frequently.<br><br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc soli=
d;padding-left:1ex">

If so, we should change it with following as?<br>
<br>
if (migratetype &gt;=3D MIGRATE_PCPTYPES) {<br>
=A0 =A0 =A0 =A0 if (is_migrate_cma(migratetype) || unlikely(is_migrate_isol=
ate(migratetype)))<br></blockquote><div>ok. <br></div><blockquote class=3D"=
gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-=
left:1ex">

<br>
Because assumption is you insist that there is lots of alloc/free for CMA.<=
br>
But since we have had unlikely on memory-hotplug check, it would be less th=
an CMA.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
<br>
<br>
&gt;<br>
&gt; I know it&#39;s an another topic but I&#39;d like to disucss it in thi=
s time because<br>
&gt; &gt; we will forget such trivial thing later, again.<br>
&gt; &gt;<br>
&gt; &gt; }<br>
&gt; &gt;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_one_page(zo=
ne, page, 0, migratetype);<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; &gt; &gt; --<br>
&gt; &gt; &gt; 1.7.9.5<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; --<br>
&gt; &gt; &gt; To unsubscribe, send a message with &#39;unsubscribe linux-m=
m&#39; in<br>
&gt; &gt; &gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo=
@kvack.org</a>. =A0For more info on Linux MM,<br>
&gt; &gt; &gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">=
http://www.linux-mm.org/</a> .<br>
&gt; &gt; &gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto=
:dont@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack=
.org">email@kvack.org</a> &lt;/a&gt;<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; Kind regards,<br>
&gt; &gt; Minchan Kim<br>
&gt; &gt;<br>
<br>
--<br>
Kind regards,<br>
Minchan Kim<br>
</div></div></blockquote></div><br></div></div>

--089e01227dfe7d96d704e9df5c9c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
