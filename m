Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 138376B004D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 01:25:50 -0500 (EST)
Received: by mail-we0-f174.google.com with SMTP id x10so854928wey.33
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 22:25:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130109062236.GA26185@blaptop>
References: <20130108075327.GB4714@blaptop>
	<CAA25o9R2FvO+Ngqg2eHFDVEpVmUtnTn1A_VJf58FtbAZM=92og@mail.gmail.com>
	<20130109062236.GA26185@blaptop>
Date: Tue, 8 Jan 2013 22:25:48 -0800
Message-ID: <CAA25o9QvDfcA7ppdBx9z2eLS9_-Ls3EEK_Ex6UASK+8f1pTqCw@mail.gmail.com>
Subject: Re: [PATCH] mm: swap out anonymous page regardless of laptop_mode
From: Luigi Semenzato <semenzato@google.com>
Content-Type: multipart/alternative; boundary=047d7bfd031c10c3a804d2d522fa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

--047d7bfd031c10c3a804d2d522fa
Content-Type: text/plain; charset=ISO-8859-1

I'll make sure I use the new version!


On Tue, Jan 8, 2013 at 10:22 PM, Minchan Kim <minchan@kernel.org> wrote:

> Hi Luigi,
>
> On Tue, Jan 08, 2013 at 05:20:25PM -0800, Luigi Semenzato wrote:
> > No problem at all---as I mentioned, we stopped using laptop_mode, so
> > this is no longer an issue for us.
> >
> > I should be able to test the patch for you in the next 2-3 days.  I
> > will let you know if I run into problems.
>
> Right now, I sent new version. I think it's better than this patch.
> Could you test new version instead of this?
>
> Thanks!
>
> >
> > Thanks!
> > Luigi
> >
> > On Mon, Jan 7, 2013 at 11:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> > > Hi Luigi,
> > >
> > > Sorry for really really late response.
> > > Today I have a time to look at this problem and it seems to found the
> problem.
> > > By your help, I can reprocude this problem easily on my KVM machine
> and this
> > > patch solves the problem.
> > >
> > > Could you test below patch? Although this patch is based on recent
> mmotm,
> > > I guess you can apply it easily to 3.4.
> > >
> > > From f74fdf644bec3e7875d245154db953b47b6c9594 Mon Sep 17 00:00:00 2001
> > > From: Minchan Kim <minchan@kernel.org>
> > > Date: Tue, 8 Jan 2013 16:23:31 +0900
> > > Subject: [PATCH] mm: swap out anonymous page regardless of laptop_mode
> > >
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
> > > may_writepage could be 1 only if total_scanned is higher than
> > > writeback_threshold in do_try_to_free_pages but unfortunately,
> > > VM can't isolate anon pages from inactive anon lru list by
> > > above reason and we already reclaimed all file-backed pages.
> > > So it ends up OOM killing.
> > >
> > > This patch makes may_writepage could be set when shrink_inactive_list
> > > encounters SwapCachePage from tail of inactive anon LRU.
> > > What it means that anon LRU list is short and memory pressure
> > > is severe so it would be better to swap out that pages by sacrificing
> > > the power rather than OOM killing.
> > >
> > > Reported-by: Luigi Semenzato <semenzato@google.com>
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/vmscan.c |   13 ++++++++++++-
> > >  1 file changed, 12 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index ff869d2..7397a6b 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1102,7 +1102,7 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
> > >                 prefetchw_prev_lru_page(page, src, flags);
> > >
> > >                 VM_BUG_ON(!PageLRU(page));
> > > -
> > > +retry:
> > >                 switch (__isolate_lru_page(page, mode)) {
> > >                 case 0:
> > >                         nr_pages = hpage_nr_pages(page);
> > > @@ -1112,6 +1112,17 @@ static unsigned long isolate_lru_pages(unsigned
> long nr_to_scan,
> > >                         break;
> > >
> > >                 case -EBUSY:
> > > +                       /*
> > > +                        * If VM encounters PageSwapCache from
> inactive LRU,
> > > +                        * it means we havd to swap out those pages
> regardless
> > > +                        * of laptop_mode for preventing OOM kill.
> > > +                        */
> > > +                       if ((mode & ISOLATE_CLEAN) &&
> PageSwapCache(page) &&
> > > +                               !PageActive(page)) {
> > > +                               mode &= ~ISOLATE_CLEAN;
> > > +                               sc->may_writepage = 1;
> > > +                               goto retry;
> > > +                       }
> > >                         /* else it is being freed elsewhere */
> > >                         list_move(&page->lru, src);
> > >                         continue;
> > > --
> > > 1.7.9.5
> > >
> > >
> > > On Thu, Nov 29, 2012 at 11:31:46AM -0800, Luigi Semenzato wrote:
> > >> Oh well, I found the problem, it's laptop_mode.  We keep it on by
> > >> default.  When I turn it off, I can allocate as fast as I can, and no
> > >> OOMs happen until swap is exhausted.
> > >>
> > >> I don't think this is a desirable behavior even for laptop_mode, so if
> > >> anybody wants to help me debug it (or wants my help in debugging it)
> > >> do let me know.
> > >>
> > >> Thanks!
> > >> Luigi
> > >>
> > >> On Thu, Nov 29, 2012 at 10:46 AM, Luigi Semenzato <
> semenzato@google.com> wrote:
> > >> > Minchan:
> > >> >
> > >> > I tried your suggestion to move the call to wake_all_kswapd from
> after
> > >> > "restart:" to after "rebalance:".  The behavior is still similar,
> but
> > >> > slightly improved.  Here's what I see.
> > >> >
> > >> > Allocating as fast as I can: 1.5 GB of the 3 GB of zram swap are
> used,
> > >> > then OOM kills happen, and the system ends up with 1 GB swap used, 2
> > >> > unused.
> > >> >
> > >> > Allocating 10 MB/s: some kills happen when only 1 to 1.5 GB are
> used,
> > >> > and continue happening while swap fills up.  Eventually swap fills
> up
> > >> > completely.  This is better than before (could not go past about 1
> GB
> > >> > of swap used), but there are too many kills too early.  I would like
> > >> > to see no OOM kills until swap is full or almost full.
> > >> >
> > >> > Allocating 20 MB/s: almost as good as with 10 MB/s, but more kills
> > >> > happen earlier, and not all swap space is used (400 MB free at the
> > >> > end).
> > >> >
> > >> > This is with 200 processes using 20 MB each, and 2:1 compression
> ratio.
> > >> >
> > >> > So it looks like kswapd is still not aggressive enough in pushing
> > >> > pages out.  What's the best way of changing that?  Play around with
> > >> > the watermarks?
> > >> >
> > >> > Incidentally, I also tried removing the min_filelist_kbytes hacky
> > >> > patch, but, as usual, the system thrashes so badly that it's
> > >> > impossible to complete any experiment.  I set it to a lower minimum
> > >> > amount of free file pages, 10 MB instead of the 50 MB which we use
> > >> > normally, and I could run with some thrashing, but I got the same
> > >> > results.
> > >> >
> > >> > Thanks!
> > >> > Luigi
> > >> >
> > >> >
> > >> > On Wed, Nov 28, 2012 at 4:31 PM, Luigi Semenzato <
> semenzato@google.com> wrote:
> > >> >> I am beginning to understand why zram appears to work fine on our
> x86
> > >> >> systems but not on our ARM systems.  The bottom line is that
> swapping
> > >> >> doesn't work as I would expect when allocation is "too fast".
> > >> >>
> > >> >> In one of my tests, opening 50 tabs simultaneously in a Chrome
> browser
> > >> >> on devices with 2 GB of RAM and a zram-disk of 3 GB
> (uncompressed), I
> > >> >> was observing that on the x86 device all of the zram swap space was
> > >> >> used before OOM kills happened, but on the ARM device I would see
> OOM
> > >> >> kills when only about 1 GB (out of 3) was swapped out.
> > >> >>
> > >> >> I wrote a simple program to understand this behavior.  The program
> > >> >> (called "hog") allocates memory and fills it with a mix of
> > >> >> incompressible data (from /dev/urandom) and highly compressible
> data
> > >> >> (1's, just to avoid zero pages) in a given ratio.  The memory is
> never
> > >> >> touched again.
> > >> >>
> > >> >> It turns out that if I don't limit the allocation speed, I see
> > >> >> premature OOM kills also on the x86 device.  If I limit the
> allocation
> > >> >> to 10 MB/s, the premature OOM kills stop happening on the x86
> device,
> > >> >> but still happen on the ARM device.  If I further limit the
> allocation
> > >> >> speed to 5 Mb/s, the premature OOM kills disappear also from the
> ARM
> > >> >> device.
> > >> >>
> > >> >> I have noticed a few time constants in the MM whose value is not
> well
> > >> >> explained, and I am wondering if the code is tuned for some ideal
> > >> >> system that doesn't behave like ours (considering, for instance,
> that
> > >> >> zram is much faster than swapping to a disk device, but it also
> uses
> > >> >> more CPU).  If this is plausible, I am wondering if anybody has
> > >> >> suggestions for changes that I could try out to obtain a better
> > >> >> behavior with a higher allocation speed.
> > >> >>
> > >> >> Thanks!
> > >> >> Luigi
> > >>
> > >> --
> > >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > >> the body to majordomo@kvack.org.  For more info on Linux MM,
> > >> see: http://www.linux-mm.org/ .
> > >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > >
> > > --
> > > Kind regards,
> > > Minchan Kim
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

--047d7bfd031c10c3a804d2d522fa
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style>I&#39;ll make sure I us=
e the new version!</div></div><div class=3D"gmail_extra"><br><br><div class=
=3D"gmail_quote">On Tue, Jan 8, 2013 at 10:22 PM, Minchan Kim <span dir=3D"=
ltr">&lt;<a href=3D"mailto:minchan@kernel.org" target=3D"_blank">minchan@ke=
rnel.org</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hi Luigi,<br>
<div class=3D"im"><br>
On Tue, Jan 08, 2013 at 05:20:25PM -0800, Luigi Semenzato wrote:<br>
&gt; No problem at all---as I mentioned, we stopped using laptop_mode, so<b=
r>
&gt; this is no longer an issue for us.<br>
&gt;<br>
&gt; I should be able to test the patch for you in the next 2-3 days. =A0I<=
br>
&gt; will let you know if I run into problems.<br>
<br>
</div>Right now, I sent new version. I think it&#39;s better than this patc=
h.<br>
Could you test new version instead of this?<br>
<br>
Thanks!<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt;<br>
&gt; Thanks!<br>
&gt; Luigi<br>
&gt;<br>
&gt; On Mon, Jan 7, 2013 at 11:53 PM, Minchan Kim &lt;<a href=3D"mailto:min=
chan@kernel.org">minchan@kernel.org</a>&gt; wrote:<br>
&gt; &gt; Hi Luigi,<br>
&gt; &gt;<br>
&gt; &gt; Sorry for really really late response.<br>
&gt; &gt; Today I have a time to look at this problem and it seems to found=
 the problem.<br>
&gt; &gt; By your help, I can reprocude this problem easily on my KVM machi=
ne and this<br>
&gt; &gt; patch solves the problem.<br>
&gt; &gt;<br>
&gt; &gt; Could you test below patch? Although this patch is based on recen=
t mmotm,<br>
&gt; &gt; I guess you can apply it easily to 3.4.<br>
&gt; &gt;<br>
&gt; &gt; From f74fdf644bec3e7875d245154db953b47b6c9594 Mon Sep 17 00:00:00=
 2001<br>
&gt; &gt; From: Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.org">minch=
an@kernel.org</a>&gt;<br>
&gt; &gt; Date: Tue, 8 Jan 2013 16:23:31 +0900<br>
&gt; &gt; Subject: [PATCH] mm: swap out anonymous page regardless of laptop=
_mode<br>
&gt; &gt;<br>
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
&gt; &gt; may_writepage could be 1 only if total_scanned is higher than<br>
&gt; &gt; writeback_threshold in do_try_to_free_pages but unfortunately,<br=
>
&gt; &gt; VM can&#39;t isolate anon pages from inactive anon lru list by<br=
>
&gt; &gt; above reason and we already reclaimed all file-backed pages.<br>
&gt; &gt; So it ends up OOM killing.<br>
&gt; &gt;<br>
&gt; &gt; This patch makes may_writepage could be set when shrink_inactive_=
list<br>
&gt; &gt; encounters SwapCachePage from tail of inactive anon LRU.<br>
&gt; &gt; What it means that anon LRU list is short and memory pressure<br>
&gt; &gt; is severe so it would be better to swap out that pages by sacrifi=
cing<br>
&gt; &gt; the power rather than OOM killing.<br>
&gt; &gt;<br>
&gt; &gt; Reported-by: Luigi Semenzato &lt;<a href=3D"mailto:semenzato@goog=
le.com">semenzato@google.com</a>&gt;<br>
&gt; &gt; Signed-off-by: Minchan Kim &lt;<a href=3D"mailto:minchan@kernel.o=
rg">minchan@kernel.org</a>&gt;<br>
&gt; &gt; ---<br>
&gt; &gt; =A0mm/vmscan.c | =A0 13 ++++++++++++-<br>
&gt; &gt; =A01 file changed, 12 insertions(+), 1 deletion(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
&gt; &gt; index ff869d2..7397a6b 100644<br>
&gt; &gt; --- a/mm/vmscan.c<br>
&gt; &gt; +++ b/mm/vmscan.c<br>
&gt; &gt; @@ -1102,7 +1102,7 @@ static unsigned long isolate_lru_pages(unsi=
gned long nr_to_scan,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prefetchw_prev_lru_page(page, src=
, flags);<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(!PageLRU(page));<br>
&gt; &gt; -<br>
&gt; &gt; +retry:<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (__isolate_lru_page(page, =
mode)) {<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 0:<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_pages =3D hpag=
e_nr_pages(page);<br>
&gt; &gt; @@ -1112,6 +1112,17 @@ static unsigned long isolate_lru_pages(uns=
igned long nr_to_scan,<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;<br>
&gt; &gt;<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case -EBUSY:<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If VM encounte=
rs PageSwapCache from inactive LRU,<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it means we ha=
vd to swap out those pages regardless<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of laptop_mode=
 for preventing OOM kill.<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((mode &amp; ISO=
LATE_CLEAN) &amp;&amp; PageSwapCache(page) &amp;&amp;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !Pa=
geActive(page)) {<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod=
e &amp;=3D ~ISOLATE_CLEAN;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc-=
&gt;may_writepage =3D 1;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 got=
o retry;<br>
&gt; &gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* else it is bei=
ng freed elsewhere */<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&amp;pa=
ge-&gt;lru, src);<br>
&gt; &gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;<br>
&gt; &gt; --<br>
&gt; &gt; 1.7.9.5<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; On Thu, Nov 29, 2012 at 11:31:46AM -0800, Luigi Semenzato wrote:<=
br>
&gt; &gt;&gt; Oh well, I found the problem, it&#39;s laptop_mode. =A0We kee=
p it on by<br>
&gt; &gt;&gt; default. =A0When I turn it off, I can allocate as fast as I c=
an, and no<br>
&gt; &gt;&gt; OOMs happen until swap is exhausted.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; I don&#39;t think this is a desirable behavior even for lapto=
p_mode, so if<br>
&gt; &gt;&gt; anybody wants to help me debug it (or wants my help in debugg=
ing it)<br>
&gt; &gt;&gt; do let me know.<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; Thanks!<br>
&gt; &gt;&gt; Luigi<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; On Thu, Nov 29, 2012 at 10:46 AM, Luigi Semenzato &lt;<a href=
=3D"mailto:semenzato@google.com">semenzato@google.com</a>&gt; wrote:<br>
&gt; &gt;&gt; &gt; Minchan:<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; I tried your suggestion to move the call to wake_all_ksw=
apd from after<br>
&gt; &gt;&gt; &gt; &quot;restart:&quot; to after &quot;rebalance:&quot;. =
=A0The behavior is still similar, but<br>
&gt; &gt;&gt; &gt; slightly improved. =A0Here&#39;s what I see.<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Allocating as fast as I can: 1.5 GB of the 3 GB of zram =
swap are used,<br>
&gt; &gt;&gt; &gt; then OOM kills happen, and the system ends up with 1 GB =
swap used, 2<br>
&gt; &gt;&gt; &gt; unused.<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Allocating 10 MB/s: some kills happen when only 1 to 1.5=
 GB are used,<br>
&gt; &gt;&gt; &gt; and continue happening while swap fills up. =A0Eventuall=
y swap fills up<br>
&gt; &gt;&gt; &gt; completely. =A0This is better than before (could not go =
past about 1 GB<br>
&gt; &gt;&gt; &gt; of swap used), but there are too many kills too early. =
=A0I would like<br>
&gt; &gt;&gt; &gt; to see no OOM kills until swap is full or almost full.<b=
r>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Allocating 20 MB/s: almost as good as with 10 MB/s, but =
more kills<br>
&gt; &gt;&gt; &gt; happen earlier, and not all swap space is used (400 MB f=
ree at the<br>
&gt; &gt;&gt; &gt; end).<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; This is with 200 processes using 20 MB each, and 2:1 com=
pression ratio.<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; So it looks like kswapd is still not aggressive enough i=
n pushing<br>
&gt; &gt;&gt; &gt; pages out. =A0What&#39;s the best way of changing that? =
=A0Play around with<br>
&gt; &gt;&gt; &gt; the watermarks?<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Incidentally, I also tried removing the min_filelist_kby=
tes hacky<br>
&gt; &gt;&gt; &gt; patch, but, as usual, the system thrashes so badly that =
it&#39;s<br>
&gt; &gt;&gt; &gt; impossible to complete any experiment. =A0I set it to a =
lower minimum<br>
&gt; &gt;&gt; &gt; amount of free file pages, 10 MB instead of the 50 MB wh=
ich we use<br>
&gt; &gt;&gt; &gt; normally, and I could run with some thrashing, but I got=
 the same<br>
&gt; &gt;&gt; &gt; results.<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; Thanks!<br>
&gt; &gt;&gt; &gt; Luigi<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt;<br>
&gt; &gt;&gt; &gt; On Wed, Nov 28, 2012 at 4:31 PM, Luigi Semenzato &lt;<a =
href=3D"mailto:semenzato@google.com">semenzato@google.com</a>&gt; wrote:<br=
>
&gt; &gt;&gt; &gt;&gt; I am beginning to understand why zram appears to wor=
k fine on our x86<br>
&gt; &gt;&gt; &gt;&gt; systems but not on our ARM systems. =A0The bottom li=
ne is that swapping<br>
&gt; &gt;&gt; &gt;&gt; doesn&#39;t work as I would expect when allocation i=
s &quot;too fast&quot;.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; In one of my tests, opening 50 tabs simultaneously i=
n a Chrome browser<br>
&gt; &gt;&gt; &gt;&gt; on devices with 2 GB of RAM and a zram-disk of 3 GB =
(uncompressed), I<br>
&gt; &gt;&gt; &gt;&gt; was observing that on the x86 device all of the zram=
 swap space was<br>
&gt; &gt;&gt; &gt;&gt; used before OOM kills happened, but on the ARM devic=
e I would see OOM<br>
&gt; &gt;&gt; &gt;&gt; kills when only about 1 GB (out of 3) was swapped ou=
t.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; I wrote a simple program to understand this behavior=
. =A0The program<br>
&gt; &gt;&gt; &gt;&gt; (called &quot;hog&quot;) allocates memory and fills =
it with a mix of<br>
&gt; &gt;&gt; &gt;&gt; incompressible data (from /dev/urandom) and highly c=
ompressible data<br>
&gt; &gt;&gt; &gt;&gt; (1&#39;s, just to avoid zero pages) in a given ratio=
. =A0The memory is never<br>
&gt; &gt;&gt; &gt;&gt; touched again.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; It turns out that if I don&#39;t limit the allocatio=
n speed, I see<br>
&gt; &gt;&gt; &gt;&gt; premature OOM kills also on the x86 device. =A0If I =
limit the allocation<br>
&gt; &gt;&gt; &gt;&gt; to 10 MB/s, the premature OOM kills stop happening o=
n the x86 device,<br>
&gt; &gt;&gt; &gt;&gt; but still happen on the ARM device. =A0If I further =
limit the allocation<br>
&gt; &gt;&gt; &gt;&gt; speed to 5 Mb/s, the premature OOM kills disappear a=
lso from the ARM<br>
&gt; &gt;&gt; &gt;&gt; device.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; I have noticed a few time constants in the MM whose =
value is not well<br>
&gt; &gt;&gt; &gt;&gt; explained, and I am wondering if the code is tuned f=
or some ideal<br>
&gt; &gt;&gt; &gt;&gt; system that doesn&#39;t behave like ours (considerin=
g, for instance, that<br>
&gt; &gt;&gt; &gt;&gt; zram is much faster than swapping to a disk device, =
but it also uses<br>
&gt; &gt;&gt; &gt;&gt; more CPU). =A0If this is plausible, I am wondering i=
f anybody has<br>
&gt; &gt;&gt; &gt;&gt; suggestions for changes that I could try out to obta=
in a better<br>
&gt; &gt;&gt; &gt;&gt; behavior with a higher allocation speed.<br>
&gt; &gt;&gt; &gt;&gt;<br>
&gt; &gt;&gt; &gt;&gt; Thanks!<br>
&gt; &gt;&gt; &gt;&gt; Luigi<br>
&gt; &gt;&gt;<br>
&gt; &gt;&gt; --<br>
&gt; &gt;&gt; To unsubscribe, send a message with &#39;unsubscribe linux-mm=
&#39; in<br>
&gt; &gt;&gt; the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@=
kvack.org</a>. =A0For more info on Linux MM,<br>
&gt; &gt;&gt; see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">h=
ttp://www.linux-mm.org/</a> .<br>
&gt; &gt;&gt; Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:=
dont@kvack.org">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.=
org">email@kvack.org</a> &lt;/a&gt;<br>
&gt; &gt;<br>
&gt; &gt; --<br>
&gt; &gt; Kind regards,<br>
&gt; &gt; Minchan Kim<br>
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
--<br>
Kind regards,<br>
Minchan Kim<br>
</div></div></blockquote></div><br></div>

--047d7bfd031c10c3a804d2d522fa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
