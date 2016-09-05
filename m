Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E49E66B0038
	for <linux-mm@kvack.org>; Sun,  4 Sep 2016 22:12:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a143so269114326pfa.0
        for <linux-mm@kvack.org>; Sun, 04 Sep 2016 19:12:14 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id dy8si1641930pab.143.2016.09.04.19.12.10
        for <linux-mm@kvack.org>;
        Sun, 04 Sep 2016 19:12:13 -0700 (PDT)
Date: Mon, 5 Sep 2016 11:12:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/4] ZRAM: make it just store the high compression rate page
Message-ID: <20160905021208.GA22701@bbox>
References: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471854309-30414-1-git-send-email-zhuhui@xiaomi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hui Zhu <zhuhui@xiaomi.com>
Cc: ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, hughd@google.com, rostedt@goodmis.org, mingo@redhat.com, peterz@infradead.org, acme@kernel.org, alexander.shishkin@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, redkoi@virtuozzo.com, luto@kernel.org, kirill.shutemov@linux.intel.com, geliangtang@163.com, baiyaowei@cmss.chinamobile.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, aarcange@redhat.com, dvlasenk@redhat.com, jmarchan@redhat.com, koct9i@gmail.com, yang.shi@linaro.org, dave.hansen@linux.intel.com, vkuznets@redhat.com, vitalywool@gmail.com, ross.zwisler@linux.intel.com, tglx@linutronix.de, kwapulinski.piotr@gmail.com, axboe@fb.com, mchristi@redhat.com, joe@perches.com, namit@vmware.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, teawater@gmail.com

Hello Hui,

On Mon, Aug 22, 2016 at 04:25:05PM +0800, Hui Zhu wrote:
> Current ZRAM just can store all pages even if the compression rate
> of a page is really low.  So the compression rate of ZRAM is out of
> control when it is running.
> In my part, I did some test and record with ZRAM.  The compression rate
> is about 40%.
> 
> This series of patches make ZRAM can just store the page that the
> compressed size is smaller than a value.
> With these patches, I set the value to 2048 and did the same test with
> before.  The compression rate is about 20%.  The times of lowmemorykiller
> also decreased.
> 
> Hui Zhu (4):
> vmscan.c: shrink_page_list: unmap anon pages after pageout
> Add non-swap page flag to mark a page will not swap
> ZRAM: do not swap the pages that compressed size bigger than non_swap
> vmscan.c: zram: add non swap support for shmem file pages
> 
>  drivers/block/zram/Kconfig     |   11 +++
>  drivers/block/zram/zram_drv.c  |   38 +++++++++++
>  drivers/block/zram/zram_drv.h  |    4 +
>  fs/proc/meminfo.c              |    6 +
>  include/linux/mm_inline.h      |   20 +++++
>  include/linux/mmzone.h         |    3 
>  include/linux/page-flags.h     |    8 ++
>  include/linux/rmap.h           |    5 +
>  include/linux/shmem_fs.h       |    6 +
>  include/trace/events/mmflags.h |    9 ++
>  kernel/events/uprobes.c        |   16 ++++
>  mm/Kconfig                     |    9 ++
>  mm/memory.c                    |   34 ++++++++++
>  mm/migrate.c                   |    4 +
>  mm/mprotect.c                  |    8 ++
>  mm/page_io.c                   |   11 ++-
>  mm/rmap.c                      |   23 ++++++
>  mm/shmem.c                     |   77 +++++++++++++++++-----
>  mm/vmscan.c                    |  139 +++++++++++++++++++++++++++++++++++------
>  19 files changed, 387 insertions(+), 44 deletions(-)

I look over the patchset now and I feel it's really hard to accept
in mainline, unfortunately. Sorry.
It spreads out lots of tricky code in MM for a special usecase
so it's hard to justify, I think.

A thing I can think to avoid no-good-comp-ratio page storing into zram
is that zram can return AOP_WRITEPAGE_ACTIVATE if it found the page is
uncompressible in zram_rw_page so that VM can promote the page to
active LRU. With that, the uncompressible page will have more time to
redirty with hope that it can have compressible data this time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
