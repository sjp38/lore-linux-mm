Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id B8F796B004A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 18:24:44 -0400 (EDT)
Date: Wed, 11 Apr 2012 00:24:25 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120410222425.GF4936@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120410212041.GP21801@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Tue 10-04-12 17:20:41, Vivek Goyal wrote:
> On Tue, Apr 10, 2012 at 11:05:05PM +0200, Jan Kara wrote:
> 
> [..]
> > > Ok. So what is the meaning of "make process wait" here? What it will be
> > > dependent on? I am thinking of a case where a process has 100MB of dirty
> > > data, has 10MB/s write limit and it issues fsync. So before that process
> > > is able to open a transaction, one needs to wait atleast 10seconds
> > > (assuming other processes are not doing IO in same cgroup). 
> >   The original idea was that we'd have "bdi-congested-for-cgroup" flag
> > and the process starting a transaction will wait for this flag to get
> > cleared before starting a new transaction. This will be easy to implement
> > in filesystems and won't have serialization issues. But my knowledge of
> > blk-throttle is lacking so there might be some problems with this approach.
> 
> I have implemented and posted patches for per bdi per cgroup congestion
> flag. The only problem I see with that is that a group might be congested
> for a long time because of lots of other IO happening (say direct IO) and
> if you keep on backing off and never submit the metadata IO (transaction),
> you get starved. And if you go ahead and submit IO in a congested group,
> we are back to serialization issue.
  Clearly, we mustn't throttle metadata IO once it gets to the block layer.
That's why we discuss throttling of processes at transaction start after
all. But I agree starvation is an issue - I originally thought blk-throttle
throttles synchronously which wouldn't have starvation issues. But when
that's not the case things are a bit more tricky. We could treat
transaction start as an IO of some size (since we already have some
estimation how large a transaction will be when we are starting it) and let
the transaction start only when our "virtual" IO would be submitted but
I feel that gets maybe too complicated... Maybe we could just delay the
transaction start by the amount reported from blk-throttle layer? Something
along your callback for throttling you implemented?

> [..]
> > > One more factor makes absolute throttling interesting and that is global
> > > throttling and not per device throttling. For example in case of btrfs,
> > > there is no single stacked device on which to put total throttling
> > > limits.
> >   Yes. My intended interface for the throttling is bdi. But you are right
> > it does not exactly match the fact that the throttling happens per device
> > so it might get tricky. Which brings up a question - shouldn't the
> > throttling blk-throttle does rather happen at bdi layer? Because the
> > uses of the functionality I have in mind would match that better.
> 
> I guess throttling at bdi layer will take care of network filesystem
> case too?
  Yes. At least for client side. On sever side Steve wants server to have
insight into how much IO we could push in future so that it can limit
number of outstanding requests if I understand him right. I'm not sure we
really want / are able to provide this amount of knowledge to filesystems
even less userspace...

> But isn't the notion of "bdi" internal to kernel and user does
> not really program thing in terms of bdi.
  Well, it is. But we already have per-bdi tunables (e.g.  readahead) that
are exported in /sys/block/<device>/queue/ so we have some precedens.
 
> Also per bdi limit mechanism will not solve the issue of global throttling
> where in case of btrfs an IO might go to multiple bdi's. So throttling limits
> are not total but per bdi.
  Well, btrfs plays tricks with bdi's but there is a special bdi called
"btrfs" which backs the whole filesystem and that is what's put in
sb->s_bdi or in each inode's i_mapping->backing_dev_info. So we have a
global bdi to work with.

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
