Date: Thu, 29 Jun 2000 14:44:08 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.4 / 2.5 VM plans
Message-ID: <20000629144408.R3473@redhat.com>
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Sun, Jun 25, 2000 at 12:51:42AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jun 25, 2000 at 12:51:42AM -0300, Rik van Riel wrote:
> 
> since I've heard some rumours of you folks having come
> up with nice VM ideas at USENIX and since I've been
> working on various VM things (and experimental 2.5 things)
> for the last months, maybe it's a good idea to see which
> of your ideas have already been put into code and to see
> which ideas fit together or are mutually exclusive.  :)

Right. :-)  The following includes a lot of the stuff that Ben and I
bashed out at Usenix.

I don't count this as new feature stuff --- most of what follows is
just identifying places where the current VM is plain broken!

> 1) re-introduce page aging,

OK.  
 
> 2) fix the latency problems of applications calling shrink_mmap
>    and flushing infinite amounts of pages  (mostly fixed)

Right, but it can't be _that_ hard to keep a persistent track of how
much of the cache has changed since the last time you looked at it.
We ought to be able to be much more aggressive about pruning
unnecessary lru list walks.

> 3) separate page replacement (page aging) and page flushing,

YES!!!.  But then again I just said as much on linux-mm in reply to
another recent post.  :-)

> 4) fix balance_dirty() to include inactive pages

No.  balance_dirty() and page cache dirty page management are
completely different.  Utterly different.  balance_dirty() only has
business doing early flush and/or flow control on buffer_heads,
nothing else.  (At least not until we have a write-behind mechanism
for pages which is independent of the buffer cache; say, if NFS
write-behind gets integrated into the mainstream write-behind code.)

> 5) implement some form of write throttling for VMAs so it'll be
>    impossible for big mmap()s, etc, to competely fill memory
>    with dirty pages

Right.  This is necessary, but is orthogonal to the other problems.  A
large part of (5) comes for free, however, if we are strict about
keeping a minimum (load-dependent) number of clean, unmapped pages
around on the VM's clean lru-list; separating out page aging and
unmapping from the flushing code fixes a lot of this anyway by
preventing dirty pages from occupying the whole of memory.

Other things to consider:

* The page aging loops need to have early break-out when 
  the number of free pages suddenly increases (exit, munmap,
  whatever);

* The page stealer shouldn't block just because kswapd is blocked on
  synchronous swapping (this comes for free if we have separate page
  flushing)

* shrink_dentry should probably skip inodes which have still got pages
  attached, as otherwise we get a lot of unnecessary cache flushes

* We MUST quantify the current VM pressure as a way of controlling
  page aging.  That way aging can be proactive under load, but we
  don't necessarily have to evict pages from memory too early (we can 
  age pages without flushing them).

* RSS accounting needs to be audited.  Right now, the per-mm rss isn't
  an atomic type, and it doesn't seem to be consistently protected by
  the page table locks.


A few other ideas Ben and I threw about are much more long-term.  

1) We think it should be possible to share page tables for
   large shared mmaps (think of libc and big sysv shm segments).  

2) We can do reverse pte maps pretty cheaply by the following:

* Reverse maps for shared mmaps are easy enough by following the
  per-inode vma list

* The pte for unshared anon pages can be encoded in the page struct
  easily.

* Shared anon pages are the tricky ones; but it's simple to maintain a
  hash list of all such ptes, and there aren't many in a typical
  system.  Fork() is, of course, the one place where lots of these
  occur, but we can minimise the number of shared anon pages over
  fork by implementing COW on page tables (that way, we share the page
  tables but NOT the pages!)

3) Think about having a list of all page tables in memory.  With
   that, we can do aging in the VM without *EVER* having to walk
   through vmas at all: we can walk through the ptes in the system
   performing atomic bitops on the ptes and age counts without caring
   about the higher level layers until a given page's age reaches
   zero.  Only at that point do we care about invoking the swapper
   for that page's vma.

Food for thought.  3) in particular seems to open up a whole new set
of possibilities, but it's definitely something for an experimental
post-2.4 branch.  :-)

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
