Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B15D06B0037
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 19:58:03 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so19457201pab.2
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 16:58:03 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ag2si50570156pbd.113.2014.08.24.16.58.01
        for <linux-mm@kvack.org>;
        Sun, 24 Aug 2014 16:58:02 -0700 (PDT)
Date: Mon, 25 Aug 2014 08:58:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 0/4] zram memory control enhance
Message-ID: <20140824235848.GK17372@bbox>
References: <1408668134-21696-1-git-send-email-minchan@kernel.org>
 <CALZtONChBVQKzROJ9zR=nXYEHSWRcmegh_w9P34FfCz9c47Mnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONChBVQKzROJ9zR=nXYEHSWRcmegh_w9P34FfCz9c47Mnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, David Horner <ds2horner@gmail.com>

Hello Dan,

On Fri, Aug 22, 2014 at 03:15:36PM -0400, Dan Streetman wrote:
> On Thu, Aug 21, 2014 at 8:42 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Currently, zram has no feature to limit memory so theoretically
> > zram can deplete system memory.
> > Users have asked for a limit several times as even without exhaustion
> > zram makes it hard to control memory usage of the platform.
> > This patchset adds the feature.
> >
> > Patch 1 makes zs_get_total_size_bytes faster because it would be
> > used frequently in later patches for the new feature.
> >
> > Patch 2 changes zs_get_total_size_bytes's return unit from bytes
> > to page so that zsmalloc doesn't need unnecessary operation(ie,
> > << PAGE_SHIFT).
> >
> > Patch 3 adds new feature. I added the feature into zram layer,
> > not zsmalloc because limiation is zram's requirement, not zsmalloc
> > so any other user using zsmalloc(ie, zpool) shouldn't affected
> > by unnecessary branch of zsmalloc. In future, if every users
> > of zsmalloc want the feature, then, we could move the feature
> > from client side to zsmalloc easily but vice versa would be
> > painful.
> >
> > Patch 4 adds news facility to report maximum memory usage of zram
> > so that this avoids user polling frequently via /sys/block/zram0/
> > mem_used_total and ensures transient max are not missed.
> 
> FWIW, with the minor update to checking the memparse in patch 3 David
> mentioned, feel free to add to all the patches:

I replied David's reply, it's not critical for the goal
of this patchset. And if we should fix, it should be memparse and handle
all of cases, not just only null case.
So I will take your Reviewed-by except 3 patch. :)

> 
> Reviewed-by: Dan Streetman <ddstreet@ieee.org>

Thanks!

> 
> >
> > * From v3
> >  * get_zs_total_size_byte function name change - Dan
> >  * clarifiction of the document - Dan
> >  * atomic account instead of introducing new lock in zsmalloc - David
> >  * remove unnecessary atomic instruction in updating max - David
> >
> > * From v2
> >  * introduce helper funcntion to update max_used_pages
> >    for readability - David
> >  * avoid unncessary zs_get_total_size call in updating loop
> >    for max_used_pages - David
> >
> > * From v1
> >  * rebased on next-20140815
> >  * fix up race problem - David, Dan
> >  * reset mem_used_max as current total_bytes, rather than 0 - David
> >  * resetting works with only "0" write for extensiblilty - David, Dan
> >
> > Minchan Kim (4):
> >   zsmalloc: move pages_allocated to zs_pool
> >   zsmalloc: change return value unit of  zs_get_total_size_bytes
> >   zram: zram memory size limitation
> >   zram: report maximum used memory
> >
> >  Documentation/ABI/testing/sysfs-block-zram |  20 ++++++
> >  Documentation/blockdev/zram.txt            |  25 +++++--
> >  drivers/block/zram/zram_drv.c              | 101 ++++++++++++++++++++++++++++-
> >  drivers/block/zram/zram_drv.h              |   6 ++
> >  include/linux/zsmalloc.h                   |   2 +-
> >  mm/zsmalloc.c                              |  30 ++++-----
> >  6 files changed, 158 insertions(+), 26 deletions(-)
> >
> > --
> > 2.0.0
> >
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
