Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C0DCE6B0100
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 16:32:54 -0400 (EDT)
Date: Wed, 4 Apr 2012 16:32:39 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404203239.GM12676@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 04, 2012 at 11:49:09AM -0700, Tejun Heo wrote:

[..]

> Thirdly, I don't see how writeback can control all the IOs.  I mean,
> what about reads or direct IOs?  It's not like IO devices have
> separate channels for those different types of IOs.  They interact
> heavily.

> Let's say we have iops/bps limitation applied on top of proportional IO
> distribution

We already do that. First IO is subjected to throttling limit and only 
then it is passed to the elevator to do the proportional IO. So throttling
is already stacked on top of proportional IO. The only question is 
should it be pushed to even higher layers or not.


> or a device holds two partitions and one
> of them is being used for direct IO w/o filesystems.  How would that
> work?  I think the question goes even deeper, what do the separate
> limits even mean?

Separate limits for buffered writes are just filling the gap. Agreed it
is not a very neat solution.

>  Does the IO sched have to calculate allocation of
> IO resource to different types of IOs and then give a "number" to
> writeback which in turn enforces that limit?  How does the elevator
> know what number to give?  Is the number iops or bps or weight?

If we push up all the throttling somewhere in higher layer, say some
of kind of per bdi throttling interface, then elevator just have to
worry about doing proportional IO. No interaction with higher layers
regarding iops/bps etc. (Not that elevator worries about it today).

> If
> the iosched doesn't know how much write workload exists, how does it
> distribute the surplus buffered writeback resource across different
> cgroups?  If so, what makes the limit actualy enforceable (due to
> inaccuracies in estimation, fluctuation in workload, delay in
> enforcement in different layers and whatnot) except for block layer
> applying the limit *again* on the resulting stream of combined IOs?

So split model is definitely confusing. Anyway, block layer will not
apply the limits again as flusher IO will go in root cgroup which 
generally goes to root which is unthrottled generally. Or flusher
could mark the bios with a flag saying "do not throttle" bios again as
these have been throttled already. So throttling again is probably not
an issue. 

In summary, agreed that split is confusing and it fills a gap existing
today.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
