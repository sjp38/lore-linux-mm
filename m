Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C96406B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 01:21:44 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so335009123pfg.0
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:21:44 -0800 (PST)
Received: from smtp.gentoo.org (woodpecker.gentoo.org. [2001:470:ea4a:1:5054:ff:fec7:86e4])
        by mx.google.com with ESMTPS id z65si39380913plh.175.2016.11.30.22.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 22:21:43 -0800 (PST)
Received: from grubbs.orbis-terrarum.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTPS id BDE583413AD
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 06:21:42 +0000 (UTC)
Date: Thu, 1 Dec 2016 06:21:42 +0000
From: "Robin H. Johnson" <robbat2@gentoo.org>
Subject: Re: drm/radeon spamming alloc_contig_range: [xxx, yyy) PFNs busy busy
Message-ID: <20161201062142.GA25917@orbis-terrarum.net>
References: <robbat2-20161129T223723-754929513Z@orbis-terrarum.net>
 <20161130092239.GD18437@dhcp22.suse.cz>
 <xa1ty4012k0f.fsf@mina86.com>
 <20161130132848.GG18432@dhcp22.suse.cz>
 <robbat2-20161130T195244-998539995Z@orbis-terrarum.net>
 <robbat2-20161130T195846-190979177Z@orbis-terrarum.net>
 <9d6e922b-d853-f24d-353c-25fbac38115b@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="lrZ03NoBR/3+SXJZ"
Content-Disposition: inline
In-Reply-To: <9d6e922b-d853-f24d-353c-25fbac38115b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Robin H. Johnson" <robbat2@gentoo.org>, Michal Hocko <mhocko@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 30, 2016 at 10:24:59PM +0100, Vlastimil Babka wrote:
> [add more CC's]
>=20
> On 11/30/2016 09:19 PM, Robin H. Johnson wrote:
> > Somewhere in the Radeon/DRM codebase, CMA page allocation has either
> > regressed in the timeline of 4.5->4.9, and/or the drm/radeon code is
> > doing something different with pages.
>=20
> Could be that it didn't use dma_generic_alloc_coherent() before, or you d=
idn't=20
> have the generic CMA pool configured.
v4.9-rc7-23-gded6e842cf49:
[    0.000000] cma: Reserved 16 MiB at 0x000000083e400000
[    0.000000] Memory: 32883108K/33519432K available (6752K kernel code, 12=
44K
rwdata, 4716K rodata, 1772K init, 2720K bss, 619940K reserved, 16384K
cma-reserved)

> What's the output of "grep CMA" on your=20
> .config?

# grep CMA .config |grep -v -e SECMARK=3D -e CONFIG_BCMA -e CONFIG_USB_HCD_=
BCMA -e INPUT_CMA3000 -e CRYPTO_CMAC
CONFIG_CMA=3Dy
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=3D7
CONFIG_DMA_CMA=3Dy
CONFIG_CMA_SIZE_MBYTES=3D16
CONFIG_CMA_SIZE_SEL_MBYTES=3Dy
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=3D8

> Or any kernel boot options with cma in name?=20
None.


> By default config this should not be used on x86.
What do you mean by that statement?=20
It should be disallowed to enable CONFIG_CMA? Radeon and CMA should be
mutually exclusive?

> > Given that I haven't seen ANY other reports of this, I'm inclined to
> > believe the problem is drm/radeon specific (if I don't start X, I can't
> > reproduce the problem).
>=20
> It's rather CMA specific, the allocation attemps just can't be 100% relia=
ble due=20
> to how CMA works. The question is if it should be spewing in the log in t=
he=20
> context of dma-cma, which has a fallback allocation option. It even uses=
=20
> __GFP_NOWARN, perhaps the CMA path should respect that?
Yes, I'd say if there's a fallback without much penalty, nowarn makes
sense. If the fallback just tries multiple addresses until success, then
the warning should only be issued when too many attempts have been made.

>=20
> > The rate of the problem starts slow, and also is relatively low on an i=
dle
> > system (my screens blank at night, no xscreensaver running), but it sti=
ll ramps
> > up over time (to the point of generating 2.5GB/hour of "(timestamp)
> > alloc_contig_range: [83e4d9, 83e4da) PFNs busy"), with various addresse=
s (~100
> > unique ranges for a day).
> >
> > My X workload is ~50 chrome tabs and ~20 terminals (over 3x 24" monitor=
s w/ 9
> > virtual desktops per monitor).
> So IIUC, except the messages, everything actually works fine?
There's high kernel CPU usage that seems to roughly correlate with the
messages, but I can't yet tell if that's due to the syslog itself, or
repeated alloc_contig_range requests.

--=20
Robin Hugh Johnson
Gentoo Linux: Dev, Infra Lead, Foundation Trustee & Treasurer
E-Mail   : robbat2@gentoo.org
GnuPG FP : 11ACBA4F 4778E3F6 E4EDF38E B27B944E 34884E85
GnuPG FP : 7D0B3CEB E9B85B1F 825BCECF EE05E6F6 A48F6136

--lrZ03NoBR/3+SXJZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.1
Comment: Robbat2 @ Orbis-Terrarum Networks - The text below is a digital signature. If it doesn't make any sense to you, ignore it.

iQJ8BAEBCgBmBQJYP8F1XxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRDQjJEMjlCMjBCMkM5MUFDQzE2NDk2NkRB
RTcyMjg3ODM3QzU5RjVGAAoJEK5yKHg3xZ9fZH0P/1Ou2BaU2z0bXwN+AzdoPHZt
Uhb86N9IqHNeofp5xdoUinJNzdhJQLW2t/9CDwe/94qTDHkn+tuNEkGH8xFzoC9b
v4j/c7q+vygg+//IWQ2TbUrisXEjggyjUNlapnp/372zVATZ3kERr+Gn88cygt9j
D0bvTc8Tb9VDPXtdwIPRjDxZCEs3ykaBYKDPM6CBCmx6M16iaeat0mC0MDZgwz3m
7TuDi6x++KhOtnMyfo09z3NJv4TmynVKayQekIeHGeutxbtg9XhnK405wCqYPdNt
piY3zeaOYAt+Fjv23GJn2MXthnoQb77pZEq7WChqiYZfFscs9GnU0BOJboRggJ6H
Nn5/1v9tVrlr8xjuDLJG0jvCN41ZtOXcKCG+1QleZGRSH3OEWcgaOiXoSBdgvvLh
1cYJsJukHQ5vkTc8h8pU4JAsOLhYBJKeAWDSWzBE7Xz2tfjbAhyH9DJkqkA4HIym
2UrSkT0LePPfSrw1W/I4l4yjf78a07VvdabaEi9KSG8gZhDHMRQqfO1Qa2jNFqz8
HxrHfH1pJIISOE9FZreOWXaYyLBSMFKZOKiH0yjx3K97wUX3S5gFLHOPsjfKcS87
g3C/hzFo52Wy2ACyO2TqKyQPGAQCrWWTUi3Znw58Iz3Pa5IGDjwuBcjnOndvpvNN
RG0ZAild49gzXrIfE8xw
=VE+M
-----END PGP SIGNATURE-----

--lrZ03NoBR/3+SXJZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
