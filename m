Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 97CBA6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 16:53:00 -0500 (EST)
Received: by padfa1 with SMTP id fa1so21351422pad.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 13:53:00 -0800 (PST)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id gu5si1575801pac.10.2015.03.03.13.52.59
        for <linux-mm@kvack.org>;
        Tue, 03 Mar 2015 13:52:59 -0800 (PST)
Date: Tue, 3 Mar 2015 16:52:58 -0500
From: Eric B Munson <emunson@akamai.com>
Subject: Re: Resurrecting the VM_PINNED discussion
Message-ID: <20150303215258.GB6995@akamai.com>
References: <20150303174105.GA3295@akamai.com>
 <54F5FEE0.2090104@suse.cz>
 <20150303184520.GA4996@akamai.com>
 <54F617A2.8040405@suse.cz>
 <20150303210150.GA6995@akamai.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hQiwHBbRI9kgIhsi"
Content-Disposition: inline
In-Reply-To: <20150303210150.GA6995@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--hQiwHBbRI9kgIhsi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 03 Mar 2015, Eric B Munson wrote:

> On Tue, 03 Mar 2015, Vlastimil Babka wrote:
>=20
> > On 03/03/2015 07:45 PM, Eric B Munson wrote:
> > > On Tue, 03 Mar 2015, Vlastimil Babka wrote:
> > >=20
> > >> On 03/03/2015 06:41 PM, Eric B Munson wrote:> All,
> > >> >
> > >> > After LSF/MM last year Peter revived a patch set that would create
> > >> > infrastructure for pinning pages as opposed to simply locking them.
> > >> > AFAICT, there was no objection to the set, it just needed some help
> > >> > from the IB folks.
> > >> >
> > >> > Am I missing something about why it was never merged?  I ask becau=
se
> > >> > Akamai has bumped into the disconnect between the mlock manpage,
> > >> > Documentation/vm/unevictable-lru.txt, and reality WRT compaction a=
nd
> > >> > locking.  A group working in userspace read those sources and wrot=
e a
> > >> > tool that mmaps many files read only and locked, munmapping them w=
hen
> > >> > they are no longer needed.  Locking is used because they cannot af=
ford a
> > >> > major fault, but they are fine with minor faults.  This tends to
> > >> > fragment memory badly so when they started looking into using huge=
tlbfs
> > >> > (or anything requiring order > 0 allocations) they found they were=
 not
> > >> > able to allocate the memory.  They were confused based on the refe=
renced
> > >> > documentation as to why compaction would continually fail to yield
> > >> > appropriately sized contiguous areas when there was more than enou=
gh
> > >> > free memory.
> > >>=20
> > >> So you are saying that mlocking (VM_LOCKED) prevents migration and t=
hus
> > >> compaction to do its job? If that's true, I think it's a bug as it i=
s AFAIK
> > >> supposed to work just fine.
> > >=20
> > > Agreed.  But as has been discussed in the threads around the VM_PINNED
> > > work, there are people that are relying on the fact that VM_LOCKED
> > > promises no minor faults.  Which is why the behavoir has remained.
> >=20
> > At least in the VM_PINNED thread after last lsf/mm, I don't see this me=
ntioned.
> > I found no references to mlocking in compaction.c, and in migrate.c the=
re's just
> > mlock_migrate_page() with comment:
> >=20
> > /*
> >  * mlock_migrate_page - called only from migrate_page_copy() to
> >  * migrate the Mlocked page flag; update statistics.
> >  */
> >=20
> > It also passes TTU_IGNORE_MLOCK to try_to_unmap(). So what am I missing=
? Where
> > is this restriction?
> >=20
>=20
> I spent quite some time looking for it as well, it is in vmscan.c
>=20
> int __isolate_lru_page(struct page *page, isolate_mode_t mode)
> {
> ...
>         /* Compaction should not handle unevictable pages but CMA can do =
so */
>         if (PageUnevictable(page) && !(mode & ISOLATE_UNEVICTABLE))
>                 return ret;
> ...
>=20
>=20

And that demonstrates that I haven't spent enough time with this code,
that isn't the restriction because when this is called from compaction.c
the mode is set to ISOLATE_UNEVICTABLE.  So back to reading the code.

Eric

--hQiwHBbRI9kgIhsi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU9i06AAoJELbVsDOpoOa9YBgQALpe2Umx8yBLDXZ0PSnzbx0Y
T8ZfTUcoCvzl/m3KYJ94oJUViPO+zF8CYNOo5dEAiAFIVbUhIS1/RorjrcxFSbWk
/kz2Q8g2uM/ZLfo5fhq5ntvHvQ8LxZ1hL8xUg8kmwyR+aC8rctt3386u3C61EhGC
IgKrZGmNs8UU+R8vjkamVm/ca9vIc3c3wTnY0qyK/rahbn2ezGNepEe74qbCvKqh
ATAcU8CKcgDYBST8wGUk137sT3xPIG1DRurGF5IaqRvmZl/sRVRfFR0pxnagmNSk
AmQBz0TWQwkcSKsHN6BZulZxhVla2zQQIfXarQhkxFF46LkzRV/YK9n1U9qpighR
trNeE+MdTX1f+oHNgmc0OT+bgiRPBSkD0riXdXH38889zr/kDvEuLoPOdyu6saZ1
AulaEJpFv0XR18Bt15r7kp1NiStV0vcdPJp8sIZjSwjE6Wc6NhzRnszHdCPfEUMf
Z4GKRH2GUVTx5J72MAnXPv5SvH7tfcPa2pjQ4wd25TXl7L9c5McE6saCX2WNu0sF
6PxBzA8fq0dAwvYRVBQhIo63PcSHHvHmBcSdCf4L8RQmzzb25KDLmT2d27N35AQL
1U6ayiBfrl+tBqH+kRHWJaGxzWCa5bQ0iGm2Mkh+wXLuHX8oPsCNVCiikGtIrLWj
rX+/xpeoMP7KrkOy/ler
=nC23
-----END PGP SIGNATURE-----

--hQiwHBbRI9kgIhsi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
