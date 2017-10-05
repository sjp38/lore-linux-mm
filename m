Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06B416B0277
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 17:15:31 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id b124so17201754qke.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 14:15:31 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r30sor7024807qtr.47.2017.10.05.14.15.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 14:15:30 -0700 (PDT)
Date: Thu, 5 Oct 2017 17:15:28 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: RE: [PATCH v4 4/5] cramfs: add mmap support
In-Reply-To: <SG2PR06MB11655D2F14AC44BA565848788A700@SG2PR06MB1165.apcprd06.prod.outlook.com>
Message-ID: <nycvar.YSQ.7.76.1710051707540.1693@knanqh.ubzr>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org> <20170927233224.31676-5-nicolas.pitre@linaro.org> <20171001083052.GB17116@infradead.org> <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr> <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr> <20171003145732.GA8890@infradead.org> <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr> <20171003153659.GA31600@infradead.org> <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr> <20171004072553.GA24620@infradead.org>
 <nycvar.YSQ.7.76.1710041608460.1693@knanqh.ubzr> <SG2PR06MB11655D2F14AC44BA565848788A700@SG2PR06MB1165.apcprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Brandt <Chris.Brandt@renesas.com>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 5 Oct 2017, Chris Brandt wrote:

> On Wednesday, October 04, 2017, Nicolas Pitre wrote:
> > Anyway, here's a replacement for patch 4/5 below:
> > 
> > ----- >8
> > Subject: cramfs: add mmap support
> > 
> > When cramfs_physmem is used then we have the opportunity to map files
> > directly from ROM, directly into user space, saving on RAM usage.
> > This gives us Execute-In-Place (XIP) support.
> 
> 
> Tested on my setup:
>  * Cortex A9 (with MMU)
>  * CONFIG_XIP_KERNEL=y
>  * booted with XIP CRAMFS as my rootfs 
>  * all apps and libraries marked as XIP in my cramfs image
> 
> 
> 
> So far, functionally it seems to work the same as [PATCH v4 4/5].
> 
> As Nicolas said, before you could easily see that all my apps and 
> libraries were XIP from Flash:
> 
> $ cat /proc/self/maps
> 00008000-000a1000 r-xp 1b005000 00:0c 18192      /bin/busybox
> 000a9000-000aa000 rw-p 00099000 00:0c 18192      /bin/busybox
> 000aa000-000ac000 rw-p 00000000 00:00 0          [heap]
> b6e69000-b6f42000 r-xp 1b0bc000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f42000-b6f4a000 ---p 1b195000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f4a000-b6f4c000 r--p 000d9000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f4c000-b6f4d000 rw-p 000db000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f4d000-b6f50000 rw-p 00000000 00:00 0
> b6f50000-b6f67000 r-xp 1b0a4000 00:0c 670372     /lib/ld-2.18-2013.10.so
> b6f6a000-b6f6b000 rw-p 00000000 00:00 0
> b6f6c000-b6f6e000 rw-p 00000000 00:00 0
> b6f6e000-b6f6f000 r--p 00016000 00:0c 670372     /lib/ld-2.18-2013.10.so
> b6f6f000-b6f70000 rw-p 00017000 00:0c 670372     /lib/ld-2.18-2013.10.so
> beac0000-beae1000 rw-p 00000000 00:00 0          [stack]
> bebc9000-bebca000 r-xp 00000000 00:00 0          [sigpage]
> ffff0000-ffff1000 r-xp 00000000 00:00 0          [vectors]
> 
> 
> 
> But now just busybox looks like it's XIP:
> 
> $ cat /proc/self/maps
> 00008000-000a1000 r-xp 1b005000 00:0c 18192      /bin/busybox
> 000a9000-000aa000 rw-p 00099000 00:0c 18192      /bin/busybox
> 000aa000-000ac000 rw-p 00000000 00:00 0          [heap]
> b6e4d000-b6f26000 r-xp 00000000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f26000-b6f2e000 ---p 000d9000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f2e000-b6f30000 r--p 000d9000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f30000-b6f31000 rw-p 000db000 00:0c 766540     /lib/libc-2.18-2013.10.so
> b6f31000-b6f34000 rw-p 00000000 00:00 0
> b6f34000-b6f4b000 r-xp 00000000 00:0c 670372     /lib/ld-2.18-2013.10.so
> b6f4e000-b6f4f000 rw-p 00000000 00:00 0
> b6f50000-b6f52000 rw-p 00000000 00:00 0
> b6f52000-b6f53000 r--p 00016000 00:0c 670372     /lib/ld-2.18-2013.10.so
> b6f53000-b6f54000 rw-p 00017000 00:0c 670372     /lib/ld-2.18-2013.10.so
> bec93000-becb4000 rw-p 00000000 00:00 0          [stack]
> befad000-befae000 r-xp 00000000 00:00 0          [sigpage]
> ffff0000-ffff1000 r-xp 00000000 00:00 0          [vectors]

Do you have the same amount of free memory once booted in both cases?

> Regardless, from a functional standpoint:
> 
> Tested-by: Chris Brandt <chris.brandt@renesas.com>

Thanks.

> Just FYI, the previous [PATCH v4 4/5] also included this (which was the 
> only real difference between v3 and v4):
> 
> 
> diff --git a/fs/cramfs/Kconfig b/fs/cramfs/Kconfig
> index 5b4e0b7e13..306549be25 100644
> --- a/fs/cramfs/Kconfig
> +++ b/fs/cramfs/Kconfig
> @@ -30,7 +30,7 @@ config CRAMFS_BLOCKDEV
>  
>  config CRAMFS_PHYSMEM
>  	bool "Support CramFs image directly mapped in physical memory"
> -	depends on CRAMFS
> +	depends on CRAMFS = y

Yeah, that was necessary because split_vma() wasn't exported to modules. 
Now split_vma() is no longer used so the no-module restriction has also 
been removed.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
