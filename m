Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B06AD6B00F7
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 14:49:15 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so703578pbc.14
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 11:49:14 -0700 (PDT)
Date: Wed, 4 Apr 2012 11:49:09 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404145134.GC12676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hey, Vivek.

On Wed, Apr 04, 2012 at 10:51:34AM -0400, Vivek Goyal wrote:
> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
> > IIUC, without cgroup, the current writeback code works more or less
> > like this.  Throwing in cgroup doesn't really change the fundamental
> > design.  Instead of a single pipe going down, we just have multiple
> > pipes to the same device, each of which should be treated separately.
> > Of course, a spinning disk can't be divided that easily and their
> > performance characteristics will be inter-dependent, but the place to
> > solve that problem is where the problem is, the block layer.
> 
> How do you take care of thorottling IO to NFS case in this model? Current
> throttling logic is tied to block device and in case of NFS, there is no
> block device.

On principle, I don't think it has be any different.  Filesystems's
interface to the underlying device is through bdi.  If a fs is block
backed, block pressure should be propagated through bdi, which should
be mostly trivial.  If a fs is network backed, we can implement a
mechanism for network backed bdis, so that they can relay the pressure
from the server side to the local fs users.

That said, network filesystems often show different behaviors and use
different mechanisms for various reasons and it wouldn't be too
surprising if something different would fit them better here or we
might need something supplemental to the usual mechanism.

> [..]
> > In the discussion, for such implementation, the following obstacles
> > were identified.
> > 
> > * There are a lot of cases where IOs are issued by a task which isn't
> >   the originiator.  ie. Writeback issues IOs for pages which are
> >   dirtied by some other tasks.  So, by the time an IO reaches the
> >   block layer, we don't know which cgroup the IO belongs to.
> > 
> >   Recently, block layer has grown support to attach a task to a bio
> >   which causes the bio to be handled as if it were issued by the
> >   associated task regardless of the actual issuing task.  It currently
> >   only allows attaching %current to a bio - bio_associate_current() -
> >   but changing it to support other tasks is trivial.
> > 
> >   We'll need to update the async issuers to tag the IOs they issue but
> >   the mechanism is already there.
> 
> Most likely this tagging will take place in "struct page" and I am not
> sure if we will be allowed to grow size of "struct page" for this reason.

With memcg enabled, we are already doing that and IIUC Jan and
Fengguang think that using inode granularity should be good enough for
writeback blaming.

> > * There's a single request pool shared by all issuers per a request
> >   queue.  This can lead to priority inversion among cgroups.  Note
> >   that problem also exists without cgroups.  Lower ioprio issuer may
> >   be holding a request holding back highprio issuer.
> > 
> >   We'll need to make request allocation cgroup (and hopefully ioprio)
> >   aware.  Probably in the form of separate request pools.  This will
> >   take some work but I don't think this will be too challenging.  I'll
> >   work on it.
> 
> This should be doable. I had implemented it long back with single request
> pool but internal limits for each group. That is block the task in the
> group if group has enough pending requests allocated from the pool. But
> separate request pool should work equally well. 
> 
> Just that it conflits a bit with current definition of q->nr_requests.
> Which specifies number of total outstanding requests on the queue. Once
> you make the pool per queue, I guess this limit will have to be
> transformed into per group upper limit.

I'm not sure about the details yet.  I *think* the suckiest part is
the actual allocation part.  We're deferring cgroup - request_queue
association until actual usage and depending on atomic allocations to
create those associations on IO path.  Doing the same for requests
might not be too pleasant.  Hmm....  allocation failure handling on
that path is already broken BTW.  Maybe we just need to get the
fallback behavior properly working.  Unsure.

> > * cfq cgroup policy throws all async IOs, which all buffered writes
> >   are, into the shared cgroup regardless of the actual cgroup.  This
> >   behavior is, I believe, mostly historical and changing it isn't
> >   difficult.  Prolly only few tens of lines of changes.  This may
> >   cause significant changes to actual IO behavior with cgroups tho.  I
> >   personally think the previous behavior was too wrong to keep (the
> >   weight was completely ignored for buffered writes) but we may want
> >   to introduce a switch to toggle between the two behaviors.
> 
> I had kept all buffered writes in in same cgroup (root cgroup) for few
> reasons.
> 
> - Because of single request descriptor pool for writes, anyway one writer
>   gets backlogged behind other. So creating separate async queues per
>   group is not going to help.
> 
> - Writeback logic was not cgroup aware. So it might not send enough IO
>   from each writer to maintain parallelism. So creating separate async
>   queues did not make sense till that was fixed.

Yeah, the above are why I find "buffered writes need separate controls
because cfq doesn't distinguish async writes" argument very ironic.
We introduce one quirk to compensate for shortages in the other part
and then later we work that around in that other part for that quirk?
I mean, that's just twisted.

> - As you said, it is historical also. We prioritize READS at the expense
>   of writes. Now by putting buffered/async writes in a separate group, we
>   will might end up prioritizing a group's async write over other group's
>   synchronous read. How many people really want that behavior? To me
>   keeping service differentiation among the sync IO matters most. Even
>   if all async IO is treated same, I guess not many people might care.

While segregation of async IOs may not matter in some cases, it does
matter to many other use cases, so it seems to me that we hard coded
that optimization decision without thinking too much about it.  For a
lot of container type use cases, the current implementation is nearly
useless (I know of cases where people are explicitly patching for
separate async queues).  At the same time, switching the default
behavior *may* disturb some of the current users and that's why I'm
thinking abut having a switch for the new behavior.

> >   Note that blk-throttle doesn't have this problem.
> 
> I am not sure what are you trying to say here. But primarily blk-throttle
> will throttle read and direct IO. Buffered writes will go to root cgroup
> which is typically unthrottled.

Ooh, my bad then.  Anyways, then the same applies to blk-throttle.
Our current implementation essentially collapses at the face of
write-heavy workload.

> > * Unlike dirty data pages, metadata tends to have strict ordering
> >   requirements and thus is susceptible to priority inversion.  Two
> >   solutions were suggested - 1. allow overdrawl for metadata writes so
> >   that low prio metadata writes don't block the whole FS, 2. provide
> >   an interface to query and wait for bdi-cgroup congestion which can
> >   be called from FS metadata paths to throttle metadata operations
> >   before they enter the stream of ordered operations.
> 
> So that probably will mean changing the order of operations also. IIUC, 
> in case of fsync (ordered mode), we opened a meta data transaction first,
> then tried to flush all the cached data and then flush metadata. So if
> fsync is throttled, all the metadata operations behind it will get 
> serialized for ext3/ext4.
> 
> So you seem to be suggesting that we change the design so that metadata
> operation does not thrown into ordered stream till we have finished
> writing all the data back to disk? I am not a filesystem developer, so
> I don't know how feasible this change is.

Jan explained it to me and I don't think it requires extensive changes
to the filesystem.  IIUC, filesystems would just block tasks creating
journal entry while its matching bdi is congested and that's the
extent of the necessary change.

> This is just one of the points. In the past while talking to Dave Chinner,
> he mentioned that in XFS, if two cgroups fall into same allocation group
> then there were cases where IO of one cgroup can get serialized behind
> other.
> 
> In general, the core of the issue is that filesystems are not cgroup aware
> and if you do throttling below filesystems, then invariably one or other
> serialization issue will come up and I am concerned that we will be constantly
> fixing those serialization issues. Or the desgin point could be so central
> to filesystem design that it can't be changed.

So, the idea is to avoid allowing any congested cgroup to enter
serialized journal.  As there's time gap until journal commit, the bdi
might be congested by the commit time.  In that case, META writes get
to overdraw cgroup limits to avoid causing priority inversion.  I
think we should be able to get most working with bdi congestion check
at the front and limit bypass for META for now.  We can worry about
overdrawing later.

> In general, if you do throttling deeper in the stakc and build back
> pressure, then all the layers sitting above should be cgroup aware
> to avoid problems. Two layers identified so far are writeback and
> filesystems. Is it really worth the complexity. How about doing 
> throttling in higher layers when IO is entering the kernel and
> keep proportional IO logic at the lowest level and current mechanism
> of building pressure continues to work?

First, I just don't think it's the right design.  It's a rather
abstract statement but I want to emphasize that having the "right"
design, in the sense that we look at the overall picture and put
configs, controls and other logics where they belong to in the
structure that their roles point to tends to make long-term
development and maintenance much easier in ways which may not be
immediately foreseeable, for both technical and social reasons -
logical structuring and layering keep us sane and make new comer's
lives at least bearable.

Secondly, I don't think it'll be a lot of added complexity.  We *need*
to fix all the said shortcoming in block layer for proper cgroup
support anyway, right?  Propagating that support upwards doesn't take
too much code.  Other than the metadata thing, it mostly just requires
updates to writeback code such that they deal with bdi-cgroup
combination instead of individual cgroups.  They'll surely require
some adjustments but we're not gonna be burdening the main paths with
cgroup awareness.  cgroup support would just make the existing
implementation work on finer grained domains.

Thirdly, I don't see how writeback can control all the IOs.  I mean,
what about reads or direct IOs?  It's not like IO devices have
separate channels for those different types of IOs.  They interact
heavily.  Let's say we have iops/bps limitation applied on top of
proportional IO distribution or a device holds two partitions and one
of them is being used for direct IO w/o filesystems.  How would that
work?  I think the question goes even deeper, what do the separate
limits even mean?  Does the IO sched have to calculate allocation of
IO resource to different types of IOs and then give a "number" to
writeback which in turn enforces that limit?  How does the elevator
know what number to give?  Is the number iops or bps or weight?  If
the iosched doesn't know how much write workload exists, how does it
distribute the surplus buffered writeback resource across different
cgroups?  If so, what makes the limit actualy enforceable (due to
inaccuracies in estimation, fluctuation in workload, delay in
enforcement in different layers and whatnot) except for block layer
applying the limit *again* on the resulting stream of combined IOs?

Fourthly, having clear layering usually means much more flexibility.
The assumptions about IO characteristics that we have are still mostly
based on devices with spindles, probably because they're still causing
the most amount of pain.  The assumptions keep changing and if we get
the layering correct, we can mostly deal with changes at the layers
concerning them - ie. in the block layer.  Maybe we'll have a
different iosched or cfq can be evolved to cover the new cases, but
the required adaptation would be logical and while upper layers might
need some adjustments they wouldn't need any major overhaul.  They'll
be still working from back pressure from IO.

So, the above are the reasons why I don't like the idea of splitting
IO control across multiple layers, well the ones that I can think of
right now anyway.  I'm currently feeling rather strong about them in
the sense of "oh no, this is about to be messed up" but maybe I'm just
not seeing what Fengguang is seeing.  I'll keep discussing there.

> So in general throttling at block layer and building back pressure is
> fine. I am concerned about two cases.
> 
> - How to handle NFS.

As said above, maybe through network based bdi pressure propagation,
Maybe some other special case mechanism.  Unsure but I don't think
this concern should dictate the whole design.

> - Do filesystem developers agree with this approach and are they willing
>   to address any serialization issues arising due to this design.

Jan, can you please fill in?  Did I understand it correctly?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
