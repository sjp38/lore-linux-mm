Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 03E106B0261
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:15:35 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e185so15351524pfg.23
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:15:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor1879724pls.118.2018.01.17.15.15.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 15:15:33 -0800 (PST)
Date: Wed, 17 Jan 2018 15:15:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Hang with v4.15-rc trying to swap back in
In-Reply-To: <20180117145847.ee3137777a42199fd3ea67b8@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1801171513030.5943@eggly.anvils>
References: <1514398340.3986.10.camel@HansenPartnership.com> <1514407817.4169.4.camel@HansenPartnership.com> <20171227232650.GA9702@bbox> <1514417689.3083.1.camel@HansenPartnership.com> <20171227235643.GA10532@bbox> <1514482907.3040.15.camel@HansenPartnership.com>
 <1514487640.3040.21.camel@HansenPartnership.com> <alpine.LSU.2.11.1801171423490.5238@eggly.anvils> <20180117145847.ee3137777a42199fd3ea67b8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-198722094-1516230931=:5943"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux Memory Management List <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-198722094-1516230931=:5943
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 17 Jan 2018, Andrew Morton wrote:
> On Wed, 17 Jan 2018 14:33:21 -0800 (PST) Hugh Dickins <hughd@google.com> =
wrote:
> > On Thu, 28 Dec 2017, James Bottomley wrote:
> > > On Thu, 2017-12-28 at 09:41 -0800, James Bottomley wrote:
> > > > I'd guess that since they're both in io_schedule, the problem is th=
at
> > > > the io_scheduler is taking far too long servicing the requests due =
to
> > > > some priority issue you've introduced.
> > >=20
> > > OK, so after some analysis, that turned out to be incorrect. =A0The
> > > problem seems to be that we're exiting do_swap_page() with locked pag=
es
> > > that have been read in from swap.
> > >=20
> > > Your changelogs are entirely unclear on why you changed the swapcache
> > > setting logic in this patch:
> > >=20
> > > commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> > > Author: Minchan Kim <minchan@kernel.org>
> > > Date:=A0=A0=A0Wed Nov 15 17:33:07 2017 -0800
> > >=20
> > > =A0=A0=A0=A0mm, swap: skip swapcache for swapin of synchronous device
> > >=20
> > > But I think you're using swapcache =3D=3D NULL as a signal the page c=
ame
> > > from a synchronous device. =A0In which case the bug is that you've
> > > forgotten we may already have picked up a page in
> > > swap_readahead_detect() which you're wrongly keeping swapcache =3D=3D=
 NULL
> > > for and the fix is this (it works on my system, although I'm still
> > > getting an unaccountable shutdown delay).
> > >=20
> > > I still think we should revert this series, because this may not be t=
he
> > > only bug lurking in the code, so it should go through a lot more
> > > rigorous testing than it has.
> >=20
> > Andrew, neither the fix below (works for me, though I have seen other
> > swap funniness, most probably unrelated), nor the reversion preferred
> > by James and Minchan (later in this linux-mm thread), was in 4.15-rc8:
> > the sands of time are running out...
>=20
> Yup.  I'm actually planning on sending in this one.  OK by you?

Thanks, yes, that looks equivalent to what I've been running with.

>=20
>=20
> From: Minchan Kim <minchan@kernel.org>
> Subject: mm/memory.c: release locked page in do_swap_page()
>=20
> James reported a bug in swap paging-in from his testing.  It is that
> do_swap_page doesn't release locked page so system hang-up happens due to
> a deadlock on PG_locked.
>=20
> It was introduced by 0bcac06f27d7 ("mm, swap: skip swapcache for swapin o=
f
> synchronous device") because I missed swap cache hit places to update
> swapcache variable to work well with other logics against swapcache in
> do_swap_page.
>=20
> This patch fixes it.
>=20
> Debugged by James Bottomley.
>=20
> Link: http://lkml.kernel.org/r/<1514407817.4169.4.camel@HansenPartnership=
=2Ecom>
> Link: http://lkml.kernel.org/r/20180102235606.GA19438@bbox
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> Reported-by: James Bottomley <James.Bottomley@hansenpartnership.com>
> Cc: Hugh Dickins <hughd@google.com>

Acked-by: Hugh Dickins <hughd@google.com>

> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>=20
>  mm/memory.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
>=20
> diff -puN mm/memory.c~mm-release-locked-page-in-do_swap_page mm/memory.c
> --- a/mm/memory.c~mm-release-locked-page-in-do_swap_page
> +++ a/mm/memory.c
> @@ -2857,8 +2857,11 @@ int do_swap_page(struct vm_fault *vmf)
>  =09int ret =3D 0;
>  =09bool vma_readahead =3D swap_use_vma_readahead();
> =20
> -=09if (vma_readahead)
> +=09if (vma_readahead) {
>  =09=09page =3D swap_readahead_detect(vmf, &swap_ra);
> +=09=09swapcache =3D page;
> +=09}
> +
>  =09if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
>  =09=09if (page)
>  =09=09=09put_page(page);
> @@ -2889,9 +2892,12 @@ int do_swap_page(struct vm_fault *vmf)
> =20
> =20
>  =09delayacct_set_flag(DELAYACCT_PF_SWAPIN);
> -=09if (!page)
> +=09if (!page) {
>  =09=09page =3D lookup_swap_cache(entry, vma_readahead ? vma : NULL,
>  =09=09=09=09=09 vmf->address);
> +=09=09swapcache =3D page;
> +=09}
> +
>  =09if (!page) {
>  =09=09struct swap_info_struct *si =3D swp_swap_info(entry);
> =20
> _
--0-198722094-1516230931=:5943--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
