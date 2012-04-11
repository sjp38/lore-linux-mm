Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2347E6B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:05:48 -0400 (EDT)
Date: Wed, 11 Apr 2012 19:05:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120411170542.GB16008@quack.suse.cz>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120407080027.GA2584@quack.suse.cz>
 <20120410180653.GJ21801@redhat.com>
 <20120410210505.GE4936@quack.suse.cz>
 <20120410212041.GP21801@redhat.com>
 <20120410222425.GF4936@quack.suse.cz>
 <20120411154005.GD16692@redhat.com>
 <20120411154531.GE16692@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120411154531.GE16692@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed 11-04-12 11:45:31, Vivek Goyal wrote:
> On Wed, Apr 11, 2012 at 11:40:05AM -0400, Vivek Goyal wrote:
> > On Wed, Apr 11, 2012 at 12:24:25AM +0200, Jan Kara wrote:
> > 
> > [..]
> > > > I have implemented and posted patches for per bdi per cgroup congestion
> > > > flag. The only problem I see with that is that a group might be congested
> > > > for a long time because of lots of other IO happening (say direct IO) and
> > > > if you keep on backing off and never submit the metadata IO (transaction),
> > > > you get starved. And if you go ahead and submit IO in a congested group,
> > > > we are back to serialization issue.
> > >   Clearly, we mustn't throttle metadata IO once it gets to the block layer.
> > > That's why we discuss throttling of processes at transaction start after
> > > all. But I agree starvation is an issue - I originally thought blk-throttle
> > > throttles synchronously which wouldn't have starvation issues.
> 
> Current bio throttling is asynchrounous. Process can submit the bio
> and go back and wait for bio to finish. That bio will be queued at device
> queue in a per cgroup queue and will be dispatched to device according
> to configured IO rate for cgroup.
> 
> The additional feature for buffered throttle (which never went upstream),
> was synchronous in nature. That is we were actively putting writer to
> sleep on a per cgroup wait queue in the request queue and wake it up when
> it can do further IO based on cgroup limits.
  Hmm, but then there would be similar starvation issues as with my simple
scheme because async IO could always use the whole available bandwidth.
Mixing of sync & async throttling is really problematic... I'm wondering
how useful the async throttling is. Because we will block on request
allocation once there are more than nr_requests pending requests so at that
point throttling becomes sync anyway.

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
