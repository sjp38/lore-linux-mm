Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07FF96B009A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 05:06:50 -0400 (EDT)
Date: Mon, 3 Aug 2009 11:25:15 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Why does __do_page_cache_readahead submit READ, not READA?
Message-ID: <20090803092515.GK12579@kernel.dk>
References: <20090729161456.GB8059@barkeeper1-xen.linbit> <20090729211845.GB4148@kernel.dk> <20090729225501.GH24801@think> <20090730060649.GC4148@kernel.dk> <20090803075202.GA13485@localhost> <20090803075933.GI12579@kernel.dk> <20090803082318.GA18731@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090803082318.GA18731@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chris Mason <chris.mason@oracle.com>, Lars Ellenberg <lars.ellenberg@linbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Neil Brown <neilb@suse.de>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 03 2009, Wu Fengguang wrote:
> On Mon, Aug 03, 2009 at 03:59:33PM +0800, Jens Axboe wrote:
> > On Mon, Aug 03 2009, Wu Fengguang wrote:
> > > On Thu, Jul 30, 2009 at 08:06:49AM +0200, Jens Axboe wrote:
> > > > On Wed, Jul 29 2009, Chris Mason wrote:
> > > > > On Wed, Jul 29, 2009 at 11:18:45PM +0200, Jens Axboe wrote:
> > > > > > On Wed, Jul 29 2009, Lars Ellenberg wrote:
> > > > > > > I naively assumed, from the "readahead" in the name, that readahead
> > > > > > > would be submitting READA bios. It does not.
> > > > > > > 
> > > > > > > I recently did some statistics on how many READ and READA requests
> > > > > > > we actually see on the block device level.
> > > > > > > I was suprised that READA is basically only used for file system
> > > > > > > internal meta data (and not even for all file systems),
> > > > > > > but _never_ for file data.
> > > > > > > 
> > > > > > > A simple
> > > > > > > 	dd if=bigfile of=/dev/null bs=4k count=1
> > > > > > > will absolutely cause readahead of the configured amount, no problem.
> > > > > > > But on the block device level, these are READ requests, where I'd
> > > > > > > expected them to be READA requests, based on the name.
> > > > > > > 
> > > > > > > This is because __do_page_cache_readahead() calls read_pages(),
> > > > > > > which in turn is mapping->a_ops->readpages(), or, as fallback,
> > > > > > > mapping->a_ops->readpage().
> > > > > > > 
> > > > > > > On that level, all variants end up submitting as READ.
> > > > > > > 
> > > > > > > This may even be intentional.
> > > > > > > But if so, I'd like to understand that.
> > > > > > 
> > > > > > I don't think it's intentional, and if memory serves, we used to use
> > > > > > READA when submitting read-ahead. Not sure how best to improve the
> > > > > > situation, since (as you describe), we lose the read-ahead vs normal
> > > > > > read at that level. I did some experimentation some time ago for
> > > > > > flagging this, see:
> > > > > > 
> > > > > > http://git.kernel.dk/?p=linux-2.6-block.git;a=commitdiff;h=16cfe64e3568cda412b3cf6b7b891331946b595e
> > > > > > 
> > > > > > which should pass down READA properly.
> > > > > 
> > > > > One of the problems in the past was that reada would fail if there
> > > > > wasn't a free request when we actually wanted it to go ahead and wait.
> > > > > Or something.  We've switched it around a few times I think.
> > > > 
> > > > Yes, we did used to do that, whether it was 2.2 or 2.4 I
> > > > don't recall :-)
> > > > 
> > > > It should be safe to enable know, whether there's a prettier way
> > > > than the above, I don't know. It works by detecting the read-ahead
> > > > marker, but it's a bit of a fragile design.
> > > 
> > > Another consideration is io-priority reversion and the overheads
> > > required to avoid it:
> > > 
> > >         readahead(pages A-Z)    => READA IO for pages A-Z
> > >         <short time later>
> > >         read(page A) => blocked => find the request that contains page A
> > >                                    and requeue/kick it as READ IO
> > > 
> > > The page-to-request lookups are not always required but nevertheless
> > > the complexity and overheads won't be trivial.
> > > 
> > > The page-to-request lookup feature would be also useful for "advanced"
> > > features like io-canceling (if implemented, hwpoison could be its
> > > first user ;)
> > 
> > I added that 3-4 years ago or so, to experiment with in-kernel
> > cancellation for things like truncate(). Tracking pages is not cheap,
> > and since the write cancelling wasn't really very sucessful, I didn't go
> > ahead with it.
> 
> Ah OK.
> 
> > So I'm not sure it's a viable alternative, even if we restricted it to
> > just tracking READA's, for instance.
> 
> Kind of agreed. I guess it won't benefit too much workloads to default
> to READA; for most workloads it would be pure overheads if considering
> priority inversion.
> 
> > But I don't think we have any priority inversion to worry about, at
> > least not from the CFQ perspective.
> 
> The priority inversion problem showed up in an early attempt to do
> boot time prefetching. I guess this problem was somehow circumvented
> by limiting the prefetch depth and do prefetches in original read
> order instead of disk location order (Arjan cc'ed).

But was that not due to the prefetcher running at a lower cpu priority?
Just flagging a reada hint will not change your priority in the IO
scheduler, so we should have no priority inversion there.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
