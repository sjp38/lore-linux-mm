Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 667346B0032
	for <linux-mm@kvack.org>; Mon, 25 May 2015 10:21:57 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so70686506pdf.3
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:21:57 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id mq6si16337967pbb.191.2015.05.25.07.21.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 07:21:56 -0700 (PDT)
Received: by padbw4 with SMTP id bw4so72222384pad.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:21:56 -0700 (PDT)
Date: Mon, 25 May 2015 23:21:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150525142149.GD14922@blaptop>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <555F2E7C.4090707@samsung.com>
 <20150525061838.GB555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525061838.GB555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Marcin Jabrzyk <m.jabrzyk@samsung.com>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On Mon, May 25, 2015 at 03:18:38PM +0900, Sergey Senozhatsky wrote:
> On (05/22/15 15:26), Marcin Jabrzyk wrote:
> > >> From the other hand, the only valid values that can be written are
> > >>in 'comp_algorithm'.
> > >>So when writing other one, returning -EINVAL seems to be reasonable.
> > >>The user would get immediately information that he can't do that,
> > >>now the information can be very deferred in time.
> > >
> > >it's not.
> > >the error message appears in syslog right before we return -EINVAL
> > >back to user.
> > 
> > Yes I've read up the code more detailed and I saw that error message
> > just before returning to user with error value.
> > 
> > But this happens when 'disksize' is wirtten, not when 'comp_algorithm'.
> > I understood, the error message in dmesg is clear there is no such
> > algorithm.
> > 
> > But this is not an immediate error, when setting the 'comp_algorithm',
> > where we already know that it's wrong, not existing etc.
> > Anything after that moment would be wrong and would not work at all.
> > 
> > From what I saw 'comp_algorithm_store' is the only *_store in zram that
> > believes user that he writes proper value and just makes strlcpy.
> > 
> > So what I've ing mind is to provide direct feedback, you have
> > written wrong name of compressor, you got -EINVAL, please write
> > correct value. This would be very useful when scripting.
> > 
> 
> I can't see how printing error 0.0012 seconds earlier helps. really.
> if one sets a compression algorithm the very next thing to do is to
> set device's disksize. even if he/she usually watch a baseball game in
> between, then the error message appears right when it's needed anyway:
> during `setup my device and make it usable' stage.
> 
> 
> >I'm not for exposing more internals, but getting -EINVAL would be nice I
> 
> you are.
> 
> find_backend() returns back to its caller a raw and completely initialized
> zcomp_backend pointer. this is very dangerous zcomp internals, which should
> never be exposed. from zcomp layer we return either ERR_PTR() or a usable
> zcomp_backend pointer. that's the rule.
> 
> 
> if you guys still insist that this is critical and very important change,
> then there should be a small helper function instead with a clear name
> (starting with zcomp_ to indicate its place) which will simply return bool
> TRUE for `algorithm is known' case and FALSE otherwise (aka `algorithm is
> unknown').
> 
> 
> something like below:
> 
> 
>   # echo LZ5 > /sys/block/zram0/comp_algorithm
>   -bash: echo: write error: Invalid argument
> 
>   dmesg
>   [ 7440.544852] Error: unknown compression algorithm: LZ5
> 
> 
> p.s. but, I still see a very little value.
> p.p.s notice a necessary and inevitable `dmesg'. (back to 'no one reads
> syslog' argument).
> 
> ---
> 
>  drivers/block/zram/zcomp.c    | 10 ++++++++++
>  drivers/block/zram/zcomp.h    |  1 +
>  drivers/block/zram/zram_drv.c |  3 +++
>  3 files changed, 14 insertions(+)
> 
> diff --git a/drivers/block/zram/zcomp.c b/drivers/block/zram/zcomp.c
> index a1a8b8e..b68b16f 100644
> --- a/drivers/block/zram/zcomp.c
> +++ b/drivers/block/zram/zcomp.c
> @@ -54,11 +54,16 @@ static struct zcomp_backend *backends[] = {
>  static struct zcomp_backend *find_backend(const char *compress)
>  {
>  	int i = 0;
> +
>  	while (backends[i]) {
>  		if (sysfs_streq(compress, backends[i]->name))
>  			break;
>  		i++;
>  	}
> +
> +	if (!backends[i])
> +		pr_err("Error: unknown compression algorithm: %s\n",
> +				compress);

find_backend is just utility function to get zcomp_backend.
IOW, it might be used for several cases in future so I want
make error report as caller's work.

>  	return backends[i];
>  }
>  
> @@ -320,6 +325,11 @@ void zcomp_destroy(struct zcomp *comp)
>  	kfree(comp);
>  }
>  
> +bool zcomp_known_algorithm(const char *comp)
> +{
> +	return find_backend(comp) != NULL;
> +}
> +
>  /*
>   * search available compressors for requested algorithm.
>   * allocate new zcomp and initialize it. return compressing
> diff --git a/drivers/block/zram/zcomp.h b/drivers/block/zram/zcomp.h
> index c59d1fc..773bdf1 100644
> --- a/drivers/block/zram/zcomp.h
> +++ b/drivers/block/zram/zcomp.h
> @@ -51,6 +51,7 @@ struct zcomp {
>  };
>  
>  ssize_t zcomp_available_show(const char *comp, char *buf);
> +bool zcomp_known_algorithm(const char *comp);
>  
>  struct zcomp *zcomp_create(const char *comp, int max_strm);
>  void zcomp_destroy(struct zcomp *comp);
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index f750e34..2197a81 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -378,6 +378,9 @@ static ssize_t comp_algorithm_store(struct device *dev,
>  	if (sz > 0 && zram->compressor[sz - 1] == '\n')
>  		zram->compressor[sz - 1] = 0x00;
>  
> +	if (!zcomp_known_algorithm(zram->compressor))

In here, we could report back to the user.

> +		len = -EINVAL;
> +
>  	up_write(&zram->init_lock);
>  	return len;
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
