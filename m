Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 721FA6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 19:27:14 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so385606wes.29
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:27:13 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id gq8si3792942wjc.76.2014.08.13.16.27.10
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 16:27:12 -0700 (PDT)
Date: Thu, 14 Aug 2014 08:27:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/3] zram: limit memory size for zram
Message-ID: <20140813232719.GD9227@bbox>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-4-git-send-email-minchan@kernel.org>
 <20140805094859.GE27993@bbox>
 <20140805131615.GA961@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140805131615.GA961@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

Hey Sergey,

On Tue, Aug 05, 2014 at 10:16:15PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (08/05/14 18:48), Minchan Kim wrote:
> > Another idea: we could define void zs_limit_mem(unsinged long nr_pages)
> > in zsmalloc and put the limit in zs_pool via new API from zram so that
> > zs_malloc could be failed as soon as it exceeds the limit.
> > 
> > In the end, zram doesn't need to call zs_get_total_size_bytes on every
> > write. It's more clean and right layer, IMHO.
> 
> yes, I think this one is better.

Although I suggested this new one, a few days ago I changed the decision
and was testing the new patchset.

If we add new API for zsmalloc, it adds unnecessary overhead for users who
doesn't care of limit. Although it's cheap, I'd like to avoid that.

The zsmalloc is just allocator so anybody can use it if they want.
But limitation is just requirement of zram who is a one of client
being able to use zsmalloc potentially so accouting should be on zram,
not zsmalloc.

If we might have more users of zsmalloc in future and they all want this
feature that limit of zsmalloc memory usage, we might move the feature
from client to zsmalloc core so everybody would be happy for performance
and readability but opposite would be painful.

In summary, let's keep the accounting logic in client side of zsmalloc(ie,
zram) at the moment but we could move it into zsmalloc core possibly
in future.

Any thoughts?

> 
> 	-ss
> 
> > On Tue, Aug 05, 2014 at 05:02:03PM +0900, Minchan Kim wrote:
> > > I have received a request several time from zram users.
> > > They want to limit memory size for zram because zram can consume
> > > lot of memory on system without limit so it makes memory management
> > > control hard.
> > > 
> > > This patch adds new knob to limit memory of zram.
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  Documentation/blockdev/zram.txt |  1 +
> > >  drivers/block/zram/zram_drv.c   | 41 +++++++++++++++++++++++++++++++++++++++++
> > >  drivers/block/zram/zram_drv.h   |  1 +
> > >  3 files changed, 43 insertions(+)
> > > 
> > > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > > index d24534bee763..fcb0561dfe2e 100644
> > > --- a/Documentation/blockdev/zram.txt
> > > +++ b/Documentation/blockdev/zram.txt
> > > @@ -96,6 +96,7 @@ size of the disk when not in use so a huge zram is wasteful.
> > >  		compr_data_size
> > >  		mem_used_total
> > >  		mem_used_max
> > > +		mem_limit
> > >  
> > >  7) Deactivate:
> > >  	swapoff /dev/zram0
> > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > index a4d637b4db7d..47f68bbb2c44 100644
> > > --- a/drivers/block/zram/zram_drv.c
> > > +++ b/drivers/block/zram/zram_drv.c
> > > @@ -137,6 +137,37 @@ static ssize_t max_comp_streams_show(struct device *dev,
> > >  	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
> > >  }
> > >  
> > > +static ssize_t mem_limit_show(struct device *dev,
> > > +		struct device_attribute *attr, char *buf)
> > > +{
> > > +	u64 val;
> > > +	struct zram *zram = dev_to_zram(dev);
> > > +
> > > +	down_read(&zram->init_lock);
> > > +	val = zram->limit_bytes;
> > > +	up_read(&zram->init_lock);
> > > +
> > > +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> > > +}
> > > +
> > > +static ssize_t mem_limit_store(struct device *dev,
> > > +		struct device_attribute *attr, const char *buf, size_t len)
> > > +{
> > > +	u64 limit;
> > > +	struct zram *zram = dev_to_zram(dev);
> > > +	int ret;
> > > +
> > > +	ret = kstrtoull(buf, 0, &limit);
> > > +	if (ret < 0)
> > > +		return ret;
> > > +
> > > +	down_write(&zram->init_lock);
> > > +	zram->limit_bytes = limit;
> > > +	ret = len;
> > > +	up_write(&zram->init_lock);
> > > +	return ret;
> > > +}
> > > +
> > >  static ssize_t max_comp_streams_store(struct device *dev,
> > >  		struct device_attribute *attr, const char *buf, size_t len)
> > >  {
> > > @@ -511,6 +542,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > >  		ret = -ENOMEM;
> > >  		goto out;
> > >  	}
> > > +
> > > +	if (zram->limit_bytes &&
> > > +		zs_get_total_size_bytes(meta->mem_pool) >= zram->limit_bytes) {
> > > +		zs_free(meta->mem_pool, handle);
> > > +		ret = -ENOMEM;
> > > +		goto out;
> > > +	}
> > > +
> > >  	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> > >  
> > >  	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> > > @@ -854,6 +893,7 @@ static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> > >  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
> > >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> > >  static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);
> > > +static DEVICE_ATTR(mem_limit, S_IRUGO, mem_limit_show, mem_limit_store);
> > >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> > >  		max_comp_streams_show, max_comp_streams_store);
> > >  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> > > @@ -883,6 +923,7 @@ static struct attribute *zram_disk_attrs[] = {
> > >  	&dev_attr_compr_data_size.attr,
> > >  	&dev_attr_mem_used_total.attr,
> > >  	&dev_attr_mem_used_max.attr,
> > > +	&dev_attr_mem_limit.attr,
> > >  	&dev_attr_max_comp_streams.attr,
> > >  	&dev_attr_comp_algorithm.attr,
> > >  	NULL,
> > > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > > index 7f21c145e317..c0d497ff6efc 100644
> > > --- a/drivers/block/zram/zram_drv.h
> > > +++ b/drivers/block/zram/zram_drv.h
> > > @@ -99,6 +99,7 @@ struct zram {
> > >  	 * we can store in a disk.
> > >  	 */
> > >  	u64 disksize;	/* bytes */
> > > +	u64 limit_bytes;
> > >  	int max_comp_streams;
> > >  	struct zram_stats stats;
> > >  	char compressor[10];
> > > -- 
> > > 2.0.0
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
> > 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
