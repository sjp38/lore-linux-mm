Date: Fri, 08 Oct 2004 16:00:28 +0900 (JST)
Message-Id: <20041008.160028.22497637.taka@valinux.co.jp>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041007120605.GA13779@logos.cnet>
References: <20041004172427.GL16374@logos.cnet>
	<20041005.115347.95910198.taka@valinux.co.jp>
	<20041007120605.GA13779@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Marcelo.

> It seems there is typo in the current version of the patch:
> 
> int try_to_migrate_pages(struct list_head *page_list)
> {
> ...
>         current->flags |= PF_KSWAPD;    /*  It's fake */
>         list_for_each_entry_safe(page, page2, page_list, lru) {
>                 /*
>                  * Start writeback I/O if it's a dirty page with buffers
>                  * and it doesn't have migrate_page method.
>                  */
>                 if (PageDirty(page) && PagePrivate(page)) {
>                         if (!TestSetPageLocked(page)) {
>                                 mapping = page_mapping(page);
>                                 if (!mapping || mapping->a_ops->migrate_page ||
a> 						^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>                                     pageout(page, mapping) != PAGE_SUCCESS) {
>                                         unlock_page(page);
>                                 }
>                         }
>                 }
> 
> 
> Shouldnt that be "!mapping->a_ops->migrate_page"?

"mapping->a_ops->migrate_page" is correct.

This code is just for optimization. If mapping->a_ops->migrate_page
isn't implemented, migrate_page_common() is used to migrate the page.
migrate_page_common() will try to write it back if it's dirty, so that
it would be better to start writeback I/O for target pages in advance
without waiting the I/O completions.

As you may know the migration code will work fine without this code.

> That is, if we can't migrate the page, try to write it out?

Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
