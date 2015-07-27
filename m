Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id D0A4F6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:54:10 -0400 (EDT)
Received: by qgii95 with SMTP id i95so53273557qgi.2
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 07:54:10 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175])
        by mx.google.com with ESMTP id f82si21194442qkf.18.2015.07.27.07.54.09
        for <linux-mm@kvack.org>;
        Mon, 27 Jul 2015 07:54:10 -0700 (PDT)
Date: Mon, 27 Jul 2015 10:54:09 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
Message-ID: <20150727145409.GB21664@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz>
 <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="QTprm0S8XgL7H0Dt"
Content-Disposition: inline
In-Reply-To: <55B63D37.20303@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--QTprm0S8XgL7H0Dt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 27 Jul 2015, Vlastimil Babka wrote:

> On 07/27/2015 03:35 PM, Eric B Munson wrote:
> >On Mon, 27 Jul 2015, Vlastimil Babka wrote:
> >
> >>On 07/24/2015 11:28 PM, Eric B Munson wrote:
> >>
> >>...
> >>
> >>>Changes from V4:
> >>>Drop all architectures for new sys call entries except x86[_64] and MI=
PS
> >>>Drop munlock2 and munlockall2
> >>>Make VM_LOCKONFAULT a modifier to VM_LOCKED only to simplify book keep=
ing
> >>>Adjust tests to match
> >>
> >>Hi, thanks for considering my suggestions. Well, I do hope there
> >>were correct as API's are hard and I'm no API expert. But since
> >>API's are also impossible to change after merging, I'm sorry but
> >>I'll keep pestering for one last thing. Thanks again for persisting,
> >>I do believe it's for the good thing!
> >>
> >>The thing is that I still don't like that one has to call
> >>mlock2(MLOCK_LOCKED) to get the equivalent of the old mlock(). Why
> >>is that flag needed? We have two modes of locking now, and v5 no
> >>longer treats them separately in vma flags. But having two flags
> >>gives us four possible combinations, so two of them would serve
> >>nothing but to confuse the programmer IMHO. What will mlock2()
> >>without flags do? What will mlock2(MLOCK_LOCKED | MLOCK_ONFAULT) do?
> >>(Note I haven't studied the code yet, as having agreed on the API
> >>should come first. But I did suggest documenting these things more
> >>thoroughly too...)
> >>OK I checked now and both cases above seem to return EINVAL.
> >>
> >>So about the only point I see in MLOCK_LOCKED flag is parity with
> >>MAP_LOCKED for mmap(). But as Kirill said (and me before as well)
> >>MAP_LOCKED is broken anyway so we shouldn't twist the rest just of
> >>the API to keep the poor thing happier in its misery.
> >>
> >>Also note that AFAICS you don't have MCL_LOCKED for mlockall() so
> >>there's no full parity anyway. But please don't fix that by adding
> >>MCL_LOCKED :)
> >>
> >>Thanks!
> >
> >
> >I have an MLOCK_LOCKED flag because I prefer an interface to be
> >explicit.
>=20
> I think it's already explicit enough that the user calls mlock2(),
> no? He obviously wants the range mlocked. An optional flag says that
> there should be no pre-fault.
>=20
> >The caller of mlock2() will be required to fill in the flags
> >argument regardless.
>=20
> I guess users not caring about MLOCK_ONFAULT will continue using
> plain mlock() without flags anyway.
>=20
> I can drop the MLOCK_LOCKED flag with 0 being the
> >value for LOCKED, but I thought it easier to make clear what was going
> >on at any call to mlock2().  If user space defines a MLOCK_LOCKED that
> >happens to be 0, I suppose that would be okay.
>=20
> Yeah that would remove the weird 4-states-of-which-2-are-invalid
> problem I mentioned, but at the cost of glibc wrapper behaving
> differently than the kernel syscall itself. For little gain.
>=20
> >We do actually have an MCL_LOCKED, we just call it MCL_CURRENT.  Would
> >you prefer that I match the name in mlock2() (add MLOCK_CURRENT
> >instead)?
>=20
> Hm it's similar but not exactly the same, because MCL_FUTURE is not
> the same as MLOCK_ONFAULT :) So MLOCK_CURRENT would be even more
> confusing. Especially if mlockall(MCL_CURRENT | MCL_FUTURE) is OK,
> but mlock2(MLOCK_LOCKED | MLOCK_ONFAULT) is invalid.

MLOCK_ONFAULT isn't meant to be the same as MCL_FUTURE, rather it is
meant to be the same as MCL_ONFAULT.  MCL_FUTURE only controls if the
locking policy will be applied to any new mappings made by this process,
not the locking policy itself.  The better comparison is MCL_CURRENT to
MLOCK_LOCK and MCL_ONFAULT to MLOCK_ONFAULT.  MCL_CURRENT and
MLOCK_LOCK do the same thing, only one requires a specific range of
addresses while the other works process wide.  This is why I suggested
changing MLOCK_LOCK to MLOCK_CURRENT.  It is an error to call
mlock2(MLOCK_LOCK | MLOCK_ONFAULT) just like it is an error to call
mlockall(MCL_CURRENT | MCL_ONFAULT).  The combinations do no make sense.

This was all decided when VM_LOCKONFAULT was a separate state from
VM_LOCKED.  Now that VM_LOCKONFAULT is a modifier to VM_LOCKED and
cannot be specified independentally, it might make more sense to mirror
that relationship to userspace.  Which would lead to soemthing like the
following:

To lock and populate a region:
mlock2(start, len, 0);

To lock on fault a region:
mlock2(start, len, MLOCK_ONFAULT);

If LOCKONFAULT is seen as a modifier to mlock, then having the flags
argument as 0 mean do mlock classic makes more sense to me.

To mlock current on fault only:
mlockall(MCL_CURRENT | MCL_ONFAULT);

To mlock future on fault only:
mlockall(MCL_FUTURE | MCL_ONFAULT);

To lock everything on fault:
mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);

I think I have talked myself into rewriting the set again :/

>=20
> >Finally, on the question of MAP_LOCKONFAULT, do you just dislike
> >MAP_LOCKED and do not want to see it extended, or is this a NAK on the
> >set if that patch is included.  I ask because I have to spin a V6 to get
> >the MLOCK flag declarations right, but I would prefer not to do a V7+.
> >If this is a NAK with, I can drop that patch and rework the tests to
> >cover without the mmap flag.  Otherwise I want to keep it, I have an
> >internal user that would like to see it added.
>=20
> I don't want to NAK that patch if you think it's useful.
>=20
>=20

--QTprm0S8XgL7H0Dt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVtkYRAAoJELbVsDOpoOa98IYQAKmPZK/MjJP+kHmBsuNCxrvl
kaCRQunDUgO+iqKfdRseLlrsYwTyc3+/UwVRFhIflA1TuBJYjHmrM5t4XNpTE91e
jcgVoLji4yxHXqR4yfucnzrfkkDtiHLynwXxXgWRM6C9SF2fZ6lCMQ4GcHhFMNDL
b6gC0sRrImT49BhJ62CaXv+m0D7df7p+CqvC6DdFL7jR9thkEqlkJKr/7NbRvuDv
Euw8v452frV46AQWa0tGxzO5eoJjOnMpyBrkxsO7RQToWPu3XybIvvEJtRjC/kHc
yMC3unbXB363U5MGKs6TY8JhumY93i/6BmmyqgqizNPxg/ZBhZ8vYArhAzd46Yva
m5s+mhGTa8Mq863NWmIJOYIyWncnvtYGJ/FloG/SS8E1Y6hcxgMwS+JzaoBInV3I
LsxOl1GdTd4TPxYB5zAbu25BnRMz4GJQJ5c2rvIuVFDRH7w3O1eFBtlm6h4OO/2a
TMNIL5IsupxC7Y8fUXbVLoZbOgp71EO0zwui/G/Kv8uXL+chl3ITUY/cj9pNvENt
IaQoDulNdDaW+XTFr5ojb965y1Z5GrY/esdCuhOPPmFhD6O36Q4xrT+vCblkYt4W
3Q5vSJsnmao3bANXdow9jbKf/wdEd9d9ioMhZ8IBEt9DJ5MFSHKiB9rcpAOhG4Df
oJyjb7xP2EqU205W7AOD
=CjzZ
-----END PGP SIGNATURE-----

--QTprm0S8XgL7H0Dt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
