Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id EAE54900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 10:12:06 -0400 (EDT)
Received: by pdbfp1 with SMTP id fp1so2042858pdb.2
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 07:12:06 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id xu6si1132544pab.113.2015.03.10.07.12.04
        for <linux-mm@kvack.org>;
        Tue, 10 Mar 2015 07:12:04 -0700 (PDT)
Date: Tue, 10 Mar 2015 10:12:03 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V3] Allow compaction of unevictable pages
Message-ID: <20150310141203.GA2310@akamai.com>
References: <1425934123-30591-1-git-send-email-emunson@akamai.com>
 <20150310112220.GW2896@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sm4nu43k4a2Rpi4c"
Content-Disposition: inline
In-Reply-To: <20150310112220.GW2896@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 10 Mar 2015, Peter Zijlstra wrote:

> On Mon, Mar 09, 2015 at 04:48:43PM -0400, Eric B Munson wrote:
> > Currently, pages which are marked as unevictable are protected from
> > compaction, but not from other types of migration.  The mlock
> > desctription does not promise that all page faults will be avoided, only
> > major ones so this protection is not necessary.  This extra protection
> > can cause problems for applications that are using mlock to avoid
> > swapping pages out, but require order > 0 allocations to continue to
> > succeed in a fragmented environment.  This patch removes the
> > ISOLATE_UNEVICTABLE mode and the check for it in __isolate_lru_page().
> > Removing this check allows the removal of the isolate_mode argument from
> > isolate_migratepages_block() because it can compute the required mode
> > from the compact_control structure.
> >=20
> > To illustrate this problem I wrote a quick test program that mmaps a
> > large number of 1MB files filled with random data.  These maps are
> > created locked and read only.  Then every other mmap is unmapped and I
> > attempt to allocate huge pages to the static huge page pool.  Without
> > this patch I am unable to allocate any huge pages after  fragmenting
> > memory.  With it, I can allocate almost all the space freed by unmapping
> > as huge pages.
>=20
> So mlock() is part of the POSIX real-time spec. For real-time purposes
> we very much do _NOT_ want page migration to happen.
>=20
> So while you might be following the letter of the spec you're very much
> violating the spirit of the thing.
>=20

Fair enough, but the documentation in the mlock manpage only explicitly
promises to prevent major faults.  If this patch is not taken, then the
manpage for mlock needs to have a note added explaining that mlock
prevents compaction as well.  The confusion our userspace devs had stems
=66rom this as they though they could use mlock to avoid swapping, but
still benefit from compaction in order > 0 allocations.

> Also, there is another solution to your problem; you can compact
> mlock'ed pages at mlock() time.

This might work for some cases, I'd have to spend some time thinking on
it, but it won't work in my case.  Memory is fragmented by unmapping
as data is no longer needed.  So we really do need to compact the
locked pages that are left.

>=20
> Furthermore, I would once again like to remind people of my VM_PINNED
> patches. The only thing that needs happening there is someone needs to
> deobfuscate the IB code.

Hence my attempt to kick that discussion last week.  Unfortunately, I
cannot provide any help with the IB code.  Having this mechanism would
give us a way to continue to allow real-time users to avoid all faults
while giving anyone that wants to avoid only major faults a way to do
so.


--sm4nu43k4a2Rpi4c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJU/vuzAAoJELbVsDOpoOa9DywP/RgDdb8ekqFRhlf9Mzb0UgYX
Amkmliyzx5FZHLvfFgT5bMV64GGMeuUJrjuG3VQD5iVp9VF1MMVqcjgXpeyXtTGn
3cKQ2OAMh2QSMdi2diUJ98AmSwB0VA71dlrKDLqKPeJvshbvzAGHLCuqNCjQ3gXR
ttXPGfoNGQVoYqyFNnKuL9brH75fgAzdxUP/RfWUO2P6MxlGAM8dzsQWFUnn5mne
Q+4Et/d5qnu8sFva0hcktBhZnuVEw2ock/KTMmlynPdxu61lVhgJZfF2+kUVdJj+
F3J7rw+T/hiawBsdzNRXokMLHuDFqQFITfGXQIv0bPS8XyuCUAchMrvTG+zlOUqb
6+OoFDqih2qCEuRjBrJ/6xzIpzE3p+dajrxtvkPxRNWNqpA0gowlwTpmyqC5nrEm
887B7+fuwVqWK2YOxM+g9nysBAM0x9x0Biy0NL/pkQ90IdA8SBt354NYbVYnkieT
AZ6KsB+Y4kvsl5AYFiQzOHYv6MY/7y6MI2YgvEjeWa+YyUpQm6+92ZQMuHcj3SNm
Dv5n+y5BWMErZH2AHHWXbj9UiJd5RvYR2KDEJWCu9ap25kIe4fesMvAzN+E+Dmr1
k77I8at5IqN0mENShjhrPYR6jcAFjH7DZ0vt62FmBuM2RTPAYJ1Y0yGULLsYLYEt
T2kNGMWLmW6UAolxM+YQ
=gdYR
-----END PGP SIGNATURE-----

--sm4nu43k4a2Rpi4c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
