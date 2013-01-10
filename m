Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C6A716B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:24:22 -0500 (EST)
Received: by mail-oa0-f49.google.com with SMTP id l10so1202283oag.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2013 15:24:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130110020347.GA14685@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
	<1357712474-27595-2-git-send-email-minchan@kernel.org>
	<20130109161854.67412dcc.akpm@linux-foundation.org>
	<20130110020347.GA14685@blaptop>
Date: Thu, 10 Jan 2013 15:24:21 -0800
Message-ID: <CAA25o9TjXNCpLHAyowboAxZrnQZmNmJOevDgA-zq4kA1K-PHXQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: prevent to add a page to swap if may_writepage is unset
From: Luigi Semenzato <semenzato@google.com>
Content-Type: multipart/alternative; boundary=f46d04447ecf8e6fab04d2f77a48
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

--f46d04447ecf8e6fab04d2f77a48
Content-Type: text/plain; charset=ISO-8859-1

For what it's worth, I tested this patch on my 3.4 kernel, and it works as
advertised.  Here's my setup.

- 2 GB RAM
- a 3 GB zram disk for swapping
- start one "hog" process per second (each hog process mallocs and touches
200 MB of memory).
- watch /proc/meminfo

1. I verified that the problem still exists on my current 3.4 kernel.  With
laptop_mode = 2, hog processes are oom-killed when about 1.8-1.9 (out of 3)
GB of swap space are still left

2. I double-checked that the problem does not exist with laptop_mode = 0:
hog processes are oom-killed when swap space is exhausted (with good
approximation).

3. I added the two-line patch, put back laptop_mode = 2, and verified that
hog processes are oom-killed when swap space is exhausted, same as case 2.

Let me know if I can run any more tests for you, and thanks for all the
support so far!



On Wed, Jan 9, 2013 at 6:03 PM, Minchan Kim <minchan@kernel.org> wrote:

> Hi Andrew,
>
> On Wed, Jan 09, 2013 at 04:18:54PM -0800, Andrew Morton wrote:
> > On Wed,  9 Jan 2013 15:21:13 +0900
> > Minchan Kim <minchan@kernel.org> wrote:
> >
> > > Recently, Luigi reported there are lots of free swap space when
> > > OOM happens. It's easily reproduced on zram-over-swap, where
> > > many instance of memory hogs are running and laptop_mode is enabled.
> > >
> > > Luigi reported there was no problem when he disabled laptop_mode.
> > > The problem when I investigate problem is following as.
> > >
> > > try_to_free_pages disable may_writepage if laptop_mode is enabled.
> > > shrink_page_list adds lots of anon pages in swap cache by
> > > add_to_swap, which makes pages Dirty and rotate them to head of
> > > inactive LRU without pageout. If it is repeated, inactive anon LRU
> > > is full of Dirty and SwapCache pages.
> > >
> > > In case of that, isolate_lru_pages fails because it try to isolate
> > > clean page due to may_writepage == 0.
> > >
> > > The may_writepage could be 1 only if total_scanned is higher than
> > > writeback_threshold in do_try_to_free_pages but unfortunately,
> > > VM can't isolate anon pages from inactive anon lru list by
> > > above reason and we already reclaimed all file-backed pages.
> > > So it ends up OOM killing.
> > >
> > > This patch prevents to add a page to swap cache unnecessary when
> > > may_writepage is unset so anoymous lru list isn't full of
> > > Dirty/Swapcache page. So VM can isolate pages from anon lru list,
> > > which ends up setting may_writepage to 1 and could swap out
> > > anon lru pages. When OOM triggers, I confirmed swap space was full.
> > >
> > > ...
> > >
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
> > >             if (PageAnon(page) && !PageSwapCache(page)) {
> > >                     if (!(sc->gfp_mask & __GFP_IO))
> > >                             goto keep_locked;
> > > +                   if (!sc->may_writepage)
> > > +                           goto keep_locked;
> > >                     if (!add_to_swap(page))
> > >                             goto activate_locked;
> > >                     may_enter_fs = 1;
> >
> > I'm not really getting it, and the description is rather hard to follow
> :(
>
> It seems I don't have a talent about description. :(
> I hope it would be better this year. :)
>
> >
> > We should be adding anon pages to swapcache even when laptop_mode is
> > set.  And we should be writing them to swap as well, then reclaiming
> > them.  The only thing laptop_mode shouild do is make the disk spin up
> > less frequently - that doesn't mean "not at all"!
>
> So it seems your rationale is that let's save power in only system has
> enough memory so let's remove may_writepage in reclaim path?
>
> If it is, I love it because I didn't see any number about power saving
> through reclaiming throttling(But surely there was reason to add it)
> and not sure it works well during long time because we have tweaked
> reclaim part too many.
>
> >
> > So something seems screwed up here and the patch looks like a
> > heavy-handed workaround.  Why aren't these anon pages getting written
> > out in laptop_mode?
>
> Don't know. It was there long time and I don't want to screw it up.
> If we decide paging out in reclaim path regardless of laptop_mode,
> it makes the problem easy without ugly workaround.
>
> Remove may_writepage? If it's too agressive, we can remove it in only
> direct reclaim path.
>
> >
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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--f46d04447ecf8e6fab04d2f77a48
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style>For what it&#39;s worth=
, I tested this patch on my 3.4 kernel, and it works as advertised. =A0Here=
&#39;s my setup.</div><div class=3D"gmail_default" style><br></div><div cla=
ss=3D"gmail_default" style>
- 2 GB RAM=A0</div><div class=3D"gmail_default" style>- a 3 GB zram disk fo=
r swapping</div><div class=3D"gmail_default" style>- start one &quot;hog&qu=
ot; process per second (each hog process mallocs and touches 200 MB of memo=
ry).</div>
<div class=3D"gmail_default" style>- watch /proc/meminfo</div><div class=3D=
"gmail_default" style><br></div><div class=3D"gmail_default" style>1. I ver=
ified that the problem still exists on my current 3.4 kernel. =A0With lapto=
p_mode =3D 2, hog processes are oom-killed when about 1.8-1.9 (out of 3) GB=
 of swap space are still left<br>
</div><div class=3D"gmail_default" style><br></div><div class=3D"gmail_defa=
ult" style>2. I double-checked that the problem does not exist with laptop_=
mode =3D 0: hog processes are oom-killed when swap space is exhausted (with=
 good approximation).</div>
<div class=3D"gmail_default" style><br></div><div class=3D"gmail_default" s=
tyle>3. I added the two-line patch, put back laptop_mode =3D 2, and verifie=
d that hog processes are oom-killed when swap space is exhausted, same as c=
ase 2.</div>
<div class=3D"gmail_default" style><br></div><div class=3D"gmail_default" s=
tyle>Let me know if I can run any more tests for you, and thanks for all th=
e support so far!</div><div class=3D"gmail_default" style><br></div></div><=
div class=3D"gmail_extra">
<br><br><div class=3D"gmail_quote">On Wed, Jan 9, 2013 at 6:03 PM, Minchan =
Kim <span dir=3D"ltr">&lt;<a href=3D"mailto:minchan@kernel.org" target=3D"_=
blank">minchan@kernel.org</a>&gt;</span> wrote:<br><blockquote class=3D"gma=
il_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-lef=
t:1ex">
Hi Andrew,<br>
<div><div class=3D"h5"><br>
On Wed, Jan 09, 2013 at 04:18:54PM -0800, Andrew Morton wrote:<br>
&gt; On Wed, =A09 Jan 2013 15:21:13 +0900<br>
&gt; Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.org">minchan@kernel.o=
rg</a>&gt; wrote:<br>
&gt;<br>
&gt; &gt; Recently, Luigi reported there are lots of free swap space when<b=
r>
&gt; &gt; OOM happens. It&#39;s easily reproduced on zram-over-swap, where<=
br>
&gt; &gt; many instance of memory hogs are running and laptop_mode is enabl=
ed.<br>
&gt; &gt;<br>
&gt; &gt; Luigi reported there was no problem when he disabled laptop_mode.=
<br>
&gt; &gt; The problem when I investigate problem is following as.<br>
&gt; &gt;<br>
&gt; &gt; try_to_free_pages disable may_writepage if laptop_mode is enabled=
.<br>
&gt; &gt; shrink_page_list adds lots of anon pages in swap cache by<br>
&gt; &gt; add_to_swap, which makes pages Dirty and rotate them to head of<b=
r>
&gt; &gt; inactive LRU without pageout. If it is repeated, inactive anon LR=
U<br>
&gt; &gt; is full of Dirty and SwapCache pages.<br>
&gt; &gt;<br>
&gt; &gt; In case of that, isolate_lru_pages fails because it try to isolat=
e<br>
&gt; &gt; clean page due to may_writepage =3D=3D 0.<br>
&gt; &gt;<br>
&gt; &gt; The may_writepage could be 1 only if total_scanned is higher than=
<br>
&gt; &gt; writeback_threshold in do_try_to_free_pages but unfortunately,<br=
>
&gt; &gt; VM can&#39;t isolate anon pages from inactive anon lru list by<br=
>
&gt; &gt; above reason and we already reclaimed all file-backed pages.<br>
&gt; &gt; So it ends up OOM killing.<br>
&gt; &gt;<br>
&gt; &gt; This patch prevents to add a page to swap cache unnecessary when<=
br>
&gt; &gt; may_writepage is unset so anoymous lru list isn&#39;t full of<br>
&gt; &gt; Dirty/Swapcache page. So VM can isolate pages from anon lru list,=
<br>
&gt; &gt; which ends up setting may_writepage to 1 and could swap out<br>
&gt; &gt; anon lru pages. When OOM triggers, I confirmed swap space was ful=
l.<br>
&gt; &gt;<br>
&gt; &gt; ...<br>
&gt; &gt;<br>
&gt; &gt; --- a/mm/vmscan.c<br>
&gt; &gt; +++ b/mm/vmscan.c<br>
&gt; &gt; @@ -780,6 +780,8 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 if (PageAnon(page) &amp;&amp; !PageSwapCa=
che(page)) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(sc-&gt;gfp_mask &am=
p; __GFP_IO))<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep=
_locked;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sc-&gt;may_writepage)<=
br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_l=
ocked;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!add_to_swap(page))<b=
r>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto acti=
vate_locked;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 may_enter_fs =3D 1;<br>
&gt;<br>
&gt; I&#39;m not really getting it, and the description is rather hard to f=
ollow :(<br>
<br>
</div></div>It seems I don&#39;t have a talent about description. :(<br>
I hope it would be better this year. :)<br>
<div class=3D"im"><br>
&gt;<br>
&gt; We should be adding anon pages to swapcache even when laptop_mode is<b=
r>
&gt; set. =A0And we should be writing them to swap as well, then reclaiming=
<br>
&gt; them. =A0The only thing laptop_mode shouild do is make the disk spin u=
p<br>
&gt; less frequently - that doesn&#39;t mean &quot;not at all&quot;!<br>
<br>
</div>So it seems your rationale is that let&#39;s save power in only syste=
m has<br>
enough memory so let&#39;s remove may_writepage in reclaim path?<br>
<br>
If it is, I love it because I didn&#39;t see any number about power saving<=
br>
through reclaiming throttling(But surely there was reason to add it)<br>
and not sure it works well during long time because we have tweaked<br>
reclaim part too many.<br>
<div class=3D"im"><br>
&gt;<br>
&gt; So something seems screwed up here and the patch looks like a<br>
&gt; heavy-handed workaround. =A0Why aren&#39;t these anon pages getting wr=
itten<br>
&gt; out in laptop_mode?<br>
<br>
</div>Don&#39;t know. It was there long time and I don&#39;t want to screw =
it up.<br>
If we decide paging out in reclaim path regardless of laptop_mode,<br>
it makes the problem easy without ugly workaround.<br>
<br>
Remove may_writepage? If it&#39;s too agressive, we can remove it in only<b=
r>
direct reclaim path.<br>
<div class=3D"im HOEnZb"><br>
&gt;<br>
&gt;<br>
&gt; --<br>
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
</div><div class=3D"im HOEnZb">--<br>
Kind regards,<br>
Minchan Kim<br>
<br>
</div><div class=3D"HOEnZb"><div class=3D"h5">--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br></div>

--f46d04447ecf8e6fab04d2f77a48--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
