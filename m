Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F315B6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 14:40:32 -0400 (EDT)
Date: Mon, 15 Aug 2011 20:40:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110815184023.GA16369@quack.suse.cz>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
 <20110815134846.GB13534@localhost>
 <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 15-08-11 10:16:38, Curt Wohlgemuth wrote:
> On Mon, Aug 15, 2011 at 6:48 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Curt,
> >
> > Some thoughts about the interface..before dipping into the code.
> >
> > On Sat, Aug 13, 2011 at 06:47:25AM +0800, Curt Wohlgemuth wrote:
> >> Add a new file, /proc/writeback/stats, which displays
> >
> > That's creating a new top directory in /proc. Do you have plans for
> > adding more files under it?
> 
> Good question.  We have several files under /proc/writeback in our
> kernels that we created at various times, some of which are probably
> no longer useful, but others seem to be.  For example:
>   - congestion: prints # of calls, # of jiffies slept in
> congestion_wait() / io_schedule_timeout() from various call points
>   - threshold_dirty : prints the current global FG threshold
>   - threshold_bg : prints the current global BG threshold
>   - pages_cleaned : prints the # pages sent to writeback -- same as
> 'nr_written' in /proc/vmstat (ours was earlier :-( )
>   - pages_dirtied (same as nr_dirtied in /proc/vmstat)
>   - prop_vm_XXX : print shift/events from vm_completions and vm_dirties
>
> I'm not sure right now if global FG/BG thresholds appear anywhere in a
> 3.1 kernel; if so, the two threshold files above are superfluous.  So
> are the pages_cleaned/dirtied.  The prop_vm files have not proven
> useful to me.  I think the congestion file has a lot of value,
> especially in an IO-less throttling world...
  /sys/kernel/debug/bdi/<dev>/stats has BdiDirtyThresh, DirtyThresh, and
BackgroundThresh. So we should already expose all you have in the threshold
files.

Regarding congestion_wait() statistics - do I get right that the numbers
gathered actually depend on the number of threads using the congested
device? They are something like
  \sum_{over threads} time_waited_for_bdi
How do you interpret the resulting numbers then?

								Honza

> >> machine global data for how many pages were cleaned for
> >> which reasons.  It also displays some additional counts for
> >> various writeback events.
> >>
> >> These data are also available for each BDI, in
> >> /sys/block/<device>/bdi/writeback_stats .
> >
> >> Sample output:
> >>
> >>    page: balance_dirty_pages           2561544
> >>    page: background_writeout              5153
> >>    page: try_to_free_pages                   0
> >>    page: sync                                0
> >>    page: kupdate                        102723
> >>    page: fdatawrite                    1228779
> >>    page: laptop_periodic                     0
> >>    page: free_more_memory                    0
> >>    page: fs_free_space                       0
> >>    periodic writeback                      377
> >>    single inode wait                         0
> >>    writeback_wb wait                         1
> >
> > That's already useful data, and could be further extended (in
> > future patches) to answer questions like "what's the writeback
> > efficiency in terms of effective chunk size?"
> >
> > So in future there could be lines like
> >
> >    pages: balance_dirty_pages           2561544
> >    chunks: balance_dirty_pages          XXXXXXX
> >    works: balance_dirty_pages           XXXXXXX
> >
> > or even derived lines like
> >
> >    pages_per_chunk: balance_dirty_pages         XXXXXXX
> >    pages_per_work: balance_dirty_pages          XXXXXXX
> >
> > Another question is, how can the display format be script friendly?
> > The current form looks not easily parse-able at least for "cut"..
> 
> I suppose you mean because of the variable number of tokens.  Yeah,
> this can be hard.  Of course, I always just use "awk '{print $NF}'"
> and it works for me :-) .  But I'd be happy to change these to use a
> consistent # of args.
> 
> Thanks,
> Curt
> 
> 
> > Thanks,
> > Fengguang
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
