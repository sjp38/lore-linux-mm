In-reply-to: <20070307021518.3b1ff4a2.akpm@linux-foundation.org> (message from
	Andrew Morton on Wed, 7 Mar 2007 02:15:18 -0800)
Subject: Re: [patch 1/8] fix race in clear_page_dirty_for_io()
References: <20070307080949.290171170@szeredi.hu>
	<20070307082337.101759335@szeredi.hu> <20070307021518.3b1ff4a2.akpm@linux-foundation.org>
Message-Id: <E1HOtR9-00007G-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 07 Mar 2007 11:31:59 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> (cc's reinstated)
> 
> On Wed, 07 Mar 2007 09:09:50 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> 
> > There's a race in clear_page_dirty_for_io() that allows a page to have
> > cleared PG_dirty, while being mapped read-write into the page table(s).
> 
> I assume you refer to this:
> 
> 		 * FIXME! We still have a race here: if somebody
> 		 * adds the page back to the page tables in
> 		 * between the "page_mkclean()" and the "TestClearPageDirty()",
> 		 * we might have it mapped without the dirty bit set.
> 		 */
> 		if (page_mkclean(page))
> 			set_page_dirty(page);
> 		if (TestClearPageDirty(page)) {
> 			dec_zone_page_state(page, NR_FILE_DIRTY);
> 			return 1;
> 		}
> 

Yes.

> I guess the comment actually refers to a writefault after the
> set_page_dirty() and before the TestClearPageDirty().  The fault handler
> will run set_page_dirty() and will return to userspace to rerun the write. 
> The page then gets set pte-dirty but this thread of control will now make
> the page !PageDirty() and will write it out.

Yes.

> With Nick's proposed lock-the-page-in-pagefaults patches, we have
> lock_page() synchronisation between pagefaults and
> clear_page_dirty_for_io() which I think will fix this.

After a quick look, I don't think it does.  It locks the page in
do_no_page(), but not for the whole fault.  In particular do_wp_page()
is not affected.  But I haven't yet looked closely at that patch, so I
could be wrong.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
