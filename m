Date: Mon, 9 Oct 2006 20:06:05 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
In-Reply-To: <20061010023654.GD15822@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0610091951350.3952@g5.osdl.org>
References: <20061010023654.GD15822@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


On Tue, 10 Oct 2006, Nick Piggin wrote:
>
> This was triggered, but not the fault of, the dirty page accounting
> patches. Suitable for -stable as well, after it goes upstream.

Applied. However, I wonder what protects "page_mapping()" here? I don't 
think we hold the page lock anywhere, so "page->mapping" can change at any 
time, no?

The worry might be that the mapping is truncated, page->mapping is set to 
NULL (but after we cached the old value in "mapping"), and then the 
"struct address_space" is released, so that when we do

	spin_lock(&mapping->private_lock);

we'd be accessing a stale pointer..

Hmm. I guess the mapping cannot become stale at least in _this_ case, 
since the page is mapped into the addess space and the mapping is thus 
pinned by the vma for normal file mappings.

But what happens for other cases where that isn't the situation, and the 
page is related to some other address space (swap, remap_file_pages, 
whatever..)?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
