Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 06E5B6B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 19:37:32 -0400 (EDT)
Date: Tue, 3 Apr 2012 16:32:31 -0700
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
Message-ID: <20120403233231.GA24333@localhost>
References: <20120328121308.568545879@intel.com>
 <20120401205647.GD6116@redhat.com>
 <20120403080014.GA15546@localhost>
 <20120403145301.GG5913@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120403145301.GG5913@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>

On Tue, Apr 03, 2012 at 10:53:01AM -0400, Vivek Goyal wrote:
> On Tue, Apr 03, 2012 at 01:00:14AM -0700, Fengguang Wu wrote:
> 
> [CC Jens]
> 
> [..]
> > > I think blkio.weight can be thought of a system wide weight of a cgroup
> > > and more than one entity/subsystem should be able to make use of it and
> > > differentiate between IO in its own way. CFQ can decide to do proportional
> > > time division, and buffered write controller should be able to use the
> > > same weight and do write bandwidth differentiation. I think it is better
> > > than introducing another buffered write controller tunable for weight.
> > > 
> > > Personally, I am not too worried about this point. We can document and
> > > explain it well.
> > 
> > Agreed. The throttling may work in *either* bps, IOPS or disk time
> > modes. In each mode blkio.weight is naturally tied to the
> > corresponding IO metrics.
> 
> Well, Tejun does not like the idea of sharing config variables among
> different policies. So I guess you shall have to come up with your
> own configurations variables as desired. As each policy will have its
> own configuration and stats, prefixing the vairable/stat name with
> policy name will help identify it. Not sure what's a good name for
> buffered write policy.
> 
> May be
> 
> blkio.dirty.weight
> blkio.dirty.bps
> blkio.buffered_write.* or
> blkio.buf_write* or
> blkio.dirty_rate.* or

OK. dirty.* or buffered_write.*, whatever looks more user friendly will be fine.

> [..]
> > 
> > Patch 6/6 shows simple test results for bps based throttling.
> > 
> > Since then I've improved the patches to work in a more "contained" way
> > when blkio.throttle.buffered_write_bps is not set.
> > 
> > The old behavior is, if blkcg A contains 1 dd and blkcg B contains 10
> > dd tasks and they have equal weight, B will get 10 times bandwidth
> > than A.
> > 
> > With the below updated core bits, A and B will get equal share of
> > write bandwidth. The basic idea is to use
> 
> Yes, this new behavior makes more sense. Two equal weight groups get
> equal bandwidth irrpesctive of number of tasks in cgroup.

Yeah, Andrew Morton reminded me of this during the writeback talk in
google :) Fortunately the current dirty throttling algorithm can
handle it easily. What's more, hierarchical cgroups can be supported
by simply using the parent's blkcg->dirty_ratelimit as the throttling
bps for the child.

> [..]
> > Test results are "pretty good looking" :-) The attached graphs
> > illustrates nice attributes of accuracy, fairness and smoothness
> > for the following tests.
> 
> Indeed. These results are pretty cool. It is hard to belive that lines
> are so smooth and lines for two tasks are overlapping each other such 
> that it is not obivious initially that they are overlapping and dirtying
> equal amount of memory. I had to take a second look to figure that out.

Thanks for noticing this! :)

> Just that results for third graph (weight 500 and 1000 respectively) are
> not perfect. I think Ideally all the 3 tasks should have dirtied same
> amount of memory.

Yeah, but note that it's not the fault of the throttling algorithm.

The unfairness is created at the very beginning ~0.1s, where dirty
pages are far under the dirty limits and the dd tasks are not
throttled at all. Since the first task manages to start 0.1s earlier
than the other two tasks, it manages to dirty at full (memory write)
speed which makes the gap.

Once the dirty throttling mechanism comes into play, you can see that
the lines for the three tasks grow fairly at the same speed/slope.

> But I think achieving perfection here might not be easy and may be
> not many people will care.

The formula itself looks simple, however it does ask for some
debugging/tuning efforts to make it behave well under various
situations.

> Given the fact that you are doing a reasonable job of providing service
> differentiation between buffered writers, I am wondering if you should
> look at the ioprio of writers with-in cgroup and provide service
> differentiation among those too. CFQ has separate queues but it loses
> the context information by the time IO is submitted. So you might be
> able to do a much better job. Anyway, this is a possible future
> enhancement and not necessarily related to this patchset.

Good point. It seems applicable to the general dirty throttling
(not relying on cgroups). It would mainly be a problem of how to map
the priority classes/values to each tasks' throttling weight (or bps).

> Also, we are controlling the rate of dirtying the memory. I am again 
> wondering whether these configuration knobs should be part of memory
> controller and not block controller. Think of NFS case. There is no
> block device or block layer involved but we will control the rate of
> dirtying memory. So some control in memory controller might make
> sense. And following kind of knobs might make sense there.
> 
> memcg.dirty_weight or memcg.dirty.weight
> memcg.dirty_bps or memcg.dirty.write_bps
> 
> Just that we control not the *absolute amount* of memory but *rate* of
> writing to memory and I think that makes it somewhat confusing and
> gives the impression that it should be part of block IO controller.

There is the future prospective of "buffered+direct write bps" interface.
Considering this, I'm a little inclined towards the blkio.* interfaces,
in despite of the fact that it's currently tightly tied to the block layer :)

> I am kind of split on this (rather little inclined towards memory
> controller), so I am raising the question and others can weigh in with
> their thoughts on what makes more sense here.

Yeah, we definitely need more inputs on the "interface" stuff.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
