Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B1FE36B0069
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 14:28:37 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id c79so96772920ybf.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 11:28:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x205si2074727ybb.131.2016.09.15.11.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 11:28:37 -0700 (PDT)
Message-ID: <1473964113.10218.92.camel@redhat.com>
Subject: Re: [PATCH 2/2] mm: vma_merge: fix race vm_page_prot race condition
 against rmap_walk
From: Rik van Riel <riel@redhat.com>
Date: Thu, 15 Sep 2016 14:28:33 -0400
In-Reply-To: <1473961304-19370-3-git-send-email-aarcange@redhat.com>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
	 <1473961304-19370-3-git-send-email-aarcange@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-9rRrGKy/nakdPBb+NJWt"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>


--=-9rRrGKy/nakdPBb+NJWt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-09-15 at 19:41 +0200, Andrea Arcangeli wrote:
> The rmap_walk can access vm_page_prot (and potentially vm_flags in
> the
> pte/pmd manipulations). So it's not safe to wait the caller to update
> the vm_page_prot/vm_flags after vma_merge returned potentially
> removing the "next" vma and extending the "current" vma over the
> next->vm_start,vm_end range, but still with the "current" vma
> vm_page_prot, after releasing the rmap locks.
>=20
> The vm_page_prot/vm_flags must be transferred from the "next" vma to
> the current vma while vma_merge still holds the rmap locks.
>=20
> The side effect of this race condition is pte corruption during
> migrate as remove_migration_ptes when run on a address of the "next"
> vma that got removed, used the vm_page_prot of the current vma.
>=20
> migrate	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0	=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mprotect
> ------------			-------------
> migrating in "next" vma
> 				vma_merge() # removes "next" vma and
> 			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0	=C2=A0=C2=A0=C2=A0=C2=
=A0# extends "current" vma
> 					=C2=A0=C2=A0=C2=A0=C2=A0# current vma is not with
> 					=C2=A0=C2=A0=C2=A0=C2=A0# vm_page_prot updated
> remove_migration_ptes
> read vm_page_prot of current "vma"
> establish pte with wrong permissions
> 				vm_set_page_prot(vma) # too late!
> 				change_protection in the old vma range
> 				only, next range is not updated
>=20
> This caused segmentation faults and potentially memory corruption in
> heavy mprotect loads with some light page migration caused by
> compaction in the background.
>=20
> Reported-by: Aditya Mandaleeka <adityam@microsoft.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>
Tested-by: Rik van Riel <riel@redhat.com>

--=20
All rights reversed

--=-9rRrGKy/nakdPBb+NJWt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX2uhSAAoJEM553pKExN6DDqkIAIRvKAWtUlV1OravZIq/0g8+
5v+7bTWew6DKJvtzZxD/TeHDa1E8K8RI5Cgn07vSr073ZGYTFUDvE9Qox3DejBPZ
Bm4glesKh80Ej1wtWZL+oTxJw76j5CHF5EnY+/A3dbqH7KkjFF61xIZuCGPKPkyG
QsEKzg2F/Zm63FRksqigIRYlnasP/E14Um853cP2C9to94SuLX0Tf3zOH2eGaYju
SMTwXSC3TSWoSsMQT8k+SSTCzb/bv4Jk51YjGOy7tzv8BPrCEP++b25FkmBpScCs
F0/oUaI/hXY1jb0m4do1AVxavlTPqfB7tmZLxP2ilPd6ABXL8+3sX4AoXb+cHAE=
=3hqu
-----END PGP SIGNATURE-----

--=-9rRrGKy/nakdPBb+NJWt--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
