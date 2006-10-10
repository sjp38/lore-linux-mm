Date: Tue, 10 Oct 2006 01:41:14 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-Id: <20061010014114.75c424f0.akpm@osdl.org>
In-Reply-To: <20061010081820.GA24748@wotan.suse.de>
References: <20061009222905.ddd270a6.akpm@osdl.org>
	<20061010054832.GC24600@wotan.suse.de>
	<20061009230832.7245814e.akpm@osdl.org>
	<20061010061958.GA25500@wotan.suse.de>
	<20061009232714.b52f678d.akpm@osdl.org>
	<20061010063900.GB25500@wotan.suse.de>
	<20061010065217.GC25500@wotan.suse.de>
	<20061010000652.bed6f901.akpm@osdl.org>
	<20061010072129.GB14557@wotan.suse.de>
	<20061010010742.50cbe1b1.akpm@osdl.org>
	<20061010081820.GA24748@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006 10:18:20 +0200
Nick Piggin <npiggin@suse.de> wrote:

> > If the buffer's redirtied after discard_buffer() got at it, we've got some
> > nasty problems in there.
> > 
> > Are you sure this race can happen?  Nobody's allowed to have a page mapped
> > while it's undergoing truncation (vmtruncate()).
> 
> Well, not technically. I think it can happen with nonlinear pages now,

How?

> but that is a bug in truncate and I have some patches to fix them.
> 
> But anyone who has done a get_user_pages, AFAIKS, can later run a
> set_page_dirty on the pages.

Most (all?) callers are (and should be) using set_page_dirty_lock().

> Nasty problem, but I think we are OK to
> just ignore the dirty bits in this case, because the truncate might
> well have happened _after_ the get_user_pages guy set the page dirty
> anyway.
> 
> > There might be a problem with the final blocks in the page outside i_size. 
> > iirc what happens here is that the bh outside i_size _is_ marked dirty, but
> > writepage() will notice that it's outside i_size and will just mark it
> > clean again without doing IO.
> 
> Didn't think of that. How does it get to writepage though, if it has
> lost its mapping?

It was only partially truncated - it's still on the address_space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
