Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 8907E6B00AC
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:45:04 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so3094040dad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 07:45:03 -0700 (PDT)
Date: Mon, 15 Oct 2012 23:44:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121015144412.GA2173@barrios>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

Hello,

On Fri, Sep 28, 2012 at 10:32:20AM -0700, Luigi Semenzato wrote:
> Greetings,
> 
> We are experimenting with zram in Chrome OS.  It works quite well
> until the system runs out of memory, at which point it seems to hang,
> but we suspect it is thrashing.
> 
> Before the (apparent) hang, the OOM killer gets rid of a few
> processes, but then the other processes gradually stop responding,
> until the entire system becomes unresponsive.

Why do you think it's zram problem? If you use swap device as storage
instead of zram, does the problem disappear?

Could you do sysrq+t,m several time and post it while hang happens?
/proc/vmstat could be helpful, too.

> 
> I am wondering if anybody has run into this.  Thanks!
> 
> Luigi
> 
> P.S.  For those who wish to know more:
> 
> 1. We use the min_filelist_kbytes patch
> (http://lwn.net/Articles/412313/)  (I am not sure if it made it into
> the standard kernel) and set min_filelist_kbytes to 50Mb.  (This may
> not matter, as it's unlikely to make things worse.)

One of the problem I look at this patch is it might prevent
increasing of zone->pages_scanned when the swap if full or anon pages
are very small although there are lots of file-backed pages.
It means OOM can't occur and page allocator could loop forever.
Please look at zone_reclaimable.

Have you ever test it without above patch?

> 
> 2. We swap only to compressed ram.  The setup is very simple:
> 
>  echo ${ZRAM_SIZE_KB}000 >/sys/block/zram0/disksize ||
>       logger -t "$UPSTART_JOB" "failed to set zram size"
>   mkswap /dev/zram0 || logger -t "$UPSTART_JOB" "mkswap /dev/zram0 failed"
>   swapon /dev/zram0 || logger -t "$UPSTART_JOB" "swapon /dev/zram0 failed"
> 
> For ZRAM_SIZE_KB, we typically use 1.5 the size of RAM (which is 2 or
> 4 Gb).  The compression factor is about 3:1.  The hangs happen for
> quite a wide range of zram sizes.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
