Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E9DF06B00EE
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 05:50:27 -0400 (EDT)
Date: Sun, 7 Aug 2011 11:50:19 +0200
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH 5/5] writeback: IO-less balance_dirty_pages()
Message-ID: <20110807095019.GA2026@thinkpad>
References: <20110806084447.388624428@intel.com>
 <20110806094527.136636891@intel.com>
 <20110806164656.GA1590@thinkpad>
 <20110807071857.GC3287@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110807071857.GC3287@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Aug 07, 2011 at 03:18:57PM +0800, Wu Fengguang wrote:
> Andrea,
> 
> On Sun, Aug 07, 2011 at 12:46:56AM +0800, Andrea Righi wrote:
> > On Sat, Aug 06, 2011 at 04:44:52PM +0800, Wu Fengguang wrote:
> 
> > > So here is a pause time oriented approach, which tries to control the
> > > pause time in each balance_dirty_pages() invocations, by controlling
> > > the number of pages dirtied before calling balance_dirty_pages(), for
> > > smooth and efficient dirty throttling:
> > >
> > > - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> > > - avoid too small pause time (less than   4ms, which burns CPU power)
> > > - avoid too large pause time (more than 200ms, which hurts responsiveness)
> > > - avoid big fluctuations of pause times
> > 
> > I definitely agree that too small pauses must be avoided. However, I
> > don't understand very well from the code how the minimum sleep time is
> > regulated.
> 
> Thanks for pointing this out. Yes, the sleep time regulation is not
> here and I should have mentioned that above. Since this is only the
> core bits, there will be some followup patches to fix the rough edges.
> (attached the two relevant patches)
> 
> > I've added a simple tracepoint (see below) to monitor the pause times in
> > balance_dirty_pages().
> > 
> > Sometimes I see very small pause time if I set a low dirty threshold
> > (<=32MB).
> 
> Yeah, it's definitely possible.
> 
> > Example:
> > 
> >  # echo $((16 * 1024 * 1024)) > /proc/sys/vm/dirty_bytes
> >  # iozone -A >/dev/null &
> >  # cat /sys/kernel/debug/tracing/trace_pipe
> >  ...
> >           iozone-2075  [001]   380.604961: writeback_dirty_throttle: 1
> >           iozone-2075  [001]   380.605966: writeback_dirty_throttle: 2
> >           iozone-2075  [001]   380.608405: writeback_dirty_throttle: 0
> >           iozone-2075  [001]   380.608980: writeback_dirty_throttle: 1
> >           iozone-2075  [001]   380.609952: writeback_dirty_throttle: 1
> >           iozone-2075  [001]   380.610952: writeback_dirty_throttle: 2
> >           iozone-2075  [001]   380.612662: writeback_dirty_throttle: 0
> >           iozone-2075  [000]   380.613799: writeback_dirty_throttle: 1
> >           iozone-2075  [000]   380.614771: writeback_dirty_throttle: 1
> >           iozone-2075  [000]   380.615767: writeback_dirty_throttle: 2
> >  ...
> > 
> > BTW, I can see this behavior only in the first minute while iozone is
> > running. Ater ~1min things seem to get stable (sleeps are usually
> > between 50ms and 200ms).
> > 
> 
> Yeah, it's roughly in line with this graph, where the red dots are the
> pause time:
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/512M/xfs-1dd-4k-8p-438M-20:10-3.0.0-next-20110802+-2011-08-06.11:03/balance_dirty_pages-pause.png
> 
> Note that the big change of pattern in the middle is due to a
> deliberate disturb: a dd will be started at 100s _reading_ 1GB data,
> which effectively livelocked the other dd dirtier task with the CFQ io
> scheduler. 
> 
> > I wonder if we shouldn't add an explicit check also for the minimum
> > sleep time.
>  
> With the more complete patchset including the pause time regulation,
> the pause time distribution should look much better, falling nicely
> into the range (5ms, 20ms):
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v8/3G/xfs-1dd-4k-8p-2948M-20:10-3.0.0-rc2-next-20110610+-2011-06-12.21:51/balance_dirty_pages-pause.png
> 
> > +TRACE_EVENT(writeback_dirty_throttle,
> > +       TP_PROTO(unsigned long sleep),
> > +       TP_ARGS(sleep),
> 
> btw, I've just pushed two more tracing patches to the git tree.
> Hope it helps :)

Perfect. Thanks for the clarification and the additional patches, I'm
going to test them right now.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
