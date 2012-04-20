Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 3F2B76B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 08:50:39 -0400 (EDT)
Date: Fri, 20 Apr 2012 20:45:18 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120420124518.GA7133@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419183118.GM10216@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120419183118.GM10216@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hi Vivek,

On Thu, Apr 19, 2012 at 02:31:18PM -0400, Vivek Goyal wrote:
> On Thu, Apr 19, 2012 at 10:23:43PM +0800, Fengguang Wu wrote:
> 
> Hi Fengguang,
> 
> [..]
> > > I don't know.  What problems?  AFAICS, the biggest issue is writeback
> > > of different inodes getting mixed resulting in poor performance, but
> > > if you think about it, that's about the frequency of switching cgroups
> > > and a problem which can and should be dealt with from block layer
> > > (e.g. use larger time slice if all the pending IOs are async).
> > 
> > Yeah increasing time slice would help that case. In general it's not
> > merely the frequency of switching cgroup if take hard disk' writeback
> > cache into account.  Think about some inodes with async IO: A1, A2,
> > A3, .., and inodes with sync IO: D1, D2, D3, ..., all from different
> > cgroups. So when the root cgroup holds all async inodes, the cfq may
> > schedule IO interleavely like this
> > 
> >         A1,    A1,    A1,    A2,    A1,    A2,    ...
> >            D1,    D2,    D3,    D4,    D5,    D6, ...
> > 
> > Now it becomes
> > 
> >         A1,    A2,    A3,    A4,    A5,    A6,    ...
> >            D1,    D2,    D3,    D4,    D5,    D6, ...
> > 
> > The difference is that it's now switching the async inodes each time.
> > At cfq level, the seek costs look the same, however the disk's
> > writeback cache may help merge the data chunks from the same inode A1.
> > Well, it may cost some latency for spin disks. But how about SSD? It
> > can run deeper queue and benefit from large writes.
> 
> Not sure what's the point here. Many things seem to be mixed up.
> 
> If we start putting async queues in separate groups (in an attempt to
> provide fairness/service differentiation), then how much IO we dispatch
> from one async inode will directly depend on slice time of that
> cgroup/queue. So if you want longer dispatch from same async inode
> increasing slice time will help.

Right. The problem is async slice time can hardly be increased when
there are sync IO, as you said below.

> Also elevator merge logic anyway increses the size of async IO requests
> and big requests are submitted to device.
> 
> If you are looking that in every dispatch cycle we continue to dispatch
> request from same inode, yes that's not possible. Too huge a slice length
> in presence of sync IO is also not good. So if you are looking for
> high throughput and sacrificing fairness then you can switch to mode
> where all async queues are put in single root group. (Note: you will have
> to do reasonably fast switch between cgroups so that all the cgroups are
> able to do some writeout in a time window).

Agreed.

> Writeback logic also submits a certain amount of writes from one inode
> and then switches to next inode in an attempt to provide fairness. Same
> thing should be directly controllable by CFQ's notion of time slice. That
> is continue to dispatch async IO from a cgroup/inode for extended durtaion
> before switching. So what's the difference. One can achieve equivalent
> behavior at any layer (writeback/CFQ).

The difference is, the flusher's slice time is 500ms, while the cfq's
async slice time is 40ms. In the one async queue case, cfq will switch
back to serve the remaining data from the same inode; while in split
async queues case, cfq will switch to the other inodes. This makes the
flusher's larger slice time somehow "useless".

> > > Writeback's duty is generating stream of async writes which can be
> > > served efficiently for the *cgroup* and keeping the buffer filled as
> > > necessary and chaining the backpressure from there to the actual
> > > dirtier.  That's what writeback does without cgroup.  Nothing
> > > fundamental changes with cgroup.  It's just finer grained.
> > 
> > Believe me, physically partitioning the dirty pages and async IO
> > streams comes at big costs. It won't scale well in many ways.
> > 
> > For one instance, splitting the request queues will give rise to
> > PG_writeback pages.  Those pages have been the biggest source of
> > latency issues in the various parts of the system.
> 
> So PG_writeback pages are one which have been submitted for IO? So even

Yes.

> now we generate PG_writeback pages across multiple inodes as we submit
> those pages for IO. By keeping the number of request descriptor per
> group low, we can build back pressure early and hence per inode/group
> we will not have too many PG_Writeback pages. IOW, number of PG_Writeback
> pages will be controllable by number of request descriptros.

> So how does situation becomes worse in case of CFQ putting them in
> separate cgroups?

Good question.

Imagine there are 10 dds (each in one cgroup) dirtying pages and the
flusher thread is issuing IO for them in round robin fashion, issuing
500ms worth of data for each inode and then go on to next.

And imagine we keep a minimal global async queue size, which is just
enough for holding the 500ms data from one inode. If it can be reduced
to 40ms without leading to underrun or hurt in other ways, then great.
Even if the queue size is much smaller than the flusher's write chunk
size, the disk will still be serving inodes on 500ms granularity,
because the flusher won't feed cfq with other data during the time.

Now consider moving to 10 async queues, each in one cfq group. Now
each inode will need to have at least 40ms data queued, so that when a
new cfq async slice comes, it can get enough data to work with.

Adding it up, (40ms per queue * 10 queues) = 400ms. It means, 400ms is
what's more than enough in the global async queue scheme is now only
barely enough to avoid queue underrun. This makes one fundamental need
to increase the total queued requests and hence PG_writeback pages.

To avoid seeks we might do tricks to let cfq return to the same group
serving the same async queue and repeat it for 500ms/40ms times.
However the cfq vdisktime/weight system in general don't work that way.
Once cgroup A get served its vdisktime will be increased and naturally
some other cgroup's async queue get selected. And it's hardly feasible
to increase async slice time to 500ms.

Overall the split async queues in cfq will be defeating the flusher's
attempt to amortize IO, because the cfq groups are now walking through
the inodes in much more "fine grained" granularity: 40ms vs 500ms.

> > It's worth to note that running multiple flusher threads per bdi means
> > not only disk seeks for spin disks, smaller IO size for SSD, but also
> > lock contentions and cache bouncing for metadata heavy workloads and
> > fast storage.
> 
> But we could still have single flusher per bdi and just check the
> write congestion state of each group and back off if it is congested.
> 
> So single thread will still be doing IO submission. Just that it will
> submit IO from multiple inodes/cgroup which can cause additional seeks.

Yes we still have the good option to run one single flusher. Except
that its writeback chunk size should be reduced to match the 40ms
async slice time and queue size mentioned above.

So yes, running one single flusher will help reduce contentions,
however cannot help avoid smaller IO size.

> And that's the tradeoff of fairness. What I am not able to understand
> is that how are you avoiding this tradeoff by implementing things in
> writeback layer. To achieve more fairness among groups, even a flusher
> thread will have to switch faster among cgroups/inodes.
 
Fairness is only a problem for the cfq groups. cfq by nature works on
sub-100ms granularities and switches between groups at that frequency.
If it gives each cgroup 500ms and there are 10 cgroups, latency will
become uncontrollable.

If still keep the global async queue, it can run small 40ms slices
without defeating the flusher's 500ms granularity. After each slice
it can freely switch to other cgroups with sync IOs, so is free from
latency issues. After return, it will continue to serve the same
inode. It will basically be working on behalf of one cgroup for 500ms
data, working for another cgroup for 500ms data and so on. That
behavior does not impact fairness, because it's still using small
slices and its weight is computed system wide thus exhibits some kind
of smooth/amortize effects over long period of time. It can naturally 
serve the same inode after return.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
