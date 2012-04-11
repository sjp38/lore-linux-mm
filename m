Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 26A4F6B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:44:29 -0400 (EDT)
Date: Wed, 11 Apr 2012 21:44:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120411194425.GG16008@quack.suse.cz>
References: <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411154531.GE16692@redhat.com>
 <20120411170542.GB16008@quack.suse.cz>
 <20120411172311.GF16692@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120411172311.GF16692@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed 11-04-12 13:23:11, Vivek Goyal wrote:
> On Wed, Apr 11, 2012 at 07:05:42PM +0200, Jan Kara wrote:
> > On Wed 11-04-12 11:45:31, Vivek Goyal wrote:
> > > On Wed, Apr 11, 2012 at 11:40:05AM -0400, Vivek Goyal wrote:
> > > > On Wed, Apr 11, 2012 at 12:24:25AM +0200, Jan Kara wrote:
> > > > 
> > > > [..]
> > > > > > I have implemented and posted patches for per bdi per cgroup congestion
> > > > > > flag. The only problem I see with that is that a group might be congested
> > > > > > for a long time because of lots of other IO happening (say direct IO) and
> > > > > > if you keep on backing off and never submit the metadata IO (transaction),
> > > > > > you get starved. And if you go ahead and submit IO in a congested group,
> > > > > > we are back to serialization issue.
> > > > >   Clearly, we mustn't throttle metadata IO once it gets to the block layer.
> > > > > That's why we discuss throttling of processes at transaction start after
> > > > > all. But I agree starvation is an issue - I originally thought blk-throttle
> > > > > throttles synchronously which wouldn't have starvation issues.
> > > 
> > > Current bio throttling is asynchrounous. Process can submit the bio
> > > and go back and wait for bio to finish. That bio will be queued at device
> > > queue in a per cgroup queue and will be dispatched to device according
> > > to configured IO rate for cgroup.
> > > 
> > > The additional feature for buffered throttle (which never went upstream),
> > > was synchronous in nature. That is we were actively putting writer to
> > > sleep on a per cgroup wait queue in the request queue and wake it up when
> > > it can do further IO based on cgroup limits.
> >   Hmm, but then there would be similar starvation issues as with my simple
> > scheme because async IO could always use the whole available bandwidth.
> 
> It depends on how the throttling logic decides to divide bandwidth between
> sync and async. I had chosen a round robin policy of dispatching some
> bios and then allowing some async IO etc. So async IO was not consuming
> the whole available bandwidth. We could easibly tilt it in favor of sync IO
> with a tunable knob.
  Ah, OK.

> > Mixing of sync & async throttling is really problematic... I'm wondering
> > how useful the async throttling is.
> 
> If sync throttling is useful, then async throttling has to be useful too?
> Especially given the fact that often async IO consumes all bandwidth
> impacting sync latencies.
  I wasn't clear enough I guess. I meant to ask if async throttling brings
some serious advantage over the sync one. And I think your answer is that
we want to have at least some IO prepared to be submitted to maintain
reasonable device utilization.

> > Because we will block on request
> > allocation once there are more than nr_requests pending requests so at that
> > point throttling becomes sync anyway.
> 
> First of all flushers will block on nr_requests and not actual writers.
  Well, but as soon as you are going to do real IO (not just use the
cache), you can block - i.e. direct IO writers, or fsync, or readers can
block.

> And secondly we thought of having per group request descriptors so that
> writes of one group don't impact others. So once the writes of a group
> are backlogged, then flusher can query the congestion status of group
> and not submit any more writes to that group. As some writes are already
> queued in that group, writes will not be starved. Well, in case of
> deadline, even direct writes go in write queue so theoritically we can
> hit starvation issue (flush not being able to submit writes without
> risking blocking) there too.
> 
> To avoid this starvation, ideally we need per bdi per cgroup flusher. so
> that flusher can simply block if there are not enough request descriptors
> in the cgroup.
  Yeah, on one hand this would simplify some things, but on the other hand
you would possibly create performance issue with interleaving IO from
different flusher threads (although that shouldn't be a big problem because
they would work on disjoint sets of inodes and should submit large enough
chunks) and also fs-wide operations such as sync(2) would need some
thinking.

Actually handling of sync(2) is interesting on it's own because if it
should obey throttling limits for each cgroup whose inode is written, it
may take *really* long time to complete it...
 
> So trying to throttle buffered writes synchronously in balance_dirty_pages(),
> atleast simlifies the implementation.  I like my implementation better
> over Fengguang's approach of throttling for simple reason that buffered
> writes and direct writes can be subjected to same throttling limits
> instead of separate limits for buffered writes.
  I guess we all agree (including Fengguang) that this is desirable.
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
