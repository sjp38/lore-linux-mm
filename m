Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Mon, 6 Aug 2001 18:13:20 +0200
References: <316580000.997104241@tiny>
In-Reply-To: <316580000.997104241@tiny>
MIME-Version: 1.0
Message-Id: <01080618132007.00294@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2001 15:24, Chris Mason wrote:
> On Monday, August 06, 2001 07:39:47 AM +0200 Daniel Phillips wrote:
> >Chris Mason wrote:
> >> there are at least 3 reasons to write buffers to disk
> >>
> >> 1) they are too old
> >> 2) the percentage of dirty buffers is too high
> >> 3) you need to reclaim them due to memory pressure
> >>
> >> There are 3 completely different things; there's no trumping of
> >> priorities.
> >
> > There is.  If your heavily loaded machine goes down and you lose
> > edits from 1/2 an hour ago even though your bdflush parms specify a
> > 30 second update cycle you'll call the system broken, whereas if it
> > runs 5% slower under heavy write+swap load that's just life.
>
> Ok, we're getting caught up in semantics here.  I'm not saying kupdate
> should switch over to write buffers that might get reclaimed instead
> of old buffers.  There still needs to be proper flushing of old data.
>
> I am saying that it should be possible to have the best buffer flushed
> under memory pressure (by kswapd/bdflush) and still get the old data
> to disk in time through kupdate.

Yes, to phrase this more precisely, after we've submitted all the 
too-old buffers we then gain the freedom to select which of the younger 
buffers to flush.  When there is memory pressure we could benefit by 
skipping over some of the sys_write buffers in favor of page_launder 
buffers.  We may well be able to recognize the latter by looking for 
!bh->b_page->age.  This method would be an alternative to your 
writepage approach.

> > By the way, I think you should combine (2) and (3) using an and,
> > which gets us back to the "kupdate thing" vs the "bdflush thing".
>
> Perhaps, since I think they would be handled in roughly the same way.

(warning: I'm going to drift pretty far off the original topic now...)

I don't see why it makes sense to have both a kupdate and a bdflush 
thread.  We should complete the process of merging these (sharing 
flush_dirty buffers was a big step) and look into the possibility of 
adding more intelligence about what to submit next.  The proof of the 
pudding is to come up with a throughput-improving patch, not so easy 
since the ore in these hills has been sought after for a good number of 
years by many skilled prospectors.

Note that bdflush also competes with an unbounded number of threads 
doing wakeup_bdflush(1)->flush_dirty_buffers.

These are called through balance_dirty:

  mark_buffer_dirty->balance_dirty
  __block_commit_write->balance_dirty
  refill_freelist->balance_dirty

(Curiously, refill_freelist also calls wakeup_bdflush(1) directly.)  You 
can see that each of these paths is very popular, and as soon as we pass 
the hard_dirty_limit everybody will jump in to try to help with buffer 
writeout.

As I recall, the current arrangement was arrived at after a flurry of 
dbench-inspired tweaking last fall and hasn't changed much since then.  
I think we need to take another look at this.  My instinct is that 
it's wrong to ever have more than one instance of flush_dirty_buffers 
active per spindle, and that the current arrangement is an attempt to 
reduce context switches or perhaps to keep buffer submission flowing 
even when page_launder blocks on writepage-><read metadata 
synchronously>.  There has to be a cleaner way to approach this.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
