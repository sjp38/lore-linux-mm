Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 586166B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 12:56:32 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so5278030pbc.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 09:56:31 -0700 (PDT)
Date: Mon, 23 Apr 2012 09:56:26 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] writeback and cgroup
Message-ID: <20120423165626.GB5406@google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404175124.GA8931@localhost>
 <20120404193355.GD29686@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120406095934.GA10465@localhost>
 <20120417223854.GG19975@google.com>
 <20120419142343.GA12684@localhost>
 <20120419202635.GA4795@quack.suse.cz>
 <20120420133441.GA7035@localhost>
 <20120420190844.GH32324@google.com>
 <20120422144649.GA7066@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120422144649.GA7066@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, vgoyal@redhat.com, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, sjayaraman@suse.com, andrea@betterlinux.com, jmoyer@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, lizefan@huawei.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, ctalbott@google.com, rni@google.com, lsf@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>

Hello, Fengguang.

On Sun, Apr 22, 2012 at 10:46:49PM +0800, Fengguang Wu wrote:
> OK. Sorry I should have explained why memcg dirty limit is not the
> right tool for back pressure based throttling.

I have two questions.  Why do we need memcg for this?  Writeback
currently works without memcg, right?  Why does that change with blkcg
aware bdi?

> Basically the more memcgs with dirty limits, the more hard time for
> the flusher to serve them fairly and knock down their dirty pages in
> time. Because the flusher works inode by inode, each one may take up
> to 0.5 second, and there may be many memcgs asking for the flusher's
> attention. Also the more memcgs, the global dirty pages pool are
> partitioned into smaller pieces, which means smaller safety margin for
> each memcg. Adding these two effects up, there may be constantly some
> memcgs hitting their dirty limits when there are dozens of memcgs.

And how is this different from a machine with smaller memory?  If so,
why?

> Such cross subsystem coordinations still look natural to me because
> "weight" is a fundamental and general parameter. It's really a blkcg
> thing (determined by the blkio.weight user interface) rather than
> specifically tied to cfq. When another kernel entity (eg. NFS or noop)
> decides to add support for proportional weight IO control in future,
> it can make use of the weights calculated by balance_dirty_pages(), too.

It is not fundamental and natural at all and is already made cfq
specific in the devel branch.  You seem to think "weight" is somehow a
global concept which everyone can agree on but it is not.  Weight of
what?  Is it disktime, bandwidth, iops or something else?  cfq deals
primarily with disktime because that makes sense for spinning drives
with single head.  For SSDs with smart enough FTLs, the unit should
probably be iops.  For storage technology bottlenecked on bus speed,
bw would make sense.

IIUC, writeback is primarily dealing with abstracted bandwidth which
is applied per-inode, which is fine at that layer as details like
block allocations isn't and shouldn't be visible there and files (or
inodes) are the level of abstraction.

However, this doesn't necessarily translate easily into the actual
underlying IO resource.  For devices with spindle, seek time dominates
and the same amount of IO may consume vastly different amount of IO
and the disk time becomes the primary resource, not the iops or
bandwidth.  Naturally, people want to allocate and limit the primary
resource, so cfq distributes disk time across different cgroups as
configured.

Your suggested solution is applying the same a number - the weight -
to one portion of a mostly arbitrarily split resource using a
different unit.  I don't even understand what that achieves.

The requirement is to be able to split IO resource according to
cgroups in configurable way and enforce the limits established by the
configuration, which we're currently failing to do for async IOs.
Your proposed solution applies some arbitrary ratio according to some
arbitrary interpretation of cfq IO time weight way up in the stack
which, when propagated to the lower layer, would cause significant
amount of delay and fluctuation which behaves completely independent
from how (using what unit, in what granularity and in what time scale)
actual IO resource is handled, split and accounted, which would result
in something which probably has some semblance of interpreting
blkcg.weight as vague best-effort priority at its luckiest moments.

So, I don't think your suggested solution is a solution at all.  I'm
in fact not even sure what it achieves at the cost of the gross
layering violation and fundamental design braindamage.

>         - No more latency
>         - No performance drop
>         - No bumpy progress and stalls
>         - No need to attach memcg to blkcg
>         - Feel free to create 1000+ IO controllers, to heart's content
>           w/o worrying about costs (if any, it would be some existing
>           scalability issues)

I'm not sure why memcg suddenly becomes necessary with blkcg and I
don't think having per-blkcg writeback and reasonable async
optimization from iosched would be considerably worse.  It sure will
add some overhead (e.g. from split buffering) but there will be proper
working isolation which is what this fuss is all about.  Also, I just
don't see how creating 1000+ (relatively active, I presume) blkcgs on
a single spindle would be sane and how is the end result gonna be
significantly better for your suggested solution, so let's please put
aside the silly non-use case.

In terms of overhead, I suspect the biggest would be the increased
buffering coming from split channels but that seems like the cost of
business to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
