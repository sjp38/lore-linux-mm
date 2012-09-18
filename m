Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 757C66B0078
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 05:58:12 -0400 (EDT)
Date: Tue, 18 Sep 2012 10:58:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Does swap_set_page_dirty() calling ->set_page_dirty() make sense?
Message-ID: <20120918095808.GJ11266@suse.de>
References: <20120917163518.GD9150@quack.suse.cz>
 <alpine.LSU.2.00.1209171204100.6720@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1209171204100.6720@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Mon, Sep 17, 2012 at 12:15:46PM -0700, Hugh Dickins wrote:
> On Mon, 17 Sep 2012, Jan Kara wrote:
> > 
> >   I tripped over a crash in reiserfs which happened due to PageSwapCache
> > page being passed to reiserfs_set_page_dirty(). Now it's not that hard to
> > make reiserfs_set_page_dirty() check that case but I really wonder: Does it
> > make sense to call mapping->a_ops->set_page_dirty() for a PageSwapCache
> > page? The page is going to be written via direct IO so from the POV of the
> > filesystem there's no need for any dirtiness tracking. Also there are
> > several ->set_page_dirty() implementations which will spectacularly crash
> > because they do things like page->mapping->host, or call
> > __set_page_dirty_buffers() which expects buffer heads in page->private.
> > Or what is the reason for calling filesystem's set_page_dirty() function?
> 
> This is a question for Mel, really: it used not to call the filesystem.
> 

And now it should only be called if SWP_FILE is set to perform read/write
of pages through the filesystem. In practice I only expect this to happen
when a swapfile is activated on NFS.

> But my reading of the 3.6 code says that it still will not call the
> filesystem, unless the filesystem (only nfs) provides a swap_activate
> method, which should be the only case in which SWP_FILE gets set.
> And I rather think Mel does want to use the filesystem set_page_dirty
> in that case.  Am I misreading?
> 

That was the intention at least.

> Did you see this on a vanilla kernel?  Or is it possible that you have
> a private patch merged in, with something else sharing the SWP_FILE bit
> (defined in include/linux/swap.h) by mistake?
> 

I see that Jan followed up that this was observed on SLES. The
implementaiton there is based on a much earlier revision of
swap-over-NFS than what was finally merged to mainline. I'll check it
out.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
