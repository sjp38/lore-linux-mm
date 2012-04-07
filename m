Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id BA5AD6B004D
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 11:08:44 -0400 (EDT)
Date: Sat, 7 Apr 2012 10:00:27 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120407080027.GA2584@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404145134.GC12676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

  Hi Vivek,

On Wed 04-04-12 10:51:34, Vivek Goyal wrote:
> On Tue, Apr 03, 2012 at 11:36:55AM -0700, Tejun Heo wrote:
> [..]
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
  Yeah, for throttling NFS or other network filesystems we'd have to come
up with some throttling mechanism at some other level. The problem with
throttling at higher levels is that you have to somehow extract information
from lower levels about amount of work so I'm not completely certain now,
where would be the right place. Possibly it also depends on the intended
usecase - so far I don't know about any real user for this functionality...

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
  We can tag inodes and then bios so this should be fine.

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
> 
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
  We talked about this at LSF and Dave Chinner had the idea that we could
make processes wait at the time when a transaction is started. At that time
we don't hold any global locks so process can be throttled without
serializing other processes. This effectively builds some cgroup awareness
into filesystems but pretty simple one so it should be doable.

> In general, if you do throttling deeper in the stakc and build back
> pressure, then all the layers sitting above should be cgroup aware
> to avoid problems. Two layers identified so far are writeback and
> filesystems. Is it really worth the complexity. How about doing 
> throttling in higher layers when IO is entering the kernel and
> keep proportional IO logic at the lowest level and current mechanism
> of building pressure continues to work?
  I would like to keep single throttling mechanism for different limitting
methods - i.e. handle proportional IO the same way as IO hard limits. So we
cannot really rely on the fact that throttling is work preserving.

The advantage of throttling at IO layer is that we can keep all the details
inside it and only export pretty minimal information (like is bdi congested
for given cgroup) to upper layers. If we wanted to do throttling at upper
layers (such as Fengguang's buffered write throttling), we need to export
the internal details to allow effective throttling...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
