Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A19F36B00F0
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 11:24:56 -0400 (EDT)
Received: by gxk23 with SMTP id 23so1645173gxk.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 08:24:54 -0700 (PDT)
Date: Mon, 18 Jul 2011 11:24:50 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 2/2] hugepage: Allow parallelization of the hugepage
 fault path
Message-ID: <20110718152450.GB3890@mgebm.net>
References: <20110125143226.37532ea2@kryten>
 <20110125143414.1dbb150c@kryten>
 <20110126092428.GR18984@csn.ul.ie>
 <20110715160650.48d61245@kryten>
 <20110715161028.2869d307@kryten>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Pd0ReVV5GZGQvF3a"
Content-Disposition: inline
In-Reply-To: <20110715161028.2869d307@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Mel Gorman <mel@csn.ul.ie>, dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--Pd0ReVV5GZGQvF3a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 15 Jul 2011, Anton Blanchard wrote:

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
> From: Anton Blanchard <anton@samba.org>
>=20
> Forward ported and made a few changes:
>=20
> - Use the Jenkins hash to scatter the hash, better than using just the
>   low bits.
>=20
> - Always round num_fault_mutexes to a power of two to avoid an
>   expensive modulus in the hash calculation.
>=20
> I also tested this patch on a large POWER7 box using a simple parallel
> fault testcase:
>=20
> http://ozlabs.org/~anton/junkcode/parallel_fault.c
>=20
> Command line options:
>=20
> parallel_fault <nr_threads> <size in kB> <skip in kB>
>=20
>=20
> First the time taken to fault 128GB of 16MB hugepages:
>=20
> # time hugectl --heap ./parallel_fault 1 134217728 16384
> 40.68 seconds
>=20
> Now the same test with 64 concurrent threads:
> # time hugectl --heap ./parallel_fault 64 134217728 16384
> 39.34 seconds
>=20
> Hardly any speedup. Finally the 64 concurrent threads test with
> this patch applied:
> # time hugectl --heap ./parallel_fault 64 134217728 16384
> 0.85 seconds
>=20
> We go from 40.68 seconds to 0.85 seconds, an improvement of 47.9x
>=20
> This was tested with the libhugetlbfs test suite, and the PASS/FAIL
> count was the same before and after this patch.
>=20
>=20
> Signed-off-by: David Gibson <dwg@au1.ibm.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>

Tested-by: Eric B Munson <emunson@mgebm.net>

--Pd0ReVV5GZGQvF3a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOJFBCAAoJEH65iIruGRnNGN0H/0VveZnL+jU6pB2yFyBR1c7e
fwqQVNo7QRpiDv3ErGpKVKYQ0WHi8yrXGPFzFSqkYdazauupc+d+gxUnUy9ucSVh
IbQJTIRcpHkus+MYlYFgpfgxjgqc3oattJ2YFSu8Mr8ziuYFfqEfdKvBLZdapetD
feJw8Skvngi1tm4KUkxrpYScOa2zkdkbXE/3TCvdEbfRxlNRMMNMyLf/GaAKUJO2
xfENxYj3POy76M3m2zHl1BLWDvavCbaMZzKaltHmPw7OjSqoR6LqeU2vH/IFPrQj
SYH8qX61v8tRQ2IqKTT/rqhcr+OoYR9CsUeFv2trdLU6JwMwvepfr8xPcf8vXr4=
=jHZc
-----END PGP SIGNATURE-----

--Pd0ReVV5GZGQvF3a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
