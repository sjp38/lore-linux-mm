Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE766B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:43:58 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so74490660pdb.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 07:43:58 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id mx8si18168176pdb.255.2015.06.15.07.43.56
        for <linux-mm@kvack.org>;
        Mon, 15 Jun 2015 07:43:57 -0700 (PDT)
Date: Mon, 15 Jun 2015 10:43:56 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH V2 0/3] Allow user to request memory to be locked
 on page fault
Message-ID: <20150615144356.GB12300@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>
 <5579DFBA.80809@akamai.com>
 <20150611123424.4bb07cffd0e5bb146cc92231@linux-foundation.org>
 <557ACAFC.90608@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tsOsTdHNUZQcU9Ye"
Content-Disposition: inline
In-Reply-To: <557ACAFC.90608@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--tsOsTdHNUZQcU9Ye
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 12 Jun 2015, Vlastimil Babka wrote:

> On 06/11/2015 09:34 PM, Andrew Morton wrote:
> >On Thu, 11 Jun 2015 15:21:30 -0400 Eric B Munson <emunson@akamai.com> wr=
ote:
> >
> >>>Ditto mlockall(MCL_ONFAULT) followed by munlock().  I'm not sure
> >>>that even makes sense but the behaviour should be understood and
> >>>tested.
> >>
> >>I have extended the kselftest for lock-on-fault to try both of these
> >>scenarios and they work as expected.  The VMA is split and the VM
> >>flags are set appropriately for the resulting VMAs.
> >
> >munlock() should do vma merging as well.  I *think* we implemented
> >that.  More tests for you to add ;)
> >
> >How are you testing the vma merging and splitting, btw?  Parsing
> >the profcs files?
> >
> >>>What's missing here is a syscall to set VM_LOCKONFAULT on an
> >>>arbitrary range of memory - mlock() for lock-on-fault.  It's a
> >>>shame that mlock() didn't take a `mode' argument.  Perhaps we
> >>>should add such a syscall - that would make the mmap flag unneeded
> >>>but I suppose it should be kept for symmetry.
> >>
> >>Do you want such a system call as part of this set?  I would need some
> >>time to make sure I had thought through all the possible corners one
> >>could get into with such a call, so it would delay a V3 quite a bit.
> >>Otherwise I can send a V3 out immediately.
> >
> >I think the way to look at this is to pretend that mm/mlock.c doesn't
> >exist and ask "how should we design these features".
> >
> >And that would be:
> >
> >- mmap() takes a `flags' argument: MAP_LOCKED|MAP_LOCKONFAULT.
>=20
> Note that the semantic of MAP_LOCKED can be subtly surprising:
>=20
> "mlock(2) fails if the memory range cannot get populated to guarantee
> that no future major faults will happen on the range.
> mmap(MAP_LOCKED) on the other hand silently succeeds even if the
> range was populated only
> partially."
>=20
> ( from http://marc.info/?l=3Dlinux-mm&m=3D143152790412727&w=3D2 )
>=20
> So MAP_LOCKED can silently behave like MAP_LOCKONFAULT. While
> MAP_LOCKONFAULT doesn't suffer from such problem, I wonder if that's
> sufficient reason not to extend mmap by new mlock() flags that can
> be instead applied to the VMA after mmapping, using the proposed
> mlock2() with flags. So I think instead we could deprecate
> MAP_LOCKED more prominently. I doubt the overhead of calling the
> extra syscall matters here?

We could talk about retiring the MAP_LOCKED flag but I suspect that
would get significantly more pushback than adding a new mmap flag.

Likely that the overhead does not matter in most cases, but presumably
there are cases where it does (as we have a MAP_LOCKED flag today).
Even with the proposed new system calls I think we should have the
MAP_LOCKONFAULT for parity with MAP_LOCKED.

>=20
> >- mlock() takes a `flags' argument.  Presently that's
> >   MLOCK_LOCKED|MLOCK_LOCKONFAULT.
> >
> >- munlock() takes a `flags' arument.  MLOCK_LOCKED|MLOCK_LOCKONFAULT
> >   to specify which flags are being cleared.
> >
> >- mlockall() and munlockall() ditto.
> >
> >
> >IOW, LOCKED and LOCKEDONFAULT are treated identically and independently.
> >
> >Now, that's how we would have designed all this on day one.  And I
> >think we can do this now, by adding new mlock2() and munlock2()
> >syscalls.  And we may as well deprecate the old mlock() and munlock(),
> >not that this matters much.
> >
> >*should* we do this?  I'm thinking "yes" - it's all pretty simple
> >boilerplate and wrappers and such, and it gets the interface correct,
> >and extensible.
>=20
> If the new LOCKONFAULT functionality is indeed desired (I haven't
> still decided myself) then I agree that would be the cleanest way.

Do you disagree with the use cases I have listed or do you think there
is a better way of addressing those cases?

>=20
> >What do others think?

--tsOsTdHNUZQcU9Ye
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVfuSrAAoJELbVsDOpoOa9SqoP/32pn+LLrjk0r2GNhFZF26Ig
182hz7lG8As2Y7a1N+mtpfGq0JmrMbaytwEcmI1BpgI64DNcNOUINEqqaWXNeEBX
idyVOQ1jeGGxDGyHLDNGfC6zlWxKGYPiKaaifSb37+hIQhOxsmXQ8U1E3GVdnRXK
g8uPlztYSH5WN7LluiIEPXN1IPs57ADkoupTmSKzU2C9nnEUVYt9AmOm2Gt49Gmu
F5f8rMGwvoC7WJGI83Xha60W7Fcv4hRoZeud/dspTKJmPrPERQ7kvqgwfTPoDWN+
IvuzwjPSSCKNZie3HzEG7ae3KASKfh2Yat1zqrKZvI1/q+OSNsn/X8VjPcORIgDz
OhzUEkL/4tTv+1a007eoPQEYUNxdgY+ZghOX7iw7OBT5gApUPc4kzwcnjTmK0l8A
FJj6sn627osTIVoVL8ScRRWhY3BgscRhwFW2tBpRUc8GacMYyevfNEpOvX8oh2bv
zdfo70SgsjTVseJb7WOB3TSjoXBgPV/xU0cBnMQZhLnUzdXHjWwm4lYqwRiPJZpO
nAn32DLqbBe4GG+PtThn8Es/uddWOrypGtEaYu7ToYz6qqrLtVeMS5UTmaAijnZK
xwEU889kELmPEg5C4rrfv+ttLUnCMkwLWxD4/fSIaPYLiz3yVIGzlTfUnyEUt8/H
ZxlwoAMcTlbg88oH6jKj
=u99f
-----END PGP SIGNATURE-----

--tsOsTdHNUZQcU9Ye--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
