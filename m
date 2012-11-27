Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 816F56B006C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 00:04:50 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so9058699pbc.14
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 21:04:49 -0800 (PST)
Message-ID: <50B449EF.50806@vflare.org>
Date: Mon, 26 Nov 2012 21:04:47 -0800
From: Nitin Gupta <ngupta@vflare.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] zram: force disksize setting before using zram
References: <1353638567-3981-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1353638567-3981-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 11/22/2012 06:42 PM, Minchan Kim wrote:
> Now zram document syas "set disksize is optional"
> but partly it's wrong. When you try to use zram firstly after
> booting, you must set disksize, otherwise zram can't work because
> zram gendisk's size is 0. But once you do it, you can use zram freely
> after reset because reset doesn't reset to zero paradoxically.
> So in this time, disksize setting is optional.:(
> It's inconsitent for user behavior and not straightforward.
>
> This patch forces always setting disksize firstly before using zram.
> Yes. It changes current behavior so someone could complain when
> he upgrades zram. Apparently it could be a problem if zram is mainline
> but it still lives in staging so behavior could be changed for right
> way to go. Let them excuse.
>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   drivers/staging/zram/zram.txt     |    7 +++--
>   drivers/staging/zram/zram_drv.c   |   57 ++++++++++++++-----------------------
>   drivers/staging/zram/zram_drv.h   |    5 +---
>   drivers/staging/zram/zram_sysfs.c |    6 +---
>   4 files changed, 27 insertions(+), 48 deletions(-)
>
> diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
> index 5f75d29..00ae66b 100644
> --- a/drivers/staging/zram/zram.txt
> +++ b/drivers/staging/zram/zram.txt
> @@ -23,10 +23,9 @@ Following shows a typical sequence of steps for using zram.
>   	This creates 4 devices: /dev/zram{0,1,2,3}
>   	(num_devices parameter is optional. Default: 1)
>
> -2) Set Disksize (Optional):
> +2) Set Disksize
>   	Set disk size by writing the value to sysfs node 'disksize'
> -	(in bytes). If disksize is not given, default value of 25%
> -	of RAM is used.
> +	(in bytes).
>

Disksize can now be set using K/M/G suffixes also (see Sergey's change: 
handle mem suffixes in disk size ...). So, this should be documented as:

2) Set Disksize
	Set disk size by writing the value to sysfs node 'disksize'.
	The value can be either in bytes or you can use mem suffixes.
	Examples:
	    # Initialize /dev/zram0 with 50MB disksize
	    echo $((50*1024*1024)) > /sys/block/zram0/disksize

	    # Using mem suffixes
	    echo 256K > /sys/block/zram0/disksize
	    echo 512M > /sys/block/zram0/disksize
	    echo 1G > /sys/block/zram0/disksize


>   	# Initialize /dev/zram0 with 50MB disksize
>   	echo $((50*1024*1024)) > /sys/block/zram0/disksize
> @@ -67,6 +66,8 @@ Following shows a typical sequence of steps for using zram.
>
>   	(This frees all the memory allocated for the given device).
>
> +	If you want to use zram again, you should set disksize first
> +	due to reset zram.


This frees all the memory allocated for the given device and resets the 
disksize to zero. You must set the disksize again before reusing the device.

>
>   Please report any problems at:
>    - Mailing list: linux-mm-cc at laptop dot org
> diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> index fb4a7c9..9ef1eca 100644
> --- a/drivers/staging/zram/zram_drv.c
> +++ b/drivers/staging/zram/zram_drv.c
> @@ -104,35 +104,6 @@ static int page_zero_filled(void *ptr)
>   	return 1;
>   }
>
> -static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
> -{
> -	if (!zram->disksize) {
> -		pr_info(
> -		"disk size not provided. You can use disksize_kb module "
> -		"param to specify size.\nUsing default: (%u%% of RAM).\n",
> -		default_disksize_perc_ram
> -		);
> -		zram->disksize = default_disksize_perc_ram *
> -					(totalram_bytes / 100);
> -	}
> -
> -	if (zram->disksize > 2 * (totalram_bytes)) {
> -		pr_info(
> -		"There is little point creating a zram of greater than "
> -		"twice the size of memory since we expect a 2:1 compression "
> -		"ratio. Note that zram uses about 0.1%% of the size of "
> -		"the disk when not in use so a huge zram is "
> -		"wasteful.\n"
> -		"\tMemory Size: %zu kB\n"
> -		"\tSize you selected: %llu kB\n"
> -		"Continuing anyway ...\n",
> -		totalram_bytes >> 10, zram->disksize
> -		);
> -	}
> -
> -	zram->disksize &= PAGE_MASK;
> -}
> -
>   static void zram_free_page(struct zram *zram, size_t index)
>   {
>   	unsigned long handle = zram->table[index].handle;
> @@ -497,6 +468,9 @@ void __zram_reset_device(struct zram *zram)
>   {
>   	size_t index;
>
> +	if (!zram->init_done)
> +		goto out;
> +
>   	zram->init_done = 0;
>
>   	/* Free various per-device buffers */
> @@ -523,8 +497,9 @@ void __zram_reset_device(struct zram *zram)
>
>   	/* Reset stats */
>   	memset(&zram->stats, 0, sizeof(zram->stats));
> -
> +out:
>   	zram->disksize = 0;
> +	set_capacity(zram->disk, 0);
>   }
>
>   void zram_reset_device(struct zram *zram)
> @@ -540,13 +515,26 @@ int zram_init_device(struct zram *zram)
>   	size_t num_pages;
>
>   	down_write(&zram->init_lock);
> -
>   	if (zram->init_done) {
>   		up_write(&zram->init_lock);
>   		return 0;
>   	}
>
> -	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
> +	BUG_ON(!zram->disksize);

It shouldn't cause a crash if user sets disksize to zero; a noop seems 
better.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
