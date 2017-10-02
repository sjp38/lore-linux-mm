Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B4E656B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 04:41:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so4278182wmu.2
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 01:41:33 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id w65si7114463wmg.33.2017.10.02.01.41.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 01:41:32 -0700 (PDT)
Date: Mon, 2 Oct 2017 10:41:31 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: 4.14-rc2 on thinkpad x220: out of memory when inserting mmc card
Message-ID: <20171002084131.GA24414@amd>
References: <20170905194739.GA31241@amd>
 <20171001093704.GA12626@amd>
 <20171001102647.GA23908@amd>
 <201710011957.ICF15708.OOLOHFSQMFFVJt@I-love.SAKURA.ne.jp>
 <72c93a69-610f-027e-c028-379b97b6f388@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline
In-Reply-To: <72c93a69-610f-027e-c028-379b97b6f388@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-mm@kvack.org, linus walleij <linus.walleij@linaro.org>


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> The memory allocation used to be optional but became mandatory with:
>=20
>   commit 304419d8a7e9204c5d19b704467b814df8c8f5b1
>   Author: Linus Walleij <linus.walleij@linaro.org>
>   Date:   Thu May 18 11:29:32 2017 +0200
>=20
>       mmc: core: Allocate per-request data using the block layer core
>=20
> There is also a bug in mmc_init_request() where it doesn't free it's
> allocations on the error path, so you might want to check if you are leak=
ing
> memory.

At this point, I don't really care about memory leaks.

But allocating 64KiB, and expecting the allocation to work is quite a
big no-no. Does code need to switch to vmalloc or something?

> Bounce buffers are being removed from v4.15 although you may experience
> performance regression with that:
>=20
> 	https://marc.info/?l=3Dlinux-mmc&m=3D150589778700551

Hmm. The performance of this is already pretty bad, I really hope it
does not get any worse.

								Pavel

>=20
>=20
> On 01/10/17 13:57, Tetsuo Handa wrote:
> > Pavel Machek wrote:
> >> Hi!
> >>
> >>> I inserted u-SD card, only to realize that it is not detected as it
> >>> should be. And dmesg indeed reveals:
> >>
> >> Tetsuo asked me to report this to linux-mm.
> >>
> >> But 2^4 is 16 pages, IIRC that can't be expected to work reliably, and
> >> thus this sounds like MMC bug, not mm bug.
> >=20
> > Yes, 16 pages is costly allocations which will fail without invoking the
> > OOM killer. But I thought this is an interesting case, for mempool
> > allocation should be able to handle memory allocation failure except
> > initial allocations, and initial allocation is failing.
> >=20
> > I think that using kvmalloc() (and converting corresponding kfree() to
> > kvfree()) will make initial allocations succeed, but that might cause
> > needlessly succeeding subsequent mempool allocations under memory press=
ure?
> >=20
> >>
> >>> [10994.299846] mmc0: new high speed SDHC card at address 0003
> >>> [10994.302196] kworker/2:1: page allocation failure: order:4,
> >>> mode:0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=3D(null)
> >>> [10994.302212] CPU: 2 PID: 9500 Comm: kworker/2:1 Not tainted
> >>> 4.14.0-rc2 #135
> >>> [10994.302215] Hardware name: LENOVO 42872WU/42872WU, BIOS 8DET73WW
> >>> (1.43 ) 10/12/2016
> >>> [10994.302222] Workqueue: events_freezable mmc_rescan
> >>> [10994.302227] Call Trace:
> >>> [10994.302233]  dump_stack+0x4d/0x67
> >>> [10994.302239]  warn_alloc+0xde/0x180
> >>> [10994.302243]  __alloc_pages_nodemask+0xaa4/0xd30
> >>> [10994.302249]  ? cache_alloc_refill+0xb73/0xc10
> >>> [10994.302252]  cache_alloc_refill+0x101/0xc10
> >>> [10994.302258]  ? mmc_init_request+0x2d/0xd0
> >>> [10994.302262]  ? mmc_init_request+0x2d/0xd0
> >>> [10994.302265]  __kmalloc+0xaf/0xe0
> >>> [10994.302269]  mmc_init_request+0x2d/0xd0
> >>> [10994.302273]  alloc_request_size+0x45/0x60
> >>> [10994.302276]  ? free_request_size+0x30/0x30
> >>> [10994.302280]  mempool_create_node+0xd7/0x130
> >>> [10994.302283]  ? alloc_request_simple+0x20/0x20
> >>> [10994.302287]  blk_init_rl+0xe8/0x110
> >>> [10994.302290]  blk_init_allocated_queue+0x70/0x180
> >>> [10994.302294]  mmc_init_queue+0xdd/0x370
> >>> [10994.302297]  mmc_blk_alloc_req+0xf6/0x340
> >>> [10994.302301]  mmc_blk_probe+0x18b/0x4e0
> >>> [10994.302305]  mmc_bus_probe+0x12/0x20
> >>> [10994.302309]  driver_probe_device+0x2f4/0x490
> >>>
> >>> Order 4 allocations are not supposed to be reliable...
> >>>
> >>> Any ideas?
> >>>
> >>> Thanks,
> >>> 									Pavel
> >>>
> >>
> >>
> >>
> >> --=20
> >> (english) http://www.livejournal.com/~pavelmachek
> >> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horse=
s/blog.html
> >=20

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--J/dobhs11T7y2rNN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnR+7sACgkQMOfwapXb+vI6iwCgqs+IWQlzfJbWTZIQQ2YL0kDc
jykAoJJEvjRoGKsY3l1rqnixkRu1Wefv
=aAr+
-----END PGP SIGNATURE-----

--J/dobhs11T7y2rNN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
