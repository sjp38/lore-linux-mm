Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 931866B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 10:18:08 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so139824513pdb.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 07:18:08 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id gl1si29729368pbd.192.2015.06.22.07.18.07
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 07:18:07 -0700 (PDT)
Date: Mon, 22 Jun 2015 10:18:06 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH V2 1/3] Add mmap flag to request pages are locked
 after page fault
Message-ID: <20150622141806.GE2329@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <1433942810-7852-2-git-send-email-emunson@akamai.com>
 <20150618152907.GG5858@dhcp22.suse.cz>
 <20150618203048.GB2329@akamai.com>
 <20150619145708.GG4913@dhcp22.suse.cz>
 <20150619164333.GD2329@akamai.com>
 <20150622123826.GF4430@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8vCeF2GUdMpe9ZbK"
Content-Disposition: inline
In-Reply-To: <20150622123826.GF4430@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--8vCeF2GUdMpe9ZbK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Jun 2015, Michal Hocko wrote:

> On Fri 19-06-15 12:43:33, Eric B Munson wrote:
> > On Fri, 19 Jun 2015, Michal Hocko wrote:
> >=20
> > > On Thu 18-06-15 16:30:48, Eric B Munson wrote:
> > > > On Thu, 18 Jun 2015, Michal Hocko wrote:
> > > [...]
> > > > > Wouldn't it be much more reasonable and straightforward to have
> > > > > MAP_FAULTPOPULATE as a counterpart for MAP_POPULATE which would
> > > > > explicitly disallow any form of pre-faulting? It would be usable =
for
> > > > > other usecases than with MAP_LOCKED combination.
> > > >=20
> > > > I don't see a clear case for it being more reasonable, it is one
> > > > possible way to solve the problem.
> > >=20
> > > MAP_FAULTPOPULATE would be usable for other cases as well. E.g. fault
> > > around is all or nothing feature. Either all mappings (which support
> > > this) fault around or none. There is no way to tell the kernel that
> > > this particular mapping shouldn't fault around. I haven't seen such a
> > > request yet but we have seen requests to have a way to opt out from
> > > a global policy in the past (e.g. per-process opt out from THP). So
> > > I can imagine somebody will come with a request to opt out from any
> > > speculative operations on the mapped area in the future.
> > >=20
> > > > But I think it leaves us in an even
> > > > more akward state WRT VMA flags.  As you noted in your fix for the
> > > > mmap() man page, one can get into a state where a VMA is VM_LOCKED,=
 but
> > > > not present.  Having VM_LOCKONFAULT states that this was intentiona=
l, if
> > > > we go to using MAP_FAULTPOPULATE instead of MAP_LOCKONFAULT, we no
> > > > longer set VM_LOCKONFAULT (unless we want to start mapping it to the
> > > > presence of two MAP_ flags).  This can make detecting the MAP_LOCKE=
D +
> > > > populate failure state harder.
> > >=20
> > > I am not sure I understand your point here. Could you be more specific
> > > how would you check for that and what for?
> >=20
> > My thought on detecting was that someone might want to know if they had
> > a VMA that was VM_LOCKED but had not been made present becuase of a
> > failure in mmap.  We don't have a way today, but adding VM_LOCKONFAULT
> > is at least explicit about what is happening which would make detecting
> > the VM_LOCKED but not present state easier.=20
>=20
> One could use /proc/<pid>/pagemap to query the residency.
>=20
> > This assumes that
> > MAP_FAULTPOPULATE does not translate to a VMA flag, but it sounds like
> > it would have to.
>=20
> Yes, it would have to have a VM flag for the vma.
>=20
> > > From my understanding MAP_LOCKONFAULT is essentially
> > > MAP_FAULTPOPULATE|MAP_LOCKED with a quite obvious semantic (unlike
> > > single MAP_LOCKED unfortunately). I would love to also have
> > > MAP_LOCKED|MAP_POPULATE (aka full mlock semantic) but I am really
> > > skeptical considering how my previous attempt to make MAP_POPULATE
> > > reasonable went.
> >=20
> > Are you objecting to the addition of the VMA flag VM_LOCKONFAULT, or the
> > new MAP_LOCKONFAULT flag (or both)?=20
>=20
> I thought the MAP_FAULTPOPULATE (or any other better name) would
> directly translate into VM_FAULTPOPULATE and wouldn't be tight to the
> locked semantic. We already have VM_LOCKED for that. The direct effect
> of the flag would be to prevent from population other than the direct
> page fault - including any speculative actions like fault around or
> read-ahead.

I like the ability to control other speculative population, but I am not
sure about overloading it with the VM_LOCKONFAULT case.  Here is my
concern.  If we are using VM_FAULTPOPULATE | VM_LOCKED to denote
LOCKONFAULT, how can we tell the difference between someone that wants
to avoid read-ahead and wants to use mlock()?  This might lead to some
interesting states with mlock() and munlock() that take flags.  For
instance, using VM_LOCKONFAULT mlock(MLOCK_ONFAULT) followed by
munlock(MLOCK_LOCKED) leaves the VMAs in the same state with
VM_LOCKONFAULT set.  If we use VM_FAULTPOPULATE, the same pair of calls
would clear VM_LOCKED, but leave VM_FAULTPOPULATE.  It may not matter in
the end, but I am concerned about the subtleties here.

>=20
> > If you prefer that MAP_LOCKED |
> > MAP_FAULTPOPULATE means that VM_LOCKONFAULT is set, I am fine with that
> > instead of introducing MAP_LOCKONFAULT.  I went with the new flag
> > because to date, we have a one to one mapping of MAP_* to VM_* flags.
> >=20
> > >=20
> > > > If this is the preferred path for mmap(), I am fine with that.=20
> > >=20
> > > > However,
> > > > I would like to see the new system calls that Andrew mentioned (and=
 that
> > > > I am testing patches for) go in as well.=20
> > >=20
> > > mlock with flags sounds like a good step but I am not sure it will ma=
ke
> > > sense in the future. POSIX has screwed that and I am not sure how many
> > > applications would use it. This ship has sailed long time ago.
> >=20
> > I don't know either, but the code is the question, right?  I know that
> > we have at least one team that wants it here.
> >=20
> > >=20
> > > > That way we give users the
> > > > ability to request VM_LOCKONFAULT for memory allocated using someth=
ing
> > > > other than mmap.
> > >=20
> > > mmap(MAP_FAULTPOPULATE); mlock() would have the same semantic even
> > > without changing mlock syscall.
> >=20
> > That is true as long as MAP_FAULTPOPULATE set a flag in the VMA(s).  It
> > doesn't cover the actual case I was asking about, which is how do I get
> > lock on fault on malloc'd memory?
>=20
> OK I see your point now. We would indeed need a flag argument for mlock.
> --=20
> Michal Hocko
> SUSE Labs

--8vCeF2GUdMpe9ZbK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJViBkeAAoJELbVsDOpoOa9pkcQALlaWWdIjaV+PbMT84IJJRE8
xU+rL1vQjFbf3KGAXPxta7KjvT0OS2mPJ15WQE58XhTeGslpwB/Ujsd9n+H3TeQ8
lk/F5wFrTvwGn5WcijHJ9xUslamjI2ewEzCUX8BIQWh/bG2X3pIpjdgNJHW1Ofb0
FpUYTqL/4EnYzDqhY2CFW6OSruru9YagVJQ2NPu6+wkdkhAtt/CpESTVF+vbJoKW
ewpOGghLVYWnjbRPB5PFAnXhjmtEpzPIOLeE62GkuQDQWdFNdnqlUMz/ZZmUyRGB
RBmPUtT3jhlUlhnkI0qY/z27S9w+mB2yvIBclPUBrGtv/73QICHmHd+rYE11YGXf
8zIglfn69cX5deCUBmdkmUsGiOZpbwVNVkI1HmvL+wMDZEwZyT3bZnSyAMyUe385
FVt+HGvq5Afxk5ooL6zPty283KGLZiKURj8Zw/g5YRBO6/B/7NRvct9x+0OzSdW0
C3u9sTfLa5wI581qumQt0cODGdhdO3SNjov9SpeZs8firqxEKhxn0pNjs7heFu7i
HQHoRJGhc8RXqjp8QsxeQL4+tepDvuAnxU53YJZxBwze6AwuWQ8WEomP51ebTnKW
xNwU2AVf6WZ3KFLyL7gjn7YxfkQll67pHPwn6BddK4SGdT5VVgX1h3MUfvo86f2V
uvYltwMOPPyaFw18cEx1
=67XH
-----END PGP SIGNATURE-----

--8vCeF2GUdMpe9ZbK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
