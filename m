Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C29E56B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 04:19:45 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so1184334pde.23
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 01:19:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fx12si852363pdb.115.2014.07.23.01.19.44
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 01:19:44 -0700 (PDT)
Date: Wed, 23 Jul 2014 03:48:55 -0400
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Re: [RFC PATCH 2/3] x86, MCE: Avoid potential deadlock in MCE context
Message-ID: <20140723074855.GA3925@gchen.bj.intel.com>
References: <1405478082-30757-1-git-send-email-gong.chen@linux.intel.com>
 <1405478082-30757-3-git-send-email-gong.chen@linux.intel.com>
 <20140721084737.GA10016@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNdxnHkX5QqsyA0e"
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32870C55@ORSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 21, 2014 at 05:14:06PM +0000, Luck, Tony wrote:
> We've evolved a bunch of mechanisms:
>=20
> 1) mce_ring: to pass pfn for AO errors from MCE context to a work thread
> 2) mce_info: to pass pfn for AR errors from MCE context to same process r=
unning in process context
> 3) mce_log: to pass entire "mce" structures from any context (MCE, CMCI, =
or init-time) to /dev/mcelog
>=20
> I was actually wondering about going in the other direction. Make the
> /dev/mcelog code register a notifier on x86_mce_decoder_chain (and
> perhaps move all the /dev/mcelog functions out of mce.c into an actual
> driver file).  Then use Chen Gong's NMI safe code to just unconditionally
> make safe copies of anything that gets passed to mce_log() and run all
> the notifiers from his do_mce_irqwork().
>=20
> -Tony

OK, I can cook some patches based on Tony's suggestion:
patch 1: add a generic lock-less memory pool to save error records
patch 2: remove mce_info (Tony has done a draft)
patch 3: remove mce_ring
patch 4: remove mce log buffer
patch 5: move all mce log related logic into a separate file lke mcelog.c
         under the same directory with mce.c

--cNdxnHkX5QqsyA0e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTz2jnAAoJEI01n1+kOSLHE5IQAJ35fzfqY2s5brre9TG2jg7+
1H38RiNCsqPFRgC3LygGugN4C1FndHSuUC5HpE4tr9gmlUV+vswX8VSB5uACGGUG
/CKog/xs3cdRgKpjdENaO6v/LsvT/Yfh1u/4YoQ1qyEFEFLy4a+EZ3yLZfUTN/8+
tLFTH0N/rYQLxVn1vKhZXmfFVmXXfBGdlPXitLpwnnYpJLki2mzKgLMM/BzUja1B
A1ryBCw+0UeFMJ7CVENb9kRPHUk5TCVf9O3WDmy6UFHiUjjlUHdUAVvihbkATllY
JI4x4oQEvyeA/WQahwQMwEgsJ4HOKipl2BxoIHSOIUsHG9yVYS3qBHb2/8HJqN+d
mvJqDGLyhPW1sNwXo0ludLj1HBxIeyziGy0yFaz6nmWI4RhW5482NloOXZAtBHiL
6qOzIdr+RhsbVSbnHuC11WcCKIEBpm6fHRn02j1OPMT6jaZaPruOKD55h5gVpU4j
/cdPw/IiujZmaZF67n2HncqFLgwW//c0gDzEH55go3HLQru7P/K6Qk31q5QiMqm3
WGRi+i/xxlyKFPzEL9BewDO3qbERXmHRJvaG/rODU1wf3BbjaUXqwf+gaqIXFPjm
/EuEIqXgMdDjhHqZydykGLqYkzzV9/DdN5pHhi/65QRPPn4RpNEBNoia8ymSR+N3
5lXijpc0IFXLDWN1WHY7
=tXI6
-----END PGP SIGNATURE-----

--cNdxnHkX5QqsyA0e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
