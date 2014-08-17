Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8EA6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:21:55 -0400 (EDT)
Received: by mail-wg0-f46.google.com with SMTP id m15so4229198wgh.17
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 16:21:55 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id bc1si22526000wjc.142.2014.08.17.16.21.52
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 16:21:54 -0700 (PDT)
Date: Mon, 18 Aug 2014 08:22:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] zram: limit memory size for zram
Message-ID: <20140817232215.GA11367@bbox>
References: <1407977877-18185-1-git-send-email-minchan@kernel.org>
 <1407977877-18185-2-git-send-email-minchan@kernel.org>
 <CALZtONB=t5nivxYTTjqjYO0EQDYvLofKO6kM_xRUn3FT1Dut6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONB=t5nivxYTTjqjYO0EQDYvLofKO6kM_xRUn3FT1Dut6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ds2horner@gmail.com

Hi Dan,

On Thu, Aug 14, 2014 at 10:33:29AM -0400, Dan Streetman wrote:
> On Wed, Aug 13, 2014 at 8:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Since zram has no control feature to limit memory usage,
> > it makes hard to manage system memrory.
> >
> > This patch adds new knob "mem_limit" via sysfs to set up the
> > limit.
> >
> > Note: I added the logic in zram, not zsmalloc because the limit
> > is requirement of zram, not zsmalloc so I'd like to avoid
> > unnecessary branch in zsmalloc.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  Documentation/blockdev/zram.txt | 20 +++++++++++++++----
> >  drivers/block/zram/zram_drv.c   | 43 +++++++++++++++++++++++++++++++++++++++++
> >  drivers/block/zram/zram_drv.h   |  1 +
> >  3 files changed, 60 insertions(+), 4 deletions(-)
> >
> > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > index 0595c3f56ccf..9f239ff8c444 100644
> > --- a/Documentation/blockdev/zram.txt
> > +++ b/Documentation/blockdev/zram.txt
> > @@ -74,14 +74,26 @@ There is little point creating a zram of greater than twice the size of memory
> >  since we expect a 2:1 compression ratio. Note that zram uses about 0.1% of the
> >  size of the disk when not in use so a huge zram is wasteful.
> >
> > -5) Activate:
> > +5) Set memory limit: Optional
> > +       Set memory limit by writing the value to sysfs node 'mem_limit'.
> > +       The value can be either in bytes or you can use mem suffixes.
> > +       Examples:
> > +           # limit /dev/zram0 with 50MB memory
> > +           echo $((50*1024*1024)) > /sys/block/zram0/mem_limit
> > +
> > +           # Using mem suffixes
> > +           echo 256K > /sys/block/zram0/mem_limit
> > +           echo 512M > /sys/block/zram0/mem_limit
> > +           echo 1G > /sys/block/zram0/mem_limit
> > +
> > +6) Activate:
> >         mkswap /dev/zram0
> >         swapon /dev/zram0
> >
> >         mkfs.ext4 /dev/zram1
> >         mount /dev/zram1 /tmp
> >
> > -6) Stats:
> > +7) Stats:
> >         Per-device statistics are exported as various nodes under
> >         /sys/block/zram<id>/
> >                 disksize
> > @@ -96,11 +108,11 @@ size of the disk when not in use so a huge zram is wasteful.
> >                 compr_data_size
> >                 mem_used_total
> >
> > -7) Deactivate:
> > +8) Deactivate:
> >         swapoff /dev/zram0
> >         umount /dev/zram1
> >
> > -8) Reset:
> > +9) Reset:
> >         Write any positive value to 'reset' sysfs node
> >         echo 1 > /sys/block/zram0/reset
> >         echo 1 > /sys/block/zram1/reset
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index d00831c3d731..b48a3d0e9031 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -122,6 +122,35 @@ static ssize_t max_comp_streams_show(struct device *dev,
> >         return scnprintf(buf, PAGE_SIZE, "%d\n", val);
> >  }
> >
> > +static ssize_t mem_limit_show(struct device *dev,
> > +               struct device_attribute *attr, char *buf)
> > +{
> > +       u64 val;
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       down_read(&zram->init_lock);
> > +       val = zram->limit_bytes;
> > +       up_read(&zram->init_lock);
> > +
> > +       return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> > +}
> > +
> > +static ssize_t mem_limit_store(struct device *dev,
> > +               struct device_attribute *attr, const char *buf, size_t len)
> > +{
> > +       u64 limit;
> > +       struct zram *zram = dev_to_zram(dev);
> > +
> > +       limit = memparse(buf, NULL);
> > +       if (!limit)
> > +               return -EINVAL;
> 
> Shouldn't passing a 0 limit be allowed, to disable the limit?

Sure. Will fix.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
