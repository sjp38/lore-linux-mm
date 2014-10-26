Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9FA6B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 01:41:18 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so3696968pdj.19
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 22:41:17 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ff1si7619912pbc.179.2014.10.25.22.41.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Oct 2014 22:41:17 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so1010568pab.24
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 22:41:16 -0700 (PDT)
Date: Sun, 26 Oct 2014 14:41:39 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 2/2] zram: avoid NULL pointer access when reading
 mem_used_total
Message-ID: <20141026054139.GA952@swordfish>
References: <000101cff035$d9f50480$8ddf0d80$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <000101cff035$d9f50480$8ddf0d80$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman' <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang' <weijie.yang.kh@gmail.com>

On (10/25/14 17:26), Weijie Yang wrote:
> Date: Sat, 25 Oct 2014 17:26:31 +0800
> From: Weijie Yang <weijie.yang@samsung.com>
> To: 'Minchan Kim' <minchan@kernel.org>
> Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Dan Streetman'
>  <ddstreet@ieee.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>,
>  'Nitin Gupta' <ngupta@vflare.org>, 'Linux-MM' <linux-mm@kvack.org>,
>  'linux-kernel' <linux-kernel@vger.kernel.org>, 'Weijie Yang'
>  <weijie.yang.kh@gmail.com>
> Subject: [PATCH 2/2] zram: avoid NULL pointer access when reading
>  mem_used_total
> X-Mailer: Microsoft Office Outlook 12.0
>=20
> There is a rare NULL pointer bug in mem_used_total_show() in concurrent
> situation, like this:
> zram is not initialized, process A is a mem_used_total reader which runs
> periodicity, while process B try to init zram.
>=20
> 	process A 				process B
> access meta, get a NULL value
> 						init zram, done
> init_done() is true
> access meta->mem_pool, get a NULL pointer BUG
>=20
> This patch fixes this issue.
> =09
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
>  drivers/block/zram/zram_drv.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 64dd79a..2ffd7d8 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -99,11 +99,12 @@ static ssize_t mem_used_total_show(struct device *dev,
>  {
>  	u64 val =3D 0;
>  	struct zram *zram =3D dev_to_zram(dev);
> -	struct zram_meta *meta =3D zram->meta;
> =20
>  	down_read(&zram->init_lock);
> -	if (init_done(zram))
> +	if (init_done(zram)) {
> +		struct zram_meta *meta =3D zram->meta;
>  		val =3D zs_get_total_pages(meta->mem_pool);
> +	}
>  	up_read(&zram->init_lock);
> =20
>  	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
> --=20
> 1.7.0.4
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
