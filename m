Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9B7606B0107
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 17:47:29 -0400 (EDT)
Date: Wed, 4 Apr 2012 14:42:28 -0700
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120404214228.GA6471@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404183528.GJ12676@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120404183528.GJ12676@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org

On Wed, Apr 04, 2012 at 02:35:29PM -0400, Vivek Goyal wrote:
> On Wed, Apr 04, 2012 at 10:51:24AM -0700, Fengguang Wu wrote:
> 
> [..]
> > The sweet split point would be for balance_dirty_pages() to do cgroup
> > aware buffered write throttling and leave other IOs to the current
> > blkcg. For this to work well as a total solution for end users, I hope
> > we can cooperate and figure out ways for the two throttling entities
> > to work well with each other.
> 
> Throttling read + direct IO, higher up has few issues too. Users will

Yeah I have a bit worry about high layer throttling, too.
Anyway here are the ideas.

> not like that a task got blocked as it tried to submit a read from a
> throttled group.

That's not the same issue I worried about :) Throttling is about
inserting small sleep/waits into selected points. For reads, the ideal
sleep point is immediately after readahead IO is summited, at the end
of __do_page_cache_readahead(). The same should be applicable to
direct IO.

> Current async behavior works well where we queue up the
> bio from the task in throttled group and let task do other things. Same
> is true for AIO where we would not like to block in bio submission.

For AIO, we'll need to delay the IO completion notification or status
update, which may involve computing some delay time and delay the
calls to io_complete() with the help of some delayed work queue. There
may be more issues to deal with as I didn't look into aio.c carefully.

The thing worried me is that in the proportional throttling case, the
high level throttling works on the *estimated* task_ratelimit =
disk_bandwidth / N, where N is the number of read IO tasks. When N
suddenly changes from 2 to 1, it may take 1 second for the estimated
task_ratelimit to adapt from disk_bandwidth/2 up to disk_bandwidth,
during which time the disk won't get 100% utilized because of the
temporally over-throttling of the remaining IO task.

This is not a problem when throttling at the block/cfq layer, since it
has the full information of pending requests and should not depend on
such estimations.

The workaround I can think of, is to put the throttled task into a wait
queue, and let block layer wake up the waiters when the IO queue runs
empty. This should be able to avoid most disk idle time.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
