Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC][PATCH] alternative way of calculating inactive_target
Date: Thu, 16 Aug 2001 10:55:32 +0200
References: <200108160337.FAA11729@mailb.telia.com>
In-Reply-To: <200108160337.FAA11729@mailb.telia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010816084939Z16265-1231+1158@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@skelleftea.mail.telia.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 16, 2001 05:33 am, Roger Larsson wrote:
> Hi,
> 
> 1. Two things in this file, first an unrelated issue (but included in the patch)
> global_target in free_shortage shouldn't it be freepages.low?
> Traditionally freepages.high has been when to stop freeing pages.
> 
> 2. I have wondered about how inactive_target is calculated.
> This is an alternative approach...
> 
> In this alternative approach I use two wrapping counters.
> (memory_clock & memory_clock_rubberband)
> 
> memory_clock is incremented only when allocating pages (and it
> is never decremented)

Yes, exactly, did you read my mind?  Page units are the natural quantum
of the time base for the whole mm.  When we clock all mm events according
to the (__alloc_page << order) timebase then lots of memory spikes are
magically transformed into smooth curves and it becomes immediately
obvious how much scanning we need to do at each instant.  Now, warning,
this is a major shift in viewpoint and I'll wager, unwelcome on this side
of the 2.5 split.  I'd be happy to work with you doing a skunkworks-type
proof-of-concept though.

> memory_clock_rubberband is calculated to be close to what
> memory_clock should have been for MEMORY_CLOCK_WINDOW seconds
> earlier, using current values and information about how long it was since it
> was updated the last time. This makes it possible to recalculate the target
> more often when pressure is high - and it simplifies kswapd too...

I'll supply a cute, efficient filter that does what you're doing with the
rubberband with a little stronger theoretical basis, as soon as I wake up
again.  Or you can look for my earlier "Early flush with bandwidth
estimation" post.  (Try to ignore the incorrect volatile handling please.)

BTW, you left out an interesting detail: any performance measurements
you've already done.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
