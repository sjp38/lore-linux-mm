Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E4CD96B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 14:31:33 -0400 (EDT)
Date: Thu, 19 Apr 2012 14:31:18 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120419183118.GM10216@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419142343.GA12684@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Thu, Apr 19, 2012 at 10:23:43PM +0800, Fengguang Wu wrote:

Hi Fengguang,

[..]
> > I don't know.  What problems?  AFAICS, the biggest issue is writeback
> > of different inodes getting mixed resulting in poor performance, but
> > if you think about it, that's about the frequency of switching cgroups
> > and a problem which can and should be dealt with from block layer
> > (e.g. use larger time slice if all the pending IOs are async).
> 
> Yeah increasing time slice would help that case. In general it's not
> merely the frequency of switching cgroup if take hard disk' writeback
> cache into account.  Think about some inodes with async IO: A1, A2,
> A3, .., and inodes with sync IO: D1, D2, D3, ..., all from different
> cgroups. So when the root cgroup holds all async inodes, the cfq may
> schedule IO interleavely like this
> 
>         A1,    A1,    A1,    A2,    A1,    A2,    ...
>            D1,    D2,    D3,    D4,    D5,    D6, ...
> 
> Now it becomes
> 
>         A1,    A2,    A3,    A4,    A5,    A6,    ...
>            D1,    D2,    D3,    D4,    D5,    D6, ...
> 
> The difference is that it's now switching the async inodes each time.
> At cfq level, the seek costs look the same, however the disk's
> writeback cache may help merge the data chunks from the same inode A1.
> Well, it may cost some latency for spin disks. But how about SSD? It
> can run deeper queue and benefit from large writes.

Not sure what's the point here. Many things seem to be mixed up.

If we start putting async queues in separate groups (in an attempt to
provide fairness/service differentiation), then how much IO we dispatch
from one async inode will directly depend on slice time of that
cgroup/queue. So if you want longer dispatch from same async inode
increasing slice time will help.

Also elevator merge logic anyway increses the size of async IO requests
and big requests are submitted to device.

If you are looking that in every dispatch cycle we continue to dispatch
request from same inode, yes that's not possible. Too huge a slice length
in presence of sync IO is also not good. So if you are looking for
high throughput and sacrificing fairness then you can switch to mode
where all async queues are put in single root group. (Note: you will have
to do reasonably fast switch between cgroups so that all the cgroups are
able to do some writeout in a time window).

Writeback logic also submits a certain amount of writes from one inode
and then switches to next inode in an attempt to provide fairness. Same
thing should be directly controllable by CFQ's notion of time slice. That
is continue to dispatch async IO from a cgroup/inode for extended durtaion
before switching. So what's the difference. One can achieve equivalent
behavior at any layer (writeback/CFQ).

> 
> > Writeback's duty is generating stream of async writes which can be
> > served efficiently for the *cgroup* and keeping the buffer filled as
> > necessary and chaining the backpressure from there to the actual
> > dirtier.  That's what writeback does without cgroup.  Nothing
> > fundamental changes with cgroup.  It's just finer grained.
> 
> Believe me, physically partitioning the dirty pages and async IO
> streams comes at big costs. It won't scale well in many ways.
> 
> For one instance, splitting the request queues will give rise to
> PG_writeback pages.  Those pages have been the biggest source of
> latency issues in the various parts of the system.

So PG_writeback pages are one which have been submitted for IO? So even
now we generate PG_writeback pages across multiple inodes as we submit
those pages for IO. By keeping the number of request descriptor per
group low, we can build back pressure early and hence per inode/group
we will not have too many PG_Writeback pages. IOW, number of PG_Writeback
pages will be controllable by number of request descriptros. So how
does situation becomes worse in case of CFQ putting them in separate
cgroups?

> It's worth to note that running multiple flusher threads per bdi means
> not only disk seeks for spin disks, smaller IO size for SSD, but also
> lock contentions and cache bouncing for metadata heavy workloads and
> fast storage.

But we could still have single flusher per bdi and just check the
write congestion state of each group and back off if it is congested.

So single thread will still be doing IO submission. Just that it will
submit IO from multiple inodes/cgroup which can cause additional seeks.
And that's the tradeoff of fairness. What I am not able to understand
is that how are you avoiding this tradeoff by implementing things in
writeback layer. To achieve more fairness among groups, even a flusher
thread will have to switch faster among cgroups/inodes.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
