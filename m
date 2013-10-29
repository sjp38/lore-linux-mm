Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4452D6B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 07:49:34 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id g10so8481798pdj.34
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 04:49:33 -0700 (PDT)
Received: from psmtp.com ([74.125.245.139])
        by mx.google.com with SMTP id l8si14690549pbi.241.2013.10.29.04.49.32
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 04:49:33 -0700 (PDT)
Received: by mail-we0-f169.google.com with SMTP id q58so8164739wes.28
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 04:49:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131029093322.GA2400@suse.de>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
	<20131029093322.GA2400@suse.de>
Date: Tue, 29 Oct 2013 19:49:30 +0800
Message-ID: <CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot page
From: Zhang Mingjun <zhang.mingjun@linaro.org>
Content-Type: multipart/alternative; boundary=f46d0444e8d7356a6b04e9dfcf6b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

--f46d0444e8d7356a6b04e9dfcf6b
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Oct 29, 2013 at 5:33 PM, Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.org wrote:
> > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> >
> > free_contig_range frees cma pages one by one and MIGRATE_CMA pages will
> be
> > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > migration action when these pages reused by CMA.
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
> >                       free_one_page(zone, page, 0, migratetype);
> >                       goto out;
>
> This slightly impacts the page allocator free path for a marginal gain
> on CMA which are relatively rare allocations. There is no obvious
> benefit to this patch as I expect CMA allocations to flush the PCP lists
>
how about keeping the migrate type of CMA page block as MIGRATE_ISOLATED
after
the alloc_contig_range , and undo_isolate_page_range at the end of
free_contig_range?
of course, it will waste the memory outside of the alloc range but in the
pageblocks.

> when a range of pages have been isolated and migrated. Is there any
> measurable benefit to this patch?
>
> after applying this patch, the video player on my platform works more
fluent,
and the driver of video decoder on my test platform using cma alloc/free
frequently.

> -- Mel Gorman
> SUSE Labs
>

--f46d0444e8d7356a6b04e9dfcf6b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Tue, Oct 29, 2013 at 5:33 PM, Mel Gorman <span dir=3D"ltr">&lt;<a href=
=3D"mailto:mgorman@suse.de" target=3D"_blank">mgorman@suse.de</a>&gt;</span=
> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left:1px solid rgb(204,204,204);padding-left:1ex"><div class=3D"im">On Mon,=
 Oct 28, 2013 at 07:42:49PM +0800, <a href=3D"mailto:zhang.mingjun@linaro.o=
rg">zhang.mingjun@linaro.org</a> wrote:<br>

</div><div><div class=3D"h5">&gt; From: Mingjun Zhang &lt;<a href=3D"mailto=
:troy.zhangmingjun@linaro.org">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt;<br>
&gt; free_contig_range frees cma pages one by one and MIGRATE_CMA pages wil=
l be<br>
&gt; used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary<=
br>
&gt; migration action when these pages reused by CMA.<br>
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
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_one_page(zone, page, =
0, migratetype);<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
<br>
</div></div>This slightly impacts the page allocator free path for a margin=
al gain<br>
on CMA which are relatively rare allocations. There is no obvious<br>
benefit to this patch as I expect CMA allocations to flush the PCP lists<br=
></blockquote><div><div>how about keeping the migrate type of CMA page bloc=
k as MIGRATE_ISOLATED after<br>the alloc_contig_range , and undo_isolate_pa=
ge_range at the end of free_contig_range?<br>
</div>of course, it will waste the memory outside of the alloc range but in=
 the pageblocks. <br></div><blockquote class=3D"gmail_quote" style=3D"margi=
n:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex=
">

when a range of pages have been isolated and migrated. Is there any<br>
measurable benefit to this patch?<br>
<span class=3D""><font color=3D"#888888"><br></font></span></blockquote><di=
v>after applying this patch, the video player on my platform works more flu=
ent,<br></div><div>and the driver of video decoder on my test platform usin=
g cma alloc/free frequently.<br>
 </div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;=
border-left:1px solid rgb(204,204,204);padding-left:1ex"><span class=3D""><=
font color=3D"#888888">
--
Mel Gorman<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div></div>

--f46d0444e8d7356a6b04e9dfcf6b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
