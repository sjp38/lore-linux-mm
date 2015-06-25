Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id AA4D16B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:46:49 -0400 (EDT)
Received: by qkei195 with SMTP id i195so1236291qke.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 07:46:49 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id p97si29524251qgd.86.2015.06.25.07.46.48
        for <linux-mm@kvack.org>;
        Thu, 25 Jun 2015 07:46:48 -0700 (PDT)
Date: Thu, 25 Jun 2015 10:46:47 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH V2 1/3] Add mmap flag to request pages are locked
 after page fault
Message-ID: <20150625144647.GG2329@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <1433942810-7852-2-git-send-email-emunson@akamai.com>
 <20150618152907.GG5858@dhcp22.suse.cz>
 <20150618203048.GB2329@akamai.com>
 <20150619145708.GG4913@dhcp22.suse.cz>
 <20150619164333.GD2329@akamai.com>
 <20150622123826.GF4430@dhcp22.suse.cz>
 <20150622141806.GE2329@akamai.com>
 <20150624085013.GB32756@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="APlYHCtpeOhspHkB"
Content-Disposition: inline
In-Reply-To: <20150624085013.GB32756@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--APlYHCtpeOhspHkB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Jun 2015, Michal Hocko wrote:

> On Mon 22-06-15 10:18:06, Eric B Munson wrote:
> > On Mon, 22 Jun 2015, Michal Hocko wrote:
> >=20
> > > On Fri 19-06-15 12:43:33, Eric B Munson wrote:
> [...]
> > > > Are you objecting to the addition of the VMA flag VM_LOCKONFAULT, o=
r the
> > > > new MAP_LOCKONFAULT flag (or both)?=20
> > >=20
> > > I thought the MAP_FAULTPOPULATE (or any other better name) would
> > > directly translate into VM_FAULTPOPULATE and wouldn't be tight to the
> > > locked semantic. We already have VM_LOCKED for that. The direct effect
> > > of the flag would be to prevent from population other than the direct
> > > page fault - including any speculative actions like fault around or
> > > read-ahead.
> >=20
> > I like the ability to control other speculative population, but I am not
> > sure about overloading it with the VM_LOCKONFAULT case.  Here is my
> > concern.  If we are using VM_FAULTPOPULATE | VM_LOCKED to denote
> > LOCKONFAULT, how can we tell the difference between someone that wants
> > to avoid read-ahead and wants to use mlock()?
>=20
> Not sure I understand. Something like?
> addr =3D mmap(VM_FAULTPOPULATE) # To prevent speculative mappings into th=
e vma
> [...]
> mlock(addr, len) # Now I want the full mlock semantic

So this leaves us without the LOCKONFAULT semantics?  That is not at all
what I am looking for.  What I want is a way to express 3 possible
states of a VMA WRT locking, locked (populated and all pages on the
unevictable LRU), lock on fault (populated by page fault, pages that are
present are on the unevictable LRU, newly faulted pages are added to
same), and not locked.

>=20
> and the later to have the full mlock semantic and populate the given
> area regardless of VM_FAULTPOPULATE being set on the vma? This would
> be an interesting question because mlock man page clearly states the
> semantic and that is to _always_ populate or fail. So I originally
> thought that it would obey VM_FAULTPOPULATE but this needs a more
> thinking.
>=20
> > This might lead to some
> > interesting states with mlock() and munlock() that take flags.  For
> > instance, using VM_LOCKONFAULT mlock(MLOCK_ONFAULT) followed by
> > munlock(MLOCK_LOCKED) leaves the VMAs in the same state with
> > VM_LOCKONFAULT set.=20
>=20
> This is really confusing. Let me try to rephrase that. So you have
> mlock(addr, len, MLOCK_ONFAULT)
> munlock(addr, len, MLOCK_LOCKED)
>=20
> IIUC you would expect the vma still being MLOCK_ONFAULT, right? Isn't
> that behavior strange and unexpected? First of all, munlock has
> traditionally dropped the lock on the address range (e.g. what should
> happen if you did plain old munlock(addr, len)). But even without
> that. You are trying to unlock something that hasn't been locked the
> same way. So I would expect -EINVAL at least, if the two modes should be
> really represented by different flags.

I would expect it to remain MLOCK_LOCKONFAULT because the user requested
munlock(addr, len, MLOCK_LOCKED).  It is not currently an error to
unlock memory that is not locked.  We do this because we do not require
the user track what areas are locked.  It is acceptable to have a mostly
locked area with holes unlocked with a single call to munlock that spans
the entire area.  The same semantics should hold for munlock with flags.
If I have an area with MLOCK_LOCKED and MLOCK_ONFAULT interleaved, it
should be acceptable to clear the MLOCK_ONFAULT flag from those areas
with a single munlock call that spans the area.

On top of continuing with munlock semantics, the implementation would
need the ability to rollback an munlock call if it failed after altering
VMAs.  If we have the same interleaved area as before and we go to
return -EINVAL the first time we hit an area that was MLOCK_LOCKED, how
do we restore the state of the VMAs we have already processed, and
possibly merged/split?
>=20
> Or did you mean the both types of lock like:
> mlock(addr, len, MLOCK_ONFAULT) | mmap(MAP_LOCKONFAULT)
> mlock(addr, len, MLOCK_LOCKED)
> munlock(addr, len, MLOCK_LOCKED)
>=20
> and that should keep MLOCK_ONFAULT?
> This sounds even more weird to me because that means that the vma in
> question would be locked by two different mechanisms. MLOCK_LOCKED with
> the "always populate" semantic would rule out MLOCK_ONFAULT so what
> would be the meaning of the other flag then? Also what should regular
> munlock(addr, len) without flags unlock? Both?

This is indeed confusing and not what I was trying to illustrate, but
since you bring it up.  mlockall() currently clears all flags and then
sets the new flags with each subsequent call.  mlock2 would use that
same behavior, if LOCKED was specified for a ONFAULT region, that region
would become LOCKED and vice versa.

I have the new system call set ready, I am waiting to post for rc1 so I
can run the benchmarks again on a base more stable than the middle of a
merge window.  We should wait to hash out implementations until the code
is up rather than talk past eachother here.

>=20
> > If we use VM_FAULTPOPULATE, the same pair of calls
> > would clear VM_LOCKED, but leave VM_FAULTPOPULATE.  It may not matter in
> > the end, but I am concerned about the subtleties here.
>=20
> This sounds like the proper behavior to me. munlock should simply always
> drop VM_LOCKED and the VM_FAULTPOPULATE can live its separate life.
>=20
> Btw. could you be more specific about semantic of m{un}lock(addr, len, fl=
ags)
> you want to propose? The more I think about that the more I am unclear
> about it, especially munlock behavior and possible flags.
> --=20
> Michal Hocko
> SUSE Labs

--APlYHCtpeOhspHkB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVjBRXAAoJELbVsDOpoOa9KZ0P/jLKjirBJ2okZdWKtpp6678q
uc0FyNGrZ+4/mRSy1NXL/QoHENiPkf/6/xNLD37kf19QXFrAPq9xIyudiHJNoYrI
VieISrU48NF2l5AX/23xmAHMuQsOEllnxD2Z8tbzYBWYwhVsyekXxFcfV9IjBIJW
o+tao1pK9hxtUKe6iZ2iYeIQ7WBPIyodKAkGlRU+e4eC5FTvJhzAWzE3SptRnBO1
j7u1bd5Y2GuLDSdSRFbwH1g3yfjW4NhGAGVxytlMiDAEASNxO1qtxQqkAIrMIlnO
VyMyfiWiZGlR9jlnO0jQxDgTNn+q9Hd2YAycKfq0ESAmo5lf0mqYCt22PvYbTbH6
hlAu3LOZs5Y7HCaCcuKYeIIyjcapAxpqkthY+BgbORKwyK7u2lK8B9NnGj4NZEZW
C3Wchy60VlT8Veru3qvzfyBZkMH+mlvZ6BKNKWgC3kgX4nnQ5DiEVYkEFoegzSJB
78wQ2dwvZXjG+ruK4SKNnN3FFxUFFoM8zMPTVwi+ox2LjN981xmFe/W7eG2kai9J
Ji7645+7JvHnszsfAO+dYeoDgVpVQBJ1lqc7F9W5iw8AA4NoNNEbg62K/YsoF1ox
uHM6I5sIzZE9AG5Rkxtw0j9cu9p9OyCWoXE1XHn7zHGsJPUSM9BWMvLKncr1PDeU
H0enY59wKDqXZvkTmSg1
=GTBQ
-----END PGP SIGNATURE-----

--APlYHCtpeOhspHkB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
