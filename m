Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 528166B0047
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 11:02:34 -0400 (EDT)
Date: Wed, 11 Mar 2009 16:02:23 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090311160223.638b4bc9@mjolnir.ossman.eu>
In-Reply-To: <20090311130022.GA22453@localhost>
References: <20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
	<20090310212118.7bf17af6@mjolnir.ossman.eu>
	<20090311013739.GA7078@localhost>
	<20090311075703.35de2488@mjolnir.ossman.eu>
	<20090311071445.GA13584@localhost>
	<20090311082658.06ff605a@mjolnir.ossman.eu>
	<20090311073619.GA26691@localhost>
	<20090311085738.4233df4e@mjolnir.ossman.eu>
	<20090311130022.GA22453@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-30314-1236783748-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-30314-1236783748-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 11 Mar 2009 21:00:22 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

>=20
> I worked up a simple debugging patch. Since the missing pages are
> continuously spanned, several stack dumping shall be enough to catch
> the page consumer.
>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 27b8681..c0df7fd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1087,6 +1087,13 @@ again:
>  			goto failed;
>  	}
> =20
> +	/* wfg - hunting the 40000 missing pages */
> +	{
> +		unsigned long pfn =3D page_to_pfn(page);
> +		if (pfn > 0x1000 && (pfn & 0xfff) <=3D 1)
> +			dump_stack();
> +	}
> +
>  	__count_zone_vm_events(PGALLOC, zone, 1 << order);
>  	zone_statistics(preferred_zone, zone);
>  	local_irq_restore(flags);

This got very noisy, but here's what was in the ring buffer once it had
booted.

Note that this is where only the "noflags" pages have been allocated,
not "lru".

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-30314-1236783748-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm30oIACgkQ7b8eESbyJLhyFwCdFE08E6xqSncPVEADFyGmHdEk
O0MAoJ+MIAeWo4GgXq3yTeQns17WFI4k
=ePbY
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-30314-1236783748-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
