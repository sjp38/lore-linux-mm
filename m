Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 674046B4AEF
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 17:41:02 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so15199785pfr.6
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 14:41:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor1573506plo.56.2018.11.27.14.41.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 14:41:01 -0800 (PST)
Date: Tue, 27 Nov 2018 12:40:52 -1000
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
Message-ID: <20181127224052.2zyxkdo4lbecq4cz@gmail.com>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
 <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181127105848.GD16502@rapoport-lnx>
 <alpine.LSU.2.11.1811271258070.4506@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="rjiqytyomg5yqcqz"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811271258070.4506@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, Matthew Wilcox <willy@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joey Pabalinas <joeypabalinas@gmail.com>


--rjiqytyomg5yqcqz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 27, 2018 at 01:08:50PM -0800, Hugh Dickins wrote:
> On Tue, 27 Nov 2018, Mike Rapoport wrote:
> > On Mon, Nov 26, 2018 at 11:27:07AM -0800, Hugh Dickins wrote:
> > >=20
> > > +/*
> > > + * A choice of three behaviors for wait_on_page_bit_common():
> > > + */
> > > +enum behavior {
> > > +	EXCLUSIVE,	/* Hold ref to page and take the bit when woken, like
> > > +			 * __lock_page() waiting on then setting PG_locked.
> > > +			 */
> > > +	SHARED,		/* Hold ref to page and check the bit when woken, like
> > > +			 * wait_on_page_writeback() waiting on PG_writeback.
> > > +			 */
> > > +	DROP,		/* Drop ref to page before wait, no check when woken,
> > > +			 * like put_and_wait_on_page_locked() on PG_locked.
> > > +			 */
> > > +};
> >=20
> > Can we please make it:
> >=20
> > /**
> >  * enum behavior - a choice of three behaviors for wait_on_page_bit_com=
mon()
> >  */
> > enum behavior {
> > 	/**
> > 	 * @EXCLUSIVE: Hold ref to page and take the bit when woken,
> > 	 * like __lock_page() waiting on then setting %PG_locked.
> > 	 */
> > 	EXCLUSIVE,
> > 	/**
> > 	 * @SHARED: Hold ref to page and check the bit when woken,
> > 	 * like wait_on_page_writeback() waiting on %PG_writeback.
> > 	 */
> > 	SHARED,
> > 	/**
> > 	 * @DROP: Drop ref to page before wait, no check when woken,
> > 	 * like put_and_wait_on_page_locked() on %PG_locked.
> > 	 */
> > 	DROP,
> > };
>=20
> I'm with Matthew, I'd prefer not: the first looks a more readable,
> less cluttered comment to me than the second: this is just an arg
> to an internal helper in mm/filemap.c, itself not kernel-doc'ed.
>=20
> But the comment is not there for me: if consensus is that the
> second is preferable, then sure, we can change it over.

For something which is internal to a single file I strongly prefer
the first as well.

--=20
Cheers,
Joey Pabalinas

--rjiqytyomg5yqcqz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEENpTlWU2hUK/KMvHp2rGdfm9DtVIFAlv9x/MACgkQ2rGdfm9D
tVKdGRAAut8v4nSlw2U4Hn42UtEqzpblfw3CUOpTTRO8TArXhZyq7cCQW9+rmfXf
83gLqcfVwIt+jg9VqpORM6hFtotkwRtwBOM0ZO5KkcHKpgI1+z9UVTWI1ZYSwm67
0CF/TyeRdNm3VP8WF1RG0CffG1ujTEZMF2sG0krVwKhBVNARD3hZSaI5jWBtxyJ0
VnCiGrkzChqwoQDtRQaIb2DXNRd1w4GX2K+A3SJi7ALUvyPsk1+rrrsss+fHaEkB
pZIy/5NNnOKvO3vxtxOSs2xWKVF5weBdjOCtr9UbZOY7BMpoZxAGCRSXxngk4K6a
croT4+68OKW4OXmyHL2HXlHPuj9dRvHQXUXtBpYRPHdwz3QC9LK62nOo8FTjO6BK
mwuoAu5pnkdZZJKLB4jIfiyPssBl6+gyYfkS5WVpNTtHXB4jdvSbyg4GGUdBUiuB
zhv8SHNSsNpDL0SORZPkOpc6OYnvZVIa+tFyop7YWCeLh3GdMcKdKSxsynaizk3c
w4cXc7E8vawHWEiEDOTp0/cbAh0ZJeU0H7WyJssdHsNEjL90dppsMxGrOTJs+U2+
zjtB9te3QakLh48Y2nppuYy+9WH75Xs72lNHo+dN3wmuAQwUH74p+FPHSynh1yoE
sj8tpBBYrkDcOlDlFuL+37U2Noo39zzfXMCoZeoMcEy01DC92iQ=
=9Eyk
-----END PGP SIGNATURE-----

--rjiqytyomg5yqcqz--
