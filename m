Date: Mon, 06 Aug 2001 12:51:48 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [RFC] using writepage to start io
Message-ID: <651080000.997116708@tiny>
In-Reply-To: <01080618132007.00294@starship>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Monday, August 06, 2001 06:13:20 PM +0200 Daniel Phillips
<phillips@bonn-fries.net> wrote:

>> I am saying that it should be possible to have the best buffer flushed
>> under memory pressure (by kswapd/bdflush) and still get the old data
>> to disk in time through kupdate.
> 
> Yes, to phrase this more precisely, after we've submitted all the 
> too-old buffers we then gain the freedom to select which of the younger 
> buffers to flush.  

Almost ;-) memory pressure doesn't need to care about how long a buffer has
been dirty, that's kupdate's job.  kupdate doesn't care if the buffer it is
writing is a good candidate for freeing, that's taken care of elsewhere.
The two never need to talk (aside from optimizations).

> When there is memory pressure we could benefit by 
> skipping over some of the sys_write buffers in favor of page_launder 
> buffers.  We may well be able to recognize the latter by looking for 
> !bh->b_page->age.  This method would be an alternative to your 
> writepage approach.

Yes, I had experimented with this in addition to the writepage patch, it
would probably be better to try it as a standalone idea.

> 
>> > By the way, I think you should combine (2) and (3) using an and,
>> > which gets us back to the "kupdate thing" vs the "bdflush thing".
>> 
>> Perhaps, since I think they would be handled in roughly the same way.
> 
> (warning: I'm going to drift pretty far off the original topic now...)
> 
> I don't see why it makes sense to have both a kupdate and a bdflush 
> thread.  

Having two threads is exactly what allows memory pressure to not be
concerned about how long a buffer has been dirty.

> We should complete the process of merging these (sharing 
> flush_dirty buffers was a big step) and look into the possibility of 
> adding more intelligence about what to submit next.  The proof of the 
> pudding is to come up with a throughput-improving patch, not so easy 
> since the ore in these hills has been sought after for a good number of 
> years by many skilled prospectors.
> 
> Note that bdflush also competes with an unbounded number of threads 
> doing wakeup_bdflush(1)->flush_dirty_buffers.

Nods.  Of course, processes could wait on bdflush instead, but bdflush
might not be able to keep up.  It would be interesting to experiment with a
bdflush thread per device, one that uses write_unlocked_buffers to get the
io done.  I'll start by switching from flush_dirty_buffers to
write_unlocked_buffers in the current code...

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
