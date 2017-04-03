Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 365EE6B0038
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 21:19:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 34so21980387wrb.20
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 18:19:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si17775556wrd.118.2017.04.02.18.19.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 02 Apr 2017 18:19:32 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Mon, 03 Apr 2017 11:18:51 +1000
Subject: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.
Message-ID: <871staffus.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


When a filesystem is mounted from a loop device, writes are
throttled by balance_dirty_pages() twice: once when writing
to the filesystem and once when the loop_handle_cmd() writes
to the backing file.  This double-throttling can trigger
positive feedback loops that create significant delays.  The
throttling at the lower level is seen by the upper level as
a slow device, so it throttles extra hard.

The PF_LESS_THROTTLE flag was created to handle exactly this
circumstance, though with an NFS filesystem mounted from a
local NFS server.  It reduces the throttling on the lower
layer so that it can proceed largely unthrottled.

To demonstrate this, create a filesystem on a loop device
and write (e.g. with dd) several large files which combine
to consume significantly more than the limit set by
/proc/sys/vm/dirty_ratio or dirty_bytes.  Measure the total
time taken.

When I do this directly on a device (no loop device) the
total time for several runs (mkfs, mount, write 200 files,
umount) is fairly stable: 28-35 seconds.
When I do this over a loop device the times are much worse
and less stable.  52-460 seconds.  Half below 100seconds,
half above.
When I apply this patch, the times become stable again,
though not as fast as the no-loop-back case: 53-72 seconds.

There may be room for further improvement as the total overhead still
seems too high, but this is a big improvement.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 drivers/block/loop.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 0ecb6461ed81..a7e1dd215fc2 100644
=2D-- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -1694,8 +1694,11 @@ static void loop_queue_work(struct kthread_work *wor=
k)
 {
 	struct loop_cmd *cmd =3D
 		container_of(work, struct loop_cmd, work);
+	int oldflags =3D current->flags & PF_LESS_THROTTLE;
=20
+	current->flags |=3D PF_LESS_THROTTLE;
 	loop_handle_cmd(cmd);
+	current->flags =3D (current->flags & ~PF_LESS_THROTTLE) | oldflags;
 }
=20
 static int loop_init_request(void *data, struct request *rq,
=2D-=20
2.12.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljhovsACgkQOeye3VZi
gbkhDQ//SY6wAXMkTSNsEhRwQs7P7yxfPVdWT1VdE1Xw1cRXCXOXMYuOlaIlnLPe
BQXT9xW9U4qr00TSfB12XxsLUCkEvrGwNuOhEstBJt7zPOGfmSOaAAV3tchfSnot
FGdBgm4jTAOVbZ22Qh85mjO08s4vE+5MttzZk48kGHaYTUUQ6irgg4OWwLEmLs0S
7ntrF0rBZTpPsqmPXfK6ha21PnxmjbMr7rZ9yyN/Te7u/6EIjfokpFmajGTQ3f37
u+LnrpU4JspgPLk5VtklDo+W/QG5/K86BEV8LHXc24N6QJtjiXoNSdh46U2jJub3
ONhBaVy6UIfELOsKgMGzVXZoNVNV5j8q1RQ44R0eQ05nNI2JWoODXNjD+ky2/OfX
NrEciVbHdpCz5GSiJETxUg3goRf18w9xM1Pq4Bi1fFeXLU5dtLz1Nqp9+ByBgNnW
aUxrn2IbvqS66C3tQt9MVIvACHRG/MOIVOpHt83ax3kkP4vq58Zc+0K3s4QWvRWL
QiGpcCIa4Bp2AF6ZPBGuW0+FB7PVRPeOrroZLfombs41Ht8RvbUzDVq/p9ENlhY4
KEFTJTzjvZMO1Val5Kwz9HceUb/hEqGdG5CkgWRiIUj5pnE7/Tav2Jwxh3DI8J6k
4aaKeqAlB1TZMrm6HssXjiwPHxXMzI1THZA0X4pgK4VpjK3FcWk=
=6nwe
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
