Date: Tue, 10 Oct 2006 05:19:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-ID: <20061010031940.GG15822@wotan.suse.de>
References: <20061010023654.GD15822@wotan.suse.de> <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2006 at 08:06:05PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 10 Oct 2006, Nick Piggin wrote:
> >
> > This was triggered, but not the fault of, the dirty page accounting
> > patches. Suitable for -stable as well, after it goes upstream.
> 
> Applied. However, I wonder what protects "page_mapping()" here? I don't 
> think we hold the page lock anywhere, so "page->mapping" can change at any 
> time, no?
> 
> The worry might be that the mapping is truncated, page->mapping is set to 
> NULL (but after we cached the old value in "mapping"), and then the 
> "struct address_space" is released, so that when we do
> 
> 	spin_lock(&mapping->private_lock);
> 
> we'd be accessing a stale pointer..
> 
> Hmm. I guess the mapping cannot become stale at least in _this_ case, 
> since the page is mapped into the addess space and the mapping is thus 
> pinned by the vma for normal file mappings.
> 
> But what happens for other cases where that isn't the situation, and the 
> page is related to some other address space (swap, remap_file_pages, 
> whatever..)?

We require that set_page_dirty only be called when it has the mapping
pinned. There are a few places that can't do this, so they have
set_page_dirty_lock which pins the mapping before calling down.

Aside, as you might remember a few months ago, we "discovered" that
lock_page needs the mapping pinned too, which gave rise to the lovely
lock_page_nosync special case!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
