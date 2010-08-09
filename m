Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C99C6B02BA
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 14:34:50 -0400 (EDT)
Received: by gwj16 with SMTP id 16so4570001gwj.14
        for <linux-mm@kvack.org>; Mon, 09 Aug 2010 11:34:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1281374816-904-2-git-send-email-ngupta@vflare.org>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
	<1281374816-904-2-git-send-email-ngupta@vflare.org>
Date: Mon, 9 Aug 2010 21:34:48 +0300
Message-ID: <AANLkTimuPK=1+xNMKfV=G1sSG60+=fa7eA3142JJZZ6p@mail.gmail.com>
Subject: Re: [PATCH 01/10] Replace ioctls with sysfs interface
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 9, 2010 at 8:26 PM, Nitin Gupta <ngupta@vflare.org> wrote:
> Creates per-device sysfs nodes in /sys/block/zram<id>/
> Currently following stats are exported:
> =A0- disksize
> =A0- num_reads
> =A0- num_writes
> =A0- invalid_io
> =A0- zero_pages
> =A0- orig_data_size
> =A0- compr_data_size
> =A0- mem_used_total
>
> By default, disksize is set to 0. So, to start using
> a zram device, fist write a disksize value and then
> initialize device by writing any positive value to
> initstate. For example:
>
> =A0 =A0 =A0 =A0# initialize /dev/zram0 with 50MB disksize
> =A0 =A0 =A0 =A0echo 50*1024*1024 | bc > /sys/block/zram0/disksize
> =A0 =A0 =A0 =A0echo 1 > /sys/block/zram0/initstate
>
> When done using a disk, issue reset to free its memory
> by writing any positive value to reset node:
>
> =A0 =A0 =A0 =A0echo 1 > /sys/block/zram0/reset
>
> This change also obviates the need for 'rzscontrol' utility.
>
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>

Looks good to me (but I'm not a sysfs guy).

Acked-by: Pekka Enberg <penberg@kernel.org>

> =A0/* Module params (documentation at end) */
> -static unsigned int num_devices;
> +unsigned int num_devices;
> +
> +static void zram_stat_inc(u32 *v)
> +{
> + =A0 =A0 =A0 *v =3D *v + 1;
> +}
> +
> +static void zram_stat_dec(u32 *v)
> +{
> + =A0 =A0 =A0 *v =3D *v - 1;
> +}
> +
> +static void zram_stat64_add(struct zram *zram, u64 *v, u64 inc)
> +{
> + =A0 =A0 =A0 spin_lock(&zram->stat64_lock);
> + =A0 =A0 =A0 *v =3D *v + inc;
> + =A0 =A0 =A0 spin_unlock(&zram->stat64_lock);
> +}
> +
> +static void zram_stat64_sub(struct zram *zram, u64 *v, u64 dec)
> +{
> + =A0 =A0 =A0 spin_lock(&zram->stat64_lock);
> + =A0 =A0 =A0 *v =3D *v - dec;
> + =A0 =A0 =A0 spin_unlock(&zram->stat64_lock);
> +}
> +
> +static void zram_stat64_inc(struct zram *zram, u64 *v)
> +{
> + =A0 =A0 =A0 zram_stat64_add(zram, v, 1);
> +}

These could probably use atomic_inc(), atomic64_inc(), and friends, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
