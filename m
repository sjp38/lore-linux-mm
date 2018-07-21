Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9F56B0003
	for <linux-mm@kvack.org>; Sat, 21 Jul 2018 12:06:32 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u1-v6so7254225wrs.18
        for <linux-mm@kvack.org>; Sat, 21 Jul 2018 09:06:32 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id m10-v6si3397406wrh.299.2018.07.21.09.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jul 2018 09:06:30 -0700 (PDT)
Date: Sat, 21 Jul 2018 18:06:19 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 2/3] x86/entry/32: Check for VM86 mode in slow-path check
Message-ID: <20180721160619.GA19856@amd>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org>
 <1532103744-31902-3-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <1532103744-31902-3-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> The SWITCH_TO_KERNEL_STACK macro only checks for CPL =3D=3D 0 to
> go down the slow and paranoid entry path. The problem is
> that this check also returns true when coming from VM86
> mode. This is not a problem by itself, as the paranoid path
> handles VM86 stack-frames just fine, but it is not necessary
> as the normal code path handles VM86 mode as well (and
> faster).
>=20
> Extend the check to include VM86 mode. This also makes an
> optimization of the paranoid path possible.
>=20
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/entry/entry_32.S | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 010cdb4..2767c62 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -414,8 +414,16 @@
>  	andl	$(0x0000ffff), PT_CS(%esp)
> =20
>  	/* Special case - entry from kernel mode via entry stack */
> -	testl	$SEGMENT_RPL_MASK, PT_CS(%esp)
> -	jz	.Lentry_from_kernel_\@
> +#ifdef CONFIG_VM86
> +	movl	PT_EFLAGS(%esp), %ecx		# mix EFLAGS and CS
> +	movb	PT_CS(%esp), %cl
> +	andl	$(X86_EFLAGS_VM | SEGMENT_RPL_MASK), %ecx
> +#else
> +	movl	PT_CS(%esp), %ecx
> +	andl	$SEGMENT_RPL_MASK, %ecx
> +#endif
> +	cmpl	$USER_RPL, %ecx
> +	jb	.Lentry_from_kernel_\@

Would it make sense to jump to the slow path as we did, and them jump
back if VM86 is detected?

Because VM86 is not really used often these days, and moving partial
registers results in short code but IIRC it will be rather slow.

								Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAltTWfsACgkQMOfwapXb+vKVGACeI9NdVcZTy/Fm7pXV6TV/7gqH
Uu0An2ln3dlg2bBDomHRNz30cXj7GbYG
=/5m4
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--
