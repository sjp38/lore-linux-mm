Date: Tue, 6 Feb 2001 10:51:05 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] thinko in mm/filemap.c (242p1)
In-Reply-To: <20010206130718.F18574@jaquet.dk>
Message-ID: <Pine.LNX.4.21.0102061049450.1535-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Feb 2001, Rasmus Andersen wrote:

> The following patch fixes what I think is a cut'n'paste slipup
> in mm/filemap.c::generic_buffer_fdatasync. It applies against
> 242p1 and 241-ac3. Comments?

> -       retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx,
>  end_idx, writeout_one_page);
> +       retval |= do_buffer_fdatasync(&inode->i_mapping->dirty_pages, start_idx,

>         retval |= do_buffer_fdatasync(&inode->i_mapping->locked_pages, start_idx
> , end_idx, waitfor_one_page);

I guess the writeout_one_page schedules the dirty pages for IO
and puts them on the list of locked pages. The last call then
waits on those same pages until they've been flushed to disk.

Your change would wait on the pages but never submit them for
IO (again, a guess, I haven't looked at the code in too much
detail).

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
