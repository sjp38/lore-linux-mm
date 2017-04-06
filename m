Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2AAC6B039F
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 19:48:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m33so8217075wrm.23
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 16:48:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k79si5094322wmd.51.2017.04.06.16.48.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 16:48:13 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Apr 2017 09:47:32 +1000
Subject: [PATCH v3] loop: Add PF_LESS_THROTTLE to block/loop device thread.
In-Reply-To: <20170406065326.GB5497@dhcp22.suse.cz>
References: <871staffus.fsf@notabene.neil.brown.name> <87wpazh3rl.fsf@notabene.neil.brown.name> <20170405071927.GA7258@dhcp22.suse.cz> <20170405073233.GD6035@dhcp22.suse.cz> <878tnegtoo.fsf@notabene.neil.brown.name> <20170406065326.GB5497@dhcp22.suse.cz>
Message-ID: <87o9w9yu7f.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ming Lei <tom.leiming@gmail.com>

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
Reviewed-by: Ming Lei <tom.leiming@gmail.com>
Suggested-by: Michal Hocko <mhocko@suse.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

Hi Jens,
 I think this version meets with everyone's approval.

Thanks,
NeilBrown


 drivers/block/loop.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 0ecb6461ed81..035b8651b8bf 100644
=2D-- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -844,10 +844,16 @@ static void loop_unprepare_queue(struct loop_device *=
lo)
 	kthread_stop(lo->worker_task);
 }
=20
+static int loop_kthread_worker_fn(void *worker_ptr)
+{
+	current->flags |=3D PF_LESS_THROTTLE;
+	return kthread_worker_fn(worker_ptr);
+}
+
 static int loop_prepare_queue(struct loop_device *lo)
 {
 	kthread_init_worker(&lo->worker);
=2D	lo->worker_task =3D kthread_run(kthread_worker_fn,
+	lo->worker_task =3D kthread_run(loop_kthread_worker_fn,
 			&lo->worker, "loop%d", lo->lo_number);
 	if (IS_ERR(lo->worker_task))
 		return -ENOMEM;
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljm05QACgkQOeye3VZi
gbn4cw/+NsFUKuHxkgtl1GFr33VMY74tjDH1pU44pMj0k75+ocjbgfH/86cNrJxs
otqw0AXjILPI4oJo3LanwBCKbx6J7DRCml654AgckyztaksSftmzfvsY9Vg5gvqS
M5kX7Wi++HXluhZGqfN8tAZ7unQDqgaI2Io9FjZIsphgH+4qKB8MbWi+QoqziUnk
koZylFmXTxZcVa0NVe1P6fmMO9UJZsY2WFuaRosWFBn6fr8p2EYf1Q9FydFOng3n
ovM/nASMNlfS4mUrqkGQu0wpzU3ckYG0EgFBFUG4PC0zaLjl6hkf0N3RKg6e9LW5
fo3auYMkqcQ8Yv8BHDNrRxlaPVajfVmXt2ssluNu0LgwqRoS7hLZUwBA1px+OwTC
kLp3IrXLiHk945uUNaAZMUuqeV4sFIWghRF2IlBmMPBUgvjHAYg+X06OXfepCYSF
o9XSEufaB3EUejrurxAbukx1V6rEZtBZv16PMQGkjJAF9s3OuTLizL+kdspKsnZu
yN64nwNhBZC3hEtijyiFrcHvKFZAmV3O3PKa64SEwMHmZzIigrBcfzjlyjUZCbrW
CXzDvkUMccgIQhlHewuJ+tdI8MFIrayLihNJyC0aBCjy4NXT3D0UP2wN5BIltl0C
d14giCYX+29xhryYSVBvx0BuQuMKVf99svnwhZ/ocqM+CBGAxS8=
=kdw3
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
