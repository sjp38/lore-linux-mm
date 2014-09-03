Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5426B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 20:02:10 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id s7so8615677lbd.35
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 17:02:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u14si553783lal.70.2014.09.02.17.02.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 17:02:09 -0700 (PDT)
Date: Wed, 3 Sep 2014 10:01:58 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: ext4 vs btrfs performance on SSD array
Message-ID: <20140903100158.34916d34@notabene.brown>
In-Reply-To: <20140902012222.GA21405@infradead.org>
References: <CAEp=YLgzsLbmEfGB5YKVcHP4CQ-_z1yxnZ0tpo7gjKZ2e1ma5g@mail.gmail.com>
	<20140902000822.GA20473@dastard>
	<20140902012222.GA21405@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/qpHnXvwX/9xC8Ii9lSW1zc6"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Nikolai Grigoriev <ngrigoriev@gmail.com>, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

--Sig_/qpHnXvwX/9xC8Ii9lSW1zc6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 1 Sep 2014 18:22:22 -0700 Christoph Hellwig <hch@infradead.org> wro=
te:

> On Tue, Sep 02, 2014 at 10:08:22AM +1000, Dave Chinner wrote:
> > Pretty obvious difference: avgrq-sz. btrfs is doing 512k IOs, ext4
> > and XFS are doing is doing 128k IOs because that's the default block
> > device readahead size.  'blockdev --setra 1024 /dev/sdd' before
> > mounting the filesystem will probably fix it.
>=20
> Btw, it's really getting time to make Linux storage fs work out the
> box.  There's way to many things that are stupid by default and we
> require everyone to fix up manually:
>=20
>  - the ridiculously low max_sectors default
>  - the very small max readahead size
>  - replacing cfq with deadline (or noop)
>  - the too small RAID5 stripe cache size
>=20
> and probably a few I forgot about.  It's time to make things perform
> well out of the box..

Do we still need maximums at all?
There was a time when the queue limit in the block device (or bdi) was an
important part of the write throttle strategy.  Without a queue limit, all =
of
memory could be consumed by memory in write-back, all queued for some devic=
e.
This wasn't healthy.

But since then the write throttling has been completely re-written.  I'm not
certain (and should check) but I suspect it doesn't depend on submit_bio
blocking when the queue is full any more.

So can we just remove the limit on max_sectors and the RAID5 stripe cache
size?  I'm certainly keen to remove the later and just use a mempool if the
limit isn't needed.
I have seen reports that a very large raid5 stripe cache size can cause
a reduction in performance.  I don't know why but I suspect it is a bug that
should be found and fixed.

Do we need max_sectors ??

NeilBrown

--Sig_/qpHnXvwX/9xC8Ii9lSW1zc6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVAZadjnsnt1WYoG5AQLXJxAAsX82VcFvlQc6mqiIU+TEQnmCi8QD+eVl
2Z7u275tYXvLAJaT9dfuQ+4lq47r6zoLLg4GvFRZVzgK9I+uVbSsAE03Fo64vgNh
6nyGTop2r4LE30actF2JsbijBnhduzIhMKArQ54k/839hSL0YELi9sTiMG+R4UFd
I8OzGnNCXP35PmmomgSZUs7D8UvzyAaLQRakVSKpTqnTAQDzYhrLTnIBlQSK78am
8TdyrcYQgjjVE9kPzjGasFv1ME4t3wxa8/t8+e9kxwDInqbie0leNAqPuzOexZcv
eIfYmsaXLUnzVIucz2/8VUUfGZRa2aor7mSD/DDq3OhjlDRgL/RBCaWCGBRHGX5F
+RT2lQnYXK0YoOekBZexL8DG428E3y1fG4zLd2nYk9qMxZia3ARqQRakKTpCJFez
D1DU2dAm8g8EEkbs+f8GTvnfmKuShjYJh83PH2w0XwHkVc9l6M7HvmInXp+RlKBW
a9jpR2EyLYCEjsOaz5gtdPBr8ZwJpu6DVRn8b19Y3sfX2mvKXRSfNwOirfM8W2qM
CiT7DX92QVABt4mY8BiGbMJXRggxNPeeiu+YZfB2ENSZeNkRk5+oM6tvrBDUR0qQ
l0Upw+3XbR4uBAvXrJNknW+F5uSLphgqfxLYsyNFP36E80ABGmD6bTQznA/sYzxH
T6H52iExhno=
=DHQt
-----END PGP SIGNATURE-----

--Sig_/qpHnXvwX/9xC8Ii9lSW1zc6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
