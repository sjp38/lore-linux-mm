Date: Thu, 24 Feb 2000 15:42:11 +0100
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: mmap/munmap semantics
Message-ID: <20000224154210.A7129@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de> <14516.11124.729025.321352@dukat.scot.redhat.com> <20000224033502.B6548@pcep-jamie.cern.ch> <14517.8311.194809.598957@dukat.scot.redhat.com> <38B52CC0.7AC1169E@intermec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <38B52CC0.7AC1169E@intermec.com>; from lars brinkhoff on Thu, Feb 24, 2000 at 02:06:08PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lars brinkhoff <lars.brinkhoff@intermec.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

lars brinkhoff wrote:
> >From a FreeBSD man page at
> http://dorifer.heim3.tu-clausthal.de/cgi-bin/man/madvise.2.html

I like the FreeBSD best, of all the man page snippets posted recently.
Everything it does is actually useful.  It's unfortunate that different
systems define MADV_DONTNEED differently though..

Let's run through useful behaviours one by one.

1. A hint to the VM system: I've finished using this data.  If it's
   modified, you can write it back right away.  If not, you can discard
   it.  FreeBSD's MADV_DONTNEED does this, but DU's doesn't.

FreeBSD:
>  MADV_DONTNEED    Allows the VM system to decrease the in-memory priority
>                   of pages in the specified range.  Additionally future
>                   references to this address range will incur a page
>                   fault.

   To avoid ambiguity, perhaps we could call this one MADV_DONE?

   In BSD compatibility mode, Glibc would define MADV_DONTNEED to be
   MADV_DONE.  In standard mode it would not define MADV_DONTNEED at all.

2. Zeroing a range in a private map.  DU's MADV_DONTNEED does this --
   that's my reading of the man page.

Digital Unix: (?yes)
>   MADV_DONTNEED   Do not need these pages
>                   The system will free any whole pages in the specified
>                   region.  All modifications will be lost and any swapped
>                   out pages will be discarded.  Subsequent access to the
>                   region will result in a zero-fill-on-demand fault as
>                   though it is being accessed for the first time.
>                   Reserved swap space is not affected by this call.

   For Linux, simply read /dev/zero into the selected range.  The kernel
   already optimises this case for anonymous mappings.

   If doing it in general turns out to be too hard to implement, I
   propose MADV_ZERO should have this effect: exactly like reading
   /dev/zero into the range, but always efficient.

3. Zeroing a range in a shared map.

   I have no idea if DU's MADV_DONTNEED has this effect, or whether it
   only has this effect on shared anonymous mappings.

   In any case, reading /dev/zero into the range will always have the
   desired effect, and Stephen's work will eventually make this
   efficient on Linux.

   Again, if the kiobuf work doesn't have the desired effect, I propose
   MADV_ZERO should be exactly like reading /dev/zero into the range,
   and efficiently if the underlying mapped object can do so
   efficiently.

4. Deferred freeing of pages.  FreeBSD's MADV_FREE does this, according
   to the posted manual snippet.  I like this very much -- it is perfect
   for a wide variety of memory allocators.

FreeBSD:
>  MADV_FREE        Gives the VM system the freedom to free pages, and tells
>                   the system that information in the specified page range
>                   is no longer important.  This is an efficient way of al-
>                   lowing malloc(3) to free pages anywhere in the address
>                   space, while keeping the address space valid.  The next
>                   time that the page is referenced, the page might be de-
>                   mand zeroed, or might contain the data that was there
>                   before the MADV_FREE call.  References made to that ad-
>                   dress space range will not make the VM system page the
>                   information back in from backing store until the page is
>                   modified again.

   I like this so much I started coding it a long time ago, as an
   mdiscard syscall.  But then I got onto something else.

   The principle here is very simple: MADV_FREE marks all the pages in
   the region as "discardable", and clears the accessed and dirty bits
   of those pages.

   Later when the kernel needs to free some memory, it is permitted to
   free "discardable" pages immediately provided they are still not
   accessed or dirty.  When vmscan is clearing the accessed and dirty
   bits on pages, if they were set it must clear the " discardable" bit.

   This allows malloc() and other user space allocators to free pages
   back to the system.  Unlike DU's MADV_DONTNEED, or mmapping
   /dev/zero, if the system does not need the page there is no
   inefficient zero-copy.  If there was, malloc() would be better off
   not bothering to return the pages.

   The FreeBSD man page seems ambiguous about the effect on a shared
   mapping: is the underlying page marked "discardable", or just the
   page table entry in this particular vm mapping?

   Also I note that the page is always zero filled if it was discarded.
   That's fine for anonymous mappings.

   For mapped files, is MADV_FREE permitted at all?  If so, should
   discarding the page replace it with a zero page, or with the
   underlying file's page before private modifications?

   I propose this is a useful behaviour, and MADV_FREE is a fine name.
   Alternatively, MADV_RESTORE if the behaviour is defined in terms of
   discarding private modifications, just as if you had re-done the
   mmap() in the region.  For private anonymous mappings the behaviours
   are equivalent; for file mappings, they are not.


Summary
-------

Four handy behaviours.

  1. MADV_DONE
  2. MADV_ZERO or read /dev/zero
  3. MADV_ZERO or read /dev/zero
  4. MADV_FREE and/or MADV_RESTORE

have a nice day,
-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
