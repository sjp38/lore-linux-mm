Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60FDC6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:58:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id b186so3268322wmf.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:58:26 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id p11si7333804wre.553.2018.01.19.04.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 04:58:25 -0800 (PST)
Date: Fri, 19 Jan 2018 13:58:20 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180119125819.GA17936@amd>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <20180119105527.GB29725@amd>
 <20180119110726.odea3h3smcjyicnk@suse.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Content-Disposition: inline
In-Reply-To: <20180119110726.odea3h3smcjyicnk@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri 2018-01-19 12:07:26, Joerg Roedel wrote:
> Hey Pavel,
>=20
> On Fri, Jan 19, 2018 at 11:55:28AM +0100, Pavel Machek wrote:
> > Thanks for doing the work.
> >=20
> > I tried applying it on top of -next, and that did not succeed. Let me
> > try Linus tree...
>=20
> Thanks for your help with testing this patch-set, but I recommend to
> wait for the next version, as review already found a couple of bugs that
> might crash your system. For example there are NMI cases that might
> crash your machine because the NMI happens in kernel mode before the cr3
> switch. VM86 mode is also definitly broken.

Thanks for heads-up. I guess I can disable NMI avoid VM86.

CONFIG_X86_PTDUMP_CORE should be responsible for boot fail. Disabling
it is not at all easy, as CONFIG_EMBEDDED selects CONFIG_EXPERTS
selects CONFIG_DEBUG_KERNEL selects CONFIG_X86_PTDUMP_CORE. (Crazy, if
you ask me). You may want to test with that enabled. Patch below might
fix it. (Signed-off-by: me).

Tests so far: kernel boots in qemu. Whole system boots on thinkpad
T40p, vulnerabities/meltdown says mitigation: PTI.. so I guess it
works.

Tested-by: me. :-)

Best regards,
								Pavel


diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 2a4849e..896b53b 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -543,7 +543,11 @@ EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
 static void ptdump_walk_user_pgd_level_checkwx(void)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
+#ifdef CONFIG_X86_64
 	pgd_t *pgd =3D (pgd_t *) &init_top_pgt;
+#else
+	pgd_t *pgd =3D swapper_pg_dir;
+#endif
=20
 	if (!static_cpu_has(X86_FEATURE_PTI))
 		return;

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlph62sACgkQMOfwapXb+vJiIQCgqBDHc+te64tub1fd2ysUnYzO
zUIAn0KcVe+znFkXmNnlqNlZM3gHxU1P
=TNq4
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
