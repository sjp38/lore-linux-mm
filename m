From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Optimize page_remove_rmap for anon pages
Date: Tue, 3 Jun 2008 09:57:48 +1000
References: <1212069392.16984.25.camel@localhost>
In-Reply-To: <1212069392.16984.25.camel@localhost>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200806030957.49069.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 29 May 2008 23:56, Martin Schwidefsky wrote:
> Greetings,
> with a recent performance analysis we discovered something interesting
> in regard to the physical dirty bits found on s390. The page_remove_rmap
> function stands out when areas of anonymous memory gets unmapped. The
> reason is the transfer of the dirty bit from the page storage key to the
> struct page when the last mapper of a page is removed. For anonymous
> pages that cease to exist this is superfluous. Without the storage key
> operations process termination is noticable faster, e.g. for a gcc test
> case we got a speedup of 2%.
> To get this done page_remove_rmap needs to know if the page dirty bit
> can be ignored. The page_test_dirty / page_clear_dirty call can only be
> avoided if page_remove_rmap is called from zap_pte_range or do_wp_page.
> If it is called from any other place - in particular try_to_unmap_one -
> the page dirty bit may not be ignored.
> The patch below introduces a new function to do that, in lack of a
> better name I called it page_zap_rmap. Comments ?

I don't know if it is that simple, is it?

I don't know how you are guaranteeing the given page ceases to exist.
Even checking for the last mapper of the page (which you don't appear
to do anyway) isn't enough because there could be a swapcount, in which
case you should still have to mark the page as dirty.

For example (I think, unless s390 somehow propogates the dirty page
bit some other way that I've missed), wouldn't the following break:

process p1 allocates anonymous page A
p1 dirties A
p1 forks p2, A now has a mapcount of 2
p2 VM_LOCKs A (something to prevent it being swapped)
page reclaim unmaps p1's pte, fails on p2
p2 exits, page_dirty does not get checked because of this patch
page has mapcount 0, PG_dirty is clear
Page reclaim can drop it without writing it to swap


Or am I misunderstanding something?

As far as the general idea goes, it might be possible to avoid the
check somehow, but you'd want to be pretty sure of yourself before
diverging the s390 path further from the common code base, no?

The "easy" way to do it might be just unconditionally mark the page
as dirty in this path (if the pte was writeable), so you can avoid
the page_test_dirty check and be sure of not missing the dirty bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
