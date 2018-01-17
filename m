Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF5A26B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:33:30 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 205so6079231pfw.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:33:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g84sor1431442pfg.79.2018.01.17.14.33.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 14:33:29 -0800 (PST)
Date: Wed, 17 Jan 2018 14:33:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Hang with v4.15-rc trying to swap back in
In-Reply-To: <1514487640.3040.21.camel@HansenPartnership.com>
Message-ID: <alpine.LSU.2.11.1801171423490.5238@eggly.anvils>
References: <1514398340.3986.10.camel@HansenPartnership.com> <1514407817.4169.4.camel@HansenPartnership.com> <20171227232650.GA9702@bbox> <1514417689.3083.1.camel@HansenPartnership.com> <20171227235643.GA10532@bbox> <1514482907.3040.15.camel@HansenPartnership.com>
 <1514487640.3040.21.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-70556300-1516228408=:5238"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux Memory Management List <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-70556300-1516228408=:5238
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 28 Dec 2017, James Bottomley wrote:
> On Thu, 2017-12-28 at 09:41 -0800, James Bottomley wrote:
> > I'd guess that since they're both in io_schedule, the problem is that
> > the io_scheduler is taking far too long servicing the requests due to
> > some priority issue you've introduced.
>=20
> OK, so after some analysis, that turned out to be incorrect. =C2=A0The
> problem seems to be that we're exiting do_swap_page() with locked pages
> that have been read in from swap.
>=20
> Your changelogs are entirely unclear on why you changed the swapcache
> setting logic in this patch:
>=20
> commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> Author: Minchan Kim <minchan@kernel.org>
> Date:=C2=A0=C2=A0=C2=A0Wed Nov 15 17:33:07 2017 -0800
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0mm, swap: skip swapcache for swapin of synchronou=
s device
>=20
> But I think you're using swapcache =3D=3D NULL as a signal the page came
> from a synchronous device. =C2=A0In which case the bug is that you've
> forgotten we may already have picked up a page in
> swap_readahead_detect() which you're wrongly keeping swapcache =3D=3D NUL=
L
> for and the fix is this (it works on my system, although I'm still
> getting an unaccountable shutdown delay).
>=20
> I still think we should revert this series, because this may not be the
> only bug lurking in the code, so it should go through a lot more
> rigorous testing than it has.

Andrew, neither the fix below (works for me, though I have seen other
swap funniness, most probably unrelated), nor the reversion preferred
by James and Minchan (later in this linux-mm thread), was in 4.15-rc8:
the sands of time are running out...

Hugh

>=20
> James
>=20
> ---
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index ca5674cbaff2..31f9845c340e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2847,7 +2847,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
>  int do_swap_page(struct vm_fault *vmf)
>  {
>  =09struct vm_area_struct *vma =3D vmf->vma;
> -=09struct page *page =3D NULL, *swapcache =3D NULL;
> +=09struct page *page =3D NULL, *swapcache;
>  =09struct mem_cgroup *memcg;
>  =09struct vma_swap_readahead swap_ra;
>  =09swp_entry_t entry;
> @@ -2892,6 +2892,7 @@ int do_swap_page(struct vm_fault *vmf)
>  =09if (!page)
>  =09=09page =3D lookup_swap_cache(entry, vma_readahead ? vma : NULL,
>  =09=09=09=09=09 vmf->address);
> +=09swapcache =3D page;
>  =09if (!page) {
>  =09=09struct swap_info_struct *si =3D swp_swap_info(entry);
> =20
--0-70556300-1516228408=:5238--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
