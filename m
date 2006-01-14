Date: Sat, 14 Jan 2006 10:01:43 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Race in new page migration code?
In-Reply-To: <20060114155517.GA30543@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com>
References: <20060114155517.GA30543@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Jan 2006, Nick Piggin wrote:

> I'm fairly sure there is a race in the page migration code
> due to your not taking a reference on the page. Taking the
> reference also can make things less convoluted.

We take that reference count on the page:

/*
 * Isolate one page from the LRU lists.
 *
 * - zone->lru_lock must be held
 */
static inline int __isolate_lru_page(struct page *page)
{
        if (unlikely(!TestClearPageLRU(page)))
                return 0;

>>>>        if (get_page_testone(page)) {
                /*
                 * It is being freed elsewhere
                 */
                __put_page(page);
                SetPageLRU(page);
                return -ENOENT;
        }

        return 1;
}

 
> Also, an unsuccessful isolation attempt does not mean something is
> wrong. I removed the WARN_ON, but you should probably be retrying
> on this level if you are really interested in migrating all pages.

It depends what you mean by unsuccessful isolate attempt. One reason for 
not being successful is that the page has been freed. Thats okay.

The other is that the page is not on the LRU, and is not being moved
back to the LRU by draining the lru caches. In that case we need to
have a WARN_ON at least for now. There may be other reasons that a page
is not on the LRU but I would like to be careful about that at first.

Its not an error but something that is of concern thus WARN_ON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
