Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8ED6B0068
	for <linux-mm@kvack.org>; Tue, 27 May 2014 06:55:01 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so1424900wib.11
        for <linux-mm@kvack.org>; Tue, 27 May 2014 03:55:00 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id lq1si23884717wjb.39.2014.05.27.03.54.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 May 2014 03:54:53 -0700 (PDT)
Date: Tue, 27 May 2014 12:54:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
Message-ID: <20140527105438.GW13658@twins.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
 <20140526203232.GC5444@laptop.programming.kicks-ass.net>
 <CALYGNiO8FNKjtETQMRSqgiArjfQ9nRAALUg9GGdNYbpKru=Sjw@mail.gmail.com>
 <20140527102909.GO30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JHjDRUnf1JOMxzko"
Content-Disposition: inline
In-Reply-To: <20140527102909.GO30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>


--JHjDRUnf1JOMxzko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 27, 2014 at 12:29:09PM +0200, Peter Zijlstra wrote:
> On Tue, May 27, 2014 at 12:49:08AM +0400, Konstantin Khlebnikov wrote:
> > Another suggestion. VM_RESERVED is stronger than VM_LOCKED and extends
> > its functionality.
> > Maybe it's easier to add VM_DONTMIGRATE and use it together with VM_LOC=
KED.
> > This will make accounting easier. No?
>=20
> I prefer the PINNED name because the not being able to migrate is only
> one of the desired effects of it, not the primary effect. We're really
> looking to keep physical pages in place and preserve mappings.
>=20
> The -rt people for example really want to avoid faults (even minor
> faults), and DONTMIGRATE would still allow unmapping.
>=20
> Maybe always setting VM_PINNED and VM_LOCKED together is easier, I
> hadn't considered that. The first thing that came to mind is that that
> might make the fork() semantics difficult, but maybe it works out.
>=20
> And while we're on the subject, my patch preserves PINNED over fork()
> but maybe we don't actually need that either.

So pinned_vm is userspace exposed, which means we have to maintain the
individual counts, and doing the fully orthogonal accounting is 'easier'
than trying to get the boundary cases right.

That is, if we have a program that does mlockall() and then does the IB
ioctl() to 'pin' a region, we'd have to make mm_mpin() do munlock()
after it splits the vma, and then do the pinned accounting.

Also, we'll have lost the LOCKED state and unless MCL_FUTURE was used,
we don't know what to restore the vma to on mm_munpin().

So while the accounting looks tricky, it has simpler semantics.

--JHjDRUnf1JOMxzko
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJThG7uAAoJEHZH4aRLwOS6eAIQALZlA3uluTkf8/ciEiNoNzcm
O+a5nh6AC26jmjZ2Y732YdRo4hC00pK2TTj2uQ32sNteklK4VMB8ZrYwOArfV6mF
zrj2zU1RlLkU1CkyIdF3UOhzzOf9F3TuEGVk3AuWVv33ybrdwQXLKKHzveczespg
WWSEvRsSGcqQUGefmS9czAJVArk/AV0Rg+3BYucPYn036yJ2+a6Kw+rTtObASSxN
+UV7lTzBIg7HgxRweS6jZ18Q/FKG4fGE+RHXPBpT2sFdrVMq4A+QeFTGZ9WPDcvP
spaNc+fr012RcVHWwLylGTkj/r9NwAv43K1TnsI5zTWMUrzDh8SGgsHsAWu6C8IK
lpax0WSdfWn2MnAXhuEzGLoLuyTUwSXsudASaqaDdSmBMu1Ur/NZmlw3qGci5SUw
0ORPj4/vPRFHaNI9Gg22fwtOTHqTOey710J2FpRtdEYxFpeAGFIfHTucj4Zal9Gu
SraZSECzMaadd1Sz6EXjiMGgau26q62aikcOYpDFvtKxe6RGEdIS6oYuQeDNPADp
+bz08PDsdm+IJDKKctOnmKQoICljHFqKmZCLSz/HY/ybTf+G6BB0qgPnTRofIFtC
6Ry7OZHTzaaJ0kfVhTxx45US63Vtoj69lQdTUnXnJDTuu3mu2VW6Dxyt51YikldN
OQ+5smSQteJyV4P7hOZ/
=I0k+
-----END PGP SIGNATURE-----

--JHjDRUnf1JOMxzko--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
