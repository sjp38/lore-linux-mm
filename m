Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B0E806B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 12:35:06 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
Date: Fri, 20 Mar 2009 03:34:54 +1100
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com> <200903200248.22623.nickpiggin@yahoo.com.au> <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain>
In-Reply-To: <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903200334.55710.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Friday 20 March 2009 03:20:57 Linus Torvalds wrote:
> On Fri, 20 Mar 2009, Nick Piggin wrote:
> > But I think we do have a race in __set_page_dirty_buffers():
> >
> > The page may not have buffers between the mapping->private_lock
> > critical section and the __set_page_dirty call there. So between
> > them, another thread might do a create_empty_buffers which can
> > see !PageDirty and thus it will create clean buffers.
>
> Hmm.
>
> Creating clean buffers is locked by the page lock, nothing else.  And not
> all page dirtiers hold the page lock (in fact, most try to avoid it - the
> rule is that you either have to hold the page lock _or_ hold a reference
> to the 'mapping', and the latter is what the mmap code does, I think).
>
> So yeah, the page lock isn't sufficient.

No. FWIW, I thought there might be a race due to page fault code
not holding page lock over set_page_dirty (well there *are* some kinds
of races, but they're another story). So I tried out my patches that
move that lock over set_page_dirty for __do_fault and do_wp_page
(so the lock is held over pte_mkwrite and set_page_dirty), but that
still didn't solve the problem either.


> > Holding mapping->private_lock over the __set_page_dirty should
> > fix it, although I guess you'd want to release it before calling
> > __mark_inode_dirty so as not to put inode_lock under there. I
> > have a patch for this if it sounds reasonable.
>
> That would seem to make sense. Maybe moving the "TestSetPageDirty()" from
> inside __set_page_dirty() to the caller? Something like the appended?
>
> This is TOTALLY untested. Of course.

Yeah, probably no need to hold private_lock while tagging the radix
tree (which is what my version did). So maybe this one is a little
better. I did test mine, it worked, but it didn't solve the problem.

Still, it does appear to solve a real race, which we should close.

>
> 			Linus
>
> ---
>  fs/buffer.c |   23 +++++++++++------------
>  1 files changed, 11 insertions(+), 12 deletions(-)
>
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 9f69741..891e1c7 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -760,15 +760,9 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
>   * If warn is true, then emit a warning if the page is not uptodate and
> has * not been truncated.
>   */
> -static int __set_page_dirty(struct page *page,
> +static void __set_page_dirty(struct page *page,
>  		struct address_space *mapping, int warn)
>  {
> -	if (unlikely(!mapping))
> -		return !TestSetPageDirty(page);
> -
> -	if (TestSetPageDirty(page))
> -		return 0;
> -
>  	spin_lock_irq(&mapping->tree_lock);
>  	if (page->mapping) {	/* Race with truncate? */
>  		WARN_ON_ONCE(warn && !PageUptodate(page));
> @@ -785,8 +779,6 @@ static int __set_page_dirty(struct page *page,
>  	}
>  	spin_unlock_irq(&mapping->tree_lock);
>  	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> -
> -	return 1;
>  }
>
>  /*
> @@ -816,6 +808,7 @@ static int __set_page_dirty(struct page *page,
>   */
>  int __set_page_dirty_buffers(struct page *page)
>  {
> +	int newly_dirty;
>  	struct address_space *mapping = page_mapping(page);
>
>  	if (unlikely(!mapping))
> @@ -831,9 +824,12 @@ int __set_page_dirty_buffers(struct page *page)
>  			bh = bh->b_this_page;
>  		} while (bh != head);
>  	}
> +	newly_dirty = !TestSetPageDirty(page);
>  	spin_unlock(&mapping->private_lock);
>
> -	return __set_page_dirty(page, mapping, 1);
> +	if (newly_dirty)
> +		__set_page_dirty(page, mapping, 1);
> +	return newly_dirty;
>  }
>  EXPORT_SYMBOL(__set_page_dirty_buffers);
>
> @@ -1262,8 +1258,11 @@ void mark_buffer_dirty(struct buffer_head *bh)
>  			return;
>  	}
>
> -	if (!test_set_buffer_dirty(bh))
> -		__set_page_dirty(bh->b_page, page_mapping(bh->b_page), 0);
> +	if (!test_set_buffer_dirty(bh)) {
> +		struct page *page = bh->b_page;
> +		if (!TestSetPageDirty(page))
> +			__set_page_dirty(page, page_mapping(page), 0);
> +	}
>  }
>
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
