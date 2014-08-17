Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CA9036B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 19:32:15 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so6536791pad.23
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 16:32:15 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gk11si18938407pbd.39.2014.08.17.16.32.13
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 16:32:14 -0700 (PDT)
Date: Mon, 18 Aug 2014 08:32:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/3] zram: limit memory size for zram
Message-ID: <20140817233225.GB11367@bbox>
References: <1407225723-23754-1-git-send-email-minchan@kernel.org>
 <1407225723-23754-4-git-send-email-minchan@kernel.org>
 <20140805094859.GE27993@bbox>
 <20140805131615.GA961@swordfish>
 <20140813232719.GD9227@bbox>
 <20140814132953.GC966@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140814132953.GC966@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>

Hello Sergey,

On Thu, Aug 14, 2014 at 10:29:53PM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (08/14/14 08:27), Minchan Kim wrote:
> > Date: Thu, 14 Aug 2014 08:27:19 +0900
> > From: Minchan Kim <minchan@kernel.org>
> > To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>,
> >  linux-kernel@vger.kernel.org, juno.choi@lge.com, seungho1.park@lge.com,
> >  Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>
> > Subject: Re: [RFC 3/3] zram: limit memory size for zram
> > User-Agent: Mutt/1.5.21 (2010-09-15)
> > 
> > Hey Sergey,
> > 
> > On Tue, Aug 05, 2014 at 10:16:15PM +0900, Sergey Senozhatsky wrote:
> > > Hello,
> > > 
> > > On (08/05/14 18:48), Minchan Kim wrote:
> > > > Another idea: we could define void zs_limit_mem(unsinged long nr_pages)
> > > > in zsmalloc and put the limit in zs_pool via new API from zram so that
> > > > zs_malloc could be failed as soon as it exceeds the limit.
> > > > 
> > > > In the end, zram doesn't need to call zs_get_total_size_bytes on every
> > > > write. It's more clean and right layer, IMHO.
> > > 
> > > yes, I think this one is better.
> > 
> > Although I suggested this new one, a few days ago I changed the decision
> > and was testing the new patchset.
> > 
> > If we add new API for zsmalloc, it adds unnecessary overhead for users who
> > doesn't care of limit. Although it's cheap, I'd like to avoid that.
> > 
> > The zsmalloc is just allocator so anybody can use it if they want.
> > But limitation is just requirement of zram who is a one of client
> > being able to use zsmalloc potentially so accouting should be on zram,
> > not zsmalloc.
> > 
> 
> my motivation was that zram does not use that much memory itself,
> zspool - does. zram is just a clueless client from that point of
> view: it recives some requests, do some things with supplied data,
> and asks zspool if the latter one can find some place to keep that
> data (and zram doesn't really care how that memory will be allocated
> or will not be).

Normally, when we consider malloc(3), malloc(3) doesn't give any API
to limit memory size for the process. It just exposes some API to
return the state like (ex, mallopt) to the user so it's user's role
to manage the memory. I thought it's same with zsmalloc.
zsmalloc already exposes zs_get_total_size_bytes so client can do it
if he want to limit and frequent API call(ex, zs_get_total_size_bytes)
should be his overhead while others who don't need to limit should
be no overhead.

> 
> I'm OK if we will have memory limitation in ZRAM. though conceptually,
> IMHO, it feels that such logic belongs to allocation layer. yet I admit
> the potential overhead issue.
> 
> > If we might have more users of zsmalloc in future and they all want this
> > feature that limit of zsmalloc memory usage, we might move the feature
> > from client to zsmalloc core so everybody would be happy for performance
> > and readability but opposite would be painful.
> > 
> > In summary, let's keep the accounting logic in client side of zsmalloc(ie,
> > zram) at the moment but we could move it into zsmalloc core possibly
> > in future.
> > 
> > Any thoughts?
> 
> agreed.

Thanks for the comment, Sergey!

> 
> 	-ss
> 
> > > 
> > > 	-ss
> > > 
> > > > On Tue, Aug 05, 2014 at 05:02:03PM +0900, Minchan Kim wrote:
> > > > > I have received a request several time from zram users.
> > > > > They want to limit memory size for zram because zram can consume
> > > > > lot of memory on system without limit so it makes memory management
> > > > > control hard.
> > > > > 
> > > > > This patch adds new knob to limit memory of zram.
> > > > > 
> > > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > > ---
> > > > >  Documentation/blockdev/zram.txt |  1 +
> > > > >  drivers/block/zram/zram_drv.c   | 41 +++++++++++++++++++++++++++++++++++++++++
> > > > >  drivers/block/zram/zram_drv.h   |  1 +
> > > > >  3 files changed, 43 insertions(+)
> > > > > 
> > > > > diff --git a/Documentation/blockdev/zram.txt b/Documentation/blockdev/zram.txt
> > > > > index d24534bee763..fcb0561dfe2e 100644
> > > > > --- a/Documentation/blockdev/zram.txt
> > > > > +++ b/Documentation/blockdev/zram.txt
> > > > > @@ -96,6 +96,7 @@ size of the disk when not in use so a huge zram is wasteful.
> > > > >  		compr_data_size
> > > > >  		mem_used_total
> > > > >  		mem_used_max
> > > > > +		mem_limit
> > > > >  
> > > > >  7) Deactivate:
> > > > >  	swapoff /dev/zram0
> > > > > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > > > > index a4d637b4db7d..47f68bbb2c44 100644
> > > > > --- a/drivers/block/zram/zram_drv.c
> > > > > +++ b/drivers/block/zram/zram_drv.c
> > > > > @@ -137,6 +137,37 @@ static ssize_t max_comp_streams_show(struct device *dev,
> > > > >  	return scnprintf(buf, PAGE_SIZE, "%d\n", val);
> > > > >  }
> > > > >  
> > > > > +static ssize_t mem_limit_show(struct device *dev,
> > > > > +		struct device_attribute *attr, char *buf)
> > > > > +{
> > > > > +	u64 val;
> > > > > +	struct zram *zram = dev_to_zram(dev);
> > > > > +
> > > > > +	down_read(&zram->init_lock);
> > > > > +	val = zram->limit_bytes;
> > > > > +	up_read(&zram->init_lock);
> > > > > +
> > > > > +	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
> > > > > +}
> > > > > +
> > > > > +static ssize_t mem_limit_store(struct device *dev,
> > > > > +		struct device_attribute *attr, const char *buf, size_t len)
> > > > > +{
> > > > > +	u64 limit;
> > > > > +	struct zram *zram = dev_to_zram(dev);
> > > > > +	int ret;
> > > > > +
> > > > > +	ret = kstrtoull(buf, 0, &limit);
> > > > > +	if (ret < 0)
> > > > > +		return ret;
> > > > > +
> > > > > +	down_write(&zram->init_lock);
> > > > > +	zram->limit_bytes = limit;
> > > > > +	ret = len;
> > > > > +	up_write(&zram->init_lock);
> > > > > +	return ret;
> > > > > +}
> > > > > +
> > > > >  static ssize_t max_comp_streams_store(struct device *dev,
> > > > >  		struct device_attribute *attr, const char *buf, size_t len)
> > > > >  {
> > > > > @@ -511,6 +542,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> > > > >  		ret = -ENOMEM;
> > > > >  		goto out;
> > > > >  	}
> > > > > +
> > > > > +	if (zram->limit_bytes &&
> > > > > +		zs_get_total_size_bytes(meta->mem_pool) >= zram->limit_bytes) {
> > > > > +		zs_free(meta->mem_pool, handle);
> > > > > +		ret = -ENOMEM;
> > > > > +		goto out;
> > > > > +	}
> > > > > +
> > > > >  	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> > > > >  
> > > > >  	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
> > > > > @@ -854,6 +893,7 @@ static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
> > > > >  static DEVICE_ATTR(orig_data_size, S_IRUGO, orig_data_size_show, NULL);
> > > > >  static DEVICE_ATTR(mem_used_total, S_IRUGO, mem_used_total_show, NULL);
> > > > >  static DEVICE_ATTR(mem_used_max, S_IRUGO, mem_used_max_show, NULL);
> > > > > +static DEVICE_ATTR(mem_limit, S_IRUGO, mem_limit_show, mem_limit_store);
> > > > >  static DEVICE_ATTR(max_comp_streams, S_IRUGO | S_IWUSR,
> > > > >  		max_comp_streams_show, max_comp_streams_store);
> > > > >  static DEVICE_ATTR(comp_algorithm, S_IRUGO | S_IWUSR,
> > > > > @@ -883,6 +923,7 @@ static struct attribute *zram_disk_attrs[] = {
> > > > >  	&dev_attr_compr_data_size.attr,
> > > > >  	&dev_attr_mem_used_total.attr,
> > > > >  	&dev_attr_mem_used_max.attr,
> > > > > +	&dev_attr_mem_limit.attr,
> > > > >  	&dev_attr_max_comp_streams.attr,
> > > > >  	&dev_attr_comp_algorithm.attr,
> > > > >  	NULL,
> > > > > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > > > > index 7f21c145e317..c0d497ff6efc 100644
> > > > > --- a/drivers/block/zram/zram_drv.h
> > > > > +++ b/drivers/block/zram/zram_drv.h
> > > > > @@ -99,6 +99,7 @@ struct zram {
> > > > >  	 * we can store in a disk.
> > > > >  	 */
> > > > >  	u64 disksize;	/* bytes */
> > > > > +	u64 limit_bytes;
> > > > >  	int max_comp_streams;
> > > > >  	struct zram_stats stats;
> > > > >  	char compressor[10];
> > > > > -- 
> > > > > 2.0.0
> > > > 
> > > > -- 
> > > > Kind regards,
> > > > Minchan Kim
> > > > 
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
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
