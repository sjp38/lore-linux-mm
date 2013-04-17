Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 88B2B6B00BF
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 16:13:13 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id fk20so1610195lab.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2013 13:13:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <516EE256.2070303@linaro.org>
References: <516EE256.2070303@linaro.org>
From: Paul Turner <pjt@google.com>
Date: Wed, 17 Apr 2013 13:12:41 -0700
Message-ID: <CAPM31RLmmCPh-FH7SDvd3tjQv-KEuaA_BDwVO9QSKqvy72_TAw@mail.gmail.com>
Subject: Re: LSF-MM Volatile Ranges Discussion Plans
Content-Type: multipart/alternative; boundary=f46d044284f87806b004da941d6a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: lsf@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Robert Love <rlove@google.com>, Dave Hansen <dave@sr71.net>, Taras Glek <tglek@mozilla.com>, Mike Hommey <mh@glandium.org>, Kostya Serebryany <kcc@google.com>

--f46d044284f87806b004da941d6a
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Apr 17, 2013 at 10:56 AM, John Stultz <john.stultz@linaro.org>wrote:

> LSF-MM Volatile Ranges Discussion Plans
> ==============================**=========
>
> Just wanted to send this out to hopefully prime the discussion at
> lsf-mm tomorrow (should the schedule hold). Much of it is background
> material we won't have time to cover.
>
> First of all, this is my (John's) perspective here, Minchan may
> disagree with me on specifics here, but I think it covers the desired
> behavior fairly well, and I've tried to call out the places where
> we currently don't yet agree.
>
>
> Volatile Ranges:
> ----------------
>
> Idea is from Android's ashmem feature (originally by Robert Love),
> which allows for unpinned ranges.
>
> I've been told other OSes support similar functionality
> (VM_FLAGS_PURGABLE and  MEM_RESET/MEM_RESET_UNDO).
>
> Been slow going last 6-mo on my part, due to lots of adorable
> SIGBABY interruptions & other work.
>
>
> Concept in general:
> -------------------
>
> Applications marks memory as volatile, allowing kernel to purge
> that memory if and when its needed. Applications can mark memory as
> non-volatile, and kernel will return a value to notify them if memory
> was purged while it was volatile.
>
>
> Use cases:
> ----------
>
> Allows for eviction of userspace cache by the kernel, which is nice
> as applications don't have to tinker with optimizing cache sizes,
> as the kernel which has the global view will optimize it for them.
>
> Marking  obscured bitmaps of rendered image data volatile. Ie: Keep
> compressed jpeg around, but mark volatile off-screen rendered bitmaps.
>
> Marking non-visible web-browser tabs as volatile.
>
> Lazy freeing of heap in malloc/free implementations.
>
>
> Parallel ways of thinking about it:
> ------------------------------**-----
>
> Also similar to MADV_DONTNEED, but eviction is needs based, not
> instantaneous. Also applications can cancel eviction if it hasn't
> happened (by setting non-volatile).  So sort of delayed and cancel-able
> MADV_DONTNEED.
>
> Can consider it like swapping some pages to /dev/null ?
>
> Rik's MADV_FREE was vary similar, but with implicit NON_VOLATILE
> marking on page-dirtying.
>
>
> Two basic usage-modes:
> ----------------------
>
> 1)  Application explicitly unmarks memory as volatile whenever it
> uses it, never touching memory marked volatile.
>
>     If memory is purged, applications is notified when it marks the
>     area as non-volatile.
>
> 2) Applications may access memory marked volatile, but should it
> access memory that was purged, it will receive SIGBUS
>
>     On SIGBUS, application has to mark needed range as non-volatile,
>     regenerate or re-fetch the data, and then can continue.
>
>     This is a little more optimistic, but applications need to be
>     able to handle getting a SIGBUS and fixing things up.
>
>     This second optimistic method is desired by Mozilla folks.
>
>
> Important Goals:
> ----------------
>
> Applications using this likely to mark and unmark ranges
> frequently (ideally only marking the data they immediately need as
> nonvolatile). This makes it necessary for these operations to be cheap,
> since applications won't volunteer their currently unused memory to
> the kernel if it adds dramatic overhead.  Although this concerned is
> lessened with the optimistic/SIGBUS usage-mode.
>
> Overall, we try to push costs from the mark/unmark paths to the page
> eviction side.
>
>
>
> Two basic types of volatile memory:
> ------------------------------**-----
>
> 1) File based memory
>
> 2) Anonymous memory
>
>
> Volatile ranges on file memory:
> ------------------------------**-
>
> This allows for using volatile ranges on shared memory between
> processes.
>
> Very similar to ashmem's unpinned pages.
>
> One example: Two processes can create a large circular buffer, where
> any unused memory in that buffer is volatile. Producer marks memory
> as non-volatile, writes to it. The consumer would read the data,
> then mark it volatile.
>
> An important distinction here is that the volatility is shared,
> in the same way the file's data is shared. Its a property of the
> file's pages, not a property of the process that marked the range as
> volatile. Thus one application can mark file data as volatile, and
> the pages could be purged from all applications mapping that data.
> And a different application could mark it as non-volatile, and that
> would keep it from being purged from all applications.
>
> For this reason, the volatility is likely best to be stored on
> address_space (or otherwise connected to the address_space/inode).
>
> Another important semantic: Volatility is cleared when all fd's to
> a file are closed.
>
>     There's no really good way for volatility to persist when no one
>     is using a file.
>
>     It could cause confusion if an application died leaving some
>     file data volatile, and then had that data disappear as it was
>     starting up again.
>
>     No volatility across reboots!
>
>
> [TBD]: For the most-part, volatile ranges really only makes sense to
> me on tmpfs files. Mostly due to semantics of purging data on files
> is similar to hole punching, and I suspect having the resulting hole
> punched pushed out to disk would cause additional io and load. Partial
> range purging could have strange effects on resulting file.
>
> [TBD]: Minchan disagrees and thinks fadvise(DONTNEED) has problems,
> as it causes immediate writeout when there's plenty of free memory
> (possibly unnecessary). Although we may defer so long that the hole
> is never punched, which may be problematic.
>
>
>
> Volatile ranges on anonymous/process memory:
> ------------------------------**--------------
>
> For anonymous memory, its mostly un-shared between processes (except
> copy-on-write pages).
>
> The only way to address anonymous memory is really relative to the
> process address space (its anonymous: there's no named handle to it).
>
> Same semantics as described above. Mark region of process memory
> volatile, or non-volatile.
>
> Volatility is a per-proecess (well mm_struct) state.
>
> Kernel will only purge a memory page, if *all* the processes that
> map that page in consider the page volatile.
>
> Important semantics: Preserve volatility over a fork, but clear child
> volatility on exec.
>
>     So if a process marks a range as volatile then forks. Both
>     the child and parent should see the same range as volatile.
>     On memory pressure, kernel could purge those pages, since all of
>     the processes that map that page consider it volatile.
>
>     If the child writes to the pages, the COW links are broken, but
>     both ranges ares still volatile, and can be purged until they
>     are marked non-volatile or cleared.
>
>     Then like mappings and the rest of memory, volatile ranges are
>     cleared on exec.
>
>
> Implementation history:
> -----------------------
>
> File-focused (John): Interval tree connected to address_space w/ global
> LRU of unpurged volatile ranges. Used shrinker to trigger purging
> off the lru. Numa folks complained that shrinker is numa-unaware and
> would cause purging on nodes not under pressure.
>
> File-focused (John): Checking volatility at page eviction time. Caused
> problems on swap-free systems, since tmpfs pages are anonymous and
> aren't aged/shrunk off lrus. In order to handle that we moved the
> pages to a volatile lru list, but that causes volatile/non-volatile
> operations to be very expensive O(n) for number of pages in the range.
>
> Anon-focused (Minchan): Store volatility in VMA. Worked well for
> anonymous ranges, but was problematic to extend to file ranges as
> we need volatility state to be connected with the file, not the
> process. Iterating across and splitting VMAs was somewhat costly.
>
> Anon-focused (Minchan): Store anonymous volatility in interval tree
> off of the mm_struct. Use global LRU of volatile ranges to use when
> purging ranges via a shrinker. Also hooks into normal eviction to
> make sure evicted pages are purged instead of swapped out. Very fast,
> due to quick manipulations to a single interval tree.  File pages in
> ranges are ignored.
>
> Both (John): Same as above, but mostly extended so interval tree
> of ranges can be hung off of the mm_struct OR an address_space.
> Currently functionality is partitioned so volatile ranges on files and
> on anonymous memory are created via separate syscalls (fvrange(fd,
> start, len, ...) vs mvrange(start_addr, len,...)).  Roughly merges
> the original first approach with the previous one.
>
> Both (John): Currently working on above, further extending mvrange()
> so it can also be used to set volatility on MAP_SHARED file mappings
> in an address space. Has the problem that handling both file and
> anonymous memory types in a single call requires iterating over vmas,
> which makes the operation more expensive.
>
> [TBD]: Cost impact of mvrange() supporting mapped file pages vs dev
> confusion of it not supporting file pages
>
>
>
> Current interfaces:
> -------------------
>
> Two current interfaces:
>     fvrange(fd, start_off, length, mode, flags, &purged)
>
>     mvrange(start_addr, length, mode, flags, &purged)
>
>
> fd/start/length:
>     Hopefully obvious :)
>
> mode:
>     VOLATILE: Sets range as volatile. Returns number of bytes marked
>     volatile.
>
>     NON_VOLATILE: Marks range as non-volatile. Returns number of bytes
>     marked non-volatile, sets purged value to 1 if any memory in the
>     bytes marked non-volatile were purged.
>
> flags:
>     VRANGE_FULL: On eviction, the entire range specified will be purged
>
>     VRANGE_PARTIAL: On eviction, we may purge only part of the
>     specified range.
>
>     In earlier discussions, it was deemed that if any page in
>     a volatile range was purged, we might as well purge the entire
>     range, since if we mark any portion of that range as non-volatile,
>     the application would have to regenerate the entire range. Thus
>     we might as well reduce memory pressure by puring the entire range.
>
>     However, with the SIGBUS semantics, applications may be able to
>     continue accessing pages in a volatile range where one unused
>     page is purged, so we may want to avoid purging the entire range
>     to allow for optimistic continued use.
>
>     Additionally partial purging is helpful so that we don't over-react
>     when we have slight memory pressure. An example, if we have a
>     64M vrange, and the kernel only needs 8M, its much cheaper to
>     free 8M now and then later when the range is marked non-volatile,
>     re-allocate only 8M (fault + allocation + zero-clearing) instead
>     of the entire 64M.
>
>     [TBD]: May consider merging flags w/ mode: ie: VOLATILE_FULL,
>     VOLATILE_PARTIAL, NON_VOLATILE
>
>     [TBD]: Might be able to simplify and go with VRANGE_PARTIAL all
>     the time?
>
> purged:
>     Flag that returns 1 if any pages in the range marked
>     NON_VOLATILE were purged. Is set to zero otherwise. Can be null
>     if mode==VOLATILE.
>
>     [TBD]: Might consider value passed to it will be |'ed with 1?.
>
>     [TBD]: Might consider purged to be more of a status bitflag,
>     allowing vrange(VOLATILE) calls to get some meaningful data like
>     if memory pressure is currently going on.
>
>
> Return value:
>     Number of bytes marked VOLATILE or NON_VOLATILE. This is necessary
>     as if we are to deal with setting ranges that cross anonymous and
>     file backed pages, we have to split the operations up into multiple
>     operations against the respective mm_struct or addess_space, and
>     there's a possibility that we could run out of memory mid-way
>     through an operation.  If we do run out of memory mid way, we
>     simply return the number of bytes successfully marked, and we
>     can return an error on the next invocation if we hit the ENOMEM
>     right away.
>
>     [TBD]: If mvrange() doesn't affect mapped file pages, then the
>     return value can be simpler.
>
>
>
> Current TODOs:
> --------------
>
> Add proper SIGBUS signaling when accessing purged file ranges.
>
> Working on handling mvrange() ranges that cross anonymous and mapped
> file regions.
>
> Handle errors mid-way through operations.
>
> Cleanups and better function names.
>
>
>
> [TBD] Contentious interface issues:
> ------------------------------**-----
>
> Does handling mvrange() calls that cross anonymous & file pages
> increase costs too much for ebizzy workload Minchan likes?
>
>     Have to take mmap_sem and traverse vmas.
>
>     Could mvrange() on file pages not be shared in the same way as
>     in fvrange()
>
>     Sane interface vs Speed?
>
> Minchan's idea of mvrange(VOLATILE_FILE|**VOLATILE_ANON|VOLATILE_BOTH):
>
>     Avoid traversing vmas on VOLATILE_ANON flag, regardless of if
>     range covers mapped file pages
>
>     Not sure we can throw sane errors without checking vmas?
>
> Do we really need a new syscall interface?
>
>     Can we maybe go back to using madvise?
>
>     Should mvrange be prioritized over fvrange, if mvrange can create
>     volatile ranges on files.
>
> Some folks still don't like SIGBUS on accessing a purged volatile page,
> instead want standard zero-fill fault.
>
>     Need some way to know page was dropped (zero is a valid data value)
>
>     After marking non-volatile, it can be zero-fill fault.
>
>
> [TBD] Contentious implementation issues:
> ------------------------------**----------
>
> Still using shrinker for purging, got early complaints from NUMA folks
>
>     Can make sure we check first page in each range and purge only
>     ranges where some page is in the zone being shrinked?
>
>     Still use shrinker, but also use normal page shrinking path,
>     but check for volatility. (swapless still needs shrinker)
>
> Probably don't want to actually hang vrange interval tree (vrange_root)
> off of address_space and struct_mm.
>
>     In earlier attempts I used a hashtable to avoid this
>         http://thread.gmane.org/gmane.**linux.kernel/1278541/focus=**
> 1278542 <http://thread.gmane.org/gmane.linux.kernel/1278541/focus=1278542>
>
>     I assume this is still a concern?
>
>
> Older non-contentious points:
> -----------------------------
>
> Coalescing of ranges: Don't do it unless the ranges overlaps
>
> Range granular vs page granular purging: Resolved with _FULL/_PARTIAL
> flags
>
>
> Other ideas/use-cases proposed:
> ------------------------------**-
>
> PTurner: Marking deep user-stack-frames as volatile to return that
> memory?
>
>
Great write-up John.

Since there's a question mark I thought I'd add a qualifier:
I think this would be specifically useful with segmented stacks.  As we
cross region boundaries we could then mark the previous region as volatile
to allow reclaim without a large re-use penalty if the stack quickly grows
again.  This is a trade-off that is typically difficult to manage.


Dmitry Vyukov: 20-80TB allocation, marked volatile right away. Never
> marking non-volatile.
>
>     Wants zero-fill and doesn't want SIGBUG
>
>     https://code.google.com/p/**thread-sanitizer/wiki/**VolatileRanges<https://code.google.com/p/thread-sanitizer/wiki/VolatileRanges>
>
>
> Misc:
> ----
> Previous discussion: https://lwn.net/Articles/**518130/<https://lwn.net/Articles/518130/>
>
>

--f46d044284f87806b004da941d6a
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Wed, Apr 17, 2013 at 10:56 AM, John Stultz <span dir=3D"ltr">&lt=
;<a href=3D"mailto:john.stultz@linaro.org" target=3D"_blank">john.stultz@li=
naro.org</a>&gt;</span> wrote:<br>


<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">LSF-MM Volatile Ranges Discussion Plans<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D<u></u>=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
<br>
Just wanted to send this out to hopefully prime the discussion at<br>
lsf-mm tomorrow (should the schedule hold). Much of it is background<br>
material we won&#39;t have time to cover.<br>
<br>
First of all, this is my (John&#39;s) perspective here, Minchan may<br>
disagree with me on specifics here, but I think it covers the desired<br>
behavior fairly well, and I&#39;ve tried to call out the places where<br>
we currently don&#39;t yet agree.<br>
<br>
<br>
Volatile Ranges:<br>
----------------<br>
<br>
Idea is from Android&#39;s ashmem feature (originally by Robert Love),<br>
which allows for unpinned ranges.<br>
<br>
I&#39;ve been told other OSes support similar functionality<br>
(VM_FLAGS_PURGABLE and =A0MEM_RESET/MEM_RESET_UNDO).<br>
<br>
Been slow going last 6-mo on my part, due to lots of adorable<br>
SIGBABY interruptions &amp; other work.<br>
<br>
<br>
Concept in general:<br>
-------------------<br>
<br>
Applications marks memory as volatile, allowing kernel to purge<br>
that memory if and when its needed. Applications can mark memory as<br>
non-volatile, and kernel will return a value to notify them if memory<br>
was purged while it was volatile.<br>
<br>
<br>
Use cases:<br>
----------<br>
<br>
Allows for eviction of userspace cache by the kernel, which is nice<br>
as applications don&#39;t have to tinker with optimizing cache sizes,<br>
as the kernel which has the global view will optimize it for them.<br>
<br>
Marking =A0obscured bitmaps of rendered image data volatile. Ie: Keep<br>
compressed jpeg around, but mark volatile off-screen rendered bitmaps.<br>
<br>
Marking non-visible web-browser tabs as volatile.<br>
<br>
Lazy freeing of heap in malloc/free implementations.<br>
<br>
<br>
Parallel ways of thinking about it:<br>
------------------------------<u></u>-----<br>
<br>
Also similar to MADV_DONTNEED, but eviction is needs based, not<br>
instantaneous. Also applications can cancel eviction if it hasn&#39;t<br>
happened (by setting non-volatile). =A0So sort of delayed and cancel-able<b=
r>
MADV_DONTNEED.<br>
<br>
Can consider it like swapping some pages to /dev/null ?<br>
<br>
Rik&#39;s MADV_FREE was vary similar, but with implicit NON_VOLATILE<br>
marking on page-dirtying.<br>
<br>
<br>
Two basic usage-modes:<br>
----------------------<br>
<br>
1) =A0Application explicitly unmarks memory as volatile whenever it<br>
uses it, never touching memory marked volatile.<br>
<br>
=A0 =A0 If memory is purged, applications is notified when it marks the<br>
=A0 =A0 area as non-volatile.<br>
<br>
2) Applications may access memory marked volatile, but should it<br>
access memory that was purged, it will receive SIGBUS<br>
<br>
=A0 =A0 On SIGBUS, application has to mark needed range as non-volatile,<br=
>
=A0 =A0 regenerate or re-fetch the data, and then can continue.<br>
<br>
=A0 =A0 This is a little more optimistic, but applications need to be<br>
=A0 =A0 able to handle getting a SIGBUS and fixing things up.<br>
<br>
=A0 =A0 This second optimistic method is desired by Mozilla folks.<br>
<br>
<br>
Important Goals:<br>
----------------<br>
<br>
Applications using this likely to mark and unmark ranges<br>
frequently (ideally only marking the data they immediately need as<br>
nonvolatile). This makes it necessary for these operations to be cheap,<br>
since applications won&#39;t volunteer their currently unused memory to<br>
the kernel if it adds dramatic overhead. =A0Although this concerned is<br>
lessened with the optimistic/SIGBUS usage-mode.<br>
<br>
Overall, we try to push costs from the mark/unmark paths to the page<br>
eviction side.<br>
<br>
<br>
<br>
Two basic types of volatile memory:<br>
------------------------------<u></u>-----<br>
<br>
1) File based memory<br>
<br>
2) Anonymous memory<br>
<br>
<br>
Volatile ranges on file memory:<br>
------------------------------<u></u>-<br>
<br>
This allows for using volatile ranges on shared memory between<br>
processes.<br>
<br>
Very similar to ashmem&#39;s unpinned pages.<br>
<br>
One example: Two processes can create a large circular buffer, where<br>
any unused memory in that buffer is volatile. Producer marks memory<br>
as non-volatile, writes to it. The consumer would read the data,<br>
then mark it volatile.<br>
<br>
An important distinction here is that the volatility is shared,<br>
in the same way the file&#39;s data is shared. Its a property of the<br>
file&#39;s pages, not a property of the process that marked the range as<br=
>
volatile. Thus one application can mark file data as volatile, and<br>
the pages could be purged from all applications mapping that data.<br>
And a different application could mark it as non-volatile, and that<br>
would keep it from being purged from all applications.<br>
<br>
For this reason, the volatility is likely best to be stored on<br>
address_space (or otherwise connected to the address_space/inode).<br>
<br>
Another important semantic: Volatility is cleared when all fd&#39;s to<br>
a file are closed.<br>
<br>
=A0 =A0 There&#39;s no really good way for volatility to persist when no on=
e<br>
=A0 =A0 is using a file.<br>
<br>
=A0 =A0 It could cause confusion if an application died leaving some<br>
=A0 =A0 file data volatile, and then had that data disappear as it was<br>
=A0 =A0 starting up again.<br>
<br>
=A0 =A0 No volatility across reboots!<br>
<br>
<br>
[TBD]: For the most-part, volatile ranges really only makes sense to<br>
me on tmpfs files. Mostly due to semantics of purging data on files<br>
is similar to hole punching, and I suspect having the resulting hole<br>
punched pushed out to disk would cause additional io and load. Partial<br>
range purging could have strange effects on resulting file.<br>
<br>
[TBD]: Minchan disagrees and thinks fadvise(DONTNEED) has problems,<br>
as it causes immediate writeout when there&#39;s plenty of free memory<br>
(possibly unnecessary). Although we may defer so long that the hole<br>
is never punched, which may be problematic.<br>
<br>
<br>
<br>
Volatile ranges on anonymous/process memory:<br>
------------------------------<u></u>--------------<br>
<br>
For anonymous memory, its mostly un-shared between processes (except<br>
copy-on-write pages).<br>
<br>
The only way to address anonymous memory is really relative to the<br>
process address space (its anonymous: there&#39;s no named handle to it).<b=
r>
<br>
Same semantics as described above. Mark region of process memory<br>
volatile, or non-volatile.<br>
<br>
Volatility is a per-proecess (well mm_struct) state.<br>
<br>
Kernel will only purge a memory page, if *all* the processes that<br>
map that page in consider the page volatile.<br>
<br>
Important semantics: Preserve volatility over a fork, but clear child<br>
volatility on exec.<br>
<br>
=A0 =A0 So if a process marks a range as volatile then forks. Both<br>
=A0 =A0 the child and parent should see the same range as volatile.<br>
=A0 =A0 On memory pressure, kernel could purge those pages, since all of<br=
>
=A0 =A0 the processes that map that page consider it volatile.<br>
<br>
=A0 =A0 If the child writes to the pages, the COW links are broken, but<br>
=A0 =A0 both ranges ares still volatile, and can be purged until they<br>
=A0 =A0 are marked non-volatile or cleared.<br>
<br>
=A0 =A0 Then like mappings and the rest of memory, volatile ranges are<br>
=A0 =A0 cleared on exec.<br>
<br>
<br>
Implementation history:<br>
-----------------------<br>
<br>
File-focused (John): Interval tree connected to address_space w/ global<br>
LRU of unpurged volatile ranges. Used shrinker to trigger purging<br>
off the lru. Numa folks complained that shrinker is numa-unaware and<br>
would cause purging on nodes not under pressure.<br>
<br>
File-focused (John): Checking volatility at page eviction time. Caused<br>
problems on swap-free systems, since tmpfs pages are anonymous and<br>
aren&#39;t aged/shrunk off lrus. In order to handle that we moved the<br>
pages to a volatile lru list, but that causes volatile/non-volatile<br>
operations to be very expensive O(n) for number of pages in the range.<br>
<br>
Anon-focused (Minchan): Store volatility in VMA. Worked well for<br>
anonymous ranges, but was problematic to extend to file ranges as<br>
we need volatility state to be connected with the file, not the<br>
process. Iterating across and splitting VMAs was somewhat costly.<br>
<br>
Anon-focused (Minchan): Store anonymous volatility in interval tree<br>
off of the mm_struct. Use global LRU of volatile ranges to use when<br>
purging ranges via a shrinker. Also hooks into normal eviction to<br>
make sure evicted pages are purged instead of swapped out. Very fast,<br>
due to quick manipulations to a single interval tree. =A0File pages in<br>
ranges are ignored.<br>
<br>
Both (John): Same as above, but mostly extended so interval tree<br>
of ranges can be hung off of the mm_struct OR an address_space.<br>
Currently functionality is partitioned so volatile ranges on files and<br>
on anonymous memory are created via separate syscalls (fvrange(fd,<br>
start, len, ...) vs mvrange(start_addr, len,...)). =A0Roughly merges<br>
the original first approach with the previous one.<br>
<br>
Both (John): Currently working on above, further extending mvrange()<br>
so it can also be used to set volatility on MAP_SHARED file mappings<br>
in an address space. Has the problem that handling both file and<br>
anonymous memory types in a single call requires iterating over vmas,<br>
which makes the operation more expensive.<br>
<br>
[TBD]: Cost impact of mvrange() supporting mapped file pages vs dev<br>
confusion of it not supporting file pages<br>
<br>
<br>
<br>
Current interfaces:<br>
-------------------<br>
<br>
Two current interfaces:<br>
=A0 =A0 fvrange(fd, start_off, length, mode, flags, &amp;purged)<br>
<br>
=A0 =A0 mvrange(start_addr, length, mode, flags, &amp;purged)<br>
<br>
<br>
fd/start/length:<br>
=A0 =A0 Hopefully obvious :)<br>
<br>
mode:<br>
=A0 =A0 VOLATILE: Sets range as volatile. Returns number of bytes marked<br=
>
=A0 =A0 volatile.<br>
<br>
=A0 =A0 NON_VOLATILE: Marks range as non-volatile. Returns number of bytes<=
br>
=A0 =A0 marked non-volatile, sets purged value to 1 if any memory in the<br=
>
=A0 =A0 bytes marked non-volatile were purged.<br>
<br>
flags:<br>
=A0 =A0 VRANGE_FULL: On eviction, the entire range specified will be purged=
<br>
<br>
=A0 =A0 VRANGE_PARTIAL: On eviction, we may purge only part of the<br>
=A0 =A0 specified range.<br>
<br>
=A0 =A0 In earlier discussions, it was deemed that if any page in<br>
=A0 =A0 a volatile range was purged, we might as well purge the entire<br>
=A0 =A0 range, since if we mark any portion of that range as non-volatile,<=
br>
=A0 =A0 the application would have to regenerate the entire range. Thus<br>
=A0 =A0 we might as well reduce memory pressure by puring the entire range.=
<br>
<br>
=A0 =A0 However, with the SIGBUS semantics, applications may be able to<br>
=A0 =A0 continue accessing pages in a volatile range where one unused<br>
=A0 =A0 page is purged, so we may want to avoid purging the entire range<br=
>
=A0 =A0 to allow for optimistic continued use.<br>
<br>
=A0 =A0 Additionally partial purging is helpful so that we don&#39;t over-r=
eact<br>
=A0 =A0 when we have slight memory pressure. An example, if we have a<br>
=A0 =A0 64M vrange, and the kernel only needs 8M, its much cheaper to<br>
=A0 =A0 free 8M now and then later when the range is marked non-volatile,<b=
r>
=A0 =A0 re-allocate only 8M (fault + allocation + zero-clearing) instead<br=
>
=A0 =A0 of the entire 64M.<br>
<br>
=A0 =A0 [TBD]: May consider merging flags w/ mode: ie: VOLATILE_FULL,<br>
=A0 =A0 VOLATILE_PARTIAL, NON_VOLATILE<br>
<br>
=A0 =A0 [TBD]: Might be able to simplify and go with VRANGE_PARTIAL all<br>
=A0 =A0 the time?<br>
<br>
purged:<br>
=A0 =A0 Flag that returns 1 if any pages in the range marked<br>
=A0 =A0 NON_VOLATILE were purged. Is set to zero otherwise. Can be null<br>
=A0 =A0 if mode=3D=3DVOLATILE.<br>
<br>
=A0 =A0 [TBD]: Might consider value passed to it will be |&#39;ed with 1?.<=
br>
<br>
=A0 =A0 [TBD]: Might consider purged to be more of a status bitflag,<br>
=A0 =A0 allowing vrange(VOLATILE) calls to get some meaningful data like<br=
>
=A0 =A0 if memory pressure is currently going on.<br>
<br>
<br>
Return value:<br>
=A0 =A0 Number of bytes marked VOLATILE or NON_VOLATILE. This is necessary<=
br>
=A0 =A0 as if we are to deal with setting ranges that cross anonymous and<b=
r>
=A0 =A0 file backed pages, we have to split the operations up into multiple=
<br>
=A0 =A0 operations against the respective mm_struct or addess_space, and<br=
>
=A0 =A0 there&#39;s a possibility that we could run out of memory mid-way<b=
r>
=A0 =A0 through an operation. =A0If we do run out of memory mid way, we<br>
=A0 =A0 simply return the number of bytes successfully marked, and we<br>
=A0 =A0 can return an error on the next invocation if we hit the ENOMEM<br>
=A0 =A0 right away.<br>
<br>
=A0 =A0 [TBD]: If mvrange() doesn&#39;t affect mapped file pages, then the<=
br>
=A0 =A0 return value can be simpler.<br>
<br>
<br>
<br>
Current TODOs:<br>
--------------<br>
<br>
Add proper SIGBUS signaling when accessing purged file ranges.<br>
<br>
Working on handling mvrange() ranges that cross anonymous and mapped<br>
file regions.<br>
<br>
Handle errors mid-way through operations.<br>
<br>
Cleanups and better function names.<br>
<br>
<br>
<br>
[TBD] Contentious interface issues:<br>
------------------------------<u></u>-----<br>
<br>
Does handling mvrange() calls that cross anonymous &amp; file pages<br>
increase costs too much for ebizzy workload Minchan likes?<br>
<br>
=A0 =A0 Have to take mmap_sem and traverse vmas.<br>
<br>
=A0 =A0 Could mvrange() on file pages not be shared in the same way as<br>
=A0 =A0 in fvrange()<br>
<br>
=A0 =A0 Sane interface vs Speed?<br>
<br>
Minchan&#39;s idea of mvrange(VOLATILE_FILE|<u></u>VOLATILE_ANON|VOLATILE_B=
OTH):<br>
<br>
=A0 =A0 Avoid traversing vmas on VOLATILE_ANON flag, regardless of if<br>
=A0 =A0 range covers mapped file pages<br>
<br>
=A0 =A0 Not sure we can throw sane errors without checking vmas?<br>
<br>
Do we really need a new syscall interface?<br>
<br>
=A0 =A0 Can we maybe go back to using madvise?<br>
<br>
=A0 =A0 Should mvrange be prioritized over fvrange, if mvrange can create<b=
r>
=A0 =A0 volatile ranges on files.<br>
<br>
Some folks still don&#39;t like SIGBUS on accessing a purged volatile page,=
<br>
instead want standard zero-fill fault.<br>
<br>
=A0 =A0 Need some way to know page was dropped (zero is a valid data value)=
<br>
<br>
=A0 =A0 After marking non-volatile, it can be zero-fill fault.<br>
<br>
<br>
[TBD] Contentious implementation issues:<br>
------------------------------<u></u>----------<br>
<br>
Still using shrinker for purging, got early complaints from NUMA folks<br>
<br>
=A0 =A0 Can make sure we check first page in each range and purge only<br>
=A0 =A0 ranges where some page is in the zone being shrinked?<br>
<br>
=A0 =A0 Still use shrinker, but also use normal page shrinking path,<br>
=A0 =A0 but check for volatility. (swapless still needs shrinker)<br>
<br>
Probably don&#39;t want to actually hang vrange interval tree (vrange_root)=
<br>
off of address_space and struct_mm.<br>
<br>
=A0 =A0 In earlier attempts I used a hashtable to avoid this<br>
=A0 =A0 =A0 =A0 <a href=3D"http://thread.gmane.org/gmane.linux.kernel/12785=
41/focus=3D1278542" target=3D"_blank">http://thread.gmane.org/gmane.<u></u>=
linux.kernel/1278541/focus=3D<u></u>1278542</a><br>
<br>
=A0 =A0 I assume this is still a concern?<br>
<br>
<br>
Older non-contentious points:<br>
-----------------------------<br>
<br>
Coalescing of ranges: Don&#39;t do it unless the ranges overlaps<br>
<br>
Range granular vs page granular purging: Resolved with _FULL/_PARTIAL<br>
flags<br>
<br>
<br>
Other ideas/use-cases proposed:<br>
------------------------------<u></u>-<br>
<br>
PTurner: Marking deep user-stack-frames as volatile to return that<br>
memory?<br>
<br></blockquote><div><br></div><div style>Great write-up John.</div><div s=
tyle><br></div><div>Since there&#39;s a question mark I thought I&#39;d add=
 a qualifier:</div><div>I think this would be specifically useful with segm=
ented stacks. =A0As we cross region boundaries we could then mark the previ=
ous region as volatile to allow reclaim without a large re-use penalty if t=
he stack quickly grows again. =A0This is a trade-off that is typically diff=
icult to manage.</div>

<div><br></div>
<div><br></div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex=
;border-left:1px #ccc solid;padding-left:1ex">
Dmitry Vyukov: 20-80TB allocation, marked volatile right away. Never<br>
marking non-volatile.<br>
<br>
=A0 =A0 Wants zero-fill and doesn&#39;t want SIGBUG<br>
<br>
=A0 =A0 <a href=3D"https://code.google.com/p/thread-sanitizer/wiki/Volatile=
Ranges" target=3D"_blank">https://code.google.com/p/<u></u>thread-sanitizer=
/wiki/<u></u>VolatileRanges</a><br>
<br>
<br>
Misc:<br>
----<br>
Previous discussion: <a href=3D"https://lwn.net/Articles/518130/" target=3D=
"_blank">https://lwn.net/Articles/<u></u>518130/</a><br>
<br>
</blockquote></div><br></div></div>

--f46d044284f87806b004da941d6a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
