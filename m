Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EB9AF6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 18:23:15 -0500 (EST)
Date: Tue, 22 Jan 2013 08:23:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 1/4] zram: force disksize setting before using zram
Message-ID: <20130121232313.GE3666@blaptop>
References: <1358745691-4556-1-git-send-email-minchan@kernel.org>
 <50FD9954.7000303@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FD9954.7000303@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, Jan 21, 2013 at 08:39:00PM +0100, Jerome Marchand wrote:
> On 01/21/2013 06:21 AM, Minchan Kim wrote:
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
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  drivers/staging/zram/zram.txt     |   27 +++++++++----------
> >  drivers/staging/zram/zram_drv.c   |   52 ++++++++++++++-----------------------
> >  drivers/staging/zram/zram_drv.h   |    5 +---
> >  drivers/staging/zram/zram_sysfs.c |    6 +----
> >  4 files changed, 35 insertions(+), 55 deletions(-)
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
> > index 61fb8f1..1d45401 100644
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
> > @@ -495,6 +467,9 @@ void __zram_reset_device(struct zram *zram)
> >  {
> >  	size_t index;
> >  
> > +	if (!zram->init_done)
> > +		goto out;
> 
> In that case, the device has not been initialized yet or has been
> reset already. zram->disksize and disk capacity should already been
> zero in that case. Why don't we just return here?
> 
> Jerome

Done.
Thanks for the pointing out, Jerome!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
