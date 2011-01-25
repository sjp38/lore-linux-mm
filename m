Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 38E976B00E9
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 14:44:24 -0500 (EST)
Received: by yia25 with SMTP id 25so2063785yia.14
        for <linux-mm@kvack.org>; Tue, 25 Jan 2011 11:44:22 -0800 (PST)
Date: Tue, 25 Jan 2011 12:44:16 -0700
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 2/2] hugepage: Allow parallelization of the hugepage
 fault path
Message-ID: <20110125194416.GB3041@mgebm.net>
References: <20110125143226.37532ea2@kryten>
 <20110125143414.1dbb150c@kryten>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xXmbgvnjoT4axfJE"
Content-Disposition: inline
In-Reply-To: <20110125143414.1dbb150c@kryten>
Sender: owner-linux-mm@kvack.org
To: Anton Blanchard <anton@samba.org>
Cc: dwg@au1.ibm.com, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--xXmbgvnjoT4axfJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 25 Jan 2011, Anton Blanchard wrote:

> From: David Gibson <dwg@au1.ibm.com>
>=20
> At present, the page fault path for hugepages is serialized by a
> single mutex.  This is used to avoid spurious out-of-memory conditions
> when the hugepage pool is fully utilized (two processes or threads can
> race to instantiate the same mapping with the last hugepage from the
> pool, the race loser returning VM_FAULT_OOM).  This problem is
> specific to hugepages, because it is normal to want to use every
> single hugepage in the system - with normal pages we simply assume
> there will always be a few spare pages which can be used temporarily
> until the race is resolved.
>=20
> Unfortunately this serialization also means that clearing of hugepages
> cannot be parallelized across multiple CPUs, which can lead to very
> long process startup times when using large numbers of hugepages.
>=20
> This patch improves the situation by replacing the single mutex with a
> table of mutexes, selected based on a hash of the address_space and
> file offset being faulted (or mm and virtual address for MAP_PRIVATE
> mappings).
>=20
>=20
> From: Anton Blanchard <anton@samba.org>
>=20
> Forward ported and made a few changes:
>=20
> - Use the Jenkins hash to scatter the hash, better than using just the
>   low bits.
>=20
> - Always round num_fault_mutexes to a power of two to avoid an expensive
>   modulus in the hash calculation.
>=20
> I also tested this patch on a 64 thread POWER6 box using a simple parallel
> fault testcase:
>=20
> http://ozlabs.org/~anton/junkcode/parallel_fault.c
>=20
> Command line options:
>=20
> parallel_fault <nr_threads> <size in kB> <skip in kB>
>=20
> First the time taken to fault 48GB of 16MB hugepages:
> # time hugectl --heap ./parallel_fault 1 50331648 16384
> 11.1 seconds
>=20
> Now the same test with 64 concurrent threads:
> # time hugectl --heap ./parallel_fault 64 50331648 16384
> 8.8 seconds
>=20
> Hardly any speedup. Finally the 64 concurrent threads test with this patch
> applied:
> # time hugectl --heap ./parallel_fault 64 50331648 16384
> 0.7 seconds
>=20
> We go from 8.8 seconds to 0.7 seconds, an improvement of 12.6x.
>=20
> Signed-off-by: David Gibson <dwg@au1.ibm.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>

Reviewed-by: Eric B Munson <emunson@mgebm.net>

--xXmbgvnjoT4axfJE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNPygQAAoJEH65iIruGRnN7fsIAIJn2iw33q3fUhB7q8/HqYU+
CXhR4Fi+rQos+cNqUbb/1z+3YVUKuM/GlJsHfXpIEWJK36F3QCYjY2DKSpriHIL0
IUfobPcJj6ReLbTPgOR9tBL/zf0mAjbv8RMz5NpBz5yW/y65b211NXKYkUG0Ufqd
3DWY/eyXV0XCVDZQkeyOz/5ePcNv6lfFN41n/RrAMgm63+ZlMQk4uvlubQSGMJnf
LPrTENLF+mpZIDkwlxkQIzj/Rhn7ZKVuQdsY+WKfG+yEYEO0Zc1pjSPkhbjohvtI
8GApsyZrHOPpkdNSpcO6KpPpZ4lNdoaa0kGHmfL0wv+jrkiihWpk5/uqwUEjeDY=
=m5U+
-----END PGP SIGNATURE-----

--xXmbgvnjoT4axfJE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
