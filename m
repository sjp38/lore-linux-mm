Date: Fri, 8 Oct 2004 07:00:10 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041008100010.GB16028@logos.cnet>
References: <20041004172427.GL16374@logos.cnet> <20041005.115347.95910198.taka@valinux.co.jp> <20041007120605.GA13779@logos.cnet> <20041008.160028.22497637.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041008.160028.22497637.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2004 at 04:00:28PM +0900, Hirokazu Takahashi wrote:
> Hi, Marcelo.
> 
> > It seems there is typo in the current version of the patch:
> > 
> > int try_to_migrate_pages(struct list_head *page_list)
> > {
> > ...
> >         current->flags |= PF_KSWAPD;    /*  It's fake */
> >         list_for_each_entry_safe(page, page2, page_list, lru) {
> >                 /*
> >                  * Start writeback I/O if it's a dirty page with buffers
> >                  * and it doesn't have migrate_page method.
> >                  */
> >                 if (PageDirty(page) && PagePrivate(page)) {
> >                         if (!TestSetPageLocked(page)) {
> >                                 mapping = page_mapping(page);
> >                                 if (!mapping || mapping->a_ops->migrate_page ||
> a> 						^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> >                                     pageout(page, mapping) != PAGE_SUCCESS) {
> >                                         unlock_page(page);
> >                                 }
> >                         }
> >                 }
> > 
> > 
> > Shouldnt that be "!mapping->a_ops->migrate_page"?
> 
> "mapping->a_ops->migrate_page" is correct.
> 
> This code is just for optimization. If mapping->a_ops->migrate_page
> isn't implemented, migrate_page_common() is used to migrate the page.
> migrate_page_common() will try to write it back if it's dirty, so that
> it would be better to start writeback I/O for target pages in advance
> without waiting the I/O completions.

Right. But if migrate_page _is_ implemented, we also start writeback! 

Shouldnt that be "if we dont have migrate_page(), start writeback, since 
in this case well use migrate_page_common() anyway."

It seems the logic is inverted, or maybe I'm wrong.

> As you may know the migration code will work fine without this code.

OK!

> > That is, if we can't migrate the page, try to write it out?

I just didnt understand the logic very well, maybe I should just 
go reread the code.

Thanks!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
