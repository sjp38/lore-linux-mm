Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7169A6B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 23:34:37 -0500 (EST)
Received: from [2001:470:1f08:1539:a11:96ff:fec6:70c4] (helo=deadeye.wl.decadent.org.uk)
	by shadbolt.decadent.org.uk with esmtps (TLS1.0:DHE_RSA_AES_128_CBC_SHA1:16)
	(Exim 4.72)
	(envelope-from <ben@decadent.org.uk>)
	id 1U5qWo-0005np-UE
	for linux-mm@kvack.org; Thu, 14 Feb 2013 04:34:34 +0000
Received: from ben by deadeye.wl.decadent.org.uk with local (Exim 4.80)
	(envelope-from <ben@decadent.org.uk>)
	id 1U5qWn-000121-PY
	for linux-mm@kvack.org; Thu, 14 Feb 2013 04:34:33 +0000
Message-ID: <1360816468.5374.285.camel@deadeye.wl.decadent.org.uk>
Subject: [PATCH] mm: Try harder to allocate vmemmap blocks
From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 14 Feb 2013 04:34:28 +0000
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZuxSMZB3jtCo+FrXJWHu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--=-ZuxSMZB3jtCo+FrXJWHu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hot-adding memory on x86_64 normally requires huge page allocation.
When this is done to a VM guest, it's usually because the system is
already tight on memory, so the request tends to fail.  Try to avoid
this by adding __GFP_REPEAT to the allocation flags.

Reported-and-tested-by: Bernhard Schmidt <Bernhard.Schmidt@lrz.de>
Reference: http://bugs.debian.org/699913
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
We could go even further and use __GFP_NOFAIL, but I'm not sure whether
that would be a good idea.

Ben.

 mm/sparse-vmemmap.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 1b7e22a..22b7e18 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -53,10 +53,12 @@ void * __meminit vmemmap_alloc_block(unsigned long size=
, int node)
 		struct page *page;
=20
 		if (node_state(node, N_HIGH_MEMORY))
-			page =3D alloc_pages_node(node,
-				GFP_KERNEL | __GFP_ZERO, get_order(size));
+			page =3D alloc_pages_node(
+				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
+				get_order(size));
 		else
-			page =3D alloc_pages(GFP_KERNEL | __GFP_ZERO,
+			page =3D alloc_pages(
+				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
 				get_order(size));
 		if (page)
 			return page_address(page);


--=-ZuxSMZB3jtCo+FrXJWHu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAURxpVOe/yOyVhhEJAQpTeg//SIiT9NavBu8IWI5jVChrvUJC8Jew7SNy
IyUYdZuAdRxtQlfgVi0U5woRaL2TCm3wyUlU0LNtPUi5zz6FIjS/mmAIf7CocydV
BvhJsUjgYGM4AeHwX5PteJivto4UG2Ia1jHK7kmq48e7ufJyW76EwykxBAS0YfK1
BpCWofgXmu5zscs6jBM3Qu4m0GbovRYecSy2Rwm6yTQ/ATemqzYA6AtZYB7hxxin
4YoYJXyOvR32t/PxzXEdrHeIANBsLYvgHwVa6pB213nMZDTALJW/K2o/JhJQ6kCf
mW19/Cdl2AHlOWyuEaQQzq4TxJYfWPmnhC2y4x8BpZA4/W0M7dkTtjEVF4WFLbB4
znUSas9agULONX1stsUDRB1SxhioB8IZQodYpODQwfOK6VrxJSFi1nXjxv3G5cPs
ccy6UrLoOjfreJ6gV/eBsmxmbH9Kv5wS0V4qMQlGhQYOle7kCyGhd/UBIlz95jbd
SAUvXIAtcvejESSKuNXnSrm4sAEXBUHMMbYp/2ap3eG4tk5oQGnY82UAeCzC2z85
be307OQJJuBSsh7RY7J7dSTYOXTive1l3MTfYlUMz8bMTXUBaV/1BKByOl6CTOJY
+RCnNAhEu2rUl4yVKb4dWxFTYgTyWQ3uVLJmfRoQYwrVaGxZbidpl+dZnb45Y0O1
d14w5ff1xHo=
=st0s
-----END PGP SIGNATURE-----

--=-ZuxSMZB3jtCo+FrXJWHu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
