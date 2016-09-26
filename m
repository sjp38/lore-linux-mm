Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EDB5F280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:23:36 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 16so317839412qtn.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 14:23:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a184si14765610qkf.17.2016.09.26.14.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 14:23:36 -0700 (PDT)
Message-ID: <1474925009.17726.61.camel@redhat.com>
Subject: Re: page_waitqueue() considered harmful
From: Rik van Riel <riel@redhat.com>
Date: Mon, 26 Sep 2016 17:23:29 -0400
In-Reply-To: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
References: 
	<CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-tjRi79130sDtmMsCqGag"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm <linux-mm@kvack.org>


--=-tjRi79130sDtmMsCqGag
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-09-26 at 13:58 -0700, Linus Torvalds wrote:

> Is there really any reason for that incredible indirection? Do we
> really want to make the page_waitqueue() be a per-zone thing at all?
> Especially since all those wait-queues won't even be *used* unless
> there is actual IO going on and people are really getting into
> contention on the page lock.. Why isn't the page_waitqueue() just one
> statically sized array?

Why are we touching file pages at all during fork()?

Could we get away with skipping copy_page_range on VMAs
that do not have any anonymous pages?

Could we teach copy_page_range to skip file PTEs during
fork?

The child process can just fault the needed file pages in
after it has been forked off.

Given how common fork + exec are, there is a real chance that:
- the child process did not need all of the parent's pages, and
- the parent process does not have some of the bits needed by
=C2=A0 the child (for exec) mapped into its page tables, anyway
=C2=A0 (as suggested by the child processes page faulting on file
=C2=A0 =C2=A0pages)

Having fewer pages mapped might also make zap_page_range
a little cheaper, both at exec and at exit time.

Am I overlooking something?

--=20
All Rights Reversed.
--=-tjRi79130sDtmMsCqGag
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJX6ZHSAAoJEM553pKExN6DbLMH/0f9W1NY5x7444ooc5VNkqC5
bA3FA4ciaUaxm/su+nrqEvR/T2Ib9FpJ48brRYOnoHF4z69ZyRllDrBnUsrfTXOV
az5Qp1r8mSN01zQHmVMQ6pkjCeNGV8k+gRkkaIrlLpgZZ+aX6aO5DduqjR5B6iDz
cNhs2j2cOLPCcuqN6I8BW7YMNPw8X1I35rhamTWu8KZlq7xlTkDTCKxRdICg0yfp
EMOOlCMBG1lLXKJxRnODCw4K7zeBlN+9EHJo+MlU6UST33pO/qqzf2jOh1ImFyAP
pKNHG5RbnUuHI2f3zg1Otip8UCXSLqxLoVYnuqmAfbeaE2ABh30XF/CEf5Q96rg=
=ceh/
-----END PGP SIGNATURE-----

--=-tjRi79130sDtmMsCqGag--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
