Date: Tue, 19 Nov 2002 14:05:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.5.48-mm1
In-Reply-To: <3DDA0153.A1971C76@digeo.com>
Message-ID: <Pine.LNX.4.44.0211191338590.1596-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Nov 2002, Andrew Morton wrote:
> 
> +loop-balance-pages.patch
> 
>  Small optimisation to loop

I disagree with this one (changing balance_dirty_pages to _ratelimited
when loop_thread writes to file): it's a step in the right direction,
but I think you should remove that balance_dirty_pages call completely.

I'm experimenting with what's needed to prevent deadoralivelock in
loop over tmpfs under heavy memory pressure (thank you for eliminating
wait_on_page_bit from shrink_list!).  One element of that is to ignore
balance_dirty_pages below loop (I hadn't noticed the explicit call,
offhand I'm unsure whether that's the only possible instance).

The loop_thread is working towards undirtying memory (completing
writeback): a loop of blk_congestion_waits is appropriate at the
upper level where the user task generating dirt needs to be throttled,
but I don't believe it's appropriate at this level - we wouldn't want
to throttle the disk, no more should we throttle the loop_thread.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
