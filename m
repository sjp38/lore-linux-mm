Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7BB856B0169
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 09:10:24 -0400 (EDT)
Date: Tue, 16 Aug 2011 15:10:19 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2 v2] writeback: Add writeback stats for pages written
Message-ID: <20110816131019.GA23416@quack.suse.cz>
References: <1313189245-7197-1-git-send-email-curtw@google.com>
 <1313189245-7197-2-git-send-email-curtw@google.com>
 <20110815134846.GB13534@localhost>
 <CAO81RMYmxRiGpEjLGyjKNeNxXg8UJDuVosNdHGKt70gezTjxGw@mail.gmail.com>
 <20110815184023.GA16369@quack.suse.cz>
 <CAO81RMbpK4ZE=4c5khSrGpzDrXbyynWp8QoFbUjMuHFeJtbDDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAO81RMbpK4ZE=4c5khSrGpzDrXbyynWp8QoFbUjMuHFeJtbDDw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  Hi Curt,

On Mon 15-08-11 11:56:08, Curt Wohlgemuth wrote:
> On Mon, Aug 15, 2011 at 11:40 AM, Jan Kara <jack@suse.cz> wrote:
> > Regarding congestion_wait() statistics - do I get right that the numbers
> > gathered actually depend on the number of threads using the congested
> > device? They are something like
> >  \sum_{over threads} time_waited_for_bdi
> > How do you interpret the resulting numbers then?
> 
> I don't have it by thread; just stupidly as totals, like this:
> 
> calls: ttfp           11290
> time: ttfp        558191
> calls: shrink_inactive_list isolated       xxx
> time : shrink_inactive_list isolated            xxx
> calls: shrink_inactive_list lumpy reclaim       xxx
> time : shrink_inactive_list lumpy reclaim          xxx
> calls: balance_pgdat                                xxx
> time : balance_pgdat                                xxx
> calls: alloc_pages_high_priority                    xxx
> time : alloc_pages_high_priority                    xxx
> calls: alloc_pages_slowpath                         xxx
> time : alloc_pages_slowpath                         xxx
> calls: throttle_vm_writeout                         xxx
> time : throttle_vm_writeout                         xxx
> calls: balance_dirty_pages                          xxx
> time : balance_dirty_pages                         xxx
  Yes, that's what I was expecting.

> Note that the "call" points above are from a very old (2.6.34 +
> backports) kernel, but you get the idea.  We just wrap
> congestion_wait() with a routine that takes a 'type' parameter; does
> the congestion_wait(); and increments the appropriate 'call' stat, and
> adds to the appropriate 'time' stat the return value from
> congestion_wait().
  OK I see. I imagine that could be useful when you are monitoring your
systems or doing some long term observations.

> For a given workload, you can get an idea for where congestion is
> adding to delays.  I really think that for IO-less
> balance_dirty_pages(), we need some insight into how long writer
> threads are being throttled.  And tracepoints are great, but not
> sufficient, IMHO.
  Well, we are going to report computed delays via tracepoints which are
going to be prime interface for debugging but I agree that some statistics
could be useful as well and more lightweight (no need to pass lots of trace
data to userspace). OTOH I wonder if we shouldn't write a userspace tool
processing trace information from balance_dirty_pages() and generating
exactly those statistics you want in the kernel - something like writeback
tracer...

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
