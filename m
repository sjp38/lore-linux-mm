Date: Sat, 18 Aug 2001 15:22:57 -0700 (PDT)
From: Ted Unangst <tedu@stanford.edu>
Subject: Re: help for swap encryption
In-Reply-To: <20010818195312.I9870@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.GSO.4.31.0108181436010.5751-100000@cardinal0.Stanford.EDU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 Aug 2001, Ingo Oeser wrote:

[complaint about filesystem code]
> No. address_space_operations is the interface.

Rik initially told me to come in at rw_swap_page_base().  but the real
work is done by calling brw_page(rw, page, dev, zones, block_size).  which
lives in fs/buffer.c.  but all the pages coming and going to the disk go
through here, so this is where i want to hook in.

address_space_operations:writepage -> swap_writepage -> rw_swap_page ->
rw_swap_page_base().  pretty much wrappers.  until it calls submit_bh
which i couldn't find source for.  but by now we're way out of the mm/
code, and i don't want to mess with it.


> > well, hopefully, it won't be too much trouble to help me.  i know you're
> > busy.  :)  someone else?
>
> I have spend some time thinking about this. We have the
> address_space_operations for this. You can encrypt/decrypt while
> your page is locked for IO and set a flag on your page. So you
> decrypt or zero on readpage and encrypt on writepage.
>
> Later you just read/write with the "inherited" function from the
> swap_aops (in mm/swap_stat.c). How does that sound?

rw_swap_page might be a little cleaner.  it's the "gateway" as far as i
can tell.  last function to touch the page going out, and first to touch
it coming in.

> Another problem is, that you need to encrypt/decrypt IN PLACE,
> which is not possible with the current cryptoapi, or have to
> copy data around in PAGEs (which costs performance).

i was going to use my own crypto routines, at first, just to make it work.
but this is the real problem i see coming up.  where (in memory) do we do
these operations?  in place would be easiest, but it means not keeping the
page in swap cache.  if we move it somewhere else, that somewhere else
needs RAM too.  dynamic allocation won't work because if we're swapping
out, we probably don't have much memory to spare.  so we need to
preallocate a buffer.  i fear this will lead to ungodly performance.
imagine swapping in with a buffer of X.  read X pages, then you have to
stop until they decrypt.  then read X more.

> If you encrypt in place, then you cannot allow two instances. You
> have to require a readpage after every writepage of the same
> page. But this shouldn't happen that often...

is it possible to keep pages from going in the swap cache?  in practice,
if we just sent the page to disk, aren't we going to free it anyway and
use it for some other purpose?

btw:  this should be obvious, but i'm missing it.  i have a page struct
that i pass to encrypt_page(page).  how do i access the memory with
pointers?  at some point, i need to acces the page as a big array.

thanks for help.  (please excuse VM naivity.  :))

ted




--
"The contagious people of Washington have stood firm against diversity
during this long period of increment weather."
      - M. Barry Mayor of Washington, DC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
