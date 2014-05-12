Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E2F3E6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 01:12:49 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so5087853pab.6
        for <linux-mm@kvack.org>; Sun, 11 May 2014 22:12:49 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gj9si8832433pac.49.2014.05.11.22.12.47
        for <linux-mm@kvack.org>;
        Sun, 11 May 2014 22:12:48 -0700 (PDT)
Date: Mon, 12 May 2014 14:15:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
Message-ID: <20140512051505.GB32617@bbox>
References: <20140505152014.GA8551@cerebellum.variantweb.net>
 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
 <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
 <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
 <20140507085743.GA31680@bbox>
 <CAL1ERfOXNrfKqMVs-Yz8yJjKKU3L5fjUEOb0Aeyqc37py-BWEg@mail.gmail.com>
 <CAAmzW4Pn2VUEnQ8FyOaBffqfUiHt6ocLEEvyaJrSKmTjaNp_wQ@mail.gmail.com>
 <20140508062418.GF5282@bbox>
 <000001cf6c16$afe73800$0fb5a800$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cf6c16$afe73800$0fb5a800$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Joonsoo Kim' <js1304@gmail.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Davidlohr Bueso' <davidlohr@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, 'Heesub Shin' <heesub.shin@samsung.com>, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Sat, May 10, 2014 at 02:10:08PM +0800, Weijie Yang wrote:
> On Thu, May 8, 2014 at 2:24 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Wed, May 07, 2014 at 11:52:59PM +0900, Joonsoo Kim wrote:
> >> >> Most popular use of zram is the in-memory swap for small embedded system
> >> >> so I don't want to increase memory footprint without good reason although
> >> >> it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
> >> >> consider compression ratio and real free memory after boot
> >>
> >> We can use bit spin lock and this would not increase memory footprint for 32 bit
> >> platform.
> >
> > Sounds like a idea.
> > Weijie, Do you mind testing with bit spin lock?
> 
> Yes, I re-test them.
> This time, I test each case 10 times, and take the average(KS/s).
> (the test machine and method are same like previous mail's)
> 
> Iozone test result:
> 
>       Test       BASE     CAS   spinlock   rwlock  bit_spinlock
> --------------------------------------------------------------
>  Initial write  1381094   1425435   1422860   1423075   1421521
>        Rewrite  1529479   1641199   1668762   1672855   1654910
>           Read  8468009  11324979  11305569  11117273  10997202
>        Re-read  8467476  11260914  11248059  11145336  10906486
>   Reverse Read  6821393   8106334   8282174   8279195   8109186
>    Stride read  7191093   8994306   9153982   8961224   9004434
>    Random read  7156353   8957932   9167098   8980465   8940476
> Mixed workload  4172747   5680814   5927825   5489578   5972253
>   Random write  1483044   1605588   1594329   1600453   1596010
>         Pwrite  1276644   1303108   1311612   1314228   1300960
>          Pread  4324337   4632869   4618386   4457870   4500166
> 
> Fio test result:
> 
>     Test     base     CAS    spinlock    rwlock  bit_spinlock
> -------------------------------------------------------------
> seq-write   933789   999357   1003298    995961   1001958
>  seq-read  5634130  6577930   6380861   6243912   6230006
>    seq-rw  1405687  1638117   1640256   1633903   1634459
>   rand-rw  1386119  1614664   1617211   1609267   1612471
> 
> 
> The base is v3.15.0-rc3, the others are per-meta entry lock.
> Every optimization method shows higher performance than the base, however,
> it is hard to say which method is the most appropriate.

It's not too big between CAS and bit_spinlock so I prefer general method.

> 
> To bit_spinlock, the modified code is mainly like this:
> 
> +#define ZRAM_FLAG_SHIFT 16
> +
> enum zram_pageflags {
>  	/* Page consists entirely of zeros */
> -	ZRAM_ZERO,
> +	ZRAM_ZERO = ZRAM_FLAG_SHIFT + 1,
> +	ZRAM_ACCESS,
>  
>  	__NR_ZRAM_PAGEFLAGS,
>  };
>  
>  /* Allocated for each disk page */
>  struct table {
>  	unsigned long handle;
> -	u16 size;	/* object size (excluding header) */
> -	u8 flags;
> +	unsigned long value;

Why does we need to change flags and size "unsigned long value"?
Couldn't we use existing flags with just adding new ZRAM_TABLE_LOCK?


>  } __aligned(4);
> 
> The lower ZRAM_FLAG_SHIFT bits of table.value is size, the higher bits
> is for zram_pageflags. By this means, it doesn't increase any memory
> overhead on both 32-bit and 64-bit system.
> 
> Any complaint or suggestions are welcomed.

Anyway, I'd like to go this way.
Pz, resend formal patch with a number.

Thanks!

> 
> >>
> >> Thanks.
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
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
