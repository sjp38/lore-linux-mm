Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BD41C6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 18:23:11 -0400 (EDT)
Date: Tue, 25 Sep 2012 00:23:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per
 bdi variable
Message-ID: <20120924222306.GC30997@quack.suse.cz>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
 <20120920084422.GA5697@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120920084422.GA5697@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On Thu 20-09-12 16:44:22, Wu Fengguang wrote:
> On Sun, Sep 16, 2012 at 08:25:42AM -0400, Namjae Jeon wrote:
> > From: Namjae Jeon <namjae.jeon@samsung.com>
> > 
> > This patch is based on suggestion by Wu Fengguang:
> > https://lkml.org/lkml/2011/8/19/19
> > 
> > kernel has mechanism to do writeback as per dirty_ratio and dirty_background
> > ratio. It also maintains per task dirty rate limit to keep balance of
> > dirty pages at any given instance by doing bdi bandwidth estimation.
> > 
> > Kernel also has max_ratio/min_ratio tunables to specify percentage of
> > writecache to control per bdi dirty limits and task throttling.
> > 
> > However, there might be a usecase where user wants a per bdi writeback tuning
> > parameter to flush dirty data once per bdi dirty data reach a threshold
> > especially at NFS server.
> > 
> > dirty_background_centisecs provides an interface where user can tune
> > background writeback start threshold using
> > /sys/block/sda/bdi/dirty_background_centisecs
> > 
> > dirty_background_centisecs is used alongwith average bdi write bandwidth
> > estimation to start background writeback.
  The functionality you describe, i.e. start flushing bdi when there's
reasonable amount of dirty data on it, looks sensible and useful. However
I'm not so sure whether the interface you propose is the right one.
Traditionally, we allow user to set amount of dirty data (either in bytes
or percentage of memory) when background writeback should start. You
propose setting the amount of data in centisecs-to-write. Why that
difference? Also this interface ties our throughput estimation code (which
is an implementation detail of current dirty throttling) with the userspace
API. So we'd have to maintain the estimation code forever, possibly also
face problems when we change the estimation code (and thus estimates in
some cases) and users will complain that the values they set originally no
longer work as they used to.

Also, as with each knob, there's a problem how to properly set its value?
Most admins won't know about the knob and so won't touch it. Others might
know about the knob but will have hard time figuring out what value should
they set. So if there's a new knob, it should have a sensible initial
value. And since this feature looks like a useful one, it shouldn't be
zero.

So my personal preference would be to have bdi->dirty_background_ratio and
bdi->dirty_background_bytes and start background writeback whenever
one of global background limit and per-bdi background limit is exceeded. I
think this interface will do the job as well and it's easier to maintain in
future.

								Honza

> > One of the use case to demonstrate the patch functionality can be
> > on NFS setup:-
> > We have a NFS setup with ethernet line of 100Mbps, while the USB
> > disk is attached to server, which has a local speed of 25MBps. Server
> > and client both are arm target boards.
> > 
> > Now if we perform a write operation over NFS (client to server), as
> > per the network speed, data can travel at max speed of 100Mbps. But
> > if we check the default write speed of USB hdd over NFS it comes
> > around to 8MB/sec, far below the speed of network.
> > 
> > Reason being is as per the NFS logic, during write operation, initially
> > pages are dirtied on NFS client side, then after reaching the dirty
> > threshold/writeback limit (or in case of sync) data is actually sent
> > to NFS server (so now again pages are dirtied on server side). This
> > will be done in COMMIT call from client to server i.e if 100MB of data
> > is dirtied and sent then it will take minimum 100MB/100Mbps ~ 8-9 seconds.
> > 
> > After the data is received, now it will take approx 100/25 ~4 Seconds to
> > write the data to USB Hdd on server side. Hence making the overall time
> > to write this much of data ~12 seconds, which in practically comes out to
> > be near 7 to 8MB/second. After this a COMMIT response will be sent to NFS
> > client.
> > 
> > However we may improve this write performace by making the use of NFS
> > server idle time i.e while data is being received from the client,
> > simultaneously initiate the writeback thread on server side. So instead
> > of waiting for the complete data to come and then start the writeback,
> > we can work in parallel while the network is still busy in receiving the
> > data. Hence in this way overall performace will be improved.
> > 
> > If we tune dirty_background_centisecs, we can see there
> > is increase in the performace and it comes out to be ~ 11MB/seconds.
> > Results are:-
> > 
> > Write test(create a 1 GB file) result at 'NFS client' after changing 
> > /sys/block/sda/bdi/dirty_background_centisecs 
> > on  *** NFS Server only - not on NFS Client ****
> > 
> > ---------------------------------------------------------------------
> > |WRITE Test with various 'dirty_background_centisecs' at NFS Server |
> > ---------------------------------------------------------------------
> > |          | default = 0 | 300 centisec| 200 centisec| 100 centisec |
> > ---------------------------------------------------------------------
> > |RecSize   |  WriteSpeed |  WriteSpeed |  WriteSpeed |  WriteSpeed  |
> > ---------------------------------------------------------------------
> > |10485760  |  8.44MB/sec |  8.60MB/sec |  9.30MB/sec |  10.27MB/sec |
> > | 1048576  |  8.48MB/sec |  8.87MB/sec |  9.31MB/sec |  10.34MB/sec |
> > |  524288  |  8.37MB/sec |  8.42MB/sec |  9.84MB/sec |  10.47MB/sec |
> > |  262144  |  8.16MB/sec |  8.51MB/sec |  9.52MB/sec |  10.62MB/sec |
> > |  131072  |  8.48MB/sec |  8.81MB/sec |  9.42MB/sec |  10.55MB/sec |
> > |   65536  |  8.38MB/sec |  9.09MB/sec |  9.76MB/sec |  10.53MB/sec |
> > |   32768  |  8.65MB/sec |  9.00MB/sec |  9.57MB/sec |  10.54MB/sec |
> > |   16384  |  8.27MB/sec |  8.80MB/sec |  9.39MB/sec |  10.43MB/sec |
> > |    8192  |  8.52MB/sec |  8.70MB/sec |  9.40MB/sec |  10.50MB/sec |
> > |    4096  |  8.20MB/sec |  8.63MB/sec |  9.80MB/sec |  10.35MB/sec |
> > ---------------------------------------------------------------------
> > 
> > we can see, average write speed is increased to ~10-11MB/sec.
> > ============================================================
> > 
> > This patch provides the changes per block devices. So that we may modify the
> > dirty_background_centisecs as per the device and overall system is not impacted
> > by the changes and we get improved perforamace in certain use cases.
> > 
> > NOTE: dirty_background_centisecs is used alongwith average bdi write bandwidth
> > estimation to start background writeback. But, bdi write bandwidth estimation
> > is an _estimation_ and may become wildly wrong. dirty_background_centisecs
> > tuning may not always work to the user expectations. dirty_background_centisecs
> > will require careful tuning by users on NFS Server.
> > As a good use case, dirty_background_time should be set around 100 (1 sec).
> > It should not be set to very small value, otherwise it will start
> > flushing for small I/O size dirty data.
> > 
> > Changes since v1:
> > * make default value of 'dirty_background_centisecs = 0' sothat there is no change
> >   in default writeback behaviour.
> > * Add description of dirty_background_centisecs in documentation.
> > 
> > Original-patch-by: Wu Fengguang <fengguang.wu@intel.com>
> > Signed-off-by: Namjae Jeon <namjae.jeon@samsung.com>
> > Signed-off-by: Vivek Trivedi <t.vivek@samsung.com>
> > ---
> >  fs/fs-writeback.c           |   21 +++++++++++++++++++--
> >  include/linux/backing-dev.h |    1 +
> >  include/linux/writeback.h   |    1 +
> >  mm/backing-dev.c            |   21 +++++++++++++++++++++
> >  mm/page-writeback.c         |    3 ++-
> >  5 files changed, 44 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index fd255c0..c427130 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -769,6 +769,22 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
> >  	return false;
> >  }
> >  
> > +bool over_dirty_bground_time(struct backing_dev_info *bdi)
> > +{
> > +	unsigned long background_thresh;
> > +
> > +	if (!bdi->dirty_background_centisecs)
> > +		return false;
> > +
> > +	background_thresh = bdi->avg_write_bandwidth *
> > +				bdi->dirty_background_centisecs / 100;
> > +
> > +	if (bdi_stat(bdi, BDI_RECLAIMABLE) > background_thresh)
> > +		return true;
> > +
> > +	return false;
> > +}
> > +
> >  /*
> >   * Called under wb->list_lock. If there are multiple wb per bdi,
> >   * only the flusher working on the first wb should do it.
> > @@ -828,7 +844,8 @@ static long wb_writeback(struct bdi_writeback *wb,
> >  		 * For background writeout, stop when we are below the
> >  		 * background dirty threshold
> >  		 */
> > -		if (work->for_background && !over_bground_thresh(wb->bdi))
> > +		if (work->for_background && !over_bground_thresh(wb->bdi) &&
> > +			!over_dirty_bground_time(wb->bdi))
> >  			break;
> >  
> >  		/*
> > @@ -920,7 +937,7 @@ static unsigned long get_nr_dirty_pages(void)
> >  
> >  static long wb_check_background_flush(struct bdi_writeback *wb)
> >  {
> > -	if (over_bground_thresh(wb->bdi)) {
> > +	if (over_bground_thresh(wb->bdi) || over_dirty_bground_time(wb->bdi)) {
> >  
> >  		struct wb_writeback_work work = {
> >  			.nr_pages	= LONG_MAX,
> > diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> > index 2a9a9ab..43d2e15 100644
> > --- a/include/linux/backing-dev.h
> > +++ b/include/linux/backing-dev.h
> > @@ -95,6 +95,7 @@ struct backing_dev_info {
> >  
> >  	unsigned int min_ratio;
> >  	unsigned int max_ratio, max_prop_frac;
> > +	unsigned int dirty_background_centisecs;
> >  
> >  	struct bdi_writeback wb;  /* default writeback info for this bdi */
> >  	spinlock_t wb_lock;	  /* protects work_list */
> > diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> > index 50c3e8f..6dc2abe 100644
> > --- a/include/linux/writeback.h
> > +++ b/include/linux/writeback.h
> > @@ -96,6 +96,7 @@ long writeback_inodes_wb(struct bdi_writeback *wb, long nr_pages,
> >  long wb_do_writeback(struct bdi_writeback *wb, int force_wait);
> >  void wakeup_flusher_threads(long nr_pages, enum wb_reason reason);
> >  void inode_wait_for_writeback(struct inode *inode);
> > +bool over_dirty_bground_time(struct backing_dev_info *bdi);
> >  
> >  /* writeback.h requires fs.h; it, too, is not included from here. */
> >  static inline void wait_on_inode(struct inode *inode)
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index d3ca2b3..b1b2fd2 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -221,12 +221,32 @@ static ssize_t max_ratio_store(struct device *dev,
> >  }
> >  BDI_SHOW(max_ratio, bdi->max_ratio)
> >  
> > +static ssize_t dirty_background_centisecs_store(struct device *dev,
> > +		struct device_attribute *attr, const char *buf, size_t count)
> > +{
> > +	struct backing_dev_info *bdi = dev_get_drvdata(dev);
> > +	unsigned int centisecs;
> > +	ssize_t ret;
> > +
> > +	ret = kstrtouint(buf, 10, &centisecs);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	bdi->dirty_background_centisecs = centisecs;
> > +	if (over_dirty_bground_time(bdi))
> > +		bdi_start_background_writeback(bdi);
> > +
> > +	return count;
> > +}
> > +BDI_SHOW(dirty_background_centisecs, bdi->dirty_background_centisecs)
> > +
> >  #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
> >  
> >  static struct device_attribute bdi_dev_attrs[] = {
> >  	__ATTR_RW(read_ahead_kb),
> >  	__ATTR_RW(min_ratio),
> >  	__ATTR_RW(max_ratio),
> > +	__ATTR_RW(dirty_background_centisecs),
> >  	__ATTR_NULL,
> >  };
> >  
> > @@ -628,6 +648,7 @@ int bdi_init(struct backing_dev_info *bdi)
> >  	bdi->min_ratio = 0;
> >  	bdi->max_ratio = 100;
> >  	bdi->max_prop_frac = FPROP_FRAC_BASE;
> > +	bdi->dirty_background_centisecs = 0;
> >  	spin_lock_init(&bdi->wb_lock);
> >  	INIT_LIST_HEAD(&bdi->bdi_list);
> >  	INIT_LIST_HEAD(&bdi->work_list);
> > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > index 5ad5ce2..8c1530d 100644
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -1403,7 +1403,8 @@ pause:
> >  	if (laptop_mode)
> >  		return;
> >  
> > -	if (nr_reclaimable > background_thresh)
> > +	if (nr_reclaimable > background_thresh ||
> > +			over_dirty_bground_time(bdi))
> >  		bdi_start_background_writeback(bdi);
> >  }
> >  
> > -- 
> > 1.7.9.5
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
