Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 269336B016B
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:21:32 -0400 (EDT)
Date: Mon, 8 Aug 2011 22:21:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/5] writeback: per task dirty rate limit
Message-ID: <20110808142123.GB22080@localhost>
References: <20110806084447.388624428@intel.com>
 <20110806094527.002914580@intel.com>
 <1312811234.10488.34.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1312811234.10488.34.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 08, 2011 at 09:47:14PM +0800, Peter Zijlstra wrote:
> On Sat, 2011-08-06 at 16:44 +0800, Wu Fengguang wrote:
> > Add two fields to task_struct.
> > 
> > 1) account dirtied pages in the individual tasks, for accuracy
> > 2) per-task balance_dirty_pages() call intervals, for flexibility
> > 
> > The balance_dirty_pages() call interval (ie. nr_dirtied_pause) will
> > scale near-sqrt to the safety gap between dirty pages and threshold.
> > 
> > XXX: The main problem of per-task nr_dirtied is, if 10k tasks start
> > dirtying pages at exactly the same time, each task will be assigned a
> > large initial nr_dirtied_pause, so that the dirty threshold will be
> > exceeded long before each task reached its nr_dirtied_pause and hence
> > call balance_dirty_pages().
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/sched.h |    7 ++
> >  mm/memory_hotplug.c   |    3 -
> >  mm/page-writeback.c   |  106 +++++++++-------------------------------
> >  3 files changed, 32 insertions(+), 84 deletions(-) 
> 
> No fork() hooks? This way tasks inherit their parent's dirty count on
> clone().

Ah good point. Here is the quick fix.

Thanks,
Fengguang
---

--- linux-next.orig/kernel/fork.c	2011-08-08 22:11:59.000000000 +0800
+++ linux-next/kernel/fork.c	2011-08-08 22:18:05.000000000 +0800
@@ -1301,6 +1301,9 @@ static struct task_struct *copy_process(
 	p->pdeath_signal = 0;
 	p->exit_state = 0;
 
+	p->nr_dirtied = 0;
+	p->nr_dirtied_pause = 8;
+
 	/*
 	 * Ok, make it visible to the rest of the system.
 	 * We dont wake it up yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
