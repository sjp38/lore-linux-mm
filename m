Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C69A16B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:58:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so5020704wmd.0
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:58:51 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p132si4061777wme.103.2018.01.17.14.58.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 14:58:50 -0800 (PST)
Date: Wed, 17 Jan 2018 14:58:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Hang with v4.15-rc trying to swap back in
Message-Id: <20180117145847.ee3137777a42199fd3ea67b8@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1801171423490.5238@eggly.anvils>
References: <1514398340.3986.10.camel@HansenPartnership.com>
	<1514407817.4169.4.camel@HansenPartnership.com>
	<20171227232650.GA9702@bbox>
	<1514417689.3083.1.camel@HansenPartnership.com>
	<20171227235643.GA10532@bbox>
	<1514482907.3040.15.camel@HansenPartnership.com>
	<1514487640.3040.21.camel@HansenPartnership.com>
	<alpine.LSU.2.11.1801171423490.5238@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux Memory Management List <linux-mm@kvack.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Wed, 17 Jan 2018 14:33:21 -0800 (PST) Hugh Dickins <hughd@google.com> wr=
ote:

> On Thu, 28 Dec 2017, James Bottomley wrote:
> > On Thu, 2017-12-28 at 09:41 -0800, James Bottomley wrote:
> > > I'd guess that since they're both in io_schedule, the problem is that
> > > the io_scheduler is taking far too long servicing the requests due to
> > > some priority issue you've introduced.
> >=20
> > OK, so after some analysis, that turned out to be incorrect. =A0The
> > problem seems to be that we're exiting do_swap_page() with locked pages
> > that have been read in from swap.
> >=20
> > Your changelogs are entirely unclear on why you changed the swapcache
> > setting logic in this patch:
> >=20
> > commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
> > Author: Minchan Kim <minchan@kernel.org>
> > Date:=A0=A0=A0Wed Nov 15 17:33:07 2017 -0800
> >=20
> > =A0=A0=A0=A0mm, swap: skip swapcache for swapin of synchronous device
> >=20
> > But I think you're using swapcache =3D=3D NULL as a signal the page came
> > from a synchronous device. =A0In which case the bug is that you've
> > forgotten we may already have picked up a page in
> > swap_readahead_detect() which you're wrongly keeping swapcache =3D=3D N=
ULL
> > for and the fix is this (it works on my system, although I'm still
> > getting an unaccountable shutdown delay).
> >=20
> > I still think we should revert this series, because this may not be the
> > only bug lurking in the code, so it should go through a lot more
> > rigorous testing than it has.
>=20
> Andrew, neither the fix below (works for me, though I have seen other
> swap funniness, most probably unrelated), nor the reversion preferred
> by James and Minchan (later in this linux-mm thread), was in 4.15-rc8:
> the sands of time are running out...

Yup.  I'm actually planning on sending in this one.  OK by you?


From: Minchan Kim <minchan@kernel.org>
Subject: mm/memory.c: release locked page in do_swap_page()

James reported a bug in swap paging-in from his testing.  It is that
do_swap_page doesn't release locked page so system hang-up happens due to
a deadlock on PG_locked.

It was introduced by 0bcac06f27d7 ("mm, swap: skip swapcache for swapin of
synchronous device") because I missed swap cache hit places to update
swapcache variable to work well with other logics against swapcache in
do_swap_page.

This patch fixes it.

Debugged by James Bottomley.

Link: http://lkml.kernel.org/r/<1514407817.4169.4.camel@HansenPartnership.c=
om>
Link: http://lkml.kernel.org/r/20180102235606.GA19438@bbox
Signed-off-by: Minchan Kim <minchan@kernel.org>
Reported-by: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff -puN mm/memory.c~mm-release-locked-page-in-do_swap_page mm/memory.c
--- a/mm/memory.c~mm-release-locked-page-in-do_swap_page
+++ a/mm/memory.c
@@ -2857,8 +2857,11 @@ int do_swap_page(struct vm_fault *vmf)
 	int ret =3D 0;
 	bool vma_readahead =3D swap_use_vma_readahead();
=20
-	if (vma_readahead)
+	if (vma_readahead) {
 		page =3D swap_readahead_detect(vmf, &swap_ra);
+		swapcache =3D page;
+	}
+
 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
 		if (page)
 			put_page(page);
@@ -2889,9 +2892,12 @@ int do_swap_page(struct vm_fault *vmf)
=20
=20
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	if (!page)
+	if (!page) {
 		page =3D lookup_swap_cache(entry, vma_readahead ? vma : NULL,
 					 vmf->address);
+		swapcache =3D page;
+	}
+
 	if (!page) {
 		struct swap_info_struct *si =3D swp_swap_info(entry);
=20
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
