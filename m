Date: Tue, 6 Feb 2001 10:39:23 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] thinko in mm/filemap.c (242p1)
In-Reply-To: <20010206135857.J18574@jaquet.dk>
Message-ID: <Pine.LNX.4.21.0102061038030.22906-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 6 Feb 2001, Rasmus Andersen wrote:

> On Tue, Feb 06, 2001 at 10:51:05AM -0200, Rik van Riel wrote:
> > On Tue, 6 Feb 2001, Rasmus Andersen wrote:
> [...]
> > 
> > I guess the writeout_one_page schedules the dirty pages for IO
> > and puts them on the list of locked pages. The last call then
> > waits on those same pages until they've been flushed to disk.
> > 
> > Your change would wait on the pages but never submit them for
> > IO (again, a guess, I haven't looked at the code in too much
> > detail).
> 
> The total function (generic_buffer_fdatasync) (with my patch):
> 
>         /* writeout dirty buffers on pages from both clean and dirty lists */
>         retval = do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx, 
> end_idx, writeout_one_page);
>         retval |= do_buffer_fdatasync(&inode->i_mapping->clean_pages, start_idx,
>  end_idx, writeout_one_page);
>         retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx
> , end_idx, writeout_one_page);
> 
>         /* now wait for locked buffers on pages from both clean and dirty lists 
> */
>         retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx,
>  end_idx, waitfor_one_page);
>         retval |= do_buffer_fdatasync(&inode->i_mapping->clean_pages, start_idx,
>  end_idx, waitfor_one_page);
>         retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx
> , end_idx, waitfor_one_page);
> 
> 
> So we start the writeout in the three first lines and wait for them in
> the last three. Without my patch we write dirty_pages out again in the
> second run.

Pages written in the first run will be moved to the locked list. 

No big deal, but its not a critical bug right now.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
