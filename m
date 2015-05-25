Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D477E6B00AA
	for <linux-mm@kvack.org>; Mon, 25 May 2015 10:16:13 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so29054373pdb.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:16:13 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id b7si16423822pat.66.2015.05.25.07.16.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 May 2015 07:16:12 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so70713969pdb.0
        for <linux-mm@kvack.org>; Mon, 25 May 2015 07:16:12 -0700 (PDT)
Date: Mon, 25 May 2015 23:16:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150525141605.GC14922@blaptop>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
 <20150522131447.GA14922@blaptop>
 <20150525040304.GA555@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525040304.GA555@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Marcin Jabrzyk <m.jabrzyk@samsung.com>, Nitin Gupta <ngupta@vflare.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>

Hello Sergey,

On Mon, May 25, 2015 at 01:03:04PM +0900, Sergey Senozhatsky wrote:
> On (05/22/15 22:14), Minchan Kim wrote:
> > > > >second, there is not much value in exposing zcomp internals,
> > > > >especially when the result is just another line in dmesg output.
> > > >
> > > > From the other hand, the only valid values that can be written are
> > > > in 'comp_algorithm'.
> > > > So when writing other one, returning -EINVAL seems to be reasonable.
> > > > The user would get immediately information that he can't do that,
> > > > now the information can be very deferred in time.
> > >
> > > it's not.
> > > the error message appears in syslog right before we return -EINVAL
> > > back to user.
> >
> > Although Marcin's description is rather misleading, I like the patch.
> > Every admin doesn't watch dmesg output. Even people could change loglevel
> > simply so KERN_INFO would be void in that case.
>
> there is no -EUNSPPORTEDCOMPRESSIONALGORITHM errno that we can return
> back to userspace and expect it [userspace] to magically transform it
> into a meaningful error message; users must check syslog/dmesg. that's
> the way it is.
>
> # echo LZ4 > /sys/block/zram0/comp_algorithm
> # -bash: echo: write error: Device or resource busy

The problem is that user cannot notice the fail until he try to
set disksize. It's not straightforward as interface.

>
> - hm.... why?
> - well, that's why:
> dmesg
> [  249.745335] zram: Can't change algorithm for initialized device
>
>
> > Instant error propagation is more strighforward for user point of view
> > rather than delaying with depending on another event.
>
> I'd rather just add two lines of code, w/o making zcomp internals visible.
>
> it seems that we are trying to solve a problem that does not really
> exist. I think what we really need to do is to rewrite zram documentation
> and to propose zramctl usage as a recommended way of managing zram devices.

Zramctl is useful for people to handle zram's inteface consistenly but
it couldn't be a justification for awkard error propagation which depends
another event(ie, disksize setting).

> zramctl does not do `typo' errors. if somebody wants to configure zram
> manually, then he simply must check syslog. it's simple.

If any action fails instanly, it makes sense to check it with syslog.
But the problem is echo lz5 > /sys/block/zram0/comp_algorithm didn't
emit any error message but could notice it when we set disksize.
It's not good.
Of course, if we need a lot code churn to fix it, I will think it over
seriously but we could fix it simply. Why not?

Frankly speaking, I didn't use zramctl ever because I didn't know when it
was merged into util-linux unforunately and my distro's util-linux seems
to not include it.
And so many products have used zram in my company are too old to use
recent util-linux. They are reluctant to update their util-linux
for just zramctl.
Time goes by, I belive zramctl would be standard way to use zram but
it couldn't cover 100% for the world usecases.
So, my point is that we should make the interface sane without dependency
of zramctl.

>
> ---
>
>  drivers/block/zram/zcomp.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/drivers/block/zram/zcomp.c b/drivers/block/zram/zcomp.c
> index a1a8b8e..d96da53 100644
> --- a/drivers/block/zram/zcomp.c
> +++ b/drivers/block/zram/zcomp.c
> @@ -54,11 +54,16 @@ static struct zcomp_backend *backends[] = {
>  static struct zcomp_backend *find_backend(const char *compress)
>  {
>   int i = 0;
> +
>   while (backends[i]) {
>   if (sysfs_streq(compress, backends[i]->name))
>   break;
>   i++;
>   }
> +
> + if (!backends[i])
> + pr_err("Error: unknown compression algorithm: %s\n",
> + compress);
>   return backends[i];
>  }
>  
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
