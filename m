Date: Sun, 29 Aug 2004 16:17:19 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829141718.GD10955@suse.de>
References: <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040829141526.GC10955@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: William Lee Irwin III <wli@holomorphy.com>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 29 2004, Jens Axboe wrote:
> > It's all very bizarre.
> > 
> > If you do a big `usemem -m 250' on a 256MB box, you end up with all memory
> > in swapcache _after_ usemem exits.  That's wrong: all the memory which
> > usemem allocated should now be free.
> > 
> > But all that swapcache is reclaimable under memory pressure.  It seems to
> > be floating about on the LRU still.
> > 
> > It only happens with the CFQ elevator, and this backout patch makes it go
> > away.
> 
> It's not bizarre, if you backout that fix (it is a fix!), ->nr_requests
> isn't initialized when cfq gets there. So it'll throttle incorrectly in
> may_queue, not a good idea.

Oh, and I think the main issue is the vm. It should cope correctly no
matter how much pending memory can be in progress on the queue, else it
should not write out so much. CFQ is just exposing this bug because it
defaults to bigger nr_requests.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
