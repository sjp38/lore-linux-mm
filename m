Date: Thu, 7 Oct 2004 09:06:05 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041007120605.GA13779@logos.cnet>
References: <20041003140723.GD4635@logos.cnet> <20041004.033559.71092746.taka@valinux.co.jp> <20041004172427.GL16374@logos.cnet> <20041005.115347.95910198.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041005.115347.95910198.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 05, 2004 at 11:53:47AM +0900, Hirokazu Takahashi wrote:

> It was the easiest way to handle pages with buffers when Iwamoto
> and I started to implement it. We thought it was slow but it would
> work for all kinds of filesystems.
> 
> > We're just trying to migrate pages to another zone. 
> > 
> > If its under writeout, wait, if its dirty, just move it to the other
> > zone.
> > 
> > Can you enlight me?
> 
> Yes, I also realize that.
> migrate_page_buffer() will do this, but I'm not certain it will work
> for all kinds of filesystems. I guess there might be some exceptions.
> We may need a special operation to handle pages on a filesystem,
> which has releasepage method.

It seems there is typo in the current version of the patch:

int try_to_migrate_pages(struct list_head *page_list)
{
...
        current->flags |= PF_KSWAPD;    /*  It's fake */
        list_for_each_entry_safe(page, page2, page_list, lru) {
                /*
                 * Start writeback I/O if it's a dirty page with buffers
                 * and it doesn't have migrate_page method.
                 */
                if (PageDirty(page) && PagePrivate(page)) {
                        if (!TestSetPageLocked(page)) {
                                mapping = page_mapping(page);
                                if (!mapping || mapping->a_ops->migrate_page ||
						^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                    pageout(page, mapping) != PAGE_SUCCESS) {
                                        unlock_page(page);
                                }
                        }
                }


Shouldnt that be "!mapping->a_ops->migrate_page"?

That is, if we can't migrate the page, try to write it out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
