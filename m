Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 85AD26B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 19:32:47 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y13so511615pdi.3
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:32:47 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id uj4si2581144pab.63.2014.08.13.16.32.45
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 16:32:46 -0700 (PDT)
Date: Thu, 14 Aug 2014 08:32:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/3] zram memory control enhance
Message-ID: <20140813233254.GF9227@bbox>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <20140813153422.GD2768@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140813153422.GD2768@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

On Wed, Aug 13, 2014 at 10:34:22AM -0500, Seth Jennings wrote:
> On Tue, Aug 05, 2014 at 05:02:00PM +0900, Minchan Kim wrote:
> > Notice! It's RFC. I didn't test at all but wanted to hear opinion
> > during merge window when it's really busy time for Andrew so we could
> > use the slack time to discuss without hurting him. ;-)
> > 
> > Patch 1 is to move pages_allocated in zsmalloc from size_class to zs_pool
> > so zs_get_total_size_bytes of zsmalloc would be faster than old.
> > zs_get_total_size_bytes could be used next patches frequently.
> > 
> > Patch 2 adds new feature which exports how many of bytes zsmalloc consumes
> > during testing workload. Normally, before fixing the zram's disksize
> > we have tested various workload and wanted to how many of bytes zram
> > consumed.
> > For it, we could poll mem_used_total of zram in userspace but the problem is
> > when memory pressure is severe and heavy swap out happens suddenly then
> > heavy swapin or exist while polling interval of user space is a few second,
> > it could miss max memory size zram had consumed easily.
> > With lack of information, user can set wrong disksize of zram so the result
> > is OOM. So this patch adds max_mem_used for zram and zsmalloc supports it
> > 
> > Patch 3 is to limit zram memory consumption. Now, zram has no bound for
> > memory usage so it could consume up all of system memory. It makes system
> > memory control for platform hard so I have heard the feature several time.
> > 
> > Feedback is welcome!
> 
> One thing you might consider doing is moving zram to use the new zpool
> API.  That way, when making changes that effect the zsmalloc API,
> consideration for zpool, and by extension, zpool users like zswap are
> also taken into account.

Now, it's rather overkill for zram.

> 
> Seth
> 
> > 
> > Minchan Kim (3):
> >   zsmalloc: move pages_allocated to zs_pool
> >   zsmalloc/zram: add zs_get_max_size_bytes and use it in zram
> >   zram: limit memory size for zram
> > 
> >  Documentation/blockdev/zram.txt |  2 ++
> >  drivers/block/zram/zram_drv.c   | 58 +++++++++++++++++++++++++++++++++++++++++
> >  drivers/block/zram/zram_drv.h   |  1 +
> >  include/linux/zsmalloc.h        |  1 +
> >  mm/zsmalloc.c                   | 50 +++++++++++++++++++++++++----------
> >  5 files changed, 98 insertions(+), 14 deletions(-)
> > 
> > -- 
> > 2.0.0
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
