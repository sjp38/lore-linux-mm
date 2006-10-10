Date: Tue, 10 Oct 2006 00:06:52 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] mm: bug in set_page_dirty_buffers
Message-Id: <20061010000652.bed6f901.akpm@osdl.org>
In-Reply-To: <20061010065217.GC25500@wotan.suse.de>
References: <20061009213806.b158ea82.akpm@osdl.org>
	<20061010044745.GA24600@wotan.suse.de>
	<20061009220127.c4721d2d.akpm@osdl.org>
	<20061010052248.GB24600@wotan.suse.de>
	<20061009222905.ddd270a6.akpm@osdl.org>
	<20061010054832.GC24600@wotan.suse.de>
	<20061009230832.7245814e.akpm@osdl.org>
	<20061010061958.GA25500@wotan.suse.de>
	<20061009232714.b52f678d.akpm@osdl.org>
	<20061010063900.GB25500@wotan.suse.de>
	<20061010065217.GC25500@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006 08:52:17 +0200
Nick Piggin <npiggin@suse.de> wrote:

> On Tue, Oct 10, 2006 at 08:39:00AM +0200, Nick Piggin wrote:
> > As far as set_page_dirty races goes, I am having a bit of a look at that,
> > but it would still require filesystems people to have a look.
> 
> I'm thinking something along the lines of this (untested) patch.

ho hum.

>  void block_invalidatepage(struct page *page, unsigned long offset)
>  {
> -	struct address_space *mapping;
> +	struct address_space *mapping = page->mapping;
>  	struct buffer_head *head, *bh, *next;
> -	unsigned int curr_off = 0;
> +	unsigned int curr_off;
>  
>  	BUG_ON(!PageLocked(page));
> -	spin_lock(&mapping->private_lock);

block_invalidatepage() doesn't take ->private_lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
