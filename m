Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 15E0D6B0255
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 09:49:45 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so95633244ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 06:49:44 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id h6si15391237ywc.97.2015.07.28.06.49.43
        for <linux-mm@kvack.org>;
        Tue, 28 Jul 2015 06:49:44 -0700 (PDT)
Date: Tue, 28 Jul 2015 09:49:42 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
Message-ID: <20150728134942.GB2407@akamai.com>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz>
 <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz>
 <20150727145409.GB21664@akamai.com>
 <20150728111725.GG24972@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="61jdw2sOBCFtR2d/"
Content-Disposition: inline
In-Reply-To: <20150728111725.GG24972@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--61jdw2sOBCFtR2d/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 28 Jul 2015, Michal Hocko wrote:

> [I am sorry but I didn't get to this sooner.]
>=20
> On Mon 27-07-15 10:54:09, Eric B Munson wrote:
> > Now that VM_LOCKONFAULT is a modifier to VM_LOCKED and
> > cannot be specified independentally, it might make more sense to mirror
> > that relationship to userspace.  Which would lead to soemthing like the
> > following:
>=20
> A modifier makes more sense.
> =20
> > To lock and populate a region:
> > mlock2(start, len, 0);
> >=20
> > To lock on fault a region:
> > mlock2(start, len, MLOCK_ONFAULT);
> >=20
> > If LOCKONFAULT is seen as a modifier to mlock, then having the flags
> > argument as 0 mean do mlock classic makes more sense to me.
> >=20
> > To mlock current on fault only:
> > mlockall(MCL_CURRENT | MCL_ONFAULT);
> >=20
> > To mlock future on fault only:
> > mlockall(MCL_FUTURE | MCL_ONFAULT);
> >=20
> > To lock everything on fault:
> > mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
>=20
> Makes sense to me. The only remaining and still tricky part would be
> the munlock{all}(flags) behavior. What should munlock(MLOCK_ONFAULT)
> do? Keep locked and poppulate the range or simply ignore the flag an
> just unlock?
>=20
> I can see some sense to allow munlockall(MCL_FUTURE[|MLOCK_ONFAULT]),
> munlockall(MCL_CURRENT) resp. munlockall(MCL_CURRENT|MCL_FUTURE) but
> other combinations sound weird to me.
>=20
> Anyway munlock with flags opens new doors of trickiness.

In the current revision there are no new munlock[all] system calls
introduced.  munlockall() unconditionally cleared both MCL_CURRENT and
MCL_FUTURE before the set and now unconditionally clears all three.
munlock() does the same for VM_LOCK and VM_LOCKONFAULT.  If the user
wants to adjust mlockall flags today, they need to call mlockall a
second time with the new flags, this remains true for mlockall after
this set and the same behavior is mirrored in mlock2.  The only
remaining question I have is should we have 2 new mlockall flags so that
the caller can explicitly set VM_LOCKONFAULT in the mm->def_flags vs
locking all current VMAs on fault.  I ask because if the user wants to
lock all current VMAs the old way, but all future VMAs on fault they
have to call mlockall() twice:

	mlockall(MCL_CURRENT);
	mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);

This has the side effect of converting all the current VMAs to
VM_LOCKONFAULT, but because they were all made present and locked in the
first call, this should not matter in most cases.  The catch is that,
like mmap(MAP_LOCKED), mlockall() does not communicate if mm_populate()
fails.  This has been true of mlockall() from the beginning so I don't
know if it needs more than an entry in the man page to clarify (which I
will add when I add documentation for MCL_ONFAULT).  In a much less
likely corner case, it is not possible in the current setup to request
all current VMAs be VM_LOCKONFAULT and all future be VM_LOCKED.


--61jdw2sOBCFtR2d/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVt4h2AAoJELbVsDOpoOa9oHIQAIcQd4UyZvk7S3Gk5qbrOB18
DBwAWsh9b5MmgjqQJ6VY9tveNG54UTtmGIt5ToxjkoJdN+y7i0Bcen7t5sh0ZJpY
cm7qGFkP9Mz+zp0cnwNi6SxjhmNdPZbFgcq7JPD4eXG73Guha/ov1yKGUCaE9I8z
NhWJEDf2QaXAeTYZMAp3QsZUE2A2vGtpVvgqXfVsoFiTXdO59wFfj7ZWs7Tvd8tA
7gFjWP2gUd3F5CxKVx7W7CujDyjqPYqjGe6GRq4RXvjgKlnzn19Dz71XM40WlQfy
mK1jm7TyXcFLT7oxcCJfzdiy72ViZ3n+lv6QbshOBkrmbTKk+WkPcmoY84Gg05mz
GyR0BeJ02Q/QWMPlCHTq8E+iBgRYrGXQxC7/0zjXizRCUxMoNtMbzYmEo63jHIUS
BpiaDFIS4b48qznxLcKn1zeG6I1tiRgVcYVLWOieVBFgKG5g0ae7Gsy5FhTHwohn
TFbs8PMRs+bZcLrY8dFFsS7/l7EBx/KZmA2Zcpj+Lcdr/LdwokV8rDN/R23spu1a
NVMoBoBXxXuDqA1pUTVCoBimDF2U5GArsy0yjHnVWzjZNqQSh1+eTEEZp+lu6eeC
briVmyabn8fCItemDJrAK/6RdvzbqHHri7Ny2d3GSyMPO36aM/lVN1wlF1qMZ3GA
9sHKsbhENoi90n42sc8Q
=YK5t
-----END PGP SIGNATURE-----

--61jdw2sOBCFtR2d/--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
