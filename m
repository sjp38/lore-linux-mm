Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id EA11B6B0083
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 14:08:07 -0400 (EDT)
Date: Thu, 5 Apr 2012 13:13:21 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120405171321.GF23999@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <20120404184909.GB29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120405163854.GE12854@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120405163854.GE12854@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Thu, Apr 05, 2012 at 09:38:54AM -0700, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Wed, Apr 04, 2012 at 11:49:09AM -0700, Tejun Heo wrote:
> > > I am not sure what are you trying to say here. But primarily blk-throttle
> > > will throttle read and direct IO. Buffered writes will go to root cgroup
> > > which is typically unthrottled.
> > 
> > Ooh, my bad then.  Anyways, then the same applies to blk-throttle.
> > Our current implementation essentially collapses at the face of
> > write-heavy workload.
> 
> I went through the code and couldn't find where blk-throttle is
> discriminating async IOs.  Were you saying that blk-throttle currently
> doesn't throttle because those IOs aren't associated with the dirtying
> task?

Yes that's what I meant. Currently most of the async IO will come from
flusher thread which is in root cgroup. So all the async IO will be in
root group and we typically keep root group unthrottled. Sorry for the
confusion here.

> If so, note that it's different from cfq which explicitly
> assigns all async IOs when choosing cfqq even if we fix tagging.

Yes. So if we can properly account for submitter, and for blk-throttle,
async IO will go in right cgroup. Unlike CFQ, there is no hard coded logic
to keep async IO in a particular group. It is just a matter of getting
the right cgroup information.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
