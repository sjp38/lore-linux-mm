Date: Sun, 29 Aug 2004 22:30:11 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829203011.GA11878@suse.de>
References: <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829131824.1b39f2e8.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: wli@holomorphy.com, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29 2004, Andrew Morton wrote:
> Jens Axboe <axboe@suse.de> wrote:
> >
> >  > > It only happens with the CFQ elevator, and this backout patch makes it go
> >  > > away.
> >  > 
> >  > It's not bizarre, if you backout that fix (it is a fix!), ->nr_requests
> >  > isn't initialized when cfq gets there. So it'll throttle incorrectly in
> >  > may_queue, not a good idea.
> > 
> >  Oh, and I think the main issue is the vm. It should cope correctly no
> >  matter how much pending memory can be in progress on the queue, else it
> >  should not write out so much. CFQ is just exposing this bug because it
> >  defaults to bigger nr_requests.
> 
> That was my point.

I didn't understand your message at all, maybe that wasn't clear enough
in my email :-). You state that the main effect of that particular patch
is to bump nr_requests to 8192, which is definitely not true. The main
effect of the patch is to make sure that ->nr_requests was valid, so
that cfqd->max_queued is valid. ->nr_requests was always overwritten
with 8192 for quite some time, irregardless of that patch. So this
particular change has nothing to do with that, and other io schedulers
will experience exactly this very problem with 8192 requests.

Why you do see a difference is that when ->max_queued isn't valid, you
end up block a lot more in get_request_wait() because cfq_may_queue will
disallow you to queue a lot more than with the patch. Since other io
schedulers don't have these sort of checks, they behave like CFQ does
with the bug in blk_init_queue() fixed.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
