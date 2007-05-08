From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070508114003.GB19294@wotan.suse.de> 
References: <20070508114003.GB19294@wotan.suse.de>  <20070508113709.GA19294@wotan.suse.de> 
Subject: Re: [rfc] optimise unlock_page 
Date: Tue, 08 May 2007 13:13:35 +0100
Message-ID: <9948.1178626415@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-arch@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:

> This patch trades a page flag for a significant improvement in the unlock_page
> fastpath. Various problems in the previous version were spotted by Hugh and
> Ben (and fixed in this one).

It looks reasonable at first glance, though it does consume yet another page
flag:-/  However, I think that's probably a worthy trade.

>  }
> -	
> +
> +static inline void unlock_page(struct page *page)
> +{
> +	VM_BUG_ON(!PageLocked(page));
> +	ClearPageLocked_Unlock(page);
> +	if (unlikely(PageWaiters(page)))
> +		__unlock_page(page);
> +}
> +

Please don't simply discard the documentation, we have little enough as it is:

> -/**
> - * unlock_page - unlock a locked page
> - * @page: the page
> - *
> - * Unlocks the page and wakes up sleepers in ___wait_on_page_locked().
> - * Also wakes sleepers in wait_on_page_writeback() because the wakeup
> - * mechananism between PageLocked pages and PageWriteback pages is shared.
> - * But that's OK - sleepers in wait_on_page_writeback() just go back to sleep.
> - *
> - * The mb is necessary to enforce ordering between the clear_bit and the read
> - * of the waitqueue (to avoid SMP races with a parallel wait_on_page_locked()).

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
