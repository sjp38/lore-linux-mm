Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 458AD6B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 08:21:52 -0500 (EST)
Subject: Re: [patch][rfc] mm: new address space calls
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090226051702.GA25605@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de>
	 <1235595597.32346.77.camel@think.oraclecorp.com>
	 <20090226051702.GA25605@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 26 Feb 2009 08:21:45 -0500
Message-Id: <1235654505.26790.12.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-02-26 at 06:17 +0100, Nick Piggin wrote:
> On Wed, Feb 25, 2009 at 03:59:57PM -0500, Chris Mason wrote:
> > On Wed, 2009-02-25 at 11:48 +0100, Nick Piggin wrote:
> > > This is about the last change to generic code I need for fsblock.
> > > Comments?
> > > 
> > 
> > Thanks for doing this.
> > 
> > We've got releasepage, invalidatepage, and now release, all with
> > slightly different semantics and some complex interactions with the rest
> > of the VM.
> 
> Release is I guess basically equivalent of releasepage/invalidatepage
> but on a per-inode rather than per-page basis. I imagine they would
> come in handy for other filesystems (in fsblock I use them for the
> "associated" metadata like buffer-heads have, and for the block extent
> map cache).
> 

Nod

> And I guess we haven't really grown complexity really, because
> previously the core code has to do hardwired callbacks for buffer.c
> anyway, and after this patch filesystems that don't care can continue
> not to define callbacks :)
> 
> 
> > One problem I have with the btrfs extent state code is that I might
> > choose to release the extent state in releasepage, but the VM might not
> > choose to free the page.  So I've got an up to date page without any of
> > the rest of my state.
> 
> I'm not sure. What semantics do you want there? In most cases (including
> fsblock default case where the filesystem does not have a pin), we're
> happy to leave clean, uptodate pages in pagecache in that case.

Right, but it really limits the state that we can keep outside the page
bits.  Take a subpage block, where we know the first 1k is up to date.
releasepage comes and we free our tracking that says the first 1k is up
to date, but the VM doesn't free the page.

Now we have a page where the uptodate bit isn't set, but the first 1k
has valid data.  We have to reread it.

I'd like a form of releasepage that knows if the vm is going to really
get rid of the page.  Or another callback that happens when the VM is
sure the page will be freed so we can drop extra metadata that doesn't
pin the page, but we always want to stay with the page.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
