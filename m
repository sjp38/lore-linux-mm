Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 809916B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 00:17:06 -0500 (EST)
Date: Thu, 26 Feb 2009 06:17:02 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090226051702.GA25605@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de> <1235595597.32346.77.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235595597.32346.77.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 03:59:57PM -0500, Chris Mason wrote:
> On Wed, 2009-02-25 at 11:48 +0100, Nick Piggin wrote:
> > This is about the last change to generic code I need for fsblock.
> > Comments?
> > 
> 
> Thanks for doing this.
> 
> We've got releasepage, invalidatepage, and now release, all with
> slightly different semantics and some complex interactions with the rest
> of the VM.

Release is I guess basically equivalent of releasepage/invalidatepage
but on a per-inode rather than per-page basis. I imagine they would
come in handy for other filesystems (in fsblock I use them for the
"associated" metadata like buffer-heads have, and for the block extent
map cache).

And I guess we haven't really grown complexity really, because
previously the core code has to do hardwired callbacks for buffer.c
anyway, and after this patch filesystems that don't care can continue
not to define callbacks :)


> One problem I have with the btrfs extent state code is that I might
> choose to release the extent state in releasepage, but the VM might not
> choose to free the page.  So I've got an up to date page without any of
> the rest of my state.

I'm not sure. What semantics do you want there? In most cases (including
fsblock default case where the filesystem does not have a pin), we're
happy to leave clean, uptodate pages in pagecache in that case.
 

> Which of these ops covers that? ;)  I'd love to help better document the
> requirements for these callbacks, I find it confusing every time.

I find myself having to re-lookup how they work too (which can be painful
following calls back and forth between mm/ and fs/ :P). I'd like to
improve documentation too..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
