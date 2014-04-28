Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id B5D116B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:16:32 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4543973eei.5
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 02:16:32 -0700 (PDT)
Received: from relay1.mentorg.com (relay1.mentorg.com. [192.94.38.131])
        by mx.google.com with ESMTPS id 45si22253248eeh.153.2014.04.28.02.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 02:09:45 -0700 (PDT)
From: Thomas Schwinge <thomas@codesourcery.com>
Subject: Re: radeon: screen garbled after page allocator change, was: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
In-Reply-To: <87sioxq3rx.fsf@schwinge.name>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org> <1375457846-21521-4-git-send-email-hannes@cmpxchg.org> <87r45fajun.fsf@schwinge.name> <20140424133722.GD4107@cmpxchg.org> <20140425214746.GC5915@gmail.com> <20140425215055.GD5915@gmail.com> <20140425230321.GG5915@gmail.com> <87sioxq3rx.fsf@schwinge.name>
Date: Mon, 28 Apr 2014 11:09:00 +0200
Message-ID: <87k3a9q0r7.fsf@schwinge.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-="; micalg=pgp-sha1;
	protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@surriel.com>, Andrea
 Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alex Deucher <alexander.deucher@amd.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, dri-devel@lists.freedesktop.org, Johannes
 Weiner <hannes@cmpxchg.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi!

On Mon, 28 Apr 2014 10:03:46 +0200, I wrote:
> On Fri, 25 Apr 2014 19:03:22 -0400, Jerome Glisse <j.glisse@gmail.com> wr=
ote:
> > On Fri, Apr 25, 2014 at 05:50:57PM -0400, Jerome Glisse wrote:
> > > On Fri, Apr 25, 2014 at 05:47:48PM -0400, Jerome Glisse wrote:
> > > > On Thu, Apr 24, 2014 at 09:37:22AM -0400, Johannes Weiner wrote:
> > > > > On Wed, Apr 02, 2014 at 04:26:08PM +0200, Thomas Schwinge wrote:
> > > > > > On Fri,  2 Aug 2013 11:37:26 -0400, Johannes Weiner <hannes@cmp=
xchg.org> wrote:
> > > > > > > Each zone that holds userspace pages of one workload must be =
aged at a
> > > > > > > speed proportional to the zone size.  [...]
> > > > > >=20
> > > > > > > Fix this with a very simple round robin allocator.  [...]
> > > > > >=20
> > > > > > This patch, adding NR_ALLOC_BATCH, eventually landed in mainlin=
e as
> > > > > > commit 81c0a2bb515fd4daae8cab64352877480792b515 (2013-09-11).
> > > > > >=20
> > > > > > I recently upgraded a Debian testing system from a 3.11 kernel =
to 3.12,
> > > > > > and it started to exhibit "strange" issues, which I then bisect=
ed to this
> > > > > > patch.  I'm not saying that the patch is faulty, as it seems to=
 be
> > > > > > working fine for everyone else, so I rather assume that somethi=
ng in a
> > > > > > (vastly?) different corner of the kernel (or my hardware?) is b=
roken.
> > > > > > ;-)
> > > > > >=20
> > > > > > The issue is that when X.org/lightdm starts up, there are "garb=
led"
> > > > > > section on the screen, for example, rectangular boxes that are =
just black
> > > > > > or otherwise "distorted", and/or sets of glyphs (corresponding =
to a set
> > > > > > of characters; but not all characters) are displayed as rectang=
ular gray
> > > > > > or black boxes, and/or icons in a GNOME session are not display=
ed
> > > > > > properly, and so on.  (Can take a snapshot if that helps?)  Swi=
tching to
> > > > > > a Linux console, I can use that one fine.  Switching back to X,=
 in the
> > > > > > majority of all cases, the screen will be completely black, but=
 with the
> > > > > > mouse cursor still rendered properly (done in hardware, I assum=
e).
> > > > > >=20
> > > > > > Reverting commit 81c0a2bb515fd4daae8cab64352877480792b515, for =
example on
> > > > > > top of v3.12, and everything is back to normal.  The problem al=
so
> > > > > > persists with a v3.14 kernel that I just built.

> > > > My guess is that the pcie bridge can only remap dma page with 32bit=
 dma
> > > > mask while the gpu is fine with 40bit dma mask. I always thought th=
at the
> > > > pcie/pci code did take care of such thing for us.
> > >=20
> > > Forgot to attach patch to test my theory. Does the attached patch fix
> > > the issue ?
>=20
> Unfortunately it does not.  :-/

Ha, the following seems to do it: additionally to dma_bits (your patch),
I'm also overriding need_dma32 for later use in
drivers/gpu/drm/ttm/ttm_bo.c:ttm_bo_add_ttm, I assume.  With that hack
applied, I have now rebooted a v3.14 build a few times, and so far things
"look" fine.

diff --git drivers/gpu/drm/radeon/radeon_device.c drivers/gpu/drm/radeon/ra=
deon_device.c
index 044bc98..90baf2f 100644
=2D-- drivers/gpu/drm/radeon/radeon_device.c
+++ drivers/gpu/drm/radeon/radeon_device.c
@@ -1243,6 +1243,8 @@ int radeon_device_init(struct radeon_device *rdev,
 		rdev->need_dma32 =3D true;
=20
 	dma_bits =3D rdev->need_dma32 ? 32 : 40;
+	dma_bits =3D 32;
+	rdev->need_dma32 =3D true;
 	r =3D pci_set_dma_mask(rdev->pdev, DMA_BIT_MASK(dma_bits));
 	if (r) {
 		rdev->need_dma32 =3D true;


Gr=C3=BC=C3=9Fe,
 Thomas

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQEcBAEBAgAGBQJTXhqsAAoJENuKOtuXzphJGMIH/RCTzpPcqXgxlpnyXYYGY1Hs
B9HYAtTZZS2QN0zQUo02ZG2CPqSUCNSyVEKvSR3Q9XcQw0y8SXVxc/nY3UxaJ1Bc
Ul9eRavAZJg1XOjJz/oqAonI6lQdz4uDX8xD7asqs7rKzlpb35dg4cSwXvvz1zdi
cD9xxVkaQRec0uQLEenToRGfB0LGa1u7bg3JPyRg1vtSOX6AGs2KA26CABLThxWm
7uU3pl05vtgeqJo9f0aveN1wXrkHMML1QxCOYLmZnYwcY20BwUPgon+V22f5Ioin
ZTQXSqAo2S69RN7eez8el6hO0gYofPgNzsTjJglU66FSYqAXKTsPd+nIVknmNog=
=coWV
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
