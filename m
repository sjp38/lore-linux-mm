Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id AC9E96B0101
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 16:18:31 -0400 (EDT)
Date: Wed, 4 Apr 2012 16:18:16 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404201816.GL12676@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 04, 2012 at 12:33:55PM -0700, Tejun Heo wrote:
> Hey, Fengguang.
> 
> On Wed, Apr 04, 2012 at 10:51:24AM -0700, Fengguang Wu wrote:
> > Yeah it should be trivial to apply the balance_dirty_pages()
> > throttling algorithm to the read/direct IOs. However up to now I don't
> > see much added value to *duplicate* the current block IO controller
> > functionalities, assuming the current users and developers are happy
> > with it.
> 
> Heh, trust me.  It's half broken and people ain't happy.  I get that
> your algorithm can be updatd to consider all IOs and I believe that
> but what I don't get is how would such information get to writeback
> and in turn how writeback would enforce the result on reads and direct
> IOs.  Through what path?  Will all reads and direct IOs travel through
> balance_dirty_pages() even direct IOs on raw block devices?  Or would
> the writeback algorithm take the configuration from cfq, apply the
> algorithm and give back the limits to enforce to cfq?  If the latter,
> isn't that at least somewhat messed up?

I think he wanted to get the configuration with the help of blkcg
interface and just implement those policies up there without any
further interaction with CFQ or lower layers.

[..]
> > The sweet split point would be for balance_dirty_pages() to do cgroup
> > aware buffered write throttling and leave other IOs to the current
> > blkcg. For this to work well as a total solution for end users, I hope
> > we can cooperate and figure out ways for the two throttling entities
> > to work well with each other.
> 
> There's where I'm confused.  How is the said split supposed to work?
> They aren't independent.  I mean, who gets to decide what and where
> are those decisions enforced?

As you said, split is just a temporary gap filling in the absense of a
good solutiong for throttling buffered writes (which is often a source
of problem for sync IO latencies). So with this solution one could put
independetly control the buffered write rate of a cgroup. Lower layers
will not throttle that traffic again as it would show up in root
cgroup. Hence blkcg and writeback need not to communicate much as
such except for confirations knobs and possibly for some stats.

[..]
> > - running concurrent flusher threads for cgroups, which adds back the
> >   disk seeks and lock contentions. And still has problems with sync
> >   and shared inodes.
> 

Or, export the notion of per group per bdi congestion and flusher does
not try to submit IO from an inode if device is congested. That way
flusher will not get blocked and we don't have to create one flusher
thread per cgroup and be happy with one flusher per bdi.

And with the comprobmise of one inode belonging to one cgroup, we will
still dispatch a bunch of IO from one inode and then move to next.
Depending on size of chunk we can reduce the seek a bit. Size of quantum
will decide tradeoff between seek and fairness of writes from inodes.

[..]
> > - the mess of metadata handling
> 
> Does throttling from writeback actually solve this problem?  What
> about fsync()?  Does that already go through balance_dirty_pages()?

By throttling the process at the time of dirtying memory, you just allowed
enough IO from process as allowed by the limits. Now fsync() has to send
only those pages to the disk and does not have to be throttled again.

So throttling process while you are admitting IO avoids these issues
with filesystem metadata.

But at the same time it does not feel right to throttle read and AIO
synchronously. Current behavior of kernel queuing up bio and throttling
it asynchronously is desirable. Only buffered write is a special case
as we anyway throttle it actively based on amount of dirty memory.

[..]
> 
> > - unnecessarily coupled with memcg, in order to take advantage of the
> >   per-memcg dirty limits for balance_dirty_pages() to actually convert
> >   the "pushed back" dirty pages pressure into lowered dirty rate. Why
> >   the hell the users *have to* setup memcg (suffering from all the
> >   inconvenience and overheads) in order to do IO throttling?  Please,
> >   this is really ugly! And the "back pressure" may constantly push the
> >   memcg dirty pages to the limits. I'm not going to support *miss use*
> >   of per-memcg dirty limits like this!
> 
> Writeback sits between blkcg and memcg and it indeed can be hairy to
> consider both sides especially given the current sorry complex state
> of cgroup and I can see why it would seem tempting to add a separate
> controller or at least knobs to support that.  That said, I *think*
> given that memcg controls all other memory parameters it probably
> would make most sense giving that parameter to memcg too.  I don't
> think this is really relevant to this discussion tho.  Who owns
> dirty_limits is a separate issue.

I agree that dirty_limit control resembles more closely to memcg than
blkcg as it is all about writing to memory and that's the resource
controlled by memcg.

I think Fegguang wanted to keep those knobs in blkcg as he thinks that
in writeback logic he can actively throttle readers and direct IO too.
But that does not sounds little messy to me too.

Hey how about reconsidering my other proposal for which I had posted
the patches. And that is keep throttling still at device level. Reads
and direct IO get throttled asynchronously but buffered writes get
throttled synchronously.

Advantages of this scheme.

- There are no separate knobs.

- All the IO (read, direct IO and buffered write) is controlled using
  same set of knobs and goes in queue of same cgroup.

- Writeback logic has no knowledge of throttling. It just invokes a 
  hook into throttling logic of device queue.

I guess this is a hybrid of active writeback throttling and back pressure
mechanism.

But it still does not solve the NFS issue as well as for direct IO,
filesystems still can get serialized, so metadata issue still needs to 
be resolved. So one can argue that why not go for full "back pressure"
method, despite it being more complex.

Here is the link, just to refresh the memory. Something to keep in mind
while assessing alternatives.

https://lkml.org/lkml/2011/6/28/243

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
