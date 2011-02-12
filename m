Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 72E428D0039
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 04:48:59 -0500 (EST)
Received: by iwc10 with SMTP id 10so3265599iwc.14
        for <linux-mm@kvack.org>; Sat, 12 Feb 2011 01:48:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110127152755.GB30919@random.random>
References: <1295841406.1949.953.camel@sli10-conroe>
	<20110124150033.GB9506@random.random>
	<20110126141746.GS18984@csn.ul.ie>
	<20110126152302.GT18984@csn.ul.ie>
	<20110126154203.GS926@random.random>
	<20110126163655.GU18984@csn.ul.ie>
	<20110126174236.GV18984@csn.ul.ie>
	<20110127134057.GA32039@csn.ul.ie>
	<20110127152755.GB30919@random.random>
Date: Sat, 12 Feb 2011 17:48:55 +0800
Message-ID: <AANLkTim7Vc1bntXEu0pFkZ=cvoLJ1hsaSx9Tq00+MODZ@mail.gmail.com>
Subject: Re: too big min_free_kbytes
From: alex shi <lkml.alex@gmail.com>
Content-Type: multipart/alternative; boundary=20cf3054a15f10a101049c12b95f
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>, alex.shi@intel.com

--20cf3054a15f10a101049c12b95f
Content-Type: text/plain; charset=ISO-8859-1

I am tried the patch, but seems it has no effect for our regression.

Regards
Alex

On Thu, Jan 27, 2011 at 11:27 PM, Andrea Arcangeli <aarcange@redhat.com>wrote:

> On Thu, Jan 27, 2011 at 01:40:58PM +0000, Mel Gorman wrote:
> > On Wed, Jan 26, 2011 at 05:42:37PM +0000, Mel Gorman wrote:
> > > On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:
> > > > > But the wmarks don't
> > > > > seem the real offender, maybe it's something related to the tiny
> pci32
> > > > > zone that materialize on 4g systems that relocate some little
> memory
> > > > > over 4g to make space for the pci32 mmio. I didn't yet finish to
> debug
> > > > > it.
> > > > >
> > > >
> > > > This has to be it. What I think is happening is that we're in
> balance_pgdat(),
> > > > the "Normal" zone is never hitting the watermark and we constantly
> call
> > > > "goto loop_again" trying to "rebalance" all zones.
> > > >
> > >
> > > Confirmed.
> > > <SNIP>
> >
> > How about the following? Functionally it would work but I am concerned
> > that the logic in balance_pgdat() and kswapd() is getting out of hand
> > having being adjusted to work with a number of corner cases already. In
> > the next cycle, it could do with a "do-over" attempt to make it easier
> > to follow.
>
> That number 8 is the problem, I don't think anybody was ever supposed
> to free 8*highwmark pages. kswapd must work in the hysteresis range
> low->high area and then sleep wait low to hit again before it gets
> wakenup. Not sure how that number 8 ever come up... but to be it looks
> like the real offender and I wouldn't work around it.
>
> totally untested... I will test....
>
> ====
> Subject: vmscan: kswapd must not free more than high_wmark pages
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> When the min_free_kbytes is set with `hugeadm
> --set-recommended-min_free_kbytes" or with THP enabled (which runs the
> equivalent of "hugeadm --set-recommended-min_free_kbytes" to activate
> anti-frag at full effectiveness automatically at boot) the high wmark
> of some zone is as high as ~88M. 88M free on a 4G system isn't
> horrible, but 88M*8 = 704M free on a 4G system is definitely
> unbearable. This only tends to be visible on 4G systems with tiny
> over-4g zone where kswapd insists to reach the high wmark on the
> over-4g zone but doing so it shrunk up to 704M from the normal zone by
> mistake.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f5d90de..9e3c78e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2407,7 +2407,7 @@ loop_again:
>                         * zone has way too many pages free already.
>                         */
>                         if (!zone_watermark_ok_safe(zone, order,
> -                                       8*high_wmark_pages(zone), end_zone,
> 0))
> +                                       high_wmark_pages(zone), end_zone,
> 0))
>                                 shrink_zone(priority, zone, &sc);
>                        reclaim_state->reclaimed_slab = 0;
>                        nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--20cf3054a15f10a101049c12b95f
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

I am tried the patch, but seems it has no effect for our regression. <br><b=
r>Regards<br>Alex <br><br><div class=3D"gmail_quote">On Thu, Jan 27, 2011 a=
t 11:27 PM, Andrea Arcangeli <span dir=3D"ltr">&lt;<a href=3D"mailto:aarcan=
ge@redhat.com">aarcange@redhat.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; borde=
r-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;"><div class=3D"im"=
>On Thu, Jan 27, 2011 at 01:40:58PM +0000, Mel Gorman wrote:<br>
&gt; On Wed, Jan 26, 2011 at 05:42:37PM +0000, Mel Gorman wrote:<br>
&gt; &gt; On Wed, Jan 26, 2011 at 04:36:55PM +0000, Mel Gorman wrote:<br>
&gt; &gt; &gt; &gt; But the wmarks don&#39;t<br>
&gt; &gt; &gt; &gt; seem the real offender, maybe it&#39;s something relate=
d to the tiny pci32<br>
&gt; &gt; &gt; &gt; zone that materialize on 4g systems that relocate some =
little memory<br>
&gt; &gt; &gt; &gt; over 4g to make space for the pci32 mmio. I didn&#39;t =
yet finish to debug<br>
&gt; &gt; &gt; &gt; it.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; This has to be it. What I think is happening is that we&#39;=
re in balance_pgdat(),<br>
&gt; &gt; &gt; the &quot;Normal&quot; zone is never hitting the watermark a=
nd we constantly call<br>
&gt; &gt; &gt; &quot;goto loop_again&quot; trying to &quot;rebalance&quot; =
all zones.<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Confirmed.<br>
&gt; &gt; &lt;SNIP&gt;<br>
&gt;<br>
&gt; How about the following? Functionally it would work but I am concerned=
<br>
&gt; that the logic in balance_pgdat() and kswapd() is getting out of hand<=
br>
&gt; having being adjusted to work with a number of corner cases already. I=
n<br>
&gt; the next cycle, it could do with a &quot;do-over&quot; attempt to make=
 it easier<br>
&gt; to follow.<br>
<br>
</div>That number 8 is the problem, I don&#39;t think anybody was ever supp=
osed<br>
to free 8*highwmark pages. kswapd must work in the hysteresis range<br>
low-&gt;high area and then sleep wait low to hit again before it gets<br>
wakenup. Not sure how that number 8 ever come up... but to be it looks<br>
like the real offender and I wouldn&#39;t work around it.<br>
<br>
totally untested... I will test....<br>
<br>
=3D=3D=3D=3D<br>
Subject: vmscan: kswapd must not free more than high_wmark pages<br>
<br>
From: Andrea Arcangeli &lt;<a href=3D"mailto:aarcange@redhat.com">aarcange@=
redhat.com</a>&gt;<br>
<br>
When the min_free_kbytes is set with `hugeadm<br>
--set-recommended-min_free_kbytes&quot; or with THP enabled (which runs the=
<br>
equivalent of &quot;hugeadm --set-recommended-min_free_kbytes&quot; to acti=
vate<br>
anti-frag at full effectiveness automatically at boot) the high wmark<br>
of some zone is as high as ~88M. 88M free on a 4G system isn&#39;t<br>
horrible, but 88M*8 =3D 704M free on a 4G system is definitely<br>
unbearable. This only tends to be visible on 4G systems with tiny<br>
over-4g zone where kswapd insists to reach the high wmark on the<br>
over-4g zone but doing so it shrunk up to 704M from the normal zone by<br>
mistake.<br>
<br>
Signed-off-by: Andrea Arcangeli &lt;<a href=3D"mailto:aarcange@redhat.com">=
aarcange@redhat.com</a>&gt;<br>
---<br>
<div class=3D"im"><br>
<br>
diff --git a/mm/vmscan.c b/mm/vmscan.c<br>
</div>index f5d90de..9e3c78e 100644<br>
<div class=3D"im">--- a/mm/vmscan.c<br>
+++ b/mm/vmscan.c<br>
</div>@@ -2407,7 +2407,7 @@ loop_again:<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * zone has way too many pa=
ges free already.<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */<br>
<div class=3D"im"> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!zone=
_watermark_ok_safe(zone, order,<br>
</div>- =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 8*high_wmark_pages(zone), end_zone, 0))<br>
<div class=3D"im">+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 high_wmark_pages(zone), end_zone, 0))<br>
</div> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0shrin=
k_zone(priority, zone, &amp;sc);<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reclaim_state-&gt;reclaimed=
_slab =3D 0;<br>
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_slab =3D shrink_slab(sc.=
nr_scanned, GFP_KERNEL,<br>
<div><div></div><div class=3D"h5"><br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
 =A0For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" target=3D"_blank">http://www.linu=
x-mm.org/</a> .<br>
Fight unfair telecom policy in Canada: sign <a href=3D"http://dissolvethecr=
tc.ca/" target=3D"_blank">http://dissolvethecrtc.ca/</a><br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</div></div></blockquote></div><br>

--20cf3054a15f10a101049c12b95f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
