Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id A28406B00EA
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 00:58:18 -0500 (EST)
Date: Tue, 5 Feb 2013 14:58:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 2/4] zram: force disksize setting before using zram
Message-ID: <20130205055816.GI2610@blaptop>
References: <1359935171-12749-1-git-send-email-minchan@kernel.org>
 <1359935171-12749-2-git-send-email-minchan@kernel.org>
 <1359963195.29377.0.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359963195.29377.0.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>, jmarchan@redhat.com, Andrew Morton <akpm@linux-foundation.org>

On Mon, Feb 04, 2013 at 01:33:15AM -0600, Ric Mason wrote:
> Hi Minchan,
> On Mon, 2013-02-04 at 08:46 +0900, Minchan Kim wrote:
> > Now zram document syas "set disksize is optional"
> > but partly it's wrong. When you try to use zram firstly after
> > booting, you must set disksize, otherwise zram can't work because
> > zram gendisk's size is 0. But once you do it, you can use zram freely
> > after reset because reset doesn't reset to zero paradoxically.
> > So in this time, disksize setting is optional.:(
> > It's inconsitent for user behavior and not straightforward.
> > 
> > This patch forces always setting disksize firstly before using zram.
> > Yes. It changes current behavior so someone could complain when
> > he upgrades zram. Apparently it could be a problem if zram is mainline
> > but it still lives in staging so behavior could be changed for right
> > way to go. Let them excuse.
> > 
> > Acked-by: Jerome Marchand <jmarchan@redhat.com>
> > Acked-by: Nitin Gupta <ngupta@vflare.org>
> > Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zram/zram.txt     |   27 ++++++++++----------
> >  drivers/staging/zram/zram_drv.c   |   51 +++++++++++++------------------------
> >  drivers/staging/zram/zram_drv.h   |    5 +---
> >  drivers/staging/zram/zram_sysfs.c |    6 +----
> >  4 files changed, 34 insertions(+), 55 deletions(-)
> > 
> > diff --git a/drivers/staging/zram/zram.txt b/drivers/staging/zram/zram.txt
> > index 5f75d29..765d790 100644
> > --- a/drivers/staging/zram/zram.txt
> > +++ b/drivers/staging/zram/zram.txt
> > @@ -23,17 +23,17 @@ Following shows a typical sequence of steps for using zram.
> >  	This creates 4 devices: /dev/zram{0,1,2,3}
> >  	(num_devices parameter is optional. Default: 1)
> >  
> > -2) Set Disksize (Optional):
> > -	Set disk size by writing the value to sysfs node 'disksize'
> > -	(in bytes). If disksize is not given, default value of 25%
> > -	of RAM is used.
> > -
> > -	# Initialize /dev/zram0 with 50MB disksize
> > -	echo $((50*1024*1024)) > /sys/block/zram0/disksize
> > -
> > -	NOTE: disksize cannot be changed if the disk contains any
> > -	data. So, for such a disk, you need to issue 'reset' (see below)
> > -	before you can change its disksize.
> > +2) Set Disksize
> > +        Set disk size by writing the value to sysfs node 'disksize'.
> > +        The value can be either in bytes or you can use mem suffixes.
> > +        Examples:
> > +            # Initialize /dev/zram0 with 50MB disksize
> > +            echo $((50*1024*1024)) > /sys/block/zram0/disksize
> > +
> > +            # Using mem suffixes
> > +            echo 256K > /sys/block/zram0/disksize
> > +            echo 512M > /sys/block/zram0/disksize
> > +            echo 1G > /sys/block/zram0/disksize
> >  
> >  3) Activate:
> >  	mkswap /dev/zram0
> > @@ -65,8 +65,9 @@ Following shows a typical sequence of steps for using zram.
> >  	echo 1 > /sys/block/zram0/reset
> >  	echo 1 > /sys/block/zram1/reset
> >  
> > -	(This frees all the memory allocated for the given device).
> > -
> > +	This frees all the memory allocated for the given device and
> > +	resets the disksize to zero. You must set the disksize again
> > +	before reusing the device.
> >  
> >  Please report any problems at:
> >   - Mailing list: linux-mm-cc at laptop dot org
> > diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
> > index 262265e..1114cad 100644
> > --- a/drivers/staging/zram/zram_drv.c
> > +++ b/drivers/staging/zram/zram_drv.c
> > @@ -94,34 +94,6 @@ static int page_zero_filled(void *ptr)
> >  	return 1;
> >  }
> >  
> > -static void zram_set_disksize(struct zram *zram, size_t totalram_bytes)
> > -{
> > -	if (!zram->disksize) {
> > -		pr_info(
> > -		"disk size not provided. You can use disksize_kb module "
> > -		"param to specify size.\nUsing default: (%u%% of RAM).\n",
> > -		default_disksize_perc_ram
> > -		);
> > -		zram->disksize = default_disksize_perc_ram *
> > -					(totalram_bytes / 100);
> > -	}
> > -
> > -	if (zram->disksize > 2 * (totalram_bytes)) {
> > -		pr_info(
> > -		"There is little point creating a zram of greater than "
> > -		"twice the size of memory since we expect a 2:1 compression "
> > -		"ratio. Note that zram uses about 0.1%% of the size of "
> > -		"the disk when not in use so a huge zram is "
> > -		"wasteful.\n"
> > -		"\tMemory Size: %zu kB\n"
> > -		"\tSize you selected: %llu kB\n"
> > -		"Continuing anyway ...\n",
> > -		totalram_bytes >> 10, zram->disksize >> 10);
> > -	}
> > -
> > -	zram->disksize &= PAGE_MASK;
> > -}
> > -
> >  static void zram_free_page(struct zram *zram, size_t index)
> >  {
> >  	unsigned long handle = zram->table[index].handle;
> > @@ -497,6 +469,9 @@ void __zram_reset_device(struct zram *zram)
> >  {
> >  	size_t index;
> >  
> > +	if (!zram->init_done)
> > +		return;
> > +
> >  	zram->init_done = 0;
> >  
> >  	/* Free various per-device buffers */
> > @@ -525,6 +500,7 @@ void __zram_reset_device(struct zram *zram)
> >  	memset(&zram->stats, 0, sizeof(zram->stats));
> >  
> >  	zram->disksize = 0;
> > +	set_capacity(zram->disk, 0);
> >  }
> >  
> >  void zram_reset_device(struct zram *zram)
> > @@ -546,7 +522,19 @@ int zram_init_device(struct zram *zram)
> >  		return 0;
> >  	}
> >  
> > -	zram_set_disksize(zram, totalram_pages << PAGE_SHIFT);
> > +	if (zram->disksize > 2 * (totalram_pages << PAGE_SHIFT)) {
> > +		pr_info(
> > +		"There is little point creating a zram of greater than "
> > +		"twice the size of memory since we expect a 2:1 compression "
> > +		"ratio. Note that zram uses about 0.1%% of the size of "
> > +		"the disk when not in use so a huge zram is "
> > +		"wasteful.\n"
> > +		"\tMemory Size: %zu kB\n"
> > +		"\tSize you selected: %llu kB\n"
> > +		"Continuing anyway ...\n",
> > +		(totalram_pages << PAGE_SHIFT) >> 10, zram->disksize >> 10
> > +		);
> > +	}
> >  
> >  	zram->compress_workmem = kzalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> 
> zram->compress_workmem is used for what?

It is used for buffer for compression.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
