Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9E4C46B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 10:06:14 -0400 (EDT)
Subject: Re: [dm-devel] Re: Why does __do_page_cache_readahead submit READ,
 not READA?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20090803075933.GI12579@kernel.dk>
References: <20090729161456.GB8059@barkeeper1-xen.linbit>
	 <20090729211845.GB4148@kernel.dk> <20090729225501.GH24801@think>
	 <20090730060649.GC4148@kernel.dk> <20090803075202.GA13485@localhost>
	 <20090803075933.GI12579@kernel.dk>
Content-Type: text/plain
Date: Mon, 03 Aug 2009 09:26:16 -0500
Message-Id: <1249309576.3943.5.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: device-mapper development <dm-devel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Lars Ellenberg <lars.ellenberg@linbit.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-08-03 at 09:59 +0200, Jens Axboe wrote:
> On Mon, Aug 03 2009, Wu Fengguang wrote:
> > On Thu, Jul 30, 2009 at 08:06:49AM +0200, Jens Axboe wrote:
> > > On Wed, Jul 29 2009, Chris Mason wrote:
> > > > On Wed, Jul 29, 2009 at 11:18:45PM +0200, Jens Axboe wrote:
> > > > > On Wed, Jul 29 2009, Lars Ellenberg wrote:
> > > > > > I naively assumed, from the "readahead" in the name, that readahead
> > > > > > would be submitting READA bios. It does not.
> > > > > > 
> > > > > > I recently did some statistics on how many READ and READA requests
> > > > > > we actually see on the block device level.
> > > > > > I was suprised that READA is basically only used for file system
> > > > > > internal meta data (and not even for all file systems),
> > > > > > but _never_ for file data.
> > > > > > 
> > > > > > A simple
> > > > > > 	dd if=bigfile of=/dev/null bs=4k count=1
> > > > > > will absolutely cause readahead of the configured amount, no problem.
> > > > > > But on the block device level, these are READ requests, where I'd
> > > > > > expected them to be READA requests, based on the name.
> > > > > > 
> > > > > > This is because __do_page_cache_readahead() calls read_pages(),
> > > > > > which in turn is mapping->a_ops->readpages(), or, as fallback,
> > > > > > mapping->a_ops->readpage().
> > > > > > 
> > > > > > On that level, all variants end up submitting as READ.
> > > > > > 
> > > > > > This may even be intentional.
> > > > > > But if so, I'd like to understand that.
> > > > > 
> > > > > I don't think it's intentional, and if memory serves, we used to use
> > > > > READA when submitting read-ahead. Not sure how best to improve the
> > > > > situation, since (as you describe), we lose the read-ahead vs normal
> > > > > read at that level. I did some experimentation some time ago for
> > > > > flagging this, see:
> > > > > 
> > > > > http://git.kernel.dk/?p=linux-2.6-block.git;a=commitdiff;h=16cfe64e3568cda412b3cf6b7b891331946b595e
> > > > > 
> > > > > which should pass down READA properly.
> > > > 
> > > > One of the problems in the past was that reada would fail if there
> > > > wasn't a free request when we actually wanted it to go ahead and wait.
> > > > Or something.  We've switched it around a few times I think.
> > > 
> > > Yes, we did used to do that, whether it was 2.2 or 2.4 I
> > > don't recall :-)
> > > 
> > > It should be safe to enable know, whether there's a prettier way
> > > than the above, I don't know. It works by detecting the read-ahead
> > > marker, but it's a bit of a fragile design.
> > 
> > Another consideration is io-priority reversion and the overheads
> > required to avoid it:
> > 
> >         readahead(pages A-Z)    => READA IO for pages A-Z
> >         <short time later>
> >         read(page A) => blocked => find the request that contains page A
> >                                    and requeue/kick it as READ IO
> > 
> > The page-to-request lookups are not always required but nevertheless
> > the complexity and overheads won't be trivial.
> > 
> > The page-to-request lookup feature would be also useful for "advanced"
> > features like io-canceling (if implemented, hwpoison could be its
> > first user ;)
> 
> I added that 3-4 years ago or so, to experiment with in-kernel
> cancellation for things like truncate(). Tracking pages is not cheap,
> and since the write cancelling wasn't really very sucessful, I didn't go
> ahead with it.

Cancellation also came up several years ago with aio, which also has
requirements for it.

> So I'm not sure it's a viable alternative, even if we restricted it to
> just tracking READA's, for instance.
> 
> But I don't think we have any priority inversion to worry about, at
> least not from the CFQ perspective.

The basic problem with cancellation when implemented at the storage
layer is that its an unusual operation.  The storage primitives which
implement it aren't often invoked, so there's a lot of wariness to
implementing them in practice.  For example, although SCSI has the abort
function, it's not implemented by a lot of controllers, so we'd have to
drop all pending I/O on the floor with a reset and then try and pick up
the pieces we wanted.  Also, cancellation is racy since you never quite
know if the I/O hit the storage or not.

On the back of this, we thought in 2003 or so that the best way to
implement cancellation was simply to do nothing and have something wait
around for the completion and throw it away.  This has exactly the same
properties as storage implemented cancellation, but the benefit is that
we don't have to perturb the storage stack to do it.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
