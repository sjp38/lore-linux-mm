Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 315848D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 22:15:03 -0400 (EDT)
Date: Tue, 29 Mar 2011 13:14:58 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110329021458.GF3008@dastard>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110325134411.GA8645@localhost>
 <20110325230544.GD26932@quack.suse.cz>
 <20110328024445.GA11816@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110328024445.GA11816@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Mar 28, 2011 at 10:44:45AM +0800, Wu Fengguang wrote:
> On Sat, Mar 26, 2011 at 07:05:44AM +0800, Jan Kara wrote:
> > And actually the NFS traces you pointed to originally seem to be different
> > problem, in fact not directly related to what balance_dirty_pages() does...
> > And with local filesystem the results seem to be reasonable (although there
> > are some longer sleeps in your JBOD measurements I don't understand yet).
> 
> Yeah the NFS case can be improved on the FS side (for now you may just
> reuse my NFS patches and focus on other generic improvements).
> 
> The JBOD issue is also beyond my understanding.
> 
> Note that XFS will also see one big IO completion per 0.5-1 seconds,
> when we are to increase the write chunk size from the current 4MB to
> near the bdi's write bandwidth. As illustrated by this graph:
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-1dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-22-58/global_dirtied_written-500.png

Which is _bad_.

Increasing the writeback chunk size simply causes dirty queue
starvation issues when there are lots of dirty files and lots more
memory than there is writeback bandwidth. Think of a machine with
1TB of RAM (that's a 200GB dirty limit) and 1GB/s of disk
throughput. Thats 3 minutes worth of writeback and increasing the
chunk size to ~1s worth of throughput means that the 200th dirty
file won't get serviced for 3 minutes....

We used to have behaviour similar to this this (prior to 2.6.16, IIRC),
and it caused all sorts of problems where people were losing 10-15
minute old data when the system crashed because writeback didn't
process the dirty inode list fast enough in the presence of lots of
large files....

A small writeback chunk size has no adverse impact on XFS as long as
the elevator does it's job of merging IOs (which in 99.9% of cases
it does) so I'm wondering what the reason for making this change
is.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
