Date: Sun, 29 Aug 2004 15:17:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829221757.GA5492@holomorphy.com>
References: <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829135917.3e8ffed8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Jens Axboe <axboe@suse.de>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe <axboe@suse.de> wrote:
>>  Why you do see a difference is that when ->max_queued isn't valid, you
>>  end up block a lot more in get_request_wait() because cfq_may_queue will
>>  disallow you to queue a lot more than with the patch. Since other io
>>  schedulers don't have these sort of checks, they behave like CFQ does
>>  with the bug in blk_init_queue() fixed.

On Sun, Aug 29, 2004 at 01:59:17PM -0700, Andrew Morton wrote:
> The changlog wasn't that detailed ;)
> But yes, it's the large nr_requests which is tripping up swapout.  I'm
> assuming that when a process exits with its anonymous memory still under
> swap I/O we're forgetting to actually free the pages when the I/O
> completes.  So we end up with a ton of zero-ref swapcache pages on the LRU.
> I assume.   Something odd's happening, that's for sure.

Maybe we need to be checking for this in end_swap_bio_write() or
rotate_reclaimable_page()?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
