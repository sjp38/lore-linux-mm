Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 2371A6B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 15:12:20 -0400 (EDT)
Date: Thu, 19 Apr 2012 15:12:06 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: Integrated IO controller for buffered+direct writes
Message-ID: <20120419191206.GN10216@redhat.com>
References: <20120419052811.GA11543@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419052811.GA11543@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-fsdevel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Thu, Apr 19, 2012 at 01:28:11PM +0800, Fengguang Wu wrote:
[..]
> The key ideas and comments can be found in two functions in the patch:
> - cfq_scale_slice()
> - blkcg_update_dirty_ratelimit()
> The other changes are mainly supporting bits.
> 
> It adapts the existing interfaces
> - blkio.throttle.write_bps_device 
> - blkio.weight
> from the semantics "for direct IO" to "for direct+buffered IO" (it
> now handles write IO only, but should be trivial to cover reads). It
> tries to do 1:1 split of direct:buffered writes inside the cgroup
> which essentially implements intra-cgroup proportional weights.

Hey, if you can explain in few lines the design and what's the objective
its much easier to understand then going through the patch and first
trying to understand the internals of writeback.

Regarding upper limit (blkio.throttle_write_bps_device) thre are only
two problems with doing it a device layer.

- We lose context information for buffered writes.
	- This can be solved by per inode cgroup association.

	- Or solve it by throttling writer synchronously in
	  balance_dirty_pages(). I had done that by exporting a hook from
	  blk-throttle so that writeback layer does not have to worry
	  about all the details.

- Filesystems can get seriliazed.
	- This needs to be solved by filesystems.

	- Or again, invoke blk-throttle hook from balance_dirty_pages. It
	  will solve the problem for buffered writes but direct writes
	  will still have filesystem serialization issue. So it needs to
	  be solved by filesystems anyway.  

- Throttling for network file systems.
	- This would be the only advantage or implementing things at
	  higher layer so that we don't have to build special knowledge
	  of throttling in lower layers.

So which of the above problem you are exactly solving by throttling
by writes in writeback layer and why exporting a throttling hook from
blk-throttle to balance_drity_pages()is not a good idea?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
