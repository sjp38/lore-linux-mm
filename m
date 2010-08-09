Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 032716B02D9
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 15:03:52 -0400 (EDT)
Received: by gwj16 with SMTP id 16so4584744gwj.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 12:03:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-7-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-7-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 22:03:50 +0300
Message-ID: <AANLkTimtdLb4Mk81fmCwksPR0GbTEaGZbo888OFefjXK@mail.gmail.com>
Subject: Re: [PATCH 06/10] Block discard support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, jaxboe@fusionio.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> The 'discard' bio discard request provides information to
> zram disks regarding blocks which are no longer in use by
> filesystem. This allows freeing memory allocated for such
> blocks.
>
> When zram devices are used as swap disks, we already have
> a callback (block_device_operations->swap_slot_free_notify).
> So, the discard support is useful only when used as generic
> (non-swap) disk.
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

Lets CC fsdevel and Jens for this.

> ---
> =A0drivers/staging/zram/zram_drv.c =A0 | =A0 25 +++++++++++++++++++++++++
> =A0drivers/staging/zram/zram_sysfs.c | =A0 11 +++++++++++
> =A02 files changed, 36 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_=
drv.c
> index efe9c93..0f9785f 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -420,6 +420,20 @@ out:
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static void zram_discard(struct zram *zram, struct bio *bio)
> +{
> + =A0 =A0 =A0 size_t bytes =3D bio->bi_size;
> + =A0 =A0 =A0 sector_t sector =3D bio->bi_sector;
> +
> + =A0 =A0 =A0 while (bytes >=3D PAGE_SIZE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zram_free_page(zram, sector >> SECTORS_PER_=
PAGE_SHIFT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sector +=3D PAGE_SIZE >> SECTOR_SHIFT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bytes -=3D PAGE_SIZE;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 bio_endio(bio, 0);
> +}
> +
> =A0/*
> =A0* Check if request is within bounds and page aligned.
> =A0*/
> @@ -451,6 +465,12 @@ static int zram_make_request(struct request_queue *q=
ueue, struct bio *bio)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (unlikely(bio_rw_flagged(bio, BIO_RW_DISCARD))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zram_inc_stat(zram, ZRAM_STAT_DISCARD);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zram_discard(zram, bio);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0switch (bio_data_dir(bio)) {
> =A0 =A0 =A0 =A0case READ:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D zram_read(zram, bio);
> @@ -606,6 +626,11 @@ static int create_device(struct zram *zram, int devi=
ce_id)
> =A0 =A0 =A0 =A0blk_queue_io_min(zram->disk->queue, PAGE_SIZE);
> =A0 =A0 =A0 =A0blk_queue_io_opt(zram->disk->queue, PAGE_SIZE);
>
> + =A0 =A0 =A0 zram->disk->queue->limits.discard_granularity =3D PAGE_SIZE=
;
> + =A0 =A0 =A0 zram->disk->queue->limits.max_discard_sectors =3D UINT_MAX;
> + =A0 =A0 =A0 zram->disk->queue->limits.discard_zeroes_data =3D 1;
> + =A0 =A0 =A0 queue_flag_set_unlocked(QUEUE_FLAG_DISCARD, zram->queue);
> +
> =A0 =A0 =A0 =A0add_disk(zram->disk);
>
> =A0#ifdef CONFIG_SYSFS
> diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zra=
m_sysfs.c
> index 43bcdd4..74971c0 100644
> --- a/drivers/staging/zram/zram_sysfs.c
> +++ b/drivers/staging/zram/zram_sysfs.c
> @@ -165,6 +165,15 @@ static ssize_t notify_free_show(struct device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0zram_get_stat(zram, ZRAM_STAT_NOTIFY_FREE)=
);
> =A0}
>
> +static ssize_t discard_show(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_attribute *attr, char *buf)
> +{
> + =A0 =A0 =A0 struct zram *zram =3D dev_to_zram(dev);
> +
> + =A0 =A0 =A0 return sprintf(buf, "%llu\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zram_get_stat(zram, ZRAM_STAT_DISCARD));
> +}
> +
> =A0static ssize_t zero_pages_show(struct device *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct device_attribute *attr, char *buf)
> =A0{
> @@ -215,6 +224,7 @@ static DEVICE_ATTR(num_reads, S_IRUGO, num_reads_show=
, NULL);
> =A0static DEVICE_ATTR(num_writes, S_IRUGO, num_writes_show, NULL);
> =A0static DEVICE_ATTR(invalid_io, S_IRUGO, invalid_io_show, NULL);
> =A0static DEVICE_ATTR(notify_free, S_IRUGO, notify_free_show, NULL);
> +static DEVICE_ATTR(discard, S_IRUGO, discard_show, NULL);
> =A0static DEVICE_ATTR(zero_pages, S_IRUGO, zero_pages_show, NULL);
> =A0static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL)=
;
> =A0static DEVICE_ATTR(compr_data_size, S_IRUGO, compr_data_size_show, NUL=
L);
> @@ -228,6 +238,7 @@ static struct attribute *zram_disk_attrs[] =3D {
> =A0 =A0 =A0 =A0&dev_attr_num_writes.attr,
> =A0 =A0 =A0 =A0&dev_attr_invalid_io.attr,
> =A0 =A0 =A0 =A0&dev_attr_notify_free.attr,
> + =A0 =A0 =A0 &dev_attr_discard.attr,
> =A0 =A0 =A0 =A0&dev_attr_zero_pages.attr,
> =A0 =A0 =A0 =A0&dev_attr_orig_data_size.attr,
> =A0 =A0 =A0 =A0&dev_attr_compr_data_size.attr,
> --
> 1.7.2.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
