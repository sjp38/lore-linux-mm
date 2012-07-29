Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1CDF86B004D
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 22:19:25 -0400 (EDT)
Date: Sun, 29 Jul 2012 11:20:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120729022009.GB16731@bbox>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hi Seth,

zcache out of staging is rather controversial as you see this thread.
But I believe zram is very mature and code/comment is clean. In addition,
it has lots of real customers in embedded side so IMHO, it would be easy to
promote it firstly. Of course, it will promote zsmalloc which is half on
what you want. What do you think about? If you agree, could you do that firstly?
If you don't want and promoting zcache continue to be controversial,
I will do that after my vacation.

Thanks.

On Fri, Jul 27, 2012 at 01:18:33PM -0500, Seth Jennings wrote:
> zcache is the remaining piece of code required to support in-kernel
> memory compression.  The other two features, cleancache and frontswap,
> have been promoted to mainline in 3.0 and 3.5.  This patchset
> promotes zcache from the staging tree to mainline.
> 
> Based on the level of activity and contributions we're seeing from a
> diverse set of people and interests, I think zcache has matured to the
> point where it makes sense to promote this out of staging.
> 
> Overview
> ========
> zcache is a backend to frontswap and cleancache that accepts pages from
> those mechanisms and compresses them, leading to reduced I/O caused by
> swap and file re-reads.  This is very valuable in shared storage situations
> to reduce load on things like SANs.  Also, in the case of slow backing/swap
> devices, zcache can also yield a performance gain.
> 
> In-Kernel Memory Compression Overview:
> 
>  swap subsystem            page cache
>         +                      +
>     frontswap              cleancache
>         +                      +
> zcache frontswap glue  zcache cleancache glue
>         +                      +
>         +---------+------------+
>                   +
>             zcache/tmem core
>                   +
>         +---------+------------+
>         +                      +
>      zsmalloc                 zbud
> 
> Everything below the frontswap/cleancache layer is current inside the
> zcache driver expect for zsmalloc which is a shared between zcache and
> another memory compression driver, zram.
> 
> Since zcache is dependent on zsmalloc, it is also being promoted by this
> patchset.
> 
> For information on zsmalloc and the rationale behind it's design and use
> cases verses already existing allocators in the kernel:
> 
> https://lkml.org/lkml/2012/1/9/386
> 
> zsmalloc is the allocator used by zcache to store persistent pages that
> comes from frontswap, as opposed to zbud which is the (internal) allocator
> used for ephemeral pages from cleancache.
> 
> zsmalloc uses many fields of the page struct to create it's conceptual
> high-order page called a zspage.  Exactly which fields are used and for
> what purpose is documented at the top of the zsmalloc .c file.  Because
> zsmalloc uses struct page extensively, Andrew advised that the
> promotion location be mm/:
> 
> https://lkml.org/lkml/2012/1/20/308
> 
> Some benchmarking numbers demonstrating the I/O saving that can be had
> with zcache:
> 
> https://lkml.org/lkml/2012/3/22/383
> 
> Dan's presentation at LSF/MM this year on zcache:
> 
> http://oss.oracle.com/projects/tmem/dist/documentation/presentations/LSFMM12-zcache-final.pdf
> 
> This patchset is based on next-20120727 + 3-part zsmalloc patchset below
> 
> https://lkml.org/lkml/2012/7/18/353
> 
> The zsmalloc patchset is already acked and will be integrated by Greg after
> 3.6-rc1 is out.
> 
> Seth Jennings (4):
>   zsmalloc: collapse internal .h into .c
>   zsmalloc: promote to mm/
>   drivers: add memory management driver class
>   zcache: promote to drivers/mm/
> 
>  drivers/Kconfig                                    |    2 +
>  drivers/Makefile                                   |    1 +
>  drivers/mm/Kconfig                                 |   13 ++
>  drivers/mm/Makefile                                |    1 +
>  drivers/{staging => mm}/zcache/Makefile            |    0
>  drivers/{staging => mm}/zcache/tmem.c              |    0
>  drivers/{staging => mm}/zcache/tmem.h              |    0
>  drivers/{staging => mm}/zcache/zcache-main.c       |    4 +-
>  drivers/staging/Kconfig                            |    4 -
>  drivers/staging/Makefile                           |    2 -
>  drivers/staging/zcache/Kconfig                     |   11 --
>  drivers/staging/zram/zram_drv.h                    |    3 +-
>  drivers/staging/zsmalloc/Kconfig                   |   10 --
>  drivers/staging/zsmalloc/Makefile                  |    3 -
>  drivers/staging/zsmalloc/zsmalloc_int.h            |  149 --------------------
>  .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
>  mm/Kconfig                                         |   18 +++
>  mm/Makefile                                        |    1 +
>  .../zsmalloc/zsmalloc-main.c => mm/zsmalloc.c      |  133 ++++++++++++++++-
>  19 files changed, 170 insertions(+), 185 deletions(-)
>  create mode 100644 drivers/mm/Kconfig
>  create mode 100644 drivers/mm/Makefile
>  rename drivers/{staging => mm}/zcache/Makefile (100%)
>  rename drivers/{staging => mm}/zcache/tmem.c (100%)
>  rename drivers/{staging => mm}/zcache/tmem.h (100%)
>  rename drivers/{staging => mm}/zcache/zcache-main.c (99%)
>  delete mode 100644 drivers/staging/zcache/Kconfig
>  delete mode 100644 drivers/staging/zsmalloc/Kconfig
>  delete mode 100644 drivers/staging/zsmalloc/Makefile
>  delete mode 100644 drivers/staging/zsmalloc/zsmalloc_int.h
>  rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
>  rename drivers/staging/zsmalloc/zsmalloc-main.c => mm/zsmalloc.c (86%)
> 
> -- 
> 1.7.9.5
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
