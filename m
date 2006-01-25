Date: Wed, 25 Jan 2006 08:32:43 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] hugepage allocator cleanup
Message-ID: <20060125163243.GG7655@holomorphy.com>
References: <20060125091103.GA32653@wotan.suse.de> <20060125150513.GF7655@holomorphy.com> <20060125151846.GB25666@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060125151846.GB25666@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 04:18:46PM +0100, Nick Piggin wrote:
> OK. Though obviously I don't want to introduce any ugliness or
> hackery to core code just for lockless pagecache (which may not
> ever go in itself).
> Basically with lockless pagecache it becomes possible that any
> page taken out of the page allocator may have its refcount raised
> by another thread.
> That other thread is looking for a pagecache page, if it takes
> a reused one, it will quickly drop the refcount again.
> So it is important not to muddle the count.  A 1->0 transition
> (as currently when allocating fresh pages for the first time)
> needs to be done with a dec-and-test rather than a plain set.

Preparatory cleanups are fine by me barring where things get to the
point of churn, which isn't a concern here.

It appears the crucial component of this update_and_free_page(). It
shouldn't be necessary as disciplined page->_count references are
redirected to the head of the hugepage, but it's trying to clean up the
page->_counts in tail pages of the hugepage in preparation for freeing.
Arguably 1->0 transition logic shouldn't be triggered, but the locking
protocol envisioned may not allow unconditionally setting page->_count.

Just yanking the page refcount affairs out of update_and_free_page()
should suffice. Could I get things trimmed down to that?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
