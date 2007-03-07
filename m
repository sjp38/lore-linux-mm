Date: Wed, 7 Mar 2007 02:15:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/8] fix race in clear_page_dirty_for_io()
Message-Id: <20070307021518.3b1ff4a2.akpm@linux-foundation.org>
In-Reply-To: <20070307082337.101759335@szeredi.hu>
References: <20070307080949.290171170@szeredi.hu>
	<20070307082337.101759335@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

(cc's reinstated)

On Wed, 07 Mar 2007 09:09:50 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> There's a race in clear_page_dirty_for_io() that allows a page to have
> cleared PG_dirty, while being mapped read-write into the page table(s).

I assume you refer to this:

		 * FIXME! We still have a race here: if somebody
		 * adds the page back to the page tables in
		 * between the "page_mkclean()" and the "TestClearPageDirty()",
		 * we might have it mapped without the dirty bit set.
		 */
		if (page_mkclean(page))
			set_page_dirty(page);
		if (TestClearPageDirty(page)) {
			dec_zone_page_state(page, NR_FILE_DIRTY);
			return 1;
		}

I guess the comment actually refers to a writefault after the
set_page_dirty() and before the TestClearPageDirty().  The fault handler
will run set_page_dirty() and will return to userspace to rerun the write. 
The page then gets set pte-dirty but this thread of control will now make
the page !PageDirty() and will write it out.

With Nick's proposed lock-the-page-in-pagefaults patches, we have
lock_page() synchronisation between pagefaults and
clear_page_dirty_for_io() which I think will fix this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
