Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id B478E6B0085
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 18:02:36 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id h15so14415481igd.4
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:02:36 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id s15si286461icm.50.2015.02.03.15.02.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 15:02:36 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id ar1so29071604iec.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 15:02:36 -0800 (PST)
Message-ID: <54D15384.7040605@gmail.com>
Date: Tue, 03 Feb 2015 18:02:28 -0500
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC] mremap: add MREMAP_NOHOLE flag
References: <7064772f72049de8a79383105f49b5db84a946e5.1422990665.git.shli@fb.com>
In-Reply-To: <7064772f72049de8a79383105f49b5db84a946e5.1422990665.git.shli@fb.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="k85NfgOQgr8iQSxbjC7EfsRiMoVCtSq86"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>, linux-mm@kvack.org
Cc: Kernel-team@fb.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--k85NfgOQgr8iQSxbjC7EfsRiMoVCtSq86
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

I think this would be very useful in some compacting garbage collectors
even in non-reallocation case too. A heap of large objects could be
compacted by transitioning between two huge regions of address space by
moving the pages with mremap. It's simple enough to cope with an
unaligned head/tail using memcpy if allocations aren't page aligned.

Of course, garbage collectors would also benefit from the ability to
make use of mremap for reallocations just as allocators like jemalloc
and tcmalloc would.

If you're unable to build enough interest in it based on the use case
for it inside allocators like jemalloc/tcmalloc, then I would suggest
poking the developers of the GCs in v8, etc. about it to see if they
have any use case for this.

It may be worth considering a new restricted system call instead of
extending mremap. Since the primary use case is about moving pages from
one region to another existing region, I see the potential for it to be
done without an exclusive mmap_sem lock just like MADV_{DONTNEED,FREE}
and page faulting. This would give up the ability to grow in-place but
that only happens if virtual memory is being fragmented anyway. The
destination and source would also need to match.


--k85NfgOQgr8iQSxbjC7EfsRiMoVCtSq86
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU0VOJAAoJEPnnEuWa9fIqZfwP/Ri7Y3POQXwlTm7uEOwRqpJy
nHqH+fuasJvI9uOOELpe/NCXrLLI8H7LXTxoWeXAxbB8eKm+zDDeiHEB2uYOhBp2
AP2Jz0JmnqMNzJLPxAhSW+5eC8GLi1A6pt/dJdtSX4stn12pd9HezLRu0dkmiA37
MWJTA9vi5cd6tqNOcB+2J3bs9zvT8c6jX1BEKa0i2KOv6k5amZwE+RMS7xHjLEuc
GcZxySJqF1J2+4ATi/x+kLsYt/pX5o6zbc8jTPaI7NWfAnSzmrAuAEC0lPIqhSfj
yqWc80XXBwHKliUspAOY9qtqY+4T5gvHqp9zOkLnWCasmAWKElvZgyxEjMYL7EPG
RcVrdtLQP9ONBsRzSTKtavJEImg8mQDfYAVErQar/XM/3wEKH0JSxpUZsXnMvyIy
RBI1yXObS+fUU8qP0EZ5lsYdnfyMjuZxug2d1BuNCtWKpX3iLar52sNTM3sYUj9Q
GEAjKdQUBcAumjQgbBAkSZ787jELbyav12VMjifoW3kLYuISDtHQXvnMESPVSMTp
Gdj8WJ/IVbAwV0d0wxyZ66NTV0HvcSxw8EAQI4zFZZWdZbl2c9FcmYuxtT0fICcR
CIc+Mu0kdfX9wviqoFacGzNGh2FyEP7wP0jKXA+TxbB+evckThnBE6BDnVquE7v5
yykgd3nvXQukbzdXApK4
=s62R
-----END PGP SIGNATURE-----

--k85NfgOQgr8iQSxbjC7EfsRiMoVCtSq86--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
