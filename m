Date: Tue, 28 Mar 2000 10:58:00 -0500 (EST)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: Re: how text page of executable are shared ?
In-Reply-To: <20000328142253.A16752@redhat.com>
Message-ID: <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > The page table entries of both the process will have entry for this page.
> > But when the page is discarded only the page entry of only one process get
> > cleared , this is what I have understood from the swap_out () function .
> 
> Yes.  swap_out() is responsible for unlinking pages from process page 
> tables.  In the case you describe, the page will still have outstanding
> references, from the other process and from the page cache.  Only when
> the page cache cleanup function (shrink_mmap) gets called, after all of
> the ptes to the page have been cleared, will the page be freed.

could you comment on a problem I'm seeing in the current (pre3) VM?
the situation is a 256M machine, otherwise idle (random daemons, no X,
couple ssh's) and a process that sequentially traverses 12 40M files
by mmaping them (and munmapping them, in order, one at a time.)

the observation is that all goes well until the ~6th file, when we 
run out of unused ram.  then we start _swapping_!  the point is that 
shrink_mmap should really be scavenging those now unmapped files,
shouldn't it?

could something be happening, like we're accidentally setting PG_referenced
on pages that are only in use by the page cache?  or perhaps someone not
adjusting page_cache_size properly?

in shrink_mmap:
                /*
                 * We can't free pages unless there's just one user
                 * (count == 2 because we added one ourselves above).
                 */
                if (page_count(page) != 2)
                        goto cache_unlock_continue;

is this wrong, since the page cache holds a reference?


thanks, mark hahn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
