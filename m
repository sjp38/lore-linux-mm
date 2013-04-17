Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id BFEE06B00B1
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 13:56:42 -0400 (EDT)
Received: by mail-da0-f54.google.com with SMTP id p1so890472dad.41
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 10:56:42 -0700 (PDT)
Message-ID: <516EE256.2070303@linaro.org>
Date: Wed, 17 Apr 2013 10:56:38 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: LSF-MM Volatile Ranges Discussion Plans
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Minchan Kim <minchan@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Paul Turner <pjt@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>

LSF-MM Volatile Ranges Discussion Plans
=======================================

Just wanted to send this out to hopefully prime the discussion at
lsf-mm tomorrow (should the schedule hold). Much of it is background
material we won't have time to cover.

First of all, this is my (John's) perspective here, Minchan may
disagree with me on specifics here, but I think it covers the desired
behavior fairly well, and I've tried to call out the places where
we currently don't yet agree.


Volatile Ranges:
----------------

Idea is from Android's ashmem feature (originally by Robert Love),
which allows for unpinned ranges.

I've been told other OSes support similar functionality
(VM_FLAGS_PURGABLE and  MEM_RESET/MEM_RESET_UNDO).

Been slow going last 6-mo on my part, due to lots of adorable
SIGBABY interruptions & other work.


Concept in general:
-------------------

Applications marks memory as volatile, allowing kernel to purge
that memory if and when its needed. Applications can mark memory as
non-volatile, and kernel will return a value to notify them if memory
was purged while it was volatile.


Use cases:
----------

Allows for eviction of userspace cache by the kernel, which is nice
as applications don't have to tinker with optimizing cache sizes,
as the kernel which has the global view will optimize it for them.

Marking  obscured bitmaps of rendered image data volatile. Ie: Keep
compressed jpeg around, but mark volatile off-screen rendered bitmaps.

Marking non-visible web-browser tabs as volatile.

Lazy freeing of heap in malloc/free implementations.


Parallel ways of thinking about it:
-----------------------------------

Also similar to MADV_DONTNEED, but eviction is needs based, not
instantaneous. Also applications can cancel eviction if it hasn't
happened (by setting non-volatile).  So sort of delayed and cancel-able
MADV_DONTNEED.

Can consider it like swapping some pages to /dev/null ?

Rik's MADV_FREE was vary similar, but with implicit NON_VOLATILE
marking on page-dirtying.


Two basic usage-modes:
----------------------

1)  Application explicitly unmarks memory as volatile whenever it
uses it, never touching memory marked volatile.

     If memory is purged, applications is notified when it marks the
     area as non-volatile.

2) Applications may access memory marked volatile, but should it
access memory that was purged, it will receive SIGBUS

     On SIGBUS, application has to mark needed range as non-volatile,
     regenerate or re-fetch the data, and then can continue.

     This is a little more optimistic, but applications need to be
     able to handle getting a SIGBUS and fixing things up.

     This second optimistic method is desired by Mozilla folks.


Important Goals:
----------------

Applications using this likely to mark and unmark ranges
frequently (ideally only marking the data they immediately need as
nonvolatile). This makes it necessary for these operations to be cheap,
since applications won't volunteer their currently unused memory to
the kernel if it adds dramatic overhead.  Although this concerned is
lessened with the optimistic/SIGBUS usage-mode.

Overall, we try to push costs from the mark/unmark paths to the page
eviction side.



Two basic types of volatile memory:
-----------------------------------

1) File based memory

2) Anonymous memory


Volatile ranges on file memory:
-------------------------------

This allows for using volatile ranges on shared memory between
processes.

Very similar to ashmem's unpinned pages.

One example: Two processes can create a large circular buffer, where
any unused memory in that buffer is volatile. Producer marks memory
as non-volatile, writes to it. The consumer would read the data,
then mark it volatile.

An important distinction here is that the volatility is shared,
in the same way the file's data is shared. Its a property of the
file's pages, not a property of the process that marked the range as
volatile. Thus one application can mark file data as volatile, and
the pages could be purged from all applications mapping that data.
And a different application could mark it as non-volatile, and that
would keep it from being purged from all applications.

For this reason, the volatility is likely best to be stored on
address_space (or otherwise connected to the address_space/inode).

Another important semantic: Volatility is cleared when all fd's to
a file are closed.

     There's no really good way for volatility to persist when no one
     is using a file.

     It could cause confusion if an application died leaving some
     file data volatile, and then had that data disappear as it was
     starting up again.

     No volatility across reboots!


[TBD]: For the most-part, volatile ranges really only makes sense to
me on tmpfs files. Mostly due to semantics of purging data on files
is similar to hole punching, and I suspect having the resulting hole
punched pushed out to disk would cause additional io and load. Partial
range purging could have strange effects on resulting file.

[TBD]: Minchan disagrees and thinks fadvise(DONTNEED) has problems,
as it causes immediate writeout when there's plenty of free memory
(possibly unnecessary). Although we may defer so long that the hole
is never punched, which may be problematic.



Volatile ranges on anonymous/process memory:
--------------------------------------------

For anonymous memory, its mostly un-shared between processes (except
copy-on-write pages).

The only way to address anonymous memory is really relative to the
process address space (its anonymous: there's no named handle to it).

Same semantics as described above. Mark region of process memory
volatile, or non-volatile.

Volatility is a per-proecess (well mm_struct) state.

Kernel will only purge a memory page, if *all* the processes that
map that page in consider the page volatile.

Important semantics: Preserve volatility over a fork, but clear child
volatility on exec.

     So if a process marks a range as volatile then forks. Both
     the child and parent should see the same range as volatile.
     On memory pressure, kernel could purge those pages, since all of
     the processes that map that page consider it volatile.

     If the child writes to the pages, the COW links are broken, but
     both ranges ares still volatile, and can be purged until they
     are marked non-volatile or cleared.

     Then like mappings and the rest of memory, volatile ranges are
     cleared on exec.


Implementation history:
-----------------------

File-focused (John): Interval tree connected to address_space w/ global
LRU of unpurged volatile ranges. Used shrinker to trigger purging
off the lru. Numa folks complained that shrinker is numa-unaware and
would cause purging on nodes not under pressure.

File-focused (John): Checking volatility at page eviction time. Caused
problems on swap-free systems, since tmpfs pages are anonymous and
aren't aged/shrunk off lrus. In order to handle that we moved the
pages to a volatile lru list, but that causes volatile/non-volatile
operations to be very expensive O(n) for number of pages in the range.

Anon-focused (Minchan): Store volatility in VMA. Worked well for
anonymous ranges, but was problematic to extend to file ranges as
we need volatility state to be connected with the file, not the
process. Iterating across and splitting VMAs was somewhat costly.

Anon-focused (Minchan): Store anonymous volatility in interval tree
off of the mm_struct. Use global LRU of volatile ranges to use when
purging ranges via a shrinker. Also hooks into normal eviction to
make sure evicted pages are purged instead of swapped out. Very fast,
due to quick manipulations to a single interval tree.  File pages in
ranges are ignored.

Both (John): Same as above, but mostly extended so interval tree
of ranges can be hung off of the mm_struct OR an address_space.
Currently functionality is partitioned so volatile ranges on files and
on anonymous memory are created via separate syscalls (fvrange(fd,
start, len, ...) vs mvrange(start_addr, len,...)).  Roughly merges
the original first approach with the previous one.

Both (John): Currently working on above, further extending mvrange()
so it can also be used to set volatility on MAP_SHARED file mappings
in an address space. Has the problem that handling both file and
anonymous memory types in a single call requires iterating over vmas,
which makes the operation more expensive.

[TBD]: Cost impact of mvrange() supporting mapped file pages vs dev
confusion of it not supporting file pages



Current interfaces:
-------------------

Two current interfaces:
     fvrange(fd, start_off, length, mode, flags, &purged)

     mvrange(start_addr, length, mode, flags, &purged)


fd/start/length:
     Hopefully obvious :)

mode:
     VOLATILE: Sets range as volatile. Returns number of bytes marked
     volatile.

     NON_VOLATILE: Marks range as non-volatile. Returns number of bytes
     marked non-volatile, sets purged value to 1 if any memory in the
     bytes marked non-volatile were purged.

flags:
     VRANGE_FULL: On eviction, the entire range specified will be purged

     VRANGE_PARTIAL: On eviction, we may purge only part of the
     specified range.

     In earlier discussions, it was deemed that if any page in
     a volatile range was purged, we might as well purge the entire
     range, since if we mark any portion of that range as non-volatile,
     the application would have to regenerate the entire range. Thus
     we might as well reduce memory pressure by puring the entire range.

     However, with the SIGBUS semantics, applications may be able to
     continue accessing pages in a volatile range where one unused
     page is purged, so we may want to avoid purging the entire range
     to allow for optimistic continued use.

     Additionally partial purging is helpful so that we don't over-react
     when we have slight memory pressure. An example, if we have a
     64M vrange, and the kernel only needs 8M, its much cheaper to
     free 8M now and then later when the range is marked non-volatile,
     re-allocate only 8M (fault + allocation + zero-clearing) instead
     of the entire 64M.

     [TBD]: May consider merging flags w/ mode: ie: VOLATILE_FULL,
     VOLATILE_PARTIAL, NON_VOLATILE

     [TBD]: Might be able to simplify and go with VRANGE_PARTIAL all
     the time?

purged:
     Flag that returns 1 if any pages in the range marked
     NON_VOLATILE were purged. Is set to zero otherwise. Can be null
     if mode==VOLATILE.

     [TBD]: Might consider value passed to it will be |'ed with 1?.

     [TBD]: Might consider purged to be more of a status bitflag,
     allowing vrange(VOLATILE) calls to get some meaningful data like
     if memory pressure is currently going on.


Return value:
     Number of bytes marked VOLATILE or NON_VOLATILE. This is necessary
     as if we are to deal with setting ranges that cross anonymous and
     file backed pages, we have to split the operations up into multiple
     operations against the respective mm_struct or addess_space, and
     there's a possibility that we could run out of memory mid-way
     through an operation.  If we do run out of memory mid way, we
     simply return the number of bytes successfully marked, and we
     can return an error on the next invocation if we hit the ENOMEM
     right away.

     [TBD]: If mvrange() doesn't affect mapped file pages, then the
     return value can be simpler.



Current TODOs:
--------------

Add proper SIGBUS signaling when accessing purged file ranges.

Working on handling mvrange() ranges that cross anonymous and mapped
file regions.

Handle errors mid-way through operations.

Cleanups and better function names.



[TBD] Contentious interface issues:
-----------------------------------

Does handling mvrange() calls that cross anonymous & file pages
increase costs too much for ebizzy workload Minchan likes?

     Have to take mmap_sem and traverse vmas.

     Could mvrange() on file pages not be shared in the same way as
     in fvrange()

     Sane interface vs Speed?

Minchan's idea of mvrange(VOLATILE_FILE|VOLATILE_ANON|VOLATILE_BOTH):

     Avoid traversing vmas on VOLATILE_ANON flag, regardless of if
     range covers mapped file pages

     Not sure we can throw sane errors without checking vmas?

Do we really need a new syscall interface?

     Can we maybe go back to using madvise?

     Should mvrange be prioritized over fvrange, if mvrange can create
     volatile ranges on files.

Some folks still don't like SIGBUS on accessing a purged volatile page,
instead want standard zero-fill fault.

     Need some way to know page was dropped (zero is a valid data value)

     After marking non-volatile, it can be zero-fill fault.


[TBD] Contentious implementation issues:
----------------------------------------

Still using shrinker for purging, got early complaints from NUMA folks

     Can make sure we check first page in each range and purge only
     ranges where some page is in the zone being shrinked?

     Still use shrinker, but also use normal page shrinking path,
     but check for volatility. (swapless still needs shrinker)

Probably don't want to actually hang vrange interval tree (vrange_root)
off of address_space and struct_mm.

     In earlier attempts I used a hashtable to avoid this
         http://thread.gmane.org/gmane.linux.kernel/1278541/focus=1278542

     I assume this is still a concern?


Older non-contentious points:
-----------------------------

Coalescing of ranges: Don't do it unless the ranges overlaps

Range granular vs page granular purging: Resolved with _FULL/_PARTIAL
flags


Other ideas/use-cases proposed:
-------------------------------

PTurner: Marking deep user-stack-frames as volatile to return that
memory?

Dmitry Vyukov: 20-80TB allocation, marked volatile right away. Never
marking non-volatile.

     Wants zero-fill and doesn't want SIGBUG

     https://code.google.com/p/thread-sanitizer/wiki/VolatileRanges


Misc:
----
Previous discussion: https://lwn.net/Articles/518130/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
