Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9D36B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 08:14:27 -0400 (EDT)
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in dmam_pool_destroy()
Date: Thu, 02 Jun 2011 11:47:36 +0200
Message-ID: <3647102.7SB09c9jIV@donald.sf-tec.de>
In-Reply-To: <20110601214313.GA3724@maxin>
References: <20110601214313.GA3724@maxin>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4796684.krExRduWp2"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin B John <maxin.john@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com


--nextPart4796684.krExRduWp2
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Maxin B John wrote:
> "dma_pool_destroy(pool)" calls "kfree(pool)". The freed pointer "pool"
> is again passed as an argument to the function "devres_destroy()".
> This patch fixes the possible use after free.
> 
> Please let me know your comments.

The pool itself is not used there, only the address where the pool has been. 
This will only lead to any trouble if something else is allocated to the same 
place and inserted into the devres list of the same device between the 
dma_pool_destroy() and devres_destroy().

But I agree that this is bad style. But if you are going to change this please 
also have a look at devm_iounmap() in lib/devres.c. Maybe also the devm_*irq* 
functions need the same changes.

Eike
--nextPart4796684.krExRduWp2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk3nXDgACgkQXKSJPmm5/E6PkQCgnoldftmAq8/gLjBVzhSZHyAo
t/UAoIqHRNZWNvy/tYTarR9622AJPD59
=0ACZ
-----END PGP SIGNATURE-----

--nextPart4796684.krExRduWp2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
