Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EE9FD6B0085
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 16:29:05 -0500 (EST)
MIME-Version: 1.0
Message-ID: <d6fc41b7-8448-40be-84c3-c24d0833bd85@default>
Date: Mon, 4 Feb 2013 13:28:55 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Questin about swap_slot free and invalidate page
References: <20130131051140.GB23548@blaptop>
 <alpine.LNX.2.00.1302031732520.4050@eggly.anvils>
 <20130204024950.GD2688@blaptop>
In-Reply-To: <20130204024950.GD2688@blaptop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Sent: Sunday, February 03, 2013 7:50 PM
> To: Hugh Dickins
> Cc: Nitin Gupta; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; l=
inux-mm@kvack.org; linux-
> kernel@vger.kernel.org; Andrew Morton
> Subject: Re: Questin about swap_slot free and invalidate page
>=20
> Hi Hugh,
>=20
> On Sun, Feb 03, 2013 at 05:51:14PM -0800, Hugh Dickins wrote:
> > On Thu, 31 Jan 2013, Minchan Kim wrote:
> >
> > > When I reviewed zswap, I was curious about frontswap_store.
> > > It said following as.
> > >
> > >  * If frontswap already contains a page with matching swaptype and
> > >  * offset, the frontswap implementation may either overwrite the data=
 and
> > >  * return success or invalidate the page from frontswap and return fa=
ilure.
> > >
> > > It didn't say why it happens. we already have __frontswap_invalidate_=
page
> > > and call it whenever swap_slot frees. If we don't free swap slot,
> > > scan_swap_map can't find the slot for swap out so I thought overwriti=
ng of
> > > data shouldn't happen in frontswap.
> > >
> > > As I looked the code, the curplit is reuse_swap_page. It couldn't fre=
e swap
> > > slot if the page founded is PG_writeback but miss calling frontswap_i=
nvalidate_page
> > > so data overwriting on frontswap can happen. I'm not sure frontswap g=
uys
> > > already discussed it long time ago.
> > >
> > > If we can fix it, we can remove duplication entry handling logic
> > > in all of backend of frontswap. All of backend should handle it altho=
ugh
> > > it's pretty rare. Of course, zram could be fixed. It might be trivial=
 now
> > > but more there are many backend of frontswap, more it would be a head=
ache.
> > >
> > > If we are trying to fix it in swap layer,  we might fix it following =
as
> > >
> > > int reuse_swap_page(struct page *page)
> > > {
> > >         ..
> > >         ..
> > >         if (count =3D=3D 1) {
> > >                 if (!PageWriteback(page)) {
> > >                         delete_from_swap_cache(page);
> > >                         SetPageDirty(page);
> > >                 } else {
> > >                         frontswap_invalidate_page();
> > >                         swap_slot_free_notify();
> > >                 }
> > >         }
> > > }
> > >
> > > But not sure, it is worth at the moment and there might be other plac=
es
> > > to be fixed.(I hope Hugh can point out if we are missing something if=
 he
> > > has a time)
> >
> > I expect you are right that reuse_swap_page() is the only way it would
> > happen for frontswap; but I'm too unfamiliar with frontswap to promise
> > you that - it's better that you insert WARN_ONs in your testing to veri=
fy.
> >
> > But I think it's a general tmem property, isn't it?  To define what
> > happens if you do give it the same key again.  So I doubt it's somethin=
g
>=20
> I am too unfamiliar with tmem property but thing I am seeing is
> EXPORT_SYMBOL(__frontswap_store). It's a one of frontend and is tighly ve=
ry
> coupled with swap subsystem.
>=20
> > that has to be fixed; but if you do find it helpful to fix it, bear in
> > mind that reuse_swap_page() is an odd corner, which may one day give th=
e
> > "stable pages" DIF/DIX people trouble, though they've not yet complaine=
d.
> >
> > I'd prefer a patch not specific to frontswap, but along the lines below=
:
> > I think that's the most robust way to express it, though I don't think
> > the (count =3D=3D 0) case can actually occur inside that block (whereas
> > count =3D=3D 0 certainly can occur in the !PageSwapCache case).
> >
> > I believe that I once upon a time took statistics of how often the
> > PageWriteback case happens here, and concluded that it wasn't often
> > enough that refusing to reuse in this case would be likely to slow
> > anyone down noticeably.
>=20
> I agree. I had a test about that with zram and that case wasn't common.
> so your patch looks good to me.
>=20
> I am waiting Dan's reply(He will come in this week) and then, judge what'=
s
> the best.

Hugh is right that handling the possibility of duplicates is
part of the tmem ABI.  If there is any possibility of duplicates,
the ABI defines how a backend must handle them to avoid data
coherency issues.

The kernel implements an in-kernel API which implements the tmem
ABI.  If the frontend and backend can always agree that duplicates
are never possible, I agree that the backend could avoid that
special case.  However, duplicates occur rarely enough and the
consequences (data loss) are bad enough that I think the case
should still be checked, at least with a BUG_ON.  I also wonder
if it is worth it to make changes to the core swap subsystem
to avoid code to implement a zswap corner case.

Remember that zswap is an oversimplified special case of tmem
that handles only one frontend (Linux frontswap) and one backend
(zswap).  Tmem goes well beyond that and already supports other
more general backends including Xen and ramster, and could also
support other frontends such as a BSD or Solaris equivalent
of frontswap, for example with a Linux ramster/zcache backend.
I'm not sure how wise it is to tear out generic code and replace
it with simplistic code unless there is absolutely no chance that
the generic code will be necessary.

My two cents,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
