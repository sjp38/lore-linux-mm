Date: Fri, 9 Jun 2000 14:23:29 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <007501bfd233$288827c0$0a1e17ac@local>
Message-ID: <Pine.LNX.4.21.0006091410100.31358-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jun 2000, Manfred Spraul wrote:

> > This is exactly what one global LRU will achieve, at less
> > cost and with better readable code.
>
> You are right, but what will you do with pinned pages once they
> reach the end of the LRU? Will you drop them from the LRU, or
> will you add them to the beginning?

We will ask the filesystem to write out data and unpin this
block. If it doesn't, we'll ask again next time, ....

Note that this is essentially harmless since we only ask the
filesystem to clean up pages so they can be unpinned, we are
in no way asking the filesystem to free used pages...

> AFAICS a few global LRU lists [your inactive, active, scavenge
> (sp?) lists] should work, but I don't understand yet how you
> want to prevent that one grep over the kernel tree will push
> everyone else into swap.

Ahh, but the swap and filesystem IO will be triggered from the
end of the _inactive_ list. We will unmap pages and allocate
swap earlier on, but we won't actually do any of the IO...

> Is the active list also a LRU list? AFAICS we don't have the
> reverse mapping "struct page ->all pte's", so we cannot push a
> page once it reaches the end of the LRU. AFAIK BSD has that
> reverse mapping (Please correct me if I'm wrong). IMHO an LRU
> won't help us.

The active list will probably have to be what our current
swap_out/shrink_mmap combo does. In 2.5 we can add the
changes needed to do reverse mapping, but until then we'll
probably have to leave this kludge ;(

> Level 1 (your active list): the page users such as * mmapped
> pages, annon pages, mapped shm pages: they are unmapped by
> mm/vmscan.c. vma->swapout() should add them to the level 2 list.
>
> * a tiny hotlist for the page & buffer cache, otherwise we have
> "spin_lock();list_del(page);list_add(page,list_head);spin_unlock()"
> during every operation. Clock algorithm with a referenced bit.

Not so fast ... this is the only level where we do page aging, so
we don't want to move the pages to the inactive list too fast. When
we first unmap a page, it'll get added to the list and start out
with a certain page age, after which aging has to happen for it to
be moved to the inactive list...

> Level 2: (your inactive list)
> * unmapped pages LRU list 1 [pages can be dirty or clean]. At
> the end of this list, page->a_ops->?? is called, and the page is
> dropped from the list. The memory owner adds it to the level 3
> list once it's clean.

The operation we call is basically only there to get the page
cleaned and the buffers removed. We try to keep a certain number
of inactive pages around so we'll always have something to reclaim
and page aging is balanced.

> Level 3: (your scavenge list)
> * LRU list of clean pages, ready for immediate reclamation.
> gfp(GFP_WAIT) takes the oldest entry from this list.

*nod*

> Level 4:
> free pages in the buddy. for GFP_ATOMIC allocations, and for
> multi page allocations.

*nod*  (and for PF_MEMALLOC allocations)

> Pages in Level 2 and 3 are never "in use", i.e. never reachable
> from user space, or read/written by generic_file_{read,write}.
> The page owner can still reclaim them if a soft pagefault
> occurs. File pages are still in the page cache hash table, shm &
> anon pages are reachable through the swap cache.

Yes.

> Level 2 could be split in 2 halfs, clean pages are added in the
> middle. [reduces IO]

We do something like this, but splitting the list in half is,
IMHO not a good idea. What we do instead is:
- walk the list, reclaiming free pages
- if we didn't get enough, walk the list again and start
  (async?) IO on a number of dirty pages
- if we didn't get enough free pages after the second run
  (unlikely at the moment, but some page->mapping->flush()
  functions we may want to make synchronous later...) we
  kick bdflush/kflushd in the nuts so we'll have enough
  free pages next time

> The selection between the Level 1 page holders could be made on
> their "reanimate rate": if one owner often request pages from
> Level 2 or 3 back, then we reap him too often.

That's what page aging is for.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
