Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1A1E6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 03:27:06 -0400 (EDT)
Date: Wed, 11 Mar 2009 08:26:58 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311082658.06ff605a@mjolnir.ossman.eu>
In-Reply-To: <20090311071445.GA13584@localhost>
References: <20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
	<20090310212118.7bf17af6@mjolnir.ossman.eu>
	<20090311013739.GA7078@localhost>
	<20090311075703.35de2488@mjolnir.ossman.eu>
	<20090311071445.GA13584@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-26703-1236756421-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-26703-1236756421-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 15:14:45 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Wed, Mar 11, 2009 at 08:57:03AM +0200, Pierre Ossman wrote:
> > On Wed, 11 Mar 2009 09:37:40 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> >=20
> > >=20
> > > This 80MB noflags pages together with the below 80MB lru pages are
> > > very close to the missing page numbers :-) Could you run the following
> > > commands on fresh booted 2.6.27 and post the output files? Thank you!
> > >=20
> > >         dd if=3D/dev/zero of=3D/tmp/s bs=3D1M count=3D1 seek=3D1024
> > >         cp /tmp/s /dev/null
> > >=20
> > >         ./page-flags > flags
> > >         ./page-areas =3D0x20000 > areas-noflags
> > >         ./page-areas =3D0x00020 > areas-lru
> > >=20
> >=20
> > Attached.
>=20
> Thank you very much!
>=20
> > I have to say, the patterns look very much like some kind of leak.
>=20
> Wow it looks really interesting.  The lru pages and noflags pages make
> perfect 1-page interleaved pattern...
>=20

Another breakthrough. I turned off everything in kernel/trace, and now
the missing memory is back. Here's the relevant diff against the
original .config:

@@ -3677,18 +3639,15 @@
 # CONFIG_BACKTRACE_SELF_TEST is not set
 # CONFIG_LKDTM is not set
 # CONFIG_FAULT_INJECTION is not set
-CONFIG_LATENCYTOP=3Dy
+# CONFIG_LATENCYTOP is not set
 # CONFIG_SYSCTL_SYSCALL_CHECK is not set
 CONFIG_HAVE_FTRACE=3Dy
 CONFIG_HAVE_DYNAMIC_FTRACE=3Dy
-CONFIG_TRACER_MAX_TRACE=3Dy
-CONFIG_TRACING=3Dy
 # CONFIG_FTRACE is not set
-CONFIG_IRQSOFF_TRACER=3Dy
-CONFIG_SYSPROF_TRACER=3Dy
-CONFIG_SCHED_TRACER=3Dy
-CONFIG_CONTEXT_SWITCH_TRACER=3Dy
-# CONFIG_FTRACE_STARTUP_TEST is not set
+# CONFIG_IRQSOFF_TRACER is not set
+# CONFIG_SYSPROF_TRACER is not set
+# CONFIG_SCHED_TRACER is not set
+# CONFIG_CONTEXT_SWITCH_TRACER is not set

I'll enable them one at a time and see when the bug reappears, but if
you have some ideas on which it could be, that would be helpful. The
machine takes some time to recompile a kernel. :)

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-26703-1236756421-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm3Z8UACgkQ7b8eESbyJLhRSgCgolE4gwrrc12EtBnxRr0lIveg
pDEAoNW2USkmxE+Yz2dc6T+zQKQLqpvs
=HXLn
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-26703-1236756421-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
