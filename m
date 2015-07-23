Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id B26B29003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 11:21:17 -0400 (EDT)
Received: by qgii95 with SMTP id i95so87973451qgi.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 08:21:17 -0700 (PDT)
Received: from prod-mail-xrelay08.akamai.com (prod-mail-xrelay08.akamai.com. [96.6.114.112])
        by mx.google.com with ESMTP id 91si6191402qkz.118.2015.07.23.08.21.15
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 08:21:16 -0700 (PDT)
Date: Thu, 23 Jul 2015 11:21:13 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 4/6] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
Message-ID: <20150723152113.GC7795@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-5-git-send-email-emunson@akamai.com>
 <55AF6A73.1080500@suse.cz>
 <20150722184343.GA2351@akamai.com>
 <55B0BBF9.7050802@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3siQDZowHQqNOShm"
Content-Disposition: inline
In-Reply-To: <55B0BBF9.7050802@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--3siQDZowHQqNOShm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 23 Jul 2015, Vlastimil Babka wrote:

> On 07/22/2015 08:43 PM, Eric B Munson wrote:
> > On Wed, 22 Jul 2015, Vlastimil Babka wrote:
> >=20
> >>=20
> >> Hi,
> >>=20
> >> I think you should include a complete description of which
> >> transitions for vma states and mlock2/munlock2 flags applied on them
> >> are valid and what they do. It will also help with the manpages.
> >> You explained some to Jon in the last thread, but I think there
> >> should be a canonical description in changelog (if not also
> >> Documentation, if mlock is covered there).
> >>=20
> >> For example the scenario Jon asked, what happens after a
> >> mlock2(MLOCK_ONFAULT) followed by mlock2(MLOCK_LOCKED), and that the
> >> answer is "nothing". Your promised code comment for
> >> apply_vma_flags() doesn't suffice IMHO (and I'm not sure it's there,
> >> anyway?).
> >=20
> > I missed adding that comment to the code, will be there in V5 along with
> > the description in the changelog.
>=20
> Thanks!
>=20
> >>=20
> >> But the more I think about the scenario and your new VM_LOCKONFAULT
> >> vma flag, it seems awkward to me. Why should munlocking at all care
> >> if the vma was mlocked with MLOCK_LOCKED or MLOCK_ONFAULT? In either
> >> case the result is that all pages currently populated are munlocked.
> >> So the flags for munlock2 should be unnecessary.
> >=20
> > Say a user has a large area of interleaved MLOCK_LOCK and MLOCK_ONFAULT
> > mappings and they want to unlock only the ones with MLOCK_LOCK.  With
> > the current implementation, this is possible in a single system call
> > that spans the entire region.  With your suggestion, the user would have
> > to know what regions where locked with MLOCK_LOCK and call munlock() on
> > each of them.  IMO, the way munlock2() works better mirrors the way
> > munlock() currently works when called on a large area of interleaved
> > locked and unlocked areas.
>=20
> Um OK, that scenario is possible in theory. But I have a hard time imagin=
ing
> that somebody would really want to do that. I think much more people would
> benefit from a simpler API.

It wasn't about imagining a scenario, more about keeping parity with
something that currently works (unlocking a large area of interleaved
locked and unlocked regions).  However, there is no reason we can't add
the new munlock2 later if it is desired.

>=20
> >=20
> >>=20
> >> I also think VM_LOCKONFAULT is unnecessary. VM_LOCKED should be
> >> enough - see how you had to handle the new flag in all places that
> >> had to handle the old flag? I think the information whether mlock
> >> was supposed to fault the whole vma is obsolete at the moment mlock
> >> returns. VM_LOCKED should be enough for both modes, and the flag to
> >> mlock2 could just control whether the pre-faulting is done.
> >>=20
> >> So what should be IMHO enough:
> >> - munlock can stay without flags
> >> - mlock2 has only one new flag MLOCK_ONFAULT. If specified,
> >> pre-faulting is not done, just set VM_LOCKED and mlock pages already
> >> present.
> >> - same with mmap(MAP_LOCKONFAULT) (need to define what happens when
> >> both MAP_LOCKED and MAP_LOCKONFAULT are specified).
> >>=20
> >> Now mlockall(MCL_FUTURE) muddles the situation in that it stores the
> >> information for future VMA's in current->mm->def_flags, and this
> >> def_flags would need to distinguish VM_LOCKED with population and
> >> without. But that could be still solvable without introducing a new
> >> vma flag everywhere.
> >=20
> > With you right up until that last paragraph.  I have been staring at
> > this a while and I cannot come up a way to handle the
> > mlockall(MCL_ONFAULT) without introducing a new vm flag.  It doesn't
> > have to be VM_LOCKONFAULT, we could use the model that Michal Hocko
> > suggested with something like VM_FAULTPOPULATE.  However, we can't
> > really use this flag anywhere except the mlock code becuase we have to
> > be able to distinguish a caller that wants to use MLOCK_LOCK with
> > whatever control VM_FAULTPOPULATE might grant outside of mlock and a
> > caller that wants MLOCK_ONFAULT.  That was a long way of saying we need
> > an extra vma flag regardless.  However, if that flag only controls if
> > mlock pre-populates it would work and it would do away with most of the
> > places I had to touch to handle VM_LOCKONFAULT properly.
>=20
> Yes, it would be a good way. Adding a new vma flag is probably cleanest a=
fter
> all, but the flag would be set *in addition* to VM_LOCKED, *just* to prev=
ent
> pre-faulting. The places that check VM_LOCKED for the actual page mlockin=
g (i.e.
> try_to_unmap_one) would just keep checking VM_LOCKED. The places where VM=
_LOCKED
> is checked to trigger prepopulation, would skip that if VM_LOCKONFAULT is=
 also
> set. Having VM_LOCKONFAULT set without also VM_LOCKED itself would be inv=
alid state.
>=20
> This should work fine with the simplified API as I proposed so let me rei=
terate
> and try fill in the blanks:
>=20
> - mlock2 has only one new flag MLOCK_ONFAULT. If specified, VM_LOCKONFAUL=
T is
> set in addition to VM_LOCKED and no prefaulting is done
>   - old mlock syscall naturally behaves as mlock2 without MLOCK_ONFAULT
>   - calling mlock/mlock2 on an already-mlocked area (if that's permitted
> already?) will add/remove VM_LOCKONFAULT as needed. If it's removing,
> prepopulate whole range. Of course adding VM_LOCKONFAULT to a vma that was
> already prefaulted doesn't make any difference, but it's consistent with =
the rest.
> - munlock removes both VM_LOCKED and VM_LOCKONFAULT
> - mmap could treat MAP_LOCKONFAULT as a modifier to MAP_LOCKED to be cons=
istent?
> or not? I'm not sure here, either way subtly differs from mlock API anywa=
y, I
> just wish MAP_LOCKED never existed...
> - mlockall(MCL_CURRENT) sets or clears VM_LOCKONFAULT depending on
> MCL_LOCKONFAULT, mlockall(MCL_FUTURE) does the same on mm->def_flags
> - munlockall2 removes both, like munlock. munlockall2(MCL_FUTURE) does th=
at to
> def_flags
>=20
> > I picked VM_LOCKONFAULT because it is explicit about what it is for and
> > there is little risk of someone coming along in 5 years and saying "why
> > not overload this flag to do this other thing completely unrelated to
> > mlock?".  A flag for controling speculative population is more likely to
> > be overloaded outside of mlock().
>=20
> Sure, let's make clear the name is related to mlock, but the behavior cou=
ld
> still be additive to MAP_LOCKED.
>=20
> > If you have a sane way of handling mlockall(MCL_ONFAULT) without a new
> > VMA flag, I am happy to give it a try, but I haven't been able to come
> > up with one that doesn't have its own gremlins.
>=20
> Well we could store the MCL_FUTURE | MCL_ONFAULT bit elsewhere in mm_stru=
ct than
> the def_flags field. The VM_LOCKED field is already evaluated specially f=
rom all
> the other def_flags. We are nearing the full 32bit space for vma flags. I=
 think
> all I've proposed above wouldn't change much if we removed per-vma
> VM_LOCKONFAULT flag from the equation. Just that re-mlocking area already
> mlocked *withouth* MLOCK_ONFAULT wouldn't know that it was alread prepopu=
lated,
> and would have to re-populate in either case (I'm not sure, maybe it's al=
ready
> done by current implementation anyway so it's not a potential performance
> regression).
> Only mlockall(MCL_FUTURE | MCL_ONFAULT) should really need the ONFAULT in=
fo to
> "stick" somewhere in mm_struct, but it doesn't have to be def_flags?

This all sounds fine and should still cover the usecase that started
this adventure.  I will include this change in the V5 spin.


--3siQDZowHQqNOShm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVsQZpAAoJELbVsDOpoOa9rPAP/1izNbG09pAsgxL0DabP9Q3+
6wqhAW/fwNDziiMvLDYdnRdyf0S7rMwSMiHF6Lkx8PXkLWocX7O8FhqF4J94wxnR
LRGVLsik6RtHTFVOGtBZdKq2+tumpIdwAYrXs5R7zZjQq/vuV+JR6jEyu6+lP+d1
Z2jyxcFuNQcIFB3oD6T0W9vG2rAkye2MPYqMjHYy88qgh3qU46nZx5wjJBDjMVFR
n3kg+vYqsZhaZqVStUNEIyf8/FftVUuhjaIgqH/GJortMAlDP2nV1oTqsnUsPiDn
lSzZVI9OgJB0J49u14QumSUHsvK+SuugJ0UQLFY1o2ZDFF/FTyAVgW1tXF34ZcoZ
ndVDFRO7B2yDy1f7Fe9d9W4rKDvOvrqUj8leYrI3XUJ+5eYQfT+WgYKwnDFY0Ol0
xsz1RAoM0B61jUN694Ypqpywa6a5XTg2sqJwJh3vXiGWs/wPTRmW1V+Y0h0PyCzw
iGbmGrLRd/WsFaGFZLp+/8Z74wInKPEBJ0wzJmM94stYDR+ZQHZazX3rSrwbloir
vX+HX28xmmyOCRMN1CXBg1N2moaCqOb0CADPk8iLBkXqZEFiNMRfEnIBVLOWUdHw
s+U9WnlLrMpozaFKpyaGAhiwGVhjusl/pd0t3yIeOWqK8sNikxomriXCH6AqEyvS
aZaJVX9ee0a6Dpn5LQGB
=KQeP
-----END PGP SIGNATURE-----

--3siQDZowHQqNOShm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
