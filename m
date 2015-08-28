Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id C18706B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 15:34:55 -0400 (EDT)
Received: by qgeh99 with SMTP id h99so37257261qge.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:34:55 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id 97si3621415qgt.30.2015.08.28.12.34.54
        for <linux-mm@kvack.org>;
        Fri, 28 Aug 2015 12:34:54 -0700 (PDT)
Date: Fri, 28 Aug 2015 15:34:54 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH v8 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150828193454.GC7925@akamai.com>
References: <1440613465-30393-1-git-send-email-emunson@akamai.com>
 <1440613465-30393-4-git-send-email-emunson@akamai.com>
 <20150828141829.GD5301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="H8ygTp4AXg6deix2"
Content-Disposition: inline
In-Reply-To: <20150828141829.GD5301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--H8ygTp4AXg6deix2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 28 Aug 2015, Michal Hocko wrote:

> On Wed 26-08-15 14:24:22, Eric B Munson wrote:
> > The cost of faulting in all memory to be locked can be very high when
> > working with large mappings.  If only portions of the mapping will be
> > used this can incur a high penalty for locking.
> >=20
> > For the example of a large file, this is the usage pattern for a large
> > statical language model (probably applies to other statical or graphical
> > models as well).  For the security example, any application transacting
> > in data that cannot be swapped out (credit card data, medical records,
> > etc).
> >=20
> > This patch introduces the ability to request that pages are not
> > pre-faulted, but are placed on the unevictable LRU when they are finally
> > faulted in.  The VM_LOCKONFAULT flag will be used together with
> > VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> > VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> > be added to the unevictable LRU when they are faulted or if they are
> > already present, but will not cause any missing pages to be faulted in.
>=20
> OK, I can live with this. Thank you for removing the part which exports
> the flag to the userspace.
> =20
> > Exposing this new lock state means that we cannot overload the meaning
> > of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> > to mean that the VMA for a fault was locked.  This means we need the
> > new FOLL_MLOCK flag to communicate the locked state of a VMA.
> > FOLL_POPULATE will now only control if the VMA should be populated and
> > in the case of VM_LOCKONFAULT, it will not be set.
>=20
> I thinking that this part is really unnecessary. populate_vma_page_range
> could have simply returned without calling gup for VM_LOCKONFAULT
> vmas. You would save the pte walk and the currently mapped pages would
> be still protected from the reclaim. The side effect would be that they
> would litter the regular LRUs and mlock/unevictable counters wouldn't be
> updated until those pages are encountered during the reclaim and culled
> to unevictable list.
>=20
> I would expect that mlock with this flag would be typically called
> on mostly unpopulated mappings so the side effects would be barely
> noticeable while the lack of pte walk would be really nice (especially
> for the large mappings).
>=20
> This would be a nice optimization and minor code reduction but I am not
> going to insist on it. I will leave the decision to you.

If I am understanding you correctly, this is how the lock on fault set
started.  Jon Corbet pointed out that this would leave pages which were
present when mlock2(MLOCK_ONFAULT) was called in an unlocked state, only
locking them after they were reclaimed and then refaulted.

Even if this was never the case, we scan the entire range for a call to
mlock() and will lock the pages which are present.  Why would we pay the
cost of getting the accounting right on the present pages for mlock, but
not lock on fault?

>=20
> > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: linux-api@vger.kernel.org
>=20
> Acked-by: Michal Hocko <mhocko@suse.com>
>=20
> One note below:
>=20
> > ---
> > Changes from v7:
> > *Drop entries in smaps and dri code to avoid exposing VM_LOCKONFAULT to
> >  userspace.  VM_LOCKONFAULT is still exposed via mm/debug.c
> > *Create VM_LOCKED_CLEAR_MASK to be used anywhere we want to clear all
> >  flags relating to locked VMAs
> >=20
> >  include/linux/mm.h |  5 +++++
> >  kernel/fork.c      |  2 +-
> >  mm/debug.c         |  1 +
> >  mm/gup.c           | 10 ++++++++--
> >  mm/huge_memory.c   |  2 +-
> >  mm/hugetlb.c       |  4 ++--
> >  mm/mlock.c         |  2 +-
> >  mm/mmap.c          |  2 +-
> >  mm/rmap.c          |  6 ++++--
> >  9 files changed, 24 insertions(+), 10 deletions(-)
> [...]
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 171b687..14ce002 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -744,7 +744,8 @@ static int page_referenced_one(struct page *page, s=
truct vm_area_struct *vma,
> > =20
> >  		if (vma->vm_flags & VM_LOCKED) {
> >  			spin_unlock(ptl);
> > -			pra->vm_flags |=3D VM_LOCKED;
> > +			pra->vm_flags |=3D
> > +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
> >  			return SWAP_FAIL; /* To break the loop */
> >  		}
> > =20
> > @@ -765,7 +766,8 @@ static int page_referenced_one(struct page *page, s=
truct vm_area_struct *vma,
> > =20
> >  		if (vma->vm_flags & VM_LOCKED) {
> >  			pte_unmap_unlock(pte, ptl);
> > -			pra->vm_flags |=3D VM_LOCKED;
> > +			pra->vm_flags |=3D
> > +				(vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT));
> >  			return SWAP_FAIL; /* To break the loop */
> >  		}
>=20
> Why do we need to export this? Neither of the consumers care and should
> care. VM_LOCKONFAULT should never be set without VM_LOCKED which is the
> only thing that we should care about.

I exported VM_LOCKONFAULT because this is an internal interface and I
saw no harm in doing so.  I do not have a use case for it at the moment,
so I would be fine dropping this hunk.


--H8ygTp4AXg6deix2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJV4LfdAAoJELbVsDOpoOa933AQALqrStAElERVKLN2zjrMhion
m61qIlWtzvaEzZQ9Oz47cEY68JBcQElY09rEirCKyTdDNOxGvCbSPQ5SkwAnGIJe
LNPAwdyuvD/viGUIuD6A5N+XT2yC59ofw6uWOK7DBvOBAGKo9dmGY7v0qWResCRf
21OY7H1HQHt6fCm4HmWTr1dOOUFz2ULuS1/ZWZrNilEZOoghUt+Gy4ExNMssG44o
NwfN1IrwmeTQdyfHjIbMIVuGcZX77gMNQ47IB+qtqr+e8fp3Q0F/JDR6o4IjqCFr
Ty+JyS1rWLsx1ua+lSptwkLOG8yV57c3P00naiNo4TZt3owEWexeJwwCjLOMoeAi
AFfou6X6czpjneVDtMgOdYkdnW+NAtqifjIQZVDkTg0WwGCyjfNSfHPUNj3OGZi7
ypfdfiYq7J7q2SHYT9uqvc/ux0hSLaO4i6T2C0/8thaAH6Hz/c49SowAQsCfrFcv
ic34RuJdczZqvFsL32tziB9u9bY3SShpsQdYWLWCaRtkmEk00PEgWbVrnun3gtAB
8l6emJdLsC3faxqh8BwLobUu+7MxzO6J8mVJjCareDUg2pOnC2RTmP5WzrklHeAq
B5ror+Ghf9zCGtxa+wIGPutsmokoxXDkWUoqrCQv9XSQlbpoSNsz3IPPV77mq3Qu
nXtM3DuDMP/4bF9hdpoK
=1dd8
-----END PGP SIGNATURE-----

--H8ygTp4AXg6deix2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
