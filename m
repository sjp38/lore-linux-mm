Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 551B76B004D
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 10:51:49 -0400 (EDT)
Date: Wed, 4 Apr 2012 10:51:34 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404145134.GC12676@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:

Hi Tejun,

Thanks for the RFC and looking into this issue. Few thoughts inline.

[..]
> IIUC, without cgroup, the current writeback code works more or less
> like this.  Throwing in cgroup doesn't really change the fundamental
> design.  Instead of a single pipe going down, we just have multiple
> pipes to the same device, each of which should be treated separately.
> Of course, a spinning disk can't be divided that easily and their
> performance characteristics will be inter-dependent, but the place to
> solve that problem is where the problem is, the block layer.

How do you take care of thorottling IO to NFS case in this model? Current
throttling logic is tied to block device and in case of NFS, there is no
block device.

[..]
> In the discussion, for such implementation, the following obstacles
> were identified.
> 
> * There are a lot of cases where IOs are issued by a task which isn't
>   the originiator.  ie. Writeback issues IOs for pages which are
>   dirtied by some other tasks.  So, by the time an IO reaches the
>   block layer, we don't know which cgroup the IO belongs to.
> 
>   Recently, block layer has grown support to attach a task to a bio
>   which causes the bio to be handled as if it were issued by the
>   associated task regardless of the actual issuing task.  It currently
>   only allows attaching %current to a bio - bio_associate_current() -
>   but changing it to support other tasks is trivial.
> 
>   We'll need to update the async issuers to tag the IOs they issue but
>   the mechanism is already there.

Most likely this tagging will take place in "struct page" and I am not
sure if we will be allowed to grow size of "struct page" for this reason.

> 
> * There's a single request pool shared by all issuers per a request
>   queue.  This can lead to priority inversion among cgroups.  Note
>   that problem also exists without cgroups.  Lower ioprio issuer may
>   be holding a request holding back highprio issuer.
> 
>   We'll need to make request allocation cgroup (and hopefully ioprio)
>   aware.  Probably in the form of separate request pools.  This will
>   take some work but I don't think this will be too challenging.  I'll
>   work on it.

This should be doable. I had implemented it long back with single request
pool but internal limits for each group. That is block the task in the
group if group has enough pending requests allocated from the pool. But
separate request pool should work equally well. 

Just that it conflits a bit with current definition of q->nr_requests.
Which specifies number of total outstanding requests on the queue. Once
you make the pool per queue, I guess this limit will have to be
transformed into per group upper limit.

> 
> * cfq cgroup policy throws all async IOs, which all buffered writes
>   are, into the shared cgroup regardless of the actual cgroup.  This
>   behavior is, I believe, mostly historical and changing it isn't
>   difficult.  Prolly only few tens of lines of changes.  This may
>   cause significant changes to actual IO behavior with cgroups tho.  I
>   personally think the previous behavior was too wrong to keep (the
>   weight was completely ignored for buffered writes) but we may want
>   to introduce a switch to toggle between the two behaviors.

I had kept all buffered writes in in same cgroup (root cgroup) for few
reasons.

- Because of single request descriptor pool for writes, anyway one writer
  gets backlogged behind other. So creating separate async queues per
  group is not going to help.

- Writeback logic was not cgroup aware. So it might not send enough IO
  from each writer to maintain parallelism. So creating separate async
  queues did not make sense till that was fixed.

- As you said, it is historical also. We prioritize READS at the expense
  of writes. Now by putting buffered/async writes in a separate group, we
  will might end up prioritizing a group's async write over other group's
  synchronous read. How many people really want that behavior? To me
  keeping service differentiation among the sync IO matters most. Even
  if all async IO is treated same, I guess not many people might care.

> 
>   Note that blk-throttle doesn't have this problem.

I am not sure what are you trying to say here. But primarily blk-throttle
will throttle read and direct IO. Buffered writes will go to root cgroup
which is typically unthrottled.

> 
> * Unlike dirty data pages, metadata tends to have strict ordering
>   requirements and thus is susceptible to priority inversion.  Two
>   solutions were suggested - 1. allow overdrawl for metadata writes so
>   that low prio metadata writes don't block the whole FS, 2. provide
>   an interface to query and wait for bdi-cgroup congestion which can
>   be called from FS metadata paths to throttle metadata operations
>   before they enter the stream of ordered operations.

So that probably will mean changing the order of operations also. IIUC, 
in case of fsync (ordered mode), we opened a meta data transaction first,
then tried to flush all the cached data and then flush metadata. So if
fsync is throttled, all the metadata operations behind it will get 
serialized for ext3/ext4.

So you seem to be suggesting that we change the design so that metadata
operation does not thrown into ordered stream till we have finished
writing all the data back to disk? I am not a filesystem developer, so
I don't know how feasible this change is.

This is just one of the points. In the past while talking to Dave Chinner,
he mentioned that in XFS, if two cgroups fall into same allocation group
then there were cases where IO of one cgroup can get serialized behind
other.

In general, the core of the issue is that filesystems are not cgroup aware
and if you do throttling below filesystems, then invariably one or other
serialization issue will come up and I am concerned that we will be constantly
fixing those serialization issues. Or the desgin point could be so central
to filesystem design that it can't be changed.

In general, if you do throttling deeper in the stakc and build back
pressure, then all the layers sitting above should be cgroup aware
to avoid problems. Two layers identified so far are writeback and
filesystems. Is it really worth the complexity. How about doing 
throttling in higher layers when IO is entering the kernel and
keep proportional IO logic at the lowest level and current mechanism
of building pressure continues to work?

Why to split. Proportional IO logic is work conserving so even if
some serialization happens, that situation should clear up pretty
soon as IO from other cgroup will dry up and IO from the group causing
serialization will make progress and at max we will lose fairness for
certain duration.

With throttling limits come from the user and one can put really low
artificial limits. So even if the underlying resources are free the
IO from throttled cgroup might not make any progress in turn choking
every other cgroup which is serialized behind it. 

So in general throttling at block layer and building back pressure is
fine. I am concerned about two cases.

- How to handle NFS.
- Do filesystem developers agree with this approach and are they willing
  to address any serialization issues arising due to this design.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
