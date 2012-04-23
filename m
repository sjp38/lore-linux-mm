Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id EA00A6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 04:33:27 -0400 (EDT)
Date: Mon, 23 Apr 2012 16:28:12 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Integrated IO controller for buffered+direct writes
Message-ID: <20120423082812.GA10857@localhost>
References: <20120419052811.GA11543@localhost>
 <20120419191206.GN10216@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419191206.GN10216@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Thu, Apr 19, 2012 at 03:12:06PM -0400, Vivek Goyal wrote:
> On Thu, Apr 19, 2012 at 01:28:11PM +0800, Fengguang Wu wrote:
> [..]
> > The key ideas and comments can be found in two functions in the patch:
> > - cfq_scale_slice()
> > - blkcg_update_dirty_ratelimit()
> > The other changes are mainly supporting bits.
> > 
> > It adapts the existing interfaces
> > - blkio.throttle.write_bps_device 
> > - blkio.weight
> > from the semantics "for direct IO" to "for direct+buffered IO" (it
> > now handles write IO only, but should be trivial to cover reads). It
> > tries to do 1:1 split of direct:buffered writes inside the cgroup
> > which essentially implements intra-cgroup proportional weights.
> 
> Hey, if you can explain in few lines the design and what's the objective
> its much easier to understand then going through the patch and first
> trying to understand the internals of writeback.
 
The main objective is to keep the current buffered IO path untouched
and keep a single pool of dirty/writeback pages and single async IO
queue.

The basic balance_dirty_pages() work model is to split the total
writeout bandwidth equally to N dirtier tasks, where N is re-estimated
on every 200ms.

        bdi->dirty_ratelimit = bdi->write_bandwidth / N
        task_ratelimit = bdi->dirty_ratelimit   # ignoring dirty position control for simplicity

To support blkcg, the new formula is 

        bdi->dirty_ratelimit = bdi->write_bandwidth / N
        blkcg->dirty_ratelimit = bdi->dirty_ratelimit
        task_ratelimit = blkcg->dirty_ratelimit / M

where N is the number of cgroups, M is the number of dirtier tasks
inside each cgroup.

To support proportional async and dio weights, the formula is
expanded to

        bdi->dirty_ratelimit = (bdi->write_bandwidth +
                                bdi->direct_write_bandwidth) / N
        blkcg->dirty_ratelimit = bdi->dirty_ratelimit / P
        task_ratelimit = blkcg->dirty_ratelimit / M

where P=2 when there are both aggressive async/dio IOs inside that
cgroup, P=1 when there are only aggressive async IOs.

balance_dirty_pages() will do dirty throttling when dirty pages
enter the page cache. It also splits up blkcg->weight into dio_weight
and async_weight for use by cfq.

cfq will continue to do proportional weight throttling:
- dio goes to each cgroup
- all async writeout carried out in the root cgroup

dirty time

  cgroup1                 cgroup2                 cgroup3
  +---------+---------+   +-------------------+   +-------------------+
  |  async  |   dio   |   |       async       |   |        dio        |
  +---------+---------+   +-------------------+   +-------------------+
     250        250               500                      500

writeout time

  root cgroup                       cgroup1       cgroup3
  +---------+-------------------+   +---------+   +-------------------+
  |  async          async       |   |   dio   |   |        dio        |
  +---------+-------------------+   +---------+   +-------------------+
             750                        250                500

In the above example, the async weights for cgroup1 and cgroup2 will
be added up and allocated to the root cgroup, so the flusher will get
half total disk time. Assume a 150MB/s disk and equal cost for
async/dio IOs, the above cfq weights will yield

        bdi->write_bandwidth = 75
        blkcg1->dio_rate = 25
        blkcg2->dio_rate = 50
        bdi->direct_write_bandwidth = sum(dio_rate) = 75

balance_dirty_pages() will detect out N=3 cgroups doing active IO, and
yield
        bdi->dirty_ratelimit = (bdi->write_bandwidth +
                                bdi->direct_write_bandwidth) / N
                             = 50
For cgroup1, it detects both aggressive async/dio IOs, so assigns half
bandwidth to the dirtier tasks inside cgroup1:

        blkcg1->dirty_ratelimit = bdi->dirty_ratelimit / 2
                                = 25

For cgroup2, it detects only aggressive async IOs, so assign full
bandwidth to the dirtier tasks inside cgroup2:

        blkcg2->dirty_ratelimit = bdi->dirty_ratelimit
                                = 50

In the end, balance_dirty_pages() will throttle dirty rates to 25+50 MB/s
for cgroup1+cgroup2, and cfq will give 250+500 weights to the flusher,
yielding 25+75 MB/s writeout bandwidth. So the two ends meet nicely.

> Regarding upper limit (blkio.throttle_write_bps_device) thre are only
> two problems with doing it a device layer.
> 
> - We lose context information for buffered writes.
> 	- This can be solved by per inode cgroup association.
> 
> 	- Or solve it by throttling writer synchronously in
> 	  balance_dirty_pages(). I had done that by exporting a hook from
> 	  blk-throttle so that writeback layer does not have to worry
> 	  about all the details.

Agreed.

> - Filesystems can get seriliazed.
> 	- This needs to be solved by filesystems.
> 
> 	- Or again, invoke blk-throttle hook from balance_dirty_pages. It
> 	  will solve the problem for buffered writes but direct writes
> 	  will still have filesystem serialization issue. So it needs to
> 	  be solved by filesystems anyway.  

Agreed.

> - Throttling for network file systems.
> 	- This would be the only advantage or implementing things at
> 	  higher layer so that we don't have to build special knowledge
> 	  of throttling in lower layers.

Yeah here is the gap.

> So which of the above problem you are exactly solving by throttling
> by writes in writeback layer and why exporting a throttling hook from
> blk-throttle to balance_drity_pages()is not a good idea?

I'm fine with adding a blk-throttle hook in balance_drity_pages().
The current dirty throttling algorithms can work just fine with it.
And this feature should serve the majority users well.

I'll remove the blkio.throttle.write_bps_device support from this
patchset. It's not complete in the current form, after all.

However as a user, I do feel it much easier to specify one single
per-cgroup limit rather than breaking it down to per-device limits.
There is also the obvious need to do per-bdi limits on software RAID,
btrfs, NFS, CIFS, fuse, etc.

So if there come such user requests where your blk-throttle runs
short, I'd be glad to do an up limit IO controller in high layer :-)

The sweet thing is, the two up limit IO controllers will be able to
live with each other peacefully and freely selectable by the user:

- "0:0             bw" enables high layer per-cgroup throttling
- "bdi_maj:bdi_min bw" enables high layer per-cgroup-per-bdi throttling
- "dev_maj:dev_min bw" enables block layer throttling

The implementation will be very similar to this prototype:

        buffered write IO controller in balance_dirty_pages()
        https://lkml.org/lkml/2012/3/28/275

It's pretty simple (in code size), yet powerful enough to distribute
total bandwidth limit equally to all IO tasks, whether they are doing
buffered or direct IO.

It will need to insert calls to a stripped down balance_dirty_pages()
in the readahead and direct IO paths. The async IO will need some more
code to delay the IO completion notifications.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
