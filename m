Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 18F746B0397
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 00:33:59 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id i18so171197wrb.21
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 21:33:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si22192820wru.100.2017.04.04.21.33.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Apr 2017 21:33:57 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Wed, 05 Apr 2017 14:33:50 +1000
Subject: [PATCH v2] loop: Add PF_LESS_THROTTLE to block/loop device thread.
In-Reply-To: <871staffus.fsf@notabene.neil.brown.name>
References: <871staffus.fsf@notabene.neil.brown.name>
Message-ID: <87wpazh3rl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ming Lei <tom.leiming@gmail.com>

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

Reviewed-by: Christoph Hellwig <hch@lst.de>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

I moved where the flag is set, thanks to suggestion from
Ming Lei.
I've preserved the *-by: tags I was offered despite the code
being different, as the concept is identical.

Thanks,
NeilBrown


 drivers/block/loop.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 0ecb6461ed81..44b3506fd086 100644
=2D-- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -852,6 +852,7 @@ static int loop_prepare_queue(struct loop_device *lo)
 	if (IS_ERR(lo->worker_task))
 		return -ENOMEM;
 	set_user_nice(lo->worker_task, MIN_NICE);
+	lo->worker_task->flags |=3D PF_LESS_THROTTLE;
 	return 0;
 }
=20
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljkc64ACgkQOeye3VZi
gbnVGRAAm447mJ9FGwuu/YvHatsA5po34D2bCIOnY/UKUyPPioo1IEUxPI4OvBlc
Y7fBt4LX5S8MTV/DnxtzKNiQrCw80uHlOVW9tZG7ohoRGFher3t6PB044bjN9gD7
jfyStD22FoZCUy3qjCqeClom4noz0TyBep43gqoqIL1t1ko3CQLQ9y3w8SgL2b7f
HKoP0BhmIWfvmpPxv+PzthU9ShsD6sleYvV6X7IifiLoccuUD6/laqYv7AQSKT9A
8XSC8TKFvwRtp/ur86bhoWD9ksle9AwowiFuvQRjZVOUqgE79HazEdBm523TI+Hv
o3BDEQMiKOKMTsxq6azbEh75NEAQkkxrMxew5c0ar90p9qUfJYJtiOsq5XdUxd2X
5W+NcqhEkFl081FEEk/vQeZcTW4KzKF9i5wFpx5T44ta90h7rPxWsUy5dL7iU6f/
D1hbpDzDQpu4l7SUl9sSUb9Sy6RA4iBNfe42KQfiSJfz5vbFFx7nEYQE3GXNcAys
N08W6lmQUmKKrRbEE3OFFprgnkq/JdKr+ZegBzFQYCW0Crswfxf+ZpTGVf2E4mT5
7KYeEXg9YSHUy/nXnUYbujRwGSK6Yotub7Yv1pOmIVJiVxCPVOLQz0uX/xmQ+t1T
syRGEtjdoI0z5BVbEd49wdcYDzpONM8mETsSYrd+0fgYn3U/kcE=
=FW4L
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
