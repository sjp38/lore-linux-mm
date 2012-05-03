Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 577306B00E7
	for <linux-mm@kvack.org>; Thu,  3 May 2012 07:08:52 -0400 (EDT)
Message-ID: <1336043475.13013.47.camel@sauron.fi.intel.com>
Subject: Re: [PATCH] vmalloc: add warning in __vmalloc
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Thu, 03 May 2012 14:11:15 +0300
In-Reply-To: <20120502124610.175e099c.akpm@linux-foundation.org>
References: <1335932890-25294-1-git-send-email-minchan@kernel.org>
	 <20120502124610.175e099c.akpm@linux-foundation.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-57Lh1wuEjZihfs+vd2pa"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com, rientjes@google.com, Neil Brown <neilb@suse.de>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David
 S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@newdream.net>


--=-57Lh1wuEjZihfs+vd2pa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-05-02 at 12:46 -0700, Andrew Morton wrote:
> On Wed,  2 May 2012 13:28:09 +0900
> Minchan Kim <minchan@kernel.org> wrote:
>=20
> > Now there are several places to use __vmalloc with GFP_ATOMIC,
> > GFP_NOIO, GFP_NOFS but unfortunately __vmalloc calls map_vm_area
> > which calls alloc_pages with GFP_KERNEL to allocate page tables.
> > It means it's possible to happen deadlock.
> > I don't know why it doesn't have reported until now.
> >=20
> > Firstly, I tried passing gfp_t to lower functions to support __vmalloc
> > with such flags but other mm guys don't want and decided that
> > all of caller should be fixed.
> >=20
> > http://marc.info/?l=3Dlinux-kernel&m=3D133517143616544&w=3D2
> >=20
> > To begin with, let's listen other's opinion whether they can fix it
> > by other approach without calling __vmalloc with such flags.
> >=20
> > So this patch adds warning in __vmalloc_node_range to detect it and
> > to be fixed hopely. __vmalloc_node_range isn't random chocie because
> > all caller which has gfp_mask of map_vm_area use it through __vmalloc_a=
rea_node.
> > And __vmalloc_area_node is current static function and is called by onl=
y
> > __vmalloc_node_range. So warning in __vmalloc_node_range would cover al=
l
> > vmalloc functions which have gfp_t argument.
> >
> > I Cced related maintainers.
> > If I miss someone, please Cced them.
> >=20
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1648,6 +1648,10 @@ void *__vmalloc_node_range(unsigned long size, u=
nsigned long align,
> >  	void *addr;
> >  	unsigned long real_size =3D size;
> > =20
> > +	WARN_ON_ONCE(!(gfp_mask & __GFP_WAIT) ||
> > +			!(gfp_mask & __GFP_IO) ||
> > +			!(gfp_mask & __GFP_FS));
> > +
> >  	size =3D PAGE_ALIGN(size);
> >  	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
> >  		goto fail;
>=20
> Well.  What are we actually doing here?  Causing the kernel to spew a
> warning due to known-buggy callsites, so that users will report the
> warnings, eventually goading maintainers into fixing their stuff.
>=20
> This isn't very efficient :(
>=20
> It would be better to fix that stuff first, then add the warning to
> prevent reoccurrences.  Yes, maintainers are very naughty and probably
> do need cattle prods^W^W warnings to motivate them to fix stuff, but we
> should first make an effort to get these things fixed without
> irritating and alarming our users. =20
>=20
> Where are these offending callsites?

OK, I checked my part - both UBI and UBIFS call __vmalloc() with
GFP_NOFS in several places of the _debugging_ code, and this is why we
do not see any issues - the debugging code is used very rarely for
validating purposes. All the places look fixable, I'll fix them a bit
later.

WARN_ON_ONCE() looks like a good first step. An I think it is better if
maintainers fix their areas rather than if someone who does not know how
the subsystem works starts trying to do that.

--=20
Best Regards,
Artem Bityutskiy

--=-57Lh1wuEjZihfs+vd2pa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABAgAGBQJPomfTAAoJECmIfjd9wqK0Le0P/jVKUGL5CYTbVVuaczEr0YHG
3u1H1H5PdbSh+nZh1k+B4954w5tS96bPRrJi2HsFGTSdAvWudF0w5jOaXZqxE9y9
JRIqsYO1n4yJcYM6vNFOTOxk0gUCap4hR+AvqBGEB8C/fiC3f5E/FxISwSrzLBFx
xMaScsYuaJJv0IzOD+MuPEDW2YuX3dyiKssqh8yWIcPNtS/o8LQ/im06HZugYvXo
cuslXW3/vtcV7npEvyXNxRioKlsouWfuEh2ukrIvHRN7hGgAkUeW87ht2Z10065U
oK+kWKd8PjrT7j0tzjnbGWZNkgUnIzo+4p91RzszfdVo/pZRQRogNAT4U6zRwbMZ
MoW9prWmwT57iI4MIu9eCvqMug+nQesCvMlok7Bh8bvESxl6+CzTGGu0VwjKkUty
xgPH3XRDGjrPPGwOUDL4Rv9ugCh8IVQE4punSIjGxwVrjtEDpLGObF7bj2Zzl46Q
7ye17JDT3p4HwtNgcDvNCUlyZ7xT2hReSQ8+GOMGuH94Wz9okMAg/eF2UHGsT1+d
pbcy2a2YbikOooG1hVMcKf3YjJHeMwVNH/Eag8zpcKg5+Hl7Gf/BxrbzetubAow2
/i01lJ7nYieCXTp+AzJiRsaBIiQ7YXhcY6pK4NCu5EeQJfl9ugxyoUBGr7h/6YlG
h5DV5VzMJrgsGpxoKonm
=U6kO
-----END PGP SIGNATURE-----

--=-57Lh1wuEjZihfs+vd2pa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
