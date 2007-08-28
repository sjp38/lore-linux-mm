Received: from [147.83.35.215] (dync-35-215.ac.upc.es [147.83.35.215])
	by gw.ac.upc.edu (Postfix) with ESMTP id A63806B01D5
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 18:54:28 +0200 (CEST)
Subject: Selective swap out of processes
From: Javier Cabezas =?ISO-8859-1?Q?Rodr=EDguez?= <jcabezas@ac.upc.edu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BiGMbkWT16S2sppt9Knt"
Date: Tue, 28 Aug 2007 18:54:30 +0200
Message-Id: <1188320070.11543.85.camel@bastion-laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-BiGMbkWT16S2sppt9Knt
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi all,

I am trying to reduce the main memory power consumption when the system
is idle. In order to achieve it, I want to freeze some processes
(user-defined) when the system enters a long idle period and swap them
out to the disk. After that, more memory is free and then, the remaining
used memory can be moved to a minimal set of memory ranks so the rest of
ranks can be switched off.

To the best of my knowledge, a process can own the following types of
memory pages:
- Mapped pages
        =C2=B7 Executable and Read-only mapped pages that are backed by a
        file in the disk. These pages can be directly unmapped (if they
        are not shared) -> UNMAP
        =C2=B7 Writable file mapped pages that must be flushed to disk
        (synced) before they are unmapped -> SYNC + UNMAP
- Anonymous pages in User Mode address spaces -> SWAP
-  Mapped pages of tmpfs filesystem -> SWAP

I have implemented the process selection mechanism (using an entry for
each PID in proc), and the process freezing/resume (using the
refrigerator function, like in the hibernation code).

Now I am implementing the memory freeing. The biggest problem here is
that the regular swapping out algorithm of the kernel only frees memory
when it is needed, so I don't know which is the behaviour of the
standard routines in this situation.  I have looked at the standard
swapping functions (shrink_zones, shrink_zone, ...) and I think they
handle all the  process page types I enumerated previously. So, for each
VMA of the process,  I build a page list with all the pages and pass it
as a parameter to shrink_page_list (before that I remove them from the
LRU active/inactive lists with del_page_from_lru).

First I have tried with the executable VMA (of a lynx process) mapped to
the executable file. However none of the pages is freed.
shrink_page_list skips each page due to this check:

referenced =3D page_referenced(page, 1);
/* In active use or really unfreeable?  Activate it. */
if (referenced && page_mapping_inuse(page))
	goto activate_locked;

It seems they are mapped somewhere else and they cannot be freed. So,
which operations should I perform on the pages (try_to_unmap,
pte_mkold, ...) before I call shrink_page_list?

I would be eternally grateful if someone could help me with this :-)

Thanks in advance.

Javi

--=20
Javier Cabezas Rodr=C3=ADguez
Phd. Student - DAC (UPC)
jcabezas@ac.upc.edu

--=-BiGMbkWT16S2sppt9Knt
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Esta parte del mensaje =?ISO-8859-1?Q?est=E1?= firmada
	digitalmente

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG1FNG7q9eX0wTM/URAnl7AJ91zmamv3HeaL6WA05JAZ4pUCZwRwCfWMH4
ywDhagXVoNeI/LwvL78usAY=
=+tQp
-----END PGP SIGNATURE-----

--=-BiGMbkWT16S2sppt9Knt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
