Date: Sun, 29 Aug 2004 13:59:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on
 swap partition
Message-Id: <20040829135917.3e8ffed8.akpm@osdl.org>
In-Reply-To: <20040829203011.GA11878@suse.de>
References: <20040828125028.2fa2a12b.akpm@osdl.org>
	<4130F55A.90705@pandora.be>
	<20040828144303.0ae2bebe.akpm@osdl.org>
	<20040828215411.GY5492@holomorphy.com>
	<20040828151349.00f742f4.akpm@osdl.org>
	<20040828222816.GZ5492@holomorphy.com>
	<20040829033031.01c5f78c.akpm@osdl.org>
	<20040829141526.GC10955@suse.de>
	<20040829141718.GD10955@suse.de>
	<20040829131824.1b39f2e8.akpm@osdl.org>
	<20040829203011.GA11878@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: wli@holomorphy.com, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe <axboe@suse.de> wrote:
>
> > That was my point.
> 
>  I didn't understand your message at all, maybe that wasn't clear enough
>  in my email :-). You state that the main effect of that particular patch
>  is to bump nr_requests to 8192, which is definitely not true. The main
>  effect of the patch is to make sure that ->nr_requests was valid, so
>  that cfqd->max_queued is valid. ->nr_requests was always overwritten
>  with 8192 for quite some time, irregardless of that patch. So this
>  particular change has nothing to do with that, and other io schedulers
>  will experience exactly this very problem with 8192 requests.
> 
>  Why you do see a difference is that when ->max_queued isn't valid, you
>  end up block a lot more in get_request_wait() because cfq_may_queue will
>  disallow you to queue a lot more than with the patch. Since other io
>  schedulers don't have these sort of checks, they behave like CFQ does
>  with the bug in blk_init_queue() fixed.

The changlog wasn't that detailed ;)

But yes, it's the large nr_requests which is tripping up swapout.  I'm
assuming that when a process exits with its anonymous memory still under
swap I/O we're forgetting to actually free the pages when the I/O
completes.  So we end up with a ton of zero-ref swapcache pages on the LRU.

I assume.   Something odd's happening, that's for sure.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
