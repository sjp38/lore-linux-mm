Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id C65AB6B013C
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 19:28:24 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id my13so96094bkb.36
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 16:28:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lx1si1684622bkb.291.2014.04.02.16.28.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 16:28:23 -0700 (PDT)
Date: Thu, 3 Apr 2014 10:28:11 +1100
From: NeilBrown <neilb@suse.de>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
Message-ID: <20140403102811.5e5110a8@notabene.brown>
In-Reply-To: <20140401140401.GZ7528@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com>
	<20140216225000.GO30257@n2100.arm.linux.org.uk>
	<1392670951.24429.10.camel@sakura.staff.proxad.net>
	<20140217210954.GA21483@n2100.arm.linux.org.uk>
	<20140315101952.GT21483@n2100.arm.linux.org.uk>
	<20140317180748.644d30e2@notabene.brown>
	<20140317181813.GA24144@arm.com>
	<20140317193316.GF21483@n2100.arm.linux.org.uk>
	<20140401091959.GA10912@n2100.arm.linux.org.uk>
	<20140401113851.GA15317@n2100.arm.linux.org.uk>
	<20140401140401.GZ7528@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/8Ru6lHIj_82KNviSBOcNypK"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kent Overstreet <koverstreet@google.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-raid@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Maxime Bizon <mbizon@freebox.fr>, linux-arm-kernel@lists.infradead.org

--Sig_/8Ru6lHIj_82KNviSBOcNypK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 1 Apr 2014 15:04:01 +0100 Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:

> On Tue, Apr 01, 2014 at 12:38:51PM +0100, Russell King - ARM Linux wrote:
> > Consider what happens when bio_alloc_pages() fails.  j starts off as one
> > for non-recovery operations, and we enter the loop to allocate the page=
s.
> > j is post-decremented to zero.  So, bio =3D r1_bio->bios[0].
> >=20
> > bio_alloc_pages(bio) fails, we jump to out_free_bio.  The first thing
> > that does is increment j, so we free from r1_bio->bios[1] up to the
> > number of raid disks, leaving r1_bio->bios[0] leaked as the r1_bio is
> > then freed.
>=20
> Neil,
>=20
> Can you please review commit a07876064a0b7 (block: Add bio_alloc_pages)
> which seems to have introduced this bug - it seems to have gone in during
> the v3.10 merge window, and looks like it was never reviewed from the
> attributations on the commit.
>=20
> The commit message is brief, and inadequately describes the functional
> change that the patch has - we go from "get up to RESYNC_PAGES into the
> bio's io_vec" to "get all RESYNC_PAGES or fail completely".
>=20
> Not withstanding the breakage of the error cleanup paths, is this an
> acceptable change of behaviour here?
>=20
> Thanks.
>=20

Hi Russell,
 thanks for finding that bug! - I'm sure I looked at that code, but obvious=
ly
 missed the problem :-(

Below is the fix that I plan to submit.  It is slightly different from yours
but should achieve the same effect.  If you could confirm that it looks good
to you I would appreciate it.

Thanks,
NeilBrown


=46rom 72dce88eee7259d65c6eba10c2e0beff357f713b Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Thu, 3 Apr 2014 10:19:12 +1100
Subject: [PATCH] md/raid1: r1buf_pool_alloc: free allocate pages when
 subsequent allocation fails.

When performing a user-request check/repair (MD_RECOVERY_REQUEST is set)
on a raid1, we allocate multiple bios each with their own set of pages.

If the page allocations for one bio fails, we currently do *not* free
the pages allocated for the previous bios, nor do we free the bio itself.

This patch frees all the already-allocate pages, and makes sure that
all the bios are freed as well.

This bug can cause a memory leak which can ultimately OOM a machine.
It was introduced in 3.10-rc1.

Fixes: a07876064a0b73ab5ef1ebcf14b1cf0231c07858
Cc: Kent Overstreet <koverstreet@google.com>
Cc: stable@vger.kernel.org (3.10+)
Reported-by: Russell King - ARM Linux <linux@arm.linux.org.uk>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
index 4a6ca1cb2e78..56e24c072b62 100644
--- a/drivers/md/raid1.c
+++ b/drivers/md/raid1.c
@@ -97,6 +97,7 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *dat=
a)
 	struct pool_info *pi =3D data;
 	struct r1bio *r1_bio;
 	struct bio *bio;
+	int need_pages;
 	int i, j;
=20
 	r1_bio =3D r1bio_pool_alloc(gfp_flags, pi);
@@ -119,15 +120,15 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void =
*data)
 	 * RESYNC_PAGES for each bio.
 	 */
 	if (test_bit(MD_RECOVERY_REQUESTED, &pi->mddev->recovery))
-		j =3D pi->raid_disks;
+		need_pages =3D pi->raid_disks;
 	else
-		j =3D 1;
-	while(j--) {
+		need_pages =3D 1;
+	for (j =3D 0; j < need_pages; j++) {
 		bio =3D r1_bio->bios[j];
 		bio->bi_vcnt =3D RESYNC_PAGES;
=20
 		if (bio_alloc_pages(bio, gfp_flags))
-			goto out_free_bio;
+			goto out_free_pages;
 	}
 	/* If not user-requests, copy the page pointers to all bios */
 	if (!test_bit(MD_RECOVERY_REQUESTED, &pi->mddev->recovery)) {
@@ -141,6 +142,14 @@ static void * r1buf_pool_alloc(gfp_t gfp_flags, void *=
data)
=20
 	return r1_bio;
=20
+out_free_pages:
+	while (--j >=3D 0) {
+		struct bio_vec *bv;
+
+		bio_for_each_segment_all(bv, r1_bio->bios[j], i)
+			__free_page(bv->bv_page);
+	}
+
 out_free_bio:
 	while (++j < pi->raid_disks)
 		bio_put(r1_bio->bios[j]);

--Sig_/8Ru6lHIj_82KNviSBOcNypK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUzydCznsnt1WYoG5AQK5ChAAwhnh1XalrwI5cRghCbWZUmiZnvw6aeOI
mhYUBOkyarpzWd5DLROYAT1cm6Hu5bjdic9ipKD1H6LTuFv+rkpI5F6f3AsLivGO
7VIOMxR04ngYKksWJKI6KqoZI9xMe0lvBaz4RATtZc3VEgEmMX3639If9EEHwBfu
4fQjnsYZPBUWAHGH26O215ZEEs+BxAjquNtc29opoXF90WxUmT/O5OwpwFSMFxNG
JD9OLHgYCzHHzsJKbR5lHmcP1lCwltkBo0DYkHaHZqVW1FP7Pb3JfMgjZDggjJBp
HGhvnX8DhizQdMneUnM2Qu3iZNjKtOM2uXGh+uh3DCvtD2TQ7MUMVdwuH0hBYsuO
pboZ/H5uMHrT5bZF3W+x2mMlt2saeD2KyNRV9/pA2ZZJiE86I1QIK/GYsfoRefsk
gnG4KDzltE47LmQg1mxyXjg+E6fxQGl7iWbPVkt01SNryOpq2cbrQ/EV4nsTg9yx
LgNMhZ27qFVAIg53plRreo4vJtFRB1suHVcvZ5rJ8KJRJerhB9xhMlNoCxJlpDtp
bPU0ajke3LKQOl4BLWYzRqbnNfmBtaazP8CWhcQvqMmo9tGTtgkT5+S39YZNRl2O
BhE+uVrBqKmvBk2ng9zlFtWXx0EP94Xz5APVjEHhId7T/oTbmB9GqMG/YbJmV4+i
0AqjuxR5upc=
=ykc+
-----END PGP SIGNATURE-----

--Sig_/8Ru6lHIj_82KNviSBOcNypK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
