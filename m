Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 84F416B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 17:05:12 -0400 (EDT)
Date: Tue, 10 Apr 2012 23:05:05 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120410210505.GE4936@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120410180653.GJ21801@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

  Hi Vivek,

On Tue 10-04-12 14:06:53, Vivek Goyal wrote:
> On Sat, Apr 07, 2012 at 10:00:27AM +0200, Jan Kara wrote:
> > > In general, the core of the issue is that filesystems are not cgroup aware
> > > and if you do throttling below filesystems, then invariably one or other
> > > serialization issue will come up and I am concerned that we will be constantly
> > > fixing those serialization issues. Or the desgin point could be so central
> > > to filesystem design that it can't be changed.
> >   We talked about this at LSF and Dave Chinner had the idea that we could
> > make processes wait at the time when a transaction is started. At that time
> > we don't hold any global locks so process can be throttled without
> > serializing other processes. This effectively builds some cgroup awareness
> > into filesystems but pretty simple one so it should be doable.
> 
> Ok. So what is the meaning of "make process wait" here? What it will be
> dependent on? I am thinking of a case where a process has 100MB of dirty
> data, has 10MB/s write limit and it issues fsync. So before that process
> is able to open a transaction, one needs to wait atleast 10seconds
> (assuming other processes are not doing IO in same cgroup). 
  The original idea was that we'd have "bdi-congested-for-cgroup" flag
and the process starting a transaction will wait for this flag to get
cleared before starting a new transaction. This will be easy to implement
in filesystems and won't have serialization issues. But my knowledge of
blk-throttle is lacking so there might be some problems with this approach.

> If this wait is based on making sure all dirty data has been written back
> before opening transaction, then it will work without any interaction with
> block layer and sounds more feasible.
> 
> > 
> > > In general, if you do throttling deeper in the stakc and build back
> > > pressure, then all the layers sitting above should be cgroup aware
> > > to avoid problems. Two layers identified so far are writeback and
> > > filesystems. Is it really worth the complexity. How about doing 
> > > throttling in higher layers when IO is entering the kernel and
> > > keep proportional IO logic at the lowest level and current mechanism
> > > of building pressure continues to work?
> >   I would like to keep single throttling mechanism for different limitting
> > methods - i.e. handle proportional IO the same way as IO hard limits. So we
> > cannot really rely on the fact that throttling is work preserving.
> > 
> > The advantage of throttling at IO layer is that we can keep all the details
> > inside it and only export pretty minimal information (like is bdi congested
> > for given cgroup) to upper layers. If we wanted to do throttling at upper
> > layers (such as Fengguang's buffered write throttling), we need to export
> > the internal details to allow effective throttling...
> 
> For absolute throttling we really don't have to expose any details. In
> fact in my implementation of throttling buffered writes, I just had exported
> a single function to be called in bdi dirty rate limit. The caller will
> simply sleep long enough depending on the size of IO it is doing and
> how many other processes are doing IO in same cgroup.
>
> So implementation was still in block layer and only a single function
> was exposed to higher layers.
  OK, I see.
 
> One more factor makes absolute throttling interesting and that is global
> throttling and not per device throttling. For example in case of btrfs,
> there is no single stacked device on which to put total throttling
> limits.
  Yes. My intended interface for the throttling is bdi. But you are right
it does not exactly match the fact that the throttling happens per device
so it might get tricky. Which brings up a question - shouldn't the
throttling blk-throttle does rather happen at bdi layer? Because the
uses of the functionality I have in mind would match that better.

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
