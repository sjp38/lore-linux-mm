Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02ADE6B02C3
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:47:08 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v36so95683768pgn.6
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 10:47:07 -0700 (PDT)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id 1si4009428pgt.572.2017.06.29.10.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 10:47:06 -0700 (PDT)
Received: from grubbs.orbis-terrarum.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTPS id 75333341876
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 17:47:06 +0000 (UTC)
Date: Thu, 29 Jun 2017 17:47:05 +0000
From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: Regarding your thread on LKML - drm_radeon spamming
 alloc_contig_range [WAS: Re: PROBLEM-PERSISTS: dmesg spam:
 alloc_contig_range: [XX, YY) PFNs busy]
Message-ID: <20170629174705.GN23586@orbis-terrarum.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="cADPt9qH4kAUtA4D"
Content-Disposition: inline
In-Reply-To: <CADK6UNEQ+WuKDRyUVPQ1RwOWCkvcU95OBh4obKj4dv62Kf5ipA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kumar Abhishek <kumar.abhishek.kakkar@gmail.com>
Cc: robbat2@orbis-terrarum.net, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, robbat2@gentoo.org, linux-mm@kvack.org, mina86@mina86.com


--cADPt9qH4kAUtA4D
Content-Type: multipart/mixed; boundary="s84eBR/zx33jl1qi"
Content-Disposition: inline


--s84eBR/zx33jl1qi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

CC'd back to LKML.

On Thu, Jun 29, 2017 at 06:11:00PM +0530, Kumar Abhishek wrote:
> Hi Robin,
>=20
> I am an independent developer who stumbled upon your thread on the LKML
> after facing a similar issue - my kernel log being spammed by
> alloc_contig_range messages. I am running Linux on an ARM system
> (specifically the BeagleBoard-X15) and am on kernel version 4.9.33 with TI
> patches on top of it.
>=20
> I am running Debian Stretch (9.0) on the system.
>=20
> Here's what my stack trace looks like:
=2E.
>=20
> It's somewhat similar to your stack trace, but this here happens on an
> etnaviv GPU (Vivante GCxx).
>=20
> In my case if I do 'sudo service lightdm stop', these messages stop too.
> This seems to suggest that the problem may be in the X server rather than
> the kernel? I seem to think this because I replicated this on an entirely
> different set of hardware than yours.
>=20
> I just wanted to bring this to your notice, and also ask you if you manag=
ed
> to solve it for yourself.
>=20
> One solution could be to demote the pr_info in alloc_contig_range to
> pr_debug or to do away with the message altogether, but this would be
> suppressing the issue instead of really knowing what it is about.
>=20
> Let me know how I could further investigate this.
The problem, as far as I got diagnosed on LKML, is that some of the GPUs
have a bunch of non-fatal contiguous memory allocation requests: they
have a meaningful fallback path on the allocation, so 'PFNs busy' is a
false busy for their case.

However, if there was a another consumer that does NOT have a fallback,
the output would still be crucially useful.

Attached is the patch that I unsuccessfully proposed on LKML to
rate-limit the messages, with the last revision to only dump_stack() if
CONFIG_CMA_DEBUG was set.

The path that LKML wanted was to add a new parameter to suppress or at
least demote the failure message, and update all of the callers: but it
means that many of the indirect callers need that added parameter as
well.

mm/cma.c:cma_alloc this call can suppress the error, you can see it retry.
mm/hugetlb.c: These callers should get the error message.

The error message DOES still have a good general use in notifying you
that something is going wrong. There was noticeable performance slowdown
in my case when it was trying hard to allocate.

--=20
Robin Hugh Johnson
E-Mail     : robbat2@orbis-terrarum.net
Home Page  : http://www.orbis-terrarum.net/?l=3Dpeople.robbat2
ICQ#       : 30269588 or 41961639
GnuPG FP   : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85

--s84eBR/zx33jl1qi
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="000-despam-pfn-busy.patch"
Content-Transfer-Encoding: quoted-printable

commit 808c209dc82ce79147122ca78e7047bc74a16149
Author: Robin H. Johnson <robbat2@gentoo.org>
Date:   Wed Nov 30 10:32:57 2016 -0800

    mm: ratelimit & trace PFNs busy.
   =20
    Signed-off-by: Robin H. Johnson <robbat2@gentoo.org>
	Acked-by: Michal Nazarewicz <mina86@mina86.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..3c28ec3d18f8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7289,8 +7289,16 @@ int alloc_contig_range(unsigned long start, unsigned=
 long end,
=20
 	/* Make sure the range is really isolated. */
 	if (test_pages_isolated(outer_start, end, false)) {
-		pr_info("%s: [%lx, %lx) PFNs busy\n",
-			__func__, outer_start, end);
+		static DEFINE_RATELIMIT_STATE(ratelimit_pfn_busy,
+					DEFAULT_RATELIMIT_INTERVAL,
+					DEFAULT_RATELIMIT_BURST);
+		if (__ratelimit(&ratelimit_pfn_busy)) {
+			pr_info("%s: [%lx, %lx) PFNs busy\n",
+				__func__, outer_start, end);
+			if (IS_ENABLED(CONFIG_CMA_DEBUG))
+				dump_stack();
+		}
+
 		ret =3D -EBUSY;
 		goto done;
 	}

--s84eBR/zx33jl1qi--

--cADPt9qH4kAUtA4D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Robbat2 @ Orbis-Terrarum Networks - The text below is a digital signature. If it doesn't make any sense to you, ignore it.

iQKTBAEBCgB9FiEEveu2pS8Vb98xaNkRGTlfI8WIJsQFAllVPRhfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldEJE
RUJCNkE1MkYxNTZGREYzMTY4RDkxMTE5Mzk1RjIzQzU4ODI2QzQACgkQGTlfI8WI
JsQbNw//WXW+x1z7iooqHc+kok4wWPDY39I1tQTDNz9W/HwKWGRJxGoneN6CQJ+G
HBCbDDun72JQtGzGy9bed4IZnhhjaKCaTSXG8UrDAJGQ/R6wt6vvDWTCHikEPNT2
W80dUhG3mkWY5Wly1KzVcqxAUM9YYzD7RTwrRppepE4hPNj3q1AZ5x5vq8LS0pLX
mCj43LG+5VstaA1LQCxW69OlFsVeRHKPXQKbzHKgucxVUaqTfu+2jP0ehdVlmXib
M3vDhbFMkNVsjIXh0uXVs4I1kgJcqqQkBv/HIOqvOHpQ4VkRsZ/10BoTQPj8Yb3I
XhTeiWxWbYDXstkEIqhViucrtyFpuDqHcWcYMa5UwUIUSxfBoVPI2RkzsUtszCS+
o4V2vunzB2MPuRxqdVv02KinErleTvHbcORqr/r1BFjOhCezf5aXyJoJm+ziPjYs
EhyvbBl4zIDzY0uSc90HfU6f6+p2HiIBY2MD6hDljlBR9RUk3uEIjy45THT8aPkU
wVhi53FMk1nFG3POorMIBvHm8oCk5Vsn2qK+pEQOk6lbxC/x2MLWRahv1cCojm45
fTzYayjqapT55A4v4Ep8p5dLrRVf0o5XBGyqtQgADFSfvq11XI1L8nDaOHa9ojoC
GwriDD6U69fzEotFU2KIFYfLIFPmJz3DVu9fxCsnsjvBCN5W2MQ=
=aCrF
-----END PGP SIGNATURE-----

--cADPt9qH4kAUtA4D--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
