Date: Thu, 21 Nov 2002 16:04:25 -0500 (EST)
From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: 2.5.48-mm1
In-Reply-To: <Pine.LNX.4.44.0211191338590.1596-100000@localhost.localdomain>
Message-ID: <Pine.LNX.3.96.1021121160056.10456D-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Nov 2002, Hugh Dickins wrote:

> I disagree with this one (changing balance_dirty_pages to _ratelimited
> when loop_thread writes to file): it's a step in the right direction,
> but I think you should remove that balance_dirty_pages call completely.
> 
> I'm experimenting with what's needed to prevent deadoralivelock in
> loop over tmpfs under heavy memory pressure (thank you for eliminating
> wait_on_page_bit from shrink_list!).  One element of that is to ignore
> balance_dirty_pages below loop (I hadn't noticed the explicit call,
> offhand I'm unsure whether that's the only possible instance).
> 
> The loop_thread is working towards undirtying memory (completing
> writeback): a loop of blk_congestion_waits is appropriate at the
> upper level where the user task generating dirt needs to be throttled,
> but I don't believe it's appropriate at this level - we wouldn't want
> to throttle the disk, no more should we throttle the loop_thread.

This is purely a performance decision. If you want to avoid bad latency on
reads then you have to throttle writes. The loop_thread will make the
system just as slow as a user application writing the same number of
pages.

If you want io scheduling you will deliberately slow writes to let reads
happen in reasonable time. And vice-versa I imagine, although I don't
think I've seen that case.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
