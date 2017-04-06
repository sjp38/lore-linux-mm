Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E15EA6B03DD
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 22:24:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a80so1618928wrc.19
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 19:24:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b70si285178wrd.219.2017.04.05.19.24.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 19:24:51 -0700 (PDT)
From: NeilBrown <neilb@suse.com>
Date: Thu, 06 Apr 2017 12:23:51 +1000
Subject: Re: [PATCH v2] loop: Add PF_LESS_THROTTLE to block/loop device thread.
In-Reply-To: <20170405073233.GD6035@dhcp22.suse.cz>
References: <871staffus.fsf@notabene.neil.brown.name> <87wpazh3rl.fsf@notabene.neil.brown.name> <20170405071927.GA7258@dhcp22.suse.cz> <20170405073233.GD6035@dhcp22.suse.cz>
Message-ID: <878tnegtoo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ming Lei <tom.leiming@gmail.com>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 05 2017, Michal Hocko wrote:

> On Wed 05-04-17 09:19:27, Michal Hocko wrote:
>> On Wed 05-04-17 14:33:50, NeilBrown wrote:
> [...]
>> > diff --git a/drivers/block/loop.c b/drivers/block/loop.c
>> > index 0ecb6461ed81..44b3506fd086 100644
>> > --- a/drivers/block/loop.c
>> > +++ b/drivers/block/loop.c
>> > @@ -852,6 +852,7 @@ static int loop_prepare_queue(struct loop_device *=
lo)
>> >  	if (IS_ERR(lo->worker_task))
>> >  		return -ENOMEM;
>> >  	set_user_nice(lo->worker_task, MIN_NICE);
>> > +	lo->worker_task->flags |=3D PF_LESS_THROTTLE;
>> >  	return 0;
>>=20
>> As mentioned elsewhere, PF flags should be updated only on the current
>> task otherwise there is potential rmw race. Is this safe? The code runs
>> concurrently with the worker thread.
>
> I believe you need something like this instead
> ---
> diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> index f347285c67ec..07b2a909e4fb 100644
> --- a/drivers/block/loop.c
> +++ b/drivers/block/loop.c
> @@ -844,10 +844,16 @@ static void loop_unprepare_queue(struct loop_device=
 *lo)
>  	kthread_stop(lo->worker_task);
>  }
>=20=20
> +int loop_kthread_worker_fn(void *worker_ptr)
> +{
> +	current->flags |=3D PF_LESS_THROTTLE;
> +	return kthread_worker_fn(worker_ptr);
> +}
> +
>  static int loop_prepare_queue(struct loop_device *lo)
>  {
>  	kthread_init_worker(&lo->worker);
> -	lo->worker_task =3D kthread_run(kthread_worker_fn,
> +	lo->worker_task =3D kthread_run(loop_kthread_worker_fn,
>  			&lo->worker, "loop%d", lo->lo_number);
>  	if (IS_ERR(lo->worker_task))
>  		return -ENOMEM;

Arg - of course.
How about we just split the kthread_create from the wake_up?

Thanks,
NeilBrown


From: NeilBrown <neilb@suse.com>
Subject: [PATCH] loop: Add PF_LESS_THROTTLE to block/loop device thread.

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
 drivers/block/loop.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index 0ecb6461ed81..95679d988725 100644
=2D-- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -847,10 +847,12 @@ static void loop_unprepare_queue(struct loop_device *=
lo)
 static int loop_prepare_queue(struct loop_device *lo)
 {
 	kthread_init_worker(&lo->worker);
=2D	lo->worker_task =3D kthread_run(kthread_worker_fn,
+	lo->worker_task =3D kthread_create(kthread_worker_fn,
 			&lo->worker, "loop%d", lo->lo_number);
 	if (IS_ERR(lo->worker_task))
 		return -ENOMEM;
+	lo->worker_task->flags |=3D PF_LESS_THROTTLE;
+	wake_up_process(lo->worker_task);
 	set_user_nice(lo->worker_task, MIN_NICE);
 	return 0;
 }
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljlprcACgkQOeye3VZi
gblZRQ/7BeHOJGPoRjeKz48keHq5kDiA9HwF/AAbwiOJy0Lp3EBQxBnhsT8X5H6z
h8Rv+ifQs44ypQaV5zNyxHeX5qbIyKqjWsljnlG8Jt/NN5NGIUiGbnHsFBJTsphy
WKaAgr5RcdBAqb6PoXPlcBbqEGIAVdVlfpDT2PsOI8EZSGVb5JnCYn9hBj4KUKhZ
k7lwgPIFoYgJ/7R7nsheC6t6rJd+vNQ5igPRJ//DLZR82ktmvKiPbxY2JAFH/n+5
3y9CsFE+Edw46rHPvCFPAaTBfqbQh/jtd17R/f/ZWqbnCY2yKlC3jDsywvdYnLtM
Qu+gYvBJ9F/GERQEVWdtEBgnB6HOJYwMlgW0fQMQYfLmToMwJn9nRx1544B4CpGo
JxOhk5sJ9k/A2oWd6T+rLCMCYjbSS9yutg5MFT15GFDlE6PWWOd8mXyhykRyeJe0
H+EzuWpod6nV986WbHzreAjrPxBEOQd36NQAhdj5Y7wuDWQ9Sstfb+81n7qnW+dd
fMuG+Gv03j+S22X2uq4JR5TjEkNQtFbZ/bnPG8Bd3/3V371xka2egmAAsndIasYW
T2geORbTyedzJ9Wqk6BUvOBR12svHQ502ztbc56P/oeYtcTKPov7WAQiGHysEHuv
VAEGSiDQw/oY6cw9PdlU27AzwHG2a9HprgAYd1xEy/ugcSpglKI=
=DFxu
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
