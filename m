Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD957828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:41:09 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id s189so484605590vkh.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:41:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i200si906138qke.191.2016.08.05.07.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 07:38:39 -0700 (PDT)
Message-ID: <1470407913.13905.66.camel@redhat.com>
Subject: Re: [PATCH] x86/mm: disable preemption during CR3 read+write
From: Rik van Riel <riel@redhat.com>
Date: Fri, 05 Aug 2016 10:38:33 -0400
In-Reply-To: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
References: <1470404259-26290-1-git-send-email-bigeasy@linutronix.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ygw81KUwZ+4QWFNpmg93"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>


--=-ygw81KUwZ+4QWFNpmg93
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-08-05 at 15:37 +0200, Sebastian Andrzej Siewior wrote:
>=C2=A0
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -135,7 +135,14 @@ static inline void
> cr4_set_bits_and_update_boot(unsigned long mask)
> =C2=A0
> =C2=A0static inline void __native_flush_tlb(void)
> =C2=A0{
> +	/*
> +	=C2=A0* if current->mm =3D=3D NULL then we borrow a mm which may
> change during a
> +	=C2=A0* task switch and therefore we must not be preempted while
> we write CR3
> +	=C2=A0* back.
> +	=C2=A0*/
> +	preempt_disable();
> =C2=A0	native_write_cr3(native_read_cr3());
> +	preempt_enable();
> =C2=A0}

That is one subtle race!

Acked-by: Rik van Riel <riel@redhat.com>

--=20

All Rights Reversed.
--=-ygw81KUwZ+4QWFNpmg93
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXpKTpAAoJEM553pKExN6DAc8H/3DhcXs3/x1K6aTFAzUfp97M
33REzE+JcAI0uWWisVPHSHAcoK8g5tGzpcXG7UuLGjPqohyB0500ukaFMFghcij8
zWCJweM49VZCPSUm7L/hpwXTkx+Ltraem6TsDuFRf3jMfSM8l500OcwocLdV4S7J
tza4Gy6ZVM49Csx42jWO1Ac15oLQWJ/77/YzyGIuGkfrHtK04pCCECzdCoCdU5I7
vxINhsoo8QFoTkeAQPXWRqUmSQkZboNn6GKg+aDWGC6TVu6KLVlpfuzgmc0wN7EN
ySA0IhptXVFT9GcXgqIy7Ow9XbsATyxXw8MUK2SBLi1LDrYW7Kts80N3mTVU1f4=
=foAC
-----END PGP SIGNATURE-----

--=-ygw81KUwZ+4QWFNpmg93--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
