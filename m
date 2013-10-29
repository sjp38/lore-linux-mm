Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 26FB96B0031
	for <linux-mm@kvack.org>; Tue, 29 Oct 2013 11:02:35 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id un4so2353121pbc.5
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 08:02:34 -0700 (PDT)
Received: from psmtp.com ([74.125.245.146])
        by mx.google.com with SMTP id iu9si16108992pac.147.2013.10.29.08.02.33
        for <linux-mm@kvack.org>;
        Tue, 29 Oct 2013 08:02:34 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id k14so3552663wgh.19
        for <linux-mm@kvack.org>; Tue, 29 Oct 2013 08:02:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20131029122708.GD2400@suse.de>
References: <1382960569-6564-1-git-send-email-zhang.mingjun@linaro.org>
	<20131029093322.GA2400@suse.de>
	<CAGT3LergVJ1XXCrVD3XeRpRCXehn9gLb7BRHHyjyseKBz39pMg@mail.gmail.com>
	<20131029122708.GD2400@suse.de>
Date: Tue, 29 Oct 2013 23:02:30 +0800
Message-ID: <CAGT3LerfYfgdkDd=LnuA8y7SUjOSTbw-HddbuzQ=O3yw-vtnnQ@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: free cma page to buddy instead of being cpu hot page
From: Zhang Mingjun <zhang.mingjun@linaro.org>
Content-Type: multipart/alternative; boundary=047d7b45105e76b66d04e9e281de
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, akpm@linux-foundation.org, Haojian Zhuang <haojian.zhuang@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, troy.zhangmingjun@huawei.com

--047d7b45105e76b66d04e9e281de
Content-Type: text/plain; charset=ISO-8859-1

On Tue, Oct 29, 2013 at 8:27 PM, Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Oct 29, 2013 at 07:49:30PM +0800, Zhang Mingjun wrote:
> > On Tue, Oct 29, 2013 at 5:33 PM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > > On Mon, Oct 28, 2013 at 07:42:49PM +0800, zhang.mingjun@linaro.orgwrote:
> > > > From: Mingjun Zhang <troy.zhangmingjun@linaro.org>
> > > >
> > > > free_contig_range frees cma pages one by one and MIGRATE_CMA pages
> will
> > > be
> > > > used as MIGRATE_MOVEABLE pages in the pcp list, it causes unnecessary
> > > > migration action when these pages reused by CMA.
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
> > > >                       free_one_page(zone, page, 0, migratetype);
> > > >                       goto out;
> > >
> > > This slightly impacts the page allocator free path for a marginal gain
> > > on CMA which are relatively rare allocations. There is no obvious
> > > benefit to this patch as I expect CMA allocations to flush the PCP
> lists
> > >
> > how about keeping the migrate type of CMA page block as MIGRATE_ISOLATED
> > after
> > the alloc_contig_range , and undo_isolate_page_range at the end of
> > free_contig_range?
>
> It would move the cost to the CMA paths so I would complain less. Bear
> in mind as well that forcing everything to go through free_one_page()
> means that every free goes through the zone lock. I doubt you have any
> machine large enough but it is possible for simultaneous CMA allocations
> to now contend on the zone lock that would have been previously fine.
> Hence, I'm interesting in knowing the underlying cause of the problem you
> are experiencing.
>
> my platform uses CMA but disabled CMA's migration func by del MIGRATE_CMA
in fallbacks[MIGRATE_MOVEABLE]. But I find CMA pages can still used by
pagecache or page fault page request from PCP list and cma allocation has to
migrate these page. So I want to free these cma pages to buddy directly not
PCP..

> of course, it will waste the memory outside of the alloc range but in the
> > pageblocks.
> >
>
> I would hope/expect that the loss would only last for the duration of
> the allocation attempt and a small amount of memory.
>
> > > when a range of pages have been isolated and migrated. Is there any
> > > measurable benefit to this patch?
> > >
> > after applying this patch, the video player on my platform works more
> > fluent,
>
> fluent almost always refers to ones command of a spoken language. I do
> not see how a video player can be fluent in anything. What is measurably
> better?
>
> For example, are allocations faster? If so, why? What cost from another
> path is removed as a result of this patch? If the cost is in the PCP
> flush then can it be checked if the PCP flush was unnecessary and called
> unconditionally even though all the pages were freed already? We had
> problems in the past where drain_all_pages() or similar were called
> unnecessarily causing long sync stalls related to IPIs. I'm wondering if
> we are seeing a similar problem here.
>
> Maybe the problem is the complete opposite. Are allocations failing
> because there are PCP pages in the way? In that case, it real fix might
> be to insert a  if the allocation is failing due to per-cpu
> pages.
>
problem is not the allocation failing, but the unexpected cma migration
slows
down the allocation.

>
> > and the driver of video decoder on my test platform using cma alloc/free
> > frequently.
> >
>
> CMA allocations are almost never used outside of these contexts. While I
> appreciate that embedded use is important I'm reluctant to see an impact
> in fast paths unless there is a good reason for every other use case. I
> also am a bit unhappy to see CMA allocations making the zone->lock
> hotter than necessary even if no embedded use case it likely to
> experience the problem in the short-term.
>
> --
> Mel Gorman
> SUSE Labs
>

--047d7b45105e76b66d04e9e281de
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">On T=
ue, Oct 29, 2013 at 8:27 PM, Mel Gorman <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:mgorman@suse.de" target=3D"_blank">mgorman@suse.de</a>&gt;</span> wrot=
e:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">

<div><div>On Tue, Oct 29, 2013 at 07:49:30PM +0800, Zhang Mingjun wrote:<br=
>
&gt; On Tue, Oct 29, 2013 at 5:33 PM, Mel Gorman &lt;<a href=3D"mailto:mgor=
man@suse.de" target=3D"_blank">mgorman@suse.de</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; On Mon, Oct 28, 2013 at 07:42:49PM +0800, <a href=3D"mailto:zhang=
.mingjun@linaro.org" target=3D"_blank">zhang.mingjun@linaro.org</a> wrote:<=
br>
&gt; &gt; &gt; From: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhangmingjun@=
linaro.org" target=3D"_blank">troy.zhangmingjun@linaro.org</a>&gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; free_contig_range frees cma pages one by one and MIGRATE_CMA=
 pages will<br>
&gt; &gt; be<br>
&gt; &gt; &gt; used as MIGRATE_MOVEABLE pages in the pcp list, it causes un=
necessary<br>
&gt; &gt; &gt; migration action when these pages reused by CMA.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Signed-off-by: Mingjun Zhang &lt;<a href=3D"mailto:troy.zhan=
gmingjun@linaro.org" target=3D"_blank">troy.zhangmingjun@linaro.org</a>&gt;=
<br>
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
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_one_page(zo=
ne, page, 0, migratetype);<br>
&gt; &gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; &gt;<br>
&gt; &gt; This slightly impacts the page allocator free path for a marginal=
 gain<br>
&gt; &gt; on CMA which are relatively rare allocations. There is no obvious=
<br>
&gt; &gt; benefit to this patch as I expect CMA allocations to flush the PC=
P lists<br>
&gt; &gt;<br>
&gt; how about keeping the migrate type of CMA page block as MIGRATE_ISOLAT=
ED<br>
&gt; after<br>
&gt; the alloc_contig_range , and undo_isolate_page_range at the end of<br>
&gt; free_contig_range?<br>
<br>
</div></div>It would move the cost to the CMA paths so I would complain les=
s. Bear<br>
in mind as well that forcing everything to go through free_one_page()<br>
means that every free goes through the zone lock. I doubt you have any<br>
machine large enough but it is possible for simultaneous CMA allocations<br=
>
to now contend on the zone lock that would have been previously fine.<br>
Hence, I&#39;m interesting in knowing the underlying cause of the problem y=
ou<br>
are experiencing.<br>
<div><br></div></blockquote><div>my platform uses CMA but disabled CMA&#39;=
s migration func by del MIGRATE_CMA<br>in fallbacks[MIGRATE_MOVEABLE]. But =
I find CMA pages can still used by<br>pagecache or page fault page request =
from PCP list and cma allocation has to<br>
migrate these page. So I want to free these cma pages to buddy directly not=
 PCP..<br></div><div><br></div><blockquote class=3D"gmail_quote" style=3D"m=
argin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div>
&gt; of course, it will waste the memory outside of the alloc range but in =
the<br>
&gt; pageblocks.<br>
&gt;<br>
<br>
</div>I would hope/expect that the loss would only last for the duration of=
<br>
the allocation attempt and a small amount of memory.<br>
<div><br>
&gt; &gt; when a range of pages have been isolated and migrated. Is there a=
ny<br>
&gt; &gt; measurable benefit to this patch?<br>
&gt; &gt;<br>
&gt; after applying this patch, the video player on my platform works more<=
br>
&gt; fluent,<br>
<br>
</div>fluent almost always refers to ones command of a spoken language. I d=
o<br>
not see how a video player can be fluent in anything. What is measurably<br=
>
better?<br>
<br>
For example, are allocations faster? If so, why? What cost from another<br>
path is removed as a result of this patch? If the cost is in the PCP<br>
flush then can it be checked if the PCP flush was unnecessary and called<br=
>
unconditionally even though all the pages were freed already? We had<br>
problems in the past where drain_all_pages() or similar were called<br>
unnecessarily causing long sync stalls related to IPIs. I&#39;m wondering i=
f<br>
we are seeing a similar problem here.<br>
<br>
Maybe the problem is the complete opposite. Are allocations failing<br>
because there are PCP pages in the way? In that case, it real fix might<br>
be to insert a=A0 if the allocation is failing due to per-cpu<br>
pages.<br></blockquote><div>problem is not the allocation failing, but the =
unexpected cma migration slows<br>down the allocation.</div><blockquote cla=
ss=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;pa=
dding-left:1ex">

<div><br>
&gt; and the driver of video decoder on my test platform using cma alloc/fr=
ee<br>
&gt; frequently.<br>
&gt;<br>
<br>
</div>CMA allocations are almost never used outside of these contexts. Whil=
e I<br>
appreciate that embedded use is important I&#39;m reluctant to see an impac=
t<br>
in fast paths unless there is a good reason for every other use case. I<br>
also am a bit unhappy to see CMA allocations making the zone-&gt;lock<br>
hotter than necessary even if no embedded use case it likely to<br>
experience the problem in the short-term.<br>
<div><div><br>
--<br>
Mel Gorman<br>
SUSE Labs<br>
</div></div></blockquote></div><br></div></div>

--047d7b45105e76b66d04e9e281de--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
