Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ACEE090014F
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 23:21:48 -0400 (EDT)
Date: Thu, 11 Aug 2011 11:21:43 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Message-ID: <20110811032143.GB11404@localhost>
References: <20110806084447.388624428@intel.com>
 <20110809020127.GA3700@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809020127.GA3700@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> [...] it only deals with controlling buffered write IO and nothing
> else. So on the same block device, other direct writes might be
> going on from same group and in this scheme a user will not have any
> control.

The IO-less balance_dirty_pages() will be able to throttle DIRECT
writes. There is nothing fundamental in the way.

The basic approach will be to add a balance_dirty_pages_ratelimited_nr()
call in the DIRECT write path, and to call into balance_dirty_pages()
regardless of the various dirty thresholds.

Then the IO-less balance_dirty_pages() has all the facilities to
throttle a task at any auto-estimated or user-specified ratelimit.

> Another disadvantage is that throttling at page cache level does not
> take care of IO spikes at device level.

Yes this is a problem. But it's a problem best fixable in the IO
scheduler.. (I cannot go to details at this time, however it does
_sound_ possible to me..)

> How do you implement proportional control here? From overall bdi bandwidth
> vary per cgroup bandwidth regularly based on cgroup weight? Again the
> issue here is that it controls only buffered WRITES and nothing else and
> in this case co-ordinating with CFQ will probably be hard. So I guess
> usage of proportional IO just for buffered WRITES will have limited
> usage.

"priority" may be a more suitable phrase. It will be implemented like
this (without the user interface):

@@ -1007,6 +1001,13 @@ static void balance_dirty_pages(struct a
                max_pause = bdi_max_pause(bdi, bdi_dirty);
               
                base_rate = bdi->dirty_ratelimit;
+               /*
+                * Double the bandwidth for PF_LESS_THROTTLE (ie. nfsd) and
+                * real-time tasks.
+                */
+               if (current->flags & PF_LESS_THROTTLE || rt_task(current))
+                       base_rate *= 2;
+              
                pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
                                               background_thresh, nr_dirty,
                                               bdi_thresh, bdi_dirty);                                                        
That is, if start 2 dd tasks A and B with priority_B=2. Then the
resulting rate_B will be equal to 2*rate_A. The ->dirty_ratelimit will
auto adapt to rate_A or equally (write_bw/3).

The same can be applied to cgroup. One may specify the whole cgroup's
dirty rate be throttled at N times that of a normal dd in the root cgroup,
or be throttled at some absolute 10MB/s rate. The corresponding
cgroup->dirty_ratelimit will be set to (N * bdi->dirty_ratelimit) for
the former and 10MB/s for the latter.

The user can specify any combinations of "priority" and "absolute
ratelimit" for any task and/or cgroup, tasks inside cgroup, and so on.
We have very powerful (bdi or cgroup)->dirty_ratelimit adaptation
mechanism to support the combinations :)

The "priority" can even be applied to DIRECT dirtiers, _as long as_
there are other buffered dirtiers to generate enough dirty pages. It's
not as easy to apply priorities when there are only DIRECT dirtiers.
In contrast, the absolute ratelimit is always applicable to all kind
of tasks and cgroups.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
