Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id C548B6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:54:20 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so68737278igb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:54:20 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id g1si8940020igg.43.2015.03.24.07.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 07:54:20 -0700 (PDT)
Received: by igbud6 with SMTP id ud6so74046376igb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:54:20 -0700 (PDT)
Message-ID: <55117A93.9040207@gmail.com>
Date: Tue, 24 Mar 2015 10:54:11 -0400
From: Daniel Micay <danielmicay@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mremap: add MREMAP_NOHOLE flag --resend
References: <deaa4139de6e6422a0cec1e3282553aed3495e94.1426626497.git.shli@fb.com>	<20150318153100.5658b741277f3717b52e42d9@linux-foundation.org>	<550A5FF8.90504@gmail.com>	<CADpJO7zBLhjecbiQeTubnTReiicVLr0-K43KbB4uCL5w_dyqJg@mail.gmail.com>	<550E6D9D.1060507@gmail.com> <CADpJO7wP+dvXyxP7SW7F12jra_cWrEba7orRXMJGytvgOJfHkA@mail.gmail.com>
In-Reply-To: <CADpJO7wP+dvXyxP7SW7F12jra_cWrEba7orRXMJGytvgOJfHkA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="3GRRfwHH9NECM73LwlMjdmM2qrHCsTo5c"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksey Kandratsenka <alkondratenko@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-api@vger.kernel.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andy Lutomirski <luto@amacapital.net>, "google-perftools@googlegroups.com" <google-perftools@googlegroups.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3GRRfwHH9NECM73LwlMjdmM2qrHCsTo5c
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> Given that mremap is holding mmap_sem exclusively, how about userspace
> malloc implementation taking some exclusive malloc lock and doing
> normal mremap followed by mmap with MAP_FIXED to fill the hole ? It
> might end up having largely same overhead. Well, modulo some extra TLB
> flushing. But arguably, reducing TLB flushes for sequence of page
> table updates could be usefully addressed separately (e.g. maybe by
> matching those syscalls, maybe via syslets).

You can't use MAP_FIXED because it has a race with other users of mmap.

The address hint will *usually* work, but you need to deal with the case
where it fails and then cope with the fallout of the fragmentation.

PaX ASLR ignores address hints so that's something else to consider if
you care about running on PaX/Grsecurity patched kernels.

I'm doing this in my own allocator that's heavily based on the jemalloc
design. It just unmaps the memory given by the hinted mmap call if it
fails to get back the hole:

https://github.com/thestinger/allocator/blob/e80d2d0c2863c490b650ecffeb33=
beaccfcfdc46/huge.c#L167-L180

On 64-bit, it relies on 1TiB of reserved address space (works even with
overcommit disabled) to do per-CPU allocation for chunks and huge (>=3D
chunk size) allocations via address range checks so it also needs this
ugly workaround too:

https://github.com/thestinger/allocator/blob/e80d2d0c2863c490b650ecffeb33=
beaccfcfdc46/huge.c#L67-L75

I'm convinced that the mmap_sem writer lock can be avoided for the case
with MREMAP_FIXED via a good heuristic though. It just needs to check
that dst is a single VMA that matches the src properties and fall back
to the writer lock if that's not the case. This will have the same
performance as a separate syscall to move pages in all the cases where
that syscall would work.


--3GRRfwHH9NECM73LwlMjdmM2qrHCsTo5c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVEXqTAAoJEPnnEuWa9fIq464P/0tVgIf0xD72jTN8w8+rtcok
ZwEmk66BC6OnjYY4vu9CMfUVySHPKZ+Q1Ve2UEIGT2leZZMkx1BukSuw5QBz9COx
ktihFkSuk/4hMfJVkEF7Azyx/Sg/Z+cipzDmSGwaYEIAKbz4+L6RYOqs81KzDDfF
TT0NbbhbyE1Hr0P5Wmi2PcROXcJRLwOeaDEOyrWl01RECdnvJFoVu1TCY82+gPfK
voWwE3oSzGzKBl7Yfj9vfG3IPbk0ENcahqG2sPyX235HuvcaU+plUPFq1+IL9vSw
2rEndWJKJKNCa8oC1bBwCALI1d2lVgE1jRDYPrEuMUeuvwglr57hOb+K7TpoZU4j
K0owFefk2bEXpYx3Cj+Y5cELu5A3DTwVDouF62yMR7mcAMX5Wq/Lo04s++vFfXmB
+tT3gAsV7n2l1KcgMrjDNY58q5YoFNa7CMaeCFnzHv0qTSJ75Chu/crh963a8UOx
XxdI8UXmWbI+vb1l3HQjn3IVhJusSnABaAIUBmYLLmcx9vNa7PpOEvCOJGsIlGsR
Fo1Co6pvfRiESmBrnULvosXSvnNGye5wcmCoGbZ6NJQyACZpknezWEXgwEgfq4S6
lftkZTUTiuWKiLWUY1FhFVJXreRPvZpnv/fTMAiEKwmiRatNC0ccG62IHhpOnhPl
2aZiU/gr4RfsJGH80pX8
=5wx2
-----END PGP SIGNATURE-----

--3GRRfwHH9NECM73LwlMjdmM2qrHCsTo5c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
