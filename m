Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 66E4F6B00F3
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 13:56:24 -0400 (EDT)
Date: Wed, 4 Apr 2012 10:51:24 -0700
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404175124.GA8931@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

Hi Tejun,

On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
> Hello, guys.
> 
> So, during LSF, I, Fengguang and Jan had a chance to sit down and talk
> about how to cgroup support to writeback.  Here's what I got from it.
> 
> Fengguang's opinion is that the throttling algorithm implemented in
> writeback is good enough and blkcg parameters can be exposed to
> writeback such that those limits can be applied from writeback.  As
> for reads and direct IOs, Fengguang opined that the algorithm can
> easily be extended to cover those cases and IIUC all IOs, whether
> buffered writes, reads or direct IOs can eventually all go through
> writeback layer which will be the one layer controlling all IOs.
 
Yeah it should be trivial to apply the balance_dirty_pages()
throttling algorithm to the read/direct IOs. However up to now I don't
see much added value to *duplicate* the current block IO controller
functionalities, assuming the current users and developers are happy
with it.

I did the buffered write IO controller mainly to fill the gap.  If I
happen to stand in your way, sorry that's not my initial intention.
It's a pity and surprise that Google as a big user does not buy in
this simple solution. You may prefer more comprehensive controls which
may not be easily achievable with the simple scheme. However the
complexities and overheads involved in throttling the flusher IOs
really upsets me. 

The sweet split point would be for balance_dirty_pages() to do cgroup
aware buffered write throttling and leave other IOs to the current
blkcg. For this to work well as a total solution for end users, I hope
we can cooperate and figure out ways for the two throttling entities
to work well with each other.

What I'm interested is, what's Google and other users' use schemes in
practice. What's their desired interfaces. Whether and how the
combined bdp+blkcg throttling can fulfill the goals.

> Unfortunately, I don't agree with that at all.  I think it's a gross
> layering violation and lacks any longterm design.  We have a well
> working model of applying and propagating resource pressure - we apply
> the pressure where the resource exists and propagates the back
> pressure through buffers to upper layers upto the originator.  Think
> about network, the pressure exists or is applied at the in/egress
> points which gets propagated through socket buffers and eventually
> throttles the originator.
> 
> Writeback, without cgroup, isn't different.  It consists a part of the
> pressure propagation chain anchored at the IO device.  IO devices
> these days generate very high pressure, which gets propgated through
> the IO sched and buffered requests, which in turn creates pressure at
> writeback.  Here, the buffering happens in page cache and pressure at
> writeback increases the amount of dirty page cache.  Propagating this
> IO pressure to the dirtying task is one of the biggest
> responsibililties of the writeback code, and this is the underlying
> design of the whole thing.
> 
> IIUC, without cgroup, the current writeback code works more or less
> like this.  Throwing in cgroup doesn't really change the fundamental
> design.  Instead of a single pipe going down, we just have multiple
> pipes to the same device, each of which should be treated separately.
> Of course, a spinning disk can't be divided that easily and their
> performance characteristics will be inter-dependent, but the place to
> solve that problem is where the problem is, the block layer.
> 
> We may have to look for optimizations and expose some details to
> improve the overall behavior and such optimizations may require some
> deviation from the fundamental design, but such optimizations should
> be justified and such deviations kept at minimum, so, no, I don't
> think we're gonna be expose blkcg / block / elevator parameters
> directly to writeback.  Unless someone can *really* convince me
> otherwise, I'll be vetoing any change toward that direction.
> 
> Let's please keep the layering clear.  IO limitations will be applied
> at the block layer and pressure will be formed there and then
> propagated upwards eventually to the originator.  Sure, exposing the
> whole information might result in better behavior for certain
> workloads, but down the road, say, in three or five years, devices
> which can be shared without worrying too much about seeks might be
> commonplace and we could be swearing at a disgusting structural mess,
> and sadly various cgroup support seems to be a prominent source of
> such design failures.

Super fast storages are coming which will make us regret to make the
IO path over complex.  Spinning disks are not going away anytime soon.
I doubt Google is willing to afford the disk seek costs on its
millions of disks and has the patience to wait until switching all of
the spin disks to SSD years later (if it will ever happen).

Sorry, I won't buy in the layering arguments and analog to networking.
Yeah network is a good way to show your "push back" idea, however
writeback has its own metadata, seeking, etc. problems.

I'd prefer we base our discussions on real things like complexities,
overheads, performance as well as user demands.

It's obvious that your below proposal involves a lot of complexities,
overheads, and will hurt performance. It basically involves

- running concurrent flusher threads for cgroups, which adds back the
  disk seeks and lock contentions. And still has problems with sync
  and shared inodes.

- splitting device queue for cgroups, possibly scaling up the pool of
  writeback pages (and locked pages in the case of stable pages) which
  could stall random processes in the system

- the mess of metadata handling

- unnecessarily coupled with memcg, in order to take advantage of the
  per-memcg dirty limits for balance_dirty_pages() to actually convert
  the "pushed back" dirty pages pressure into lowered dirty rate. Why
  the hell the users *have to* setup memcg (suffering from all the
  inconvenience and overheads) in order to do IO throttling?  Please,
  this is really ugly! And the "back pressure" may constantly push the
  memcg dirty pages to the limits. I'm not going to support *miss use*
  of per-memcg dirty limits like this!

I cannot believe you would keep overlooking all the problems without
good reasons. Please do tell us the reasons that matter.

Thanks,
Fengguang

> IMHO, treating cgroup - device/bdi pair as a separate device should
> suffice as the underlying design.  After all, blkio cgroup support's
> ultimate goal is dividing the IO resource into separate bins.
> Implementation details might change as underlying technology changes
> and we learn more about how to do it better but that is the goal which
> we'll always try to keep close to.  Writeback should (be able to)
> treat them as separate devices.  We surely will need adjustments and
> optimizations to make things work at least somewhat reasonably but
> that is the baseline.
> 
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
> 
> * cfq cgroup policy throws all async IOs, which all buffered writes
>   are, into the shared cgroup regardless of the actual cgroup.  This
>   behavior is, I believe, mostly historical and changing it isn't
>   difficult.  Prolly only few tens of lines of changes.  This may
>   cause significant changes to actual IO behavior with cgroups tho.  I
>   personally think the previous behavior was too wrong to keep (the
>   weight was completely ignored for buffered writes) but we may want
>   to introduce a switch to toggle between the two behaviors.
> 
>   Note that blk-throttle doesn't have this problem.
> 
> * Unlike dirty data pages, metadata tends to have strict ordering
>   requirements and thus is susceptible to priority inversion.  Two
>   solutions were suggested - 1. allow overdrawl for metadata writes so
>   that low prio metadata writes don't block the whole FS, 2. provide
>   an interface to query and wait for bdi-cgroup congestion which can
>   be called from FS metadata paths to throttle metadata operations
>   before they enter the stream of ordered operations.
> 
>   I think combination of the above two should be enough for solving
>   the problem.  I *think* the second can be implemented as part of
>   cgroup aware request allocation update.  The first one needs a bit
>   more thinking but there can be easier interim solutions (e.g. throw
>   META writes to the head of the cgroup queue or just plain ignore
>   cgroup limits for META writes) for now.
> 
> * I'm sure there are a lot of design choices to be made in the
>   writeback implementation but IIUC Jan seems to agree that the
>   simplest would be simply deal different cgroup-bdi pairs as
>   completely separate which shouldn't add too much complexity to the
>   already intricate writeback code.
> 
> So, I think we have something which sounds like a plan, which at least
> I can agree with and seems doable without adding a lot of complexity.
> 
> Jan, Fengguang, I'm pretty sure I missed some stuff from writeback's
> side and IIUC Fengguang doesn't agree with this approach too much, so
> please voice your opinions & comments.
> 
> Thank you.
> 
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
