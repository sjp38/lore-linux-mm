Date: Wed, 24 May 2000 13:02:57 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: discussion with Matt Dillon
Message-ID: <Pine.LNX.4.21.0005241256270.24993-170000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="655889-1842000895-959184177=:24993"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

--655889-1842000895-959184177=:24993
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

over the last days I had a very interesting discussion 
about virtual memory with Matt Dillon. It would be cool
if people here could read these emails and give us comments,
reactions, questions, ... about them.

I believe it would be a good thing for Linux to have a
whole bunch of people who understand virtual memory so
we can keep an eye on each other and make sure something
good gets built.

Also, I'd *really* appreciate some comments on the 2.3/4
VM plan I sent to the list earlier today. I want to start
implementing it RSN (as in, after lunch) so I need to know
if I missed any critical design issues...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--655889-1842000895-959184177=:24993
Content-Type: MULTIPART/Digest; BOUNDARY="655889-1110733960-959184177=:24993"
Content-ID: <Pine.LNX.4.21.0005241256287.24993@duckman.distro.conectiva>
Content-Description: Digest of 7 messages

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256280.24993@duckman.distro.conectiva>
Content-Description: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Return-Path: <dillon@apollo.backplane.com>
Received: from perninha.conectiva.com.br (perninha.conectiva.com.br [200.250.58.156])
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id DAA18483
	for <riel@duckman.distro.conectiva>; Tue, 23 May 2000 03:32:33 -0300
Received: from apollo.backplane.com (apollo.backplane.com [216.240.41.2])
	by perninha.conectiva.com.br (8.9.3/8.9.3) with ESMTP id DAA00990
	for <riel@conectiva.com.br>; Tue, 23 May 2000 03:32:56 -0300
Received: (from dillon@localhost)
	by apollo.backplane.com (8.9.3/8.9.1) id XAA64159;
	Mon, 22 May 2000 23:32:20 -0700 (PDT)
	(envelope-from dillon)
Date: Mon, 22 May 2000 23:32:20 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005230632.XAA64159@apollo.backplane.com>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Linux VM/IO balancing (fwd to linux-mm?)


    I sent this to Alan who suggested that I send this to you!  I've 
    fleshed it out a bit more from the version I sent to Alan.

    I've been following the linux VM/memory subsystem issues closely and
    I have a few suggestions on how to clean it up. Unfortunately, 
    being FreeBSD centric these days I do not want to create controversy.
    But at this point I think even linux developers know that the 
    algorithms being used in the linux kernel are struggling
    with the issue.  The time may be ripe for some outside input (though I
    will note that I was heavy into linux in earlier years, as Alan's
    mail archives attest to!).

    What I do below is essentially describe the FreeBSD VM/memory subsystem
    from an algorithmic point of view, minus some of the fluff.  It is very
    straightforward in concept and the benefits should be obvious to anyone 
    who has worked on the VM system.  I think it would be a fine blueprint
    to use in linux.

    I would like you to consider posting this to linux-kernel.  I leave it
    up to you -- I think if I were to post it independantly it would simply
    result in controversy and seem more like a FreeBSD vs Linux thing rather
    then a 'how to fix the VM system' thing.  But if you post it
    and preface it appropriately, the result might be better.  So I am
    sending it to you.  It may help kickstart creating a formal algorithmic
    blueprint rather then hacking up patches that solve one problem that
    only create other problems.

    Please feel free to edit it in any way if you think you can reduce 
    potential us-vs-them issues even more.  I think there is a chance here
    to get the whole of the linux developer community on the same page
    in regards to the memory-load issue.

    I didn't intend to turn this into a paper, but I've spent so much time
    describing it that I think I am going to submit it to daemon news in
    a cleaned-up form :-).

						Thanks!

						-Matt

	    ---------


    Even though I don't do much coding for Linux these days, I've always
    avidly tracked the kernel mailing list.  I've been tracking the memory
    balancing thread for a while now and, having dealt with similar issues
    in FreeBSD I believe I can offer a suggestion.

    First of all, I am not trying to turn this into a comparison or anything.
    Don't think of the FreeBSD memory subsystem as being 'FreeBSD' more
    as being the work of a handful of very good theorists and programmers
    (John Dyson being the main element there), and years of testing under
    varying loads.  The algorithms FreeBSD uses are NOT 15 years old, they
    are more like 3 years old, and much of the work I myself have done is 
    less then one year old.  Also, keep in mind that the standard FUD about
    FreeBSD 'swapping more' the linux is just that --- FUD.  FreeBSD only
    swaps when it needs to, or thinks it may benefit by freeing up an
    idle dirty page for more active reuse.  I make an attempt to describe
    in exact detail how and why FreeBSD pages things out, and why it works
    so well, somewhere down below :-).

    My suggestions are as follows:

    First, stop treating the buffer cache as an entity separate from the
    VM system.  The two are inexorably bound together, especially considering
    the massive use of mmap() (both file-backed and anonymous mmaps) in
    modern programming.  Depending on what you are running a properly
    balanced system might have anywhere from 80% of its memory assigned 
    as file cache to 80% of its memory assigned to hold anonymous memory
    for processes.  it is NOT possible to impose limitations and still
    get a reasonably scaleable balanced system.  DO NOT TREAT THESE
    AS TWO DIFFERENT CACHES!

    Second, start keeping real statistics on memory use across on a
    physical-page-basis.  That means tracking how often VM pages are 
    referenced (statistically) as well as how often filesystem pages are 
    referenced by discrete I/O calls (deterministically).  Keep track of
    a real per-physical-page statistical 'weight'.  (What this means for
    linux is that you really need to test the pte's associated with physical
    pages by iterating through the physical pagse in your outer loop, NOT 
    by trying to iterate through every page table of every process!).

    FreeBSD keeps a center-weighted statistic for every page of memory 
    (buffer cache or VM cache, it makes no difference).   This has turned
    out to be a nearly perfect balancing algorithm and I strongly recommend
    that linux adopt a similar model.  But what makes it work is that
    FreeBSD is willing to eat a couple of cpu cycles to keep accurate
    statistics of page use by the VM system in order to avoid the bad
    things that happen when one would otherwise choose the wrong page to
    reuse or clean.

    What I describe below is the essential core of the algorithm FreeBSD
    uses.  It's not an exact representation, but it gets to the heart of
    FreeBSD's memory-balancing success.

    The algorithm is a *modified* LRU.  Lets say you decide on a weighting
    betweeen 0 and 10.  When a page is first allocated (either to the
    buffer cache or for anonymous memory) its statistical weight is
    set to the middle (5).  If the page is used often the statistical 
    weight slowly rises to its maximum (10).  If the page remains idle
    (or was just used once) the statistical weight slowly drops to its
    minimum (0).

    The statistical weight is updated in real time by I/O system calls,
    and updated statistically (by checking and clearing the page-referenced
    bit in pte's) for mapped memory.  When you mmap() a file and issue 
    syscalls on the descriptor, the weight may be updated by BOTH methods. 
    The rate at which the statistical page-reference updating operates depends
    on the perceived memory load.  A lightly loaded system (unstressed
    memory) doesn't bother to scan the page-referenced bit all that often,
    while a heavy memory load scans the page-referenced bit quite often
    to keep the statistical weight intact.

    When memory is allocated and no free pages are available, a clean page
    is discarded from the cache (all 'clean' pages are considered to be
    cache pretty much), lowest weight first.  This in itself does NOT 
    contribute to the memory load calculation.  That is, if you are scanning
    a 10GB file you are not creating any memory stress on the system.

    The LRU nature of the order of the pages in the queue is not strict.
    The real parameter is the statistic, the ordering of the pages in the
    queue uses a heuristic -- the pages 'migrate' over time so they are
    reasonably well ordered within the queue, but no great effort is made
    to order them exactly.  The VM system will scan a portion of the queue
    to locate a reasonable page to reuse (for example, it will look for
    a page with a weighting less then 2).

    The pagedaemon's scan rate is based on the perceived memory load
    and ONLY the perceived memory load.  It is perfectly acceptable to 
    have most of the system memory in 'active' use if allocations are not
    occuring often, perfectly acceptable to have most of the system memory
    backing file pages if processes aren't doing a lot of pageins, perfectly
    acceptable for the system memory to be mostly dedicated to process
    anonymous memory if processes have big ACTIVE footprints, perfectly
    acceptable for most of the pages to be dirty if they are all in active
    use and the memory subsystem is not otherwise being stressed.

    The reason FreeBSD's memory subsystem works so well is precisely because
    it does not impose any artificial limitations on the balance point.

    Memory load is calculated in two ways:  First, if the memory system finds
    itself reusing active pages (in my example, any page with a statistical
    weight greater then 5), second based on the dirty:clean page ratio.  A
    high ratio does not itself cause paging to occur, but a high ratio 
    combined with the system reusing active pages does.

    The dirty/clean ratio is treated as an INDEPENDANT problem.  The
    same statistic is kept for dirty pages as it is for clean pages, but
    dirty pages are placed on their own independant LRUish queue and do
    not take part in the 'normal' memory allocation algorithm.  A
    separate algorithm (also part of the pageout daemon) controls the
    cleaning of dirty pages.

    When the memory load increases, an attempt is made to balance the
    dirty/clean ratio by 'cleaning' dirty pages, which of course means
    paging them out.   FreeBSD makes NO distinction between writing a dirty
    file-backed page and allocating swap for a dirty anonymous memory page.
    The same per-page memory-use statistic is also used to determine which
    dirty pages to clean first.  In effect, it is precisely this attempt
    to balance the dirty/clean ratio which increases the number of clean
    pages available to reuse.  The idea here is to increase the number of
    clean pages to the point where the system is no longer being forced
    to reuse 'active' pages.  Once this is achieved there is no longer any
    need clean the remaining dirty pages.

    Under extreme memory loads the balance point moves on its own to a
    point where FreeBSD tries to keep as many pages in a clean state as
    possible.  When the memory load gets to this point the system is 
    considered to be thrashing and we start taking anti-thrashing measures,
    such as swapping out whole processes and holding them idle for 20-second
    spans.  It rarely gets to this point, but even when it does the system
    is still kept reasonably balanced.

    It should be noted that the center-weighting algorithm works in virtually
    all situations, including workign WONDERFULLY when you have I/O
    centric programs (i.e. a program that reads or writes gigabytes of
    data).  By making slight adjustments to the initial weight (or even no
    adjustments at all) the VM system will tend to reuse used-once memory
    (think of scanning a file) before it tries to reuse more actively used
    memory.

    Now, of course, there are other kernel processes messing with memory.
    The filesystem update daemon, for example.  But these processes are
    not designed to handle heavy memory loads and we do it that way on
    purpose.  At most the update daemon will speed up a little under intense
    filesystem loads, but that is as far as it goes.  Only one process is
    designed to handle heavy memory loads and that is the pageout daemon.

					---
				    Stress Cases

    * Stressing dirty pages in the system via I/O calls (read/write)

	The algorithm tends to cause sequential I/O calls to give pages
	a middling weight, and since the pages are not reused they tend 
	to be recycled within their domain (so you don't blow the rest
	of the cache).

    * Stressing dirty pages in the system via mmap (shared R+W)

	The system tends to run low on clean pages, detected by the
	fact that new allocations are reusing clean pages which have high
	weights.  When this occurs the pageout daemon attempts to 'clean'
	dirty pages (page them out) in order to increase the number of
	clean pages available.  Having a larger number of clean pages 
	available tends to give them more time to age, thus reducing the
	average weight the allocator sees.  This is a negative feedback
	loop which results in balance.

    * I/O (read/shared-mmap) stress

	The algorithm tends to weight the clean pages according to use.
	The weightings for filesystem cache pages read via read() are
	adjusted at the time of the read() while VM pages are adjusted
	statistically (The VM page scan rate depends on the level of
	stress).  Since in modern systems mmap() is used heavily, no
	special consideration is given to one access method verses the
	other.

    * VM (anonymous memory) stress

	Anonymous swap-backed memory is treated no differently from
	file-backed (filesystem buffers / mmap) memory.  Clean anonymous
	pages (most likely with swap already allocated if they are clean)
	can be reused just the same as pages belonging to the filesystem
	buffer cache.  Swap is assigned to dirty anonymous pages on the
	fly, only when the pageout daemon decides to actually clean the
	page.  Once swap is assigned the clean page can be reused.  

	If a swap-backed page is brought back into memory, it is brought
	back in clean (swap is left assigned).   Swap is only freed if
	the page is re-dirtied by the process.  

	Thus most anonymous-memory pages in a heavily loaded system tend
	to remain clean, allowing them to be reused more easily and extending
	the life of the system further along the curve before it reaches a
	thrashing state.

    * Write Clustering.

	Whenever the system decides to clean a dirty page it will, on the
	fly, attempt to locate dirty nearby pages.  FreeBSD is actually
	quite sophisticated in this regard in that it actually goes and does
	the calculation to ensure that only pages physically contiguous 
	on the disk are clustered for the write.  The cluster is then written
	and marked clean all in one go (cluster size limit is 64-128K). 

    * Sequential Detection Heuristic for read clustering (read())

	A heuristic detects sequential read behavior and implements two
	optimizations.  (1) it implements read-aheads (as long as they
	are reasonably contiguous on the physical media, we explicitly do
	not try to issue read-aheads if it would cause an extra disk seek),
	(2) it implements priority depression read-behind (reduce by 1 the
	statistical weight of pages that have already been read).  Reuse of
	the pages can still cause the statistical weighting to increase to
	the maximum, but this optimization has a tendancy to greatly reduce
	the stress that large sequential reads have on the rest of the
	memory subsystem.

    * Sequential Detection Heuristic for read clustering (VM fault)

	A heuristic detects sequential VM fault operation, either forwards
	or backwards and adjusts the cluster window around the fault taken,
	either shifting it forwards or backwards, or making the window
	smaller (e.g. if random fault operation is detecting).  fault-ahead
	I/O is initiated based on the algorithm and anything found cached
	is pre-faulted into the page table.  (The window size in FreeBSD is 
	approximately 64KBytes for this particular algorithm).  The window
	is further restriction to ensure that only media-contiguous blocks
	are clustered.

    * Sequential Detection Heuristic for write clustering (write())

	In the case of write() I/O (write system call), in order to
	avoid saturating the memory system with dirty pages, if the
	sequential detection heuristic determines that writes are
	occuring sequentially, FreeBSD implements write-behind.  That 
	is it issues the I/O on the dirty buffers preceding the write
	point immediately (and asynchronously), in order to get the
	pages into a clean state and thus reuseable, thus avoiding
	stressing the memory system.  In this case there is also a
	limit emplaced on the number of dirty filesystem buffers
	allowed to accumulate (since I/O is slower then the write() 
	calls creating the dirty buffers).  

	What you wind up in this case is maximum disk throughput for the
	sequential write without thousands of unnecessary dirty pages,
	which is asynchronous up to a reasonable point and then starts
	blocking to give the I/O the chance to catch up a little in
	order to avoid starving the clean page cache.

    * Sequential Detection Heuristic for write clustering (mmap)

	Currently not implemented under FreeBSD.  This used to be a big
	problem because you could completely saturate the VM system with
	dirty pages before the system even realized it.  To fix this we
	threw in a memory-stress check in vm_fault to block when dirtying
	pages in the face of having too many dirty pages already, giving
	I/O a chance to catch up a little.

	This actually improved performance because it left a greater number
	of clean pages available and so the page selection algorithm in the
	allocator worked better (tended to select idle pages rather then
	active pages).

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256281.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Date: Tue, 23 May 2000 09:34:23 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
X-Sender: riel@duckman.distro.conectiva
To: Matthew Dillon <dillon@apollo.backplane.com>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
In-Reply-To: <200005230632.XAA64159@apollo.backplane.com>
Message-ID: <Pine.LNX.4.21.0005230836110.19121-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Mon, 22 May 2000, Matthew Dillon wrote:

>     What I do below is essentially describe the FreeBSD VM/memory subsystem
>     from an algorithmic point of view, minus some of the fluff.  It is very
>     straightforward in concept and the benefits should be obvious to anyone 
>     who has worked on the VM system.  I think it would be a fine blueprint
>     to use in linux.

I'm already looking at implementing this (and have been for a few
weeks). I'm reading vm/vm_pageout.c in detail now, mainly to scan
for pitfalls which I may have overlooked in my own design.

Davem has implemented some nice active/inactive queue code too, I
will probably cut'n'paste some of his code. I'll also try to avoid
some of the problems FreeBSD has (using the active/inactive queue
as primary scanning point and _then_ skipping to the virtual object
for IO clustering, as well as results obtained with my anti-hog code
suggest that we want to do scanning of virtual objects only, with an
active list, cache list and laundry list as only lists).

>     My suggestions are as follows:
> 
>     First, stop treating the buffer cache as an entity separate from the
>     VM system.  The two are inexorably bound together, especially considering
>     the massive use of mmap() (both file-backed and anonymous mmaps) in
>     modern programming.  Depending on what you are running a properly
>     balanced system might have anywhere from 80% of its memory assigned 
>     as file cache to 80% of its memory assigned to hold anonymous memory
>     for processes.  it is NOT possible to impose limitations and still
>     get a reasonably scaleable balanced system.  DO NOT TREAT THESE
>     AS TWO DIFFERENT CACHES!

We stopped doing this around kernel version 2.3.8 ;)
For all intents and purposes the buffer cache and the page
cache are one. There are still a few special cases where we
haven't figured out how to put the data into the page cache
cleanly, but those are real exceptions.

>     Second, start keeping real statistics on memory use across on a
>     physical-page-basis.  That means tracking how often VM pages are 
>     referenced (statistically) as well as how often filesystem pages are 
>     referenced by discrete I/O calls (deterministically).  Keep track of
>     a real per-physical-page statistical 'weight'.  (What this means for
>     linux is that you really need to test the pte's associated with physical
>     pages by iterating through the physical pagse in your outer loop, NOT 
>     by trying to iterate through every page table of every process!).

Hmmm, why would it matter in what order we scan stuff?

>     FreeBSD keeps a center-weighted statistic for every page of memory 
>     (buffer cache or VM cache, it makes no difference).   This has turned
>     out to be a nearly perfect balancing algorithm and I strongly recommend
>     that linux adopt a similar model.  But what makes it work is that
>     FreeBSD is willing to eat a couple of cpu cycles to keep accurate
>     statistics of page use by the VM system in order to avoid the bad
>     things that happen when one would otherwise choose the wrong page to
>     reuse or clean.

I fully agree on this point. Linus and Andrea have always been
a strong opponent of any possible "overhead", leading to a VM
subsystem that is optimised for CPU use, not for managing memory ;(

>     The algorithm is a *modified* LRU.  Lets say you decide on a weighting
>     betweeen 0 and 10.  When a page is first allocated (either to the
>     buffer cache or for anonymous memory) its statistical weight is
>     set to the middle (5).  If the page is used often the statistical 
>     weight slowly rises to its maximum (10).  If the page remains idle
>     (or was just used once) the statistical weight slowly drops to its
>     minimum (0).

*nod*  We may want to age physical pages in a way like this.

>     The statistical weight is updated in real time by I/O system calls,
>     and updated statistically (by checking and clearing the page-referenced
>     bit in pte's) for mapped memory.  When you mmap() a file and issue 
>     syscalls on the descriptor, the weight may be updated by BOTH methods. 
>     The rate at which the statistical page-reference updating operates depends
>     on the perceived memory load.  A lightly loaded system (unstressed
>     memory) doesn't bother to scan the page-referenced bit all that often,
>     while a heavy memory load scans the page-referenced bit quite often
>     to keep the statistical weight intact.

Nice.

>     When memory is allocated and no free pages are available, a clean page
>     is discarded from the cache (all 'clean' pages are considered to be
>     cache pretty much), lowest weight first.  This in itself does NOT 
>     contribute to the memory load calculation.  That is, if you are scanning
>     a 10GB file you are not creating any memory stress on the system.

*nod*

>     The LRU nature of the order of the pages in the queue is not strict.
>     The real parameter is the statistic, the ordering of the pages in the
>     queue uses a heuristic -- the pages 'migrate' over time so they are
>     reasonably well ordered within the queue, but no great effort is made
>     to order them exactly.  The VM system will scan a portion of the queue
>     to locate a reasonable page to reuse (for example, it will look for
>     a page with a weighting less then 2).

*nod*

>     The pagedaemon's scan rate is based on the perceived memory load
>     and ONLY the perceived memory load.  It is perfectly acceptable to 
>     have most of the system memory in 'active' use if allocations are not
>     occuring often, perfectly acceptable to have most of the system memory
>     backing file pages if processes aren't doing a lot of pageins, perfectly
>     acceptable for the system memory to be mostly dedicated to process
>     anonymous memory if processes have big ACTIVE footprints, perfectly
>     acceptable for most of the pages to be dirty if they are all in active
>     use and the memory subsystem is not otherwise being stressed.
>
>     The reason FreeBSD's memory subsystem works so well is precisely because
>     it does not impose any artificial limitations on the balance point.

Yup. This is a good thing which will be implemented in Linux too.

>     Memory load is calculated in two ways:  First, if the memory system finds
>     itself reusing active pages (in my example, any page with a statistical
>     weight greater then 5), second based on the dirty:clean page ratio.  A
>     high ratio does not itself cause paging to occur, but a high ratio 
>     combined with the system reusing active pages does.

Hmmmm, this isn't what I'm seeing in the code. Could you point me
at the code where this is happening?

>     The dirty/clean ratio is treated as an INDEPENDANT problem.  The
>     same statistic is kept for dirty pages as it is for clean pages, but
>     dirty pages are placed on their own independant LRUish queue and do
>     not take part in the 'normal' memory allocation algorithm.  A
>     separate algorithm (also part of the pageout daemon) controls the
>     cleaning of dirty pages.

This is planned for Linux as well.

>     When the memory load increases, an attempt is made to balance the
>     dirty/clean ratio by 'cleaning' dirty pages, which of course means
>     paging them out.   FreeBSD makes NO distinction between writing a dirty
>     file-backed page and allocating swap for a dirty anonymous memory page.
>     The same per-page memory-use statistic is also used to determine which
>     dirty pages to clean first.  In effect, it is precisely this attempt
>     to balance the dirty/clean ratio which increases the number of clean
>     pages available to reuse.  The idea here is to increase the number of
>     clean pages to the point where the system is no longer being forced
>     to reuse 'active' pages.  Once this is achieved there is no longer any
>     need clean the remaining dirty pages.

I've read the code and it seems to do this:
- put inactive pages in the cached queue
- launder up to maxlaunder pages per scan (if needed)

>     Under extreme memory loads the balance point moves on its own to a
>     point where FreeBSD tries to keep as many pages in a clean state as
>     possible.  When the memory load gets to this point the system is 
>     considered to be thrashing and we start taking anti-thrashing measures,
>     such as swapping out whole processes and holding them idle for 20-second
>     spans.  It rarely gets to this point, but even when it does the system
>     is still kept reasonably balanced.

Uhmmmm. This does not seem to be exactly what the code does...
(then again, I could be wrong)

>     It should be noted that the center-weighting algorithm works in virtually
>     all situations, including workign WONDERFULLY when you have I/O
>     centric programs (i.e. a program that reads or writes gigabytes of
>     data).  By making slight adjustments to the initial weight (or even no
>     adjustments at all) the VM system will tend to reuse used-once memory
>     (think of scanning a file) before it tries to reuse more actively used
>     memory.

*nod*

Always trying to keep 1/3rd of the mapped pages in an "inactive"
age is probably a good idea for Linux. The biggest problem with
our code seems to be that we're *not* trying to have a balanced
aging of pages ...

>     Now, of course, there are other kernel processes messing with memory.
>     The filesystem update daemon, for example.  But these processes are
>     not designed to handle heavy memory loads and we do it that way on
>     purpose.  At most the update daemon will speed up a little under intense
>     filesystem loads, but that is as far as it goes.  Only one process is
>     designed to handle heavy memory loads and that is the pageout daemon.

*nod*

> 					---
> 				    Stress Cases
> 
>     * Stressing dirty pages in the system via I/O calls (read/write)
> 
> 	The algorithm tends to cause sequential I/O calls to give pages
> 	a middling weight, and since the pages are not reused they tend 
> 	to be recycled within their domain (so you don't blow the rest
> 	of the cache).

This is a good argument for starting at a middle weight. Thanks
for bringing this case to my attention, we really want something
like this.

>     * Stressing dirty pages in the system via mmap (shared R+W)
> 
> 	The system tends to run low on clean pages, detected by the
> 	fact that new allocations are reusing clean pages which have high
> 	weights.  When this occurs the pageout daemon attempts to 'clean'
> 	dirty pages (page them out) in order to increase the number of
> 	clean pages available.  Having a larger number of clean pages 
> 	available tends to give them more time to age, thus reducing the
> 	average weight the allocator sees.  This is a negative feedback
> 	loop which results in balance.

Hummm, where in the code can I find info on this?
It certainly sounds interesting...

>     * I/O (read/shared-mmap) stress
> 
> 	The algorithm tends to weight the clean pages according to use.
> 	The weightings for filesystem cache pages read via read() are
> 	adjusted at the time of the read() while VM pages are adjusted
> 	statistically (The VM page scan rate depends on the level of
> 	stress).  Since in modern systems mmap() is used heavily, no
> 	special consideration is given to one access method verses the
> 	other.

*nod*

>     * VM (anonymous memory) stress
> 
> 	Anonymous swap-backed memory is treated no differently from
> 	file-backed (filesystem buffers / mmap) memory.  Clean anonymous
> 	pages (most likely with swap already allocated if they are clean)
> 	can be reused just the same as pages belonging to the filesystem
> 	buffer cache.  Swap is assigned to dirty anonymous pages on the
> 	fly, only when the pageout daemon decides to actually clean the
> 	page.  Once swap is assigned the clean page can be reused.  
> 
> 	If a swap-backed page is brought back into memory, it is brought
> 	back in clean (swap is left assigned).   Swap is only freed if
> 	the page is re-dirtied by the process.  
> 
> 	Thus most anonymous-memory pages in a heavily loaded system tend
> 	to remain clean, allowing them to be reused more easily and extending
> 	the life of the system further along the curve before it reaches a
> 	thrashing state.

A few points:
- it may be easier to assign swap entries based on virtual
  scanning of processes, otherwise you'll end up with the
  strange jumping between queue scanning and virtual scanning
  that FreeBSD is doing now
- vnodes are why FreeBSD is able to delay writing anonymous
  pages till later on
- not every page weighs equally ... you want some fairness
  between memory hogs and small processes
- Linux already does the don't-rewrite-clean-swap thing

>     * Write Clustering.
> 
> 	Whenever the system decides to clean a dirty page it will, on the
> 	fly, attempt to locate dirty nearby pages.  FreeBSD is actually
> 	quite sophisticated in this regard in that it actually goes and does
> 	the calculation to ensure that only pages physically contiguous 
> 	on the disk are clustered for the write.  The cluster is then written
> 	and marked clean all in one go (cluster size limit is 64-128K). 

Neat...

>     * Sequential Detection Heuristic for read clustering (read())
> 
> 	A heuristic detects sequential read behavior and implements two
> 	optimizations.  (1) it implements read-aheads (as long as they
> 	are reasonably contiguous on the physical media, we explicitly do
> 	not try to issue read-aheads if it would cause an extra disk seek),
> 	(2) it implements priority depression read-behind (reduce by 1 the
> 	statistical weight of pages that have already been read).  Reuse of
> 	the pages can still cause the statistical weighting to increase to
> 	the maximum, but this optimization has a tendancy to greatly reduce
> 	the stress that large sequential reads have on the rest of the
> 	memory subsystem.

Ohhhh, nice ;)

>     * Sequential Detection Heuristic for read clustering (VM fault)
> 
> 	A heuristic detects sequential VM fault operation, either forwards
> 	or backwards and adjusts the cluster window around the fault taken,
> 	either shifting it forwards or backwards, or making the window
> 	smaller (e.g. if random fault operation is detecting).  fault-ahead
> 	I/O is initiated based on the algorithm and anything found cached
> 	is pre-faulted into the page table.  (The window size in FreeBSD is 
> 	approximately 64KBytes for this particular algorithm).  The window
> 	is further restriction to ensure that only media-contiguous blocks
> 	are clustered.

Again ... neat.

>     * Sequential Detection Heuristic for write clustering (write())
> 
> 	In the case of write() I/O (write system call), in order to
> 	avoid saturating the memory system with dirty pages, if the
> 	sequential detection heuristic determines that writes are
> 	occuring sequentially, FreeBSD implements write-behind.  That 
> 	is it issues the I/O on the dirty buffers preceding the write
> 	point immediately (and asynchronously), in order to get the
> 	pages into a clean state and thus reuseable, thus avoiding
> 	stressing the memory system.  In this case there is also a
> 	limit emplaced on the number of dirty filesystem buffers
> 	allowed to accumulate (since I/O is slower then the write() 
> 	calls creating the dirty buffers).  
> 
> 	What you wind up in this case is maximum disk throughput for the
> 	sequential write without thousands of unnecessary dirty pages,
> 	which is asynchronous up to a reasonable point and then starts
> 	blocking to give the I/O the chance to catch up a little in
> 	order to avoid starving the clean page cache.

Cool.

>     * Sequential Detection Heuristic for write clustering (mmap)
> 
> 	Currently not implemented under FreeBSD.  This used to be a big
> 	problem because you could completely saturate the VM system with
> 	dirty pages before the system even realized it.  To fix this we
> 	threw in a memory-stress check in vm_fault to block when dirtying
> 	pages in the face of having too many dirty pages already, giving
> 	I/O a chance to catch up a little.
> 
> 	This actually improved performance because it left a greater number
> 	of clean pages available and so the page selection algorithm in the
> 	allocator worked better (tended to select idle pages rather then
> 	active pages).

This is an extremely good idea. When we have too many (or just,
a lot of) dirty pages, we should delay faults in write-enabled
VMAs, while allowing faults in read-only VMAs to proceed as
fast as possible ...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/


--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256282.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Return-Path: <dillon@apollo.backplane.com>
Received: from perninha.conectiva.com.br (perninha.conectiva.com.br [200.250.58.156])
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id OAA20874
	for <riel@duckman.distro.conectiva>; Tue, 23 May 2000 14:07:04 -0300
Received: from apollo.backplane.com (apollo.backplane.com [216.240.41.2])
	by perninha.conectiva.com.br (8.9.3/8.9.3) with ESMTP id OAA31919
	for <riel@conectiva.com.br>; Tue, 23 May 2000 14:07:19 -0300
Received: (from dillon@localhost)
	by apollo.backplane.com (8.9.3/8.9.1) id KAA68220;
	Tue, 23 May 2000 10:06:38 -0700 (PDT)
	(envelope-from dillon)
Date: Tue, 23 May 2000 10:06:38 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005231706.KAA68220@apollo.backplane.com>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
References: <Pine.LNX.4.21.0005230836110.19121-100000@duckman.distro.conectiva>


:I'm already looking at implementing this (and have been for a few
:weeks). I'm reading vm/vm_pageout.c in detail now, mainly to scan
:for pitfalls which I may have overlooked in my own design.
 
    Great!

:Davem has implemented some nice active/inactive queue code too, I
:will probably cut'n'paste some of his code. I'll also try to avoid
:some of the problems FreeBSD has (using the active/inactive queue
:as primary scanning point and _then_ skipping to the virtual object
:for IO clustering, as well as results obtained with my anti-hog code
:suggest that we want to do scanning of virtual objects only, with an
:active list, cache list and laundry list as only lists).

    I would not characterize this as a problem in FreeBSD, it's actually
    one of its more powerful features.  What FreeBSD is doing is using 
    the center-weighted algorithm to locate a page that it believes
    should be reused or paged out.  Once the page is selected FreeBSD
    tries to make the best of the disk seek that it's about to do by
    clustering other nearby pages along with it.  You can't find the best
    candidate by scanning via the VM objects.

    The problem with trying to locate the page to reuse from the VM object
    alone is that it doesn't work.  You might end up scanning all the VM
    objects to locate a good page to reuse.  If you just scan a few VM 
    objects, there is a very good chance that you will *not* choose the best
    page to reuse/flush.  For example, there was some code in the linux
    kernel a while ago that tried to scan the 'biggest' VM object under 
    the assumption that good candidates for page reuse would likely be 
    found there)... if you happen to choose a VM object which is being
    very actively used by the system, then try to reuse/flush a page from
    it, you wind up stalling whatever process was using it even if other
    VM objects have better candidates. 

    Nor do you want to scan ALL VM objects to locate the best page -- that
    would lead to O(N^2) cpu overhead in locating the page.  FreeBSD
    locates the page candidate using the page queues because it can do so
    in an O(N) or better manner (usually it's more around O(1)).
    
:>     Second, start keeping real statistics on memory use across on a
:>     physical-page-basis.  That means tracking how often VM pages are 
:>     referenced (statistically) as well as how often filesystem pages are 
:>     referenced by discrete I/O calls (deterministically).  Keep track of
:>     a real per-physical-page statistical 'weight'.  (What this means for
:>     linux is that you really need to test the pte's associated with physical
:>     pages by iterating through the physical pagse in your outer loop, NOT 
:>     by trying to iterate through every page table of every process!).
:
:Hmmm, why would it matter in what order we scan stuff?

    The problem here is that any given page of physical memory may exist
    in the virtual address space of many processes.  If you scan by iterating
    through process page tables you wind up giving an artificial advantage
    (or disadvantage) to shared pages.  This is not a good measure of whether
    the page can be reused.  Also, iterating through the process page tables
    means going through an unknown number of pte's and blowing your L1
    cache in the process -- it doesn't scale.  Iterating through physical
    memory and then locating the associated pte's treats each page on a more
    equal footing, irregardless on how much or how little it is being shared
    in regards to updating its statistics.  

    A massively shared page that happens to be very active already gets the
    benefit of being accessed by multiple processse (setting the ref'd 
    bit), you don't need to give it any special handling.

:>     FreeBSD keeps a center-weighted statistic for every page of memory 
:>     (buffer cache or VM cache, it makes no difference).   This has turned
:>     out to be a nearly perfect balancing algorithm and I strongly recommend
:>     that linux adopt a similar model.  But what makes it work is that
:>     FreeBSD is willing to eat a couple of cpu cycles to keep accurate
:>     statistics of page use by the VM system in order to avoid the bad
:>     things that happen when one would otherwise choose the wrong page to
:>     reuse or clean.
:
:I fully agree on this point. Linus and Andrea have always been
:a strong opponent of any possible "overhead", leading to a VM
:subsystem that is optimised for CPU use, not for managing memory ;(

    I think you could sell it to them if you make it clear that the 
    statistics do not eat cpu unless the system is stressed (FreeBSD doesn't
    even bother doing the page scan unless it thinks the system is 
    stressed), and when the system is stressed it makes a whole lot more
    sense to eat cpu choosing the right page since choosing the wrong page
    can lead to hundreds of thousands of wasted cpu cycles doing unnecessary
    paging and even more real-time in process stalls.

:>......  (all sorts of good stuff removed)

:>     Memory load is calculated in two ways:  First, if the memory system finds
:>     itself reusing active pages (in my example, any page with a statistical
:>     weight greater then 5), second based on the dirty:clean page ratio.  A
:>     high ratio does not itself cause paging to occur, but a high ratio 
:>     combined with the system reusing active pages does.
:
:Hmmmm, this isn't what I'm seeing in the code. Could you point me
:at the code where this is happening?

    Yes.  It's confusing because FreeBSD implements the stress calculation
    with additionals page queues rather then attempt to keep a single
    queue sorted by weight, which can be expensive.  When the system 
    allocates a page (vm_page_alloc() in vm/vm_page.c) it uses free pages 
    first (there usually aren't very many truely free pages), then cache
    pages (basically clean 'idle' pages), and if this fails it wakes up
    the page daemon, blocks, and retries.  The page daemon is responsible
    for moving pages into the cache for use by the allocator.

    The page daemon (vm/vm_pageout.c, vm_pageout() and vm_pageout_scan())
    is responsible for adjusting act_count (see vm_pageout_scan()) and
    adjusting the position of pages in their queues.

    The page daemon starts by scanning pages in the inactive queue.  Pages
    in this queue have no mmu mappings and have been determined to be
    relatively inactive.  Within the queue the pages are loosely ordered
    by weight (trying to order them exactly would waste too much cpu).
    See the 'rescan0' label in vm/vm_pageout.c.  While scanning this queue
    the pageout daemon updates the activity weighting for the page by
    checking the PG_REFERENED bit.

    The inactive queue also tends to contain dirty pages to launder.  The
    page daemon does not flush out dirty pages immediately, if it can't
    find enough clean pages in the inactive queue (line 927 in 
    vm/vm_pageout.c, see 'If we still have a page shortage'), it goes up
    and rescans the inactive queue to start the pageout ops on some of
    its pages before going on to the active queue.

    If there is still a page shortage the page daemon then scans the active
    queue.  Line 943 'Scan the active queue for things we can deactivate'.
    This queue is also loosely sorted by the page weighting and as with the
    inactive queue scan the loop also checks the page-referenced bit to
    update the weighting on the fly while scanning the active queue.

    Under normal conditions, pages are not deactivated until the active
    count reaches 0.  Line 1013 of vm/vm_pageout.c.

    This is where the stress test is implied.  If the page daemon scans the
    active queue and does not find any pages whos weighting has reached 0,
    then it starts to hit around line 1077 (the vm_paging_target() test)
    and becomes much more aggressive with the syncer and swapper.  At
    line 1097 if we determine that we have run out of swap and also do
    not have sufficient clean pages, we start killing processes.

    I'll get back to the vm_paging_target() function in a second.

    The vm_daemon() is responsible for the next stage of aggressiveness
    in a heavily loaded system.  The daemon is responsible for testing
    processes against their resident-memory rlimit and forcefully deactivating
    pages.  The daemon also notices processes marked as being swapped out 
    and is more agressive on those processes (the act of marking a process
    as being swapped out does not actually pageout any of its pages, but
    if the system swapper is activated in a heavy-use situation it will 
    use the mark to then agressively swap out that process's pages).

    Ok, back to vm_paging_target().  This function (sys/vmmeter.h) is
    responsible for balancing the clean/dirty ratio by forcing pages
    to be moved from the active queue to the inactive queue if insufficient
    pages were found and no pages in the active queue were found with 
    a 0 weighting.  This is the stress test.  If the page daemon was not
    able to find a sufficient number of pages in the active queue with a 0
    weighting, it assumes that the memory system is under stress and speeds
    up the syncer and moer-agressively enforces RSS resource limits
    (vm/vm_pageout.c line 1081).


    I will readily admit that FreeBSD suffers from accretions here... there
    has been a lot of hacking of the code.  The main reason FreeBSD is not
    using a completely pure center-weighted LRU algorithm is to avoid 
    thrashing.  It attempts to enforce leaving a page in the active queue
    for a certain minimum period of time (based on the weighting having to
    drop to 0 in order for the page to leave the queue), and FreeBSD doesn't
    mind stalling processes a bit if this winds up occuring because if it
    takes recently activated pages out of the active queue too quickly,
    the system's thrash point occurs a lot sooner.

:...
:
:>     When the memory load increases, an attempt is made to balance the
:>     dirty/clean ratio by 'cleaning' dirty pages, which of course means
:>     paging them out.   FreeBSD makes NO distinction between writing a dirty
:>     file-backed page and allocating swap for a dirty anonymous memory page.
:>     The same per-page memory-use statistic is also used to determine which
:>     dirty pages to clean first.  In effect, it is precisely this attempt
:>     to balance the dirty/clean ratio which increases the number of clean
:>     pages available to reuse.  The idea here is to increase the number of
:>     clean pages to the point where the system is no longer being forced
:>     to reuse 'active' pages.  Once this is achieved there is no longer any
:>     need clean the remaining dirty pages.
:
:I've read the code and it seems to do this:
:- put inactive pages in the cached queue
:- launder up to maxlaunder pages per scan (if needed)

    Correct.  Basically the way to think of the algorithm is to ignore
    the fact that an active queue exists at all.  The active queue holds
    pages in an unstressed memory environment.  In a stressed memory 
    environment the active queue imposes a minimum in-core-resident time
    for the page to avoid thrashing.  

    The system implements the page weighting independantly for both the 
    active and inactive queues.  Under medium stress conditions pages
    are moved from the active to the inactive queue based on their weighting
    reaching 0.  Once in the inactive queue (under medium stress conditions),
    pages tend to be LRU ordered (all their weightings tend to be 0 at this
    point).  But under heavier loading conditions pages may be moved from
    the active to the inactive queue forcefully, before their weighting 
    reaches 0.  In this case the inactive queue serves the same loosely-sorted
    weighting function that the active queue was supposed to serve until
    it too runs out of pages.

    The page laundering code is stuffed in the middle there somewhere using
    a simple heuristic to try to start laundering pages during the inactive
    queue scan.  It is not strictly based on page weighting but it winds up
    being that way due to the loosely weighted ordering of the pages in the
    queue.

:>     Under extreme memory loads the balance point moves on its own to a
:>     point where FreeBSD tries to keep as many pages in a clean state as
:>     possible.  When the memory load gets to this point the system is 
:>     considered to be thrashing and we start taking anti-thrashing measures,
:>     such as swapping out whole processes and holding them idle for 20-second
:>     spans.  It rarely gets to this point, but even when it does the system
:>     is still kept reasonably balanced.
:
:Uhmmmm. This does not seem to be exactly what the code does...
:(then again, I could be wrong)

    Your right.  It isn't *exactly* what the code does, but it's the
    algorithmic effect minus the confusion of implementing the algorithm
    over multiple page queues (active/inactive/cache), which was done 
    solely to avoid page thrashing.

:Always trying to keep 1/3rd of the mapped pages in an "inactive"
:age is probably a good idea for Linux. The biggest problem with
:our code seems to be that we're *not* trying to have a balanced
:aging of pages ...

    That's my take too.  Also note that FreeBSD doesn't bother deactivating
    pages unless there is actually some stress on the memory system... if 
    you look at a lightly loaded FreeBSD box you will see a huge number of
    'active' pages -- most of those are probably idle.  The moving of pages
    from queue to queue only occurs when the memory allocator starts to run
    out.  This alone does not indicate stress... it's only when the page
    daemon is unable to find sufficient pages in the active queue with a
    0 weighting where the stress starts to come into play.

:>     * Stressing dirty pages in the system via I/O calls (read/write)
:> 
:> 	The algorithm tends to cause sequential I/O calls to give pages
:> 	a middling weight, and since the pages are not reused they tend 
:> 	to be recycled within their domain (so you don't blow the rest
:> 	of the cache).
:
:This is a good argument for starting at a middle weight. Thanks
:for bringing this case to my attention, we really want something
:like this.

    This is something I added to FreeBSD 4.x after tests showed that
    FreeBSD 3.x was 'blowing' the page cache unnecessarily when people
    would do things like tar up directory trees.  It made a big difference
    in the performance of the rest of the system without effecting the
    I/O bound process.

    There is a gotcha, though-- you have to be careful to allow some
    balancing to occur so you do not recycle too-few pages within the
    domain.  e.g. if the domain is only 10 pages, then the tar or dd or
    whatever is throwing away potentially cache able file pages much to soon.
    I have a hack in 4.x now that slowly balances this case.  See
    vm_page_dontneed() in vm/vm_page.c.

:
:>     * Stressing dirty pages in the system via mmap (shared R+W)
:> 
:> 	The system tends to run low on clean pages, detected by the
:> 	fact that new allocations are reusing clean pages which have high
:> 	weights.  When this occurs the pageout daemon attempts to 'clean'
:> 	dirty pages (page them out) in order to increase the number of
:> 	clean pages available.  Having a larger number of clean pages 
:> 	available tends to give them more time to age, thus reducing the
:> 	average weight the allocator sees.  This is a negative feedback
:> 	loop which results in balance.
:
:Hummm, where in the code can I find info on this?
:It certainly sounds interesting...

    This is a side effect of the maxlaunder stuff in the inactive page
    scan done by the page daemon.  However, under heavier load situations
    we also speedup the filesystem syncer, and we also, through other means,
    speed up the buffer daemon (which is responsible for staging out I/O
    related to dirty filesystem buffers).

:> 	page.  Once swap is assigned the clean page can be reused.  
:> 
:> 	If a swap-backed page is brought back into memory, it is brought
:> 	back in clean (swap is left assigned).   Swap is only freed if
:> 	the page is re-dirtied by the process.  
:> 
:> 	Thus most anonymous-memory pages in a heavily loaded system tend
:> 	to remain clean, allowing them to be reused more easily and extending
:> 	the life of the system further along the curve before it reaches a
:> 	thrashing state.
:
:A few points:
:- it may be easier to assign swap entries based on virtual
:  scanning of processes, otherwise you'll end up with the
:  strange jumping between queue scanning and virtual scanning
:  that FreeBSD is doing now

    No, because a physical page may be associated with many processes
    and thus have multiple virtual copies.  Scanning by virtual results
    in improperly weighting these pages and winds up being an O(N^2)
    scanning algorithm rather then an O(N) or O(1) algorithm.

    FreeBSD scans physical pages in order to guarentee deterministic 
    algorithmic overhead and to avoid unnecessary redundant scanning.

    The two-phase I/O clustering operation is done on purpose... it may seem
    a bit strange to you but it actually works!  The first phase is to
    locate the page candidate (the center weighted LRU algorithm), the second
    phase is to locate clusterable pages near that candidate.  The second
    phase is explicitly restricted to candidates which wind up being
    contiguous on the physical media... if we are going to do an I/O we might
    as well make the best of it.  The clustering goes to the core of the
    reason why FreeBSD remains reasonably efficient even when under very
    heavy loads, but it only works if FreeBSD is able to choose the right
    page candidate in the first place.

:- vnodes are why FreeBSD is able to delay writing anonymous
:  pages till later on

:- not every page weighs equally ... you want some fairness
:  between memory hogs and small processes

    This is handled by the 'memoryuse' resource limit.  You cannot otherwise
    determine which is the more important process.  You definitely do not
    want to make the assumption that the processes with larger RSS should
    be paged out moer... that will lead to serious performance problems
    with things like, oh, your X session.

    So FreeBSD does not make the distinction until it sees serious memory
    stress on the system.  FreeBSD tries to operate strictly based on the
    page-use weighting.

:- Linux already does the don't-rewrite-clean-swap thing
:
:... (more good stuff removed)
:> 
:> 	A heuristic detects sequential read behavior and implements two
:> 	optimizations.  (1) it implements read-aheads (as long as they
:> 	are reasonably contiguous on the physical media, we explicitly do
:...
:
:Ohhhh, nice ;)
:
:>     * Sequential Detection Heuristic for read clustering (VM fault)
:> 
:> 	A heuristic detects sequential VM fault operation, either forwards
:...
:
:Again ... neat.

    Yes.  These optimizations have the side effect of reducing memory 
    stress as well, which makes the LRU center weighting algorithm work
    better.

:>     * Sequential Detection Heuristic for write clustering (write())
:> 
:> 	In the case of write() I/O (write system call), in order to
:> 	avoid saturating the memory system with dirty pages, if the
:...
:
:Cool.

    Same effect on the LRU cw algorithm.

:>     * Sequential Detection Heuristic for write clustering (mmap)
:> 
:> 	Currently not implemented under FreeBSD.  This used to be a big
:> 	problem because you could completely saturate the VM system with
:> 	dirty pages before the system even realized it.  To fix this we
:> 	threw in a memory-stress check in vm_fault to block when dirtying
:> 	pages in the face of having too many dirty pages already, giving
:> 	I/O a chance to catch up a little.
:> 
:> 	This actually improved performance because it left a greater number
:> 	of clean pages available and so the page selection algorithm in the
:> 	allocator worked better (tended to select idle pages rather then
:> 	active pages).
:
:This is an extremely good idea. When we have too many (or just,
:a lot of) dirty pages, we should delay faults in write-enabled
:VMAs, while allowing faults in read-only VMAs to proceed as
:fast as possible ...
:
:regards,
:
:Rik

    Happy to help!  If you have any other questions don't hesitate to
    give me an email ring, I really enjoy talking tech with people who
    know what they are doing :-).

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256283.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Date: Tue, 23 May 2000 15:11:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
X-Sender: riel@duckman.distro.conectiva
To: Matthew Dillon <dillon@apollo.backplane.com>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
In-Reply-To: <200005231706.KAA68220@apollo.backplane.com>
Message-ID: <Pine.LNX.4.21.0005231454380.19121-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Tue, 23 May 2000, Matthew Dillon wrote:

> :I'm already looking at implementing this (and have been for a few
> :weeks). I'm reading vm/vm_pageout.c in detail now, mainly to scan
> :for pitfalls which I may have overlooked in my own design.
>  
>     Great!

I'm currently looking at which part of the code I can implement
before 2.4 is released by Linus. I've read your email and would
like to think I'm understanding most of the rationale behind the
FreeBSD VM subsystem...

> :- not every page weighs equally ... you want some fairness
> :  between memory hogs and small processes
>
>     This is handled by the 'memoryuse' resource limit.  You cannot otherwise
>     determine which is the more important process.  You definitely do not
>     want to make the assumption that the processes with larger RSS should
>     be paged out moer... that will lead to serious performance problems
>     with things like, oh, your X session.

This is not exactly what the antihog code does. It will scan
bigger processes more often, leading (hopefully) to:
1) better statistics about which pages are really used in big
   processes
2) better interactive performance because the lightly used memory
   of the user's shell is not paged out
3) more memory pressure on big processes, I've seen this speed
   up the system because
	a) small processes had less page faults
	b) the memory hog(s) had less disk wait time

I haven't seen this code be any problem to X or other interactive
processes ... if the memory is really used it won't be paged out,
it's just that a big process will have to use its pages more heavily
than a smaller process. To express this mathematically:

A = process a, rss size(A)
B = process b, rss size(B)    [N times size(A)]
P(X) = memory pressure on process X

	P(B) = P(A) * (size(B)/size(A)) * sqrt(size(B)/size(A))

and the memory pressure on every page from process B will be:

	P(page in B) = P(page in A) * sqrt(size(B)/size(A))

I know this doesn't give the best system-wide aging of pages,
but it should provide fairer distribution of memory between
processes. There are no artificial restrictions on processes
with a big RSS, the only thing is that we pressure their pages
harder (and will inactivate their pages sooner).

This makes sure that a big process (that puts a lot of load on
the VM subsystem) does not "transfer" its memory load to smaller
processes. Lightly used pages in smaller processes will still be
paged out in favor of heavily used pages in the big process, but
small processes have a better chance of running well.

This is doing something comperable to what the swap code is
doing (penalise big processes more than small ones), but does
it in the paging code. It allows a few big processes to grow
until the point where they are thrashing without impacting
the rest of the system too much.

Then again, this VMS-influenced idea could be all wrong. I'd
*love* to hear your view on this ...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256284.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Return-Path: <dillon@apollo.backplane.com>
Received: from perninha.conectiva.com.br (perninha.conectiva.com.br [200.250.58.156])
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id QAA21732
	for <riel@duckman.distro.conectiva>; Tue, 23 May 2000 16:39:31 -0300
Received: from apollo.backplane.com (apollo.backplane.com [216.240.41.2])
	by perninha.conectiva.com.br (8.9.3/8.9.3) with ESMTP id QAA30959
	for <riel@conectiva.com.br>; Tue, 23 May 2000 16:39:47 -0300
Received: (from dillon@localhost)
	by apollo.backplane.com (8.9.3/8.9.1) id MAA69005;
	Tue, 23 May 2000 12:39:07 -0700 (PDT)
	(envelope-from dillon)
Date: Tue, 23 May 2000 12:39:07 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005231939.MAA69005@apollo.backplane.com>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
References: <Pine.LNX.4.21.0005231454380.19121-100000@duckman.distro.conectiva>


:This is not exactly what the antihog code does. It will scan
:bigger processes more often, leading (hopefully) to:
:1) better statistics about which pages are really used in big
:   processes
:2) better interactive performance because the lightly used memory
:   of the user's shell is not paged out
:3) more memory pressure on big processes, I've seen this speed
:   up the system because
:	a) small processes had less page faults
:	b) the memory hog(s) had less disk wait time
:
:I haven't seen this code be any problem to X or other interactive
:processes ... if the memory is really used it won't be paged out,
:it's just that a big process will have to use its pages more heavily
:than a smaller process. To express this mathematically:
:
:A = process a, rss size(A)
:B = process b, rss size(B)    [N times size(A)]
:P(X) = memory pressure on process X
:
:	P(B) = P(A) * (size(B)/size(A)) * sqrt(size(B)/size(A))
:
:and the memory pressure on every page from process B will be:
:
:	P(page in B) = P(page in A) * sqrt(size(B)/size(A))
:
:I know this doesn't give the best system-wide aging of pages,
:but it should provide fairer distribution of memory between
:processes. There are no artificial restrictions on processes
:with a big RSS, the only thing is that we pressure their pages
:harder (and will inactivate their pages sooner).
:
:This makes sure that a big process (that puts a lot of load on
:the VM subsystem) does not "transfer" its memory load to smaller
:processes. Lightly used pages in smaller processes will still be
:paged out in favor of heavily used pages in the big process, but
:small processes have a better chance of running well.
:
:This is doing something comperable to what the swap code is
:doing (penalise big processes more than small ones), but does
:it in the paging code. It allows a few big processes to grow
:until the point where they are thrashing without impacting
:the rest of the system too much.
:
:Then again, this VMS-influenced idea could be all wrong. I'd
:*love* to hear your view on this ...
:
:regards,
:
:Rik

    Well, I have a pretty strong opinion on trying to rationalize
    penalizing big processes simply because they are big.  It's a bad
    idea for several reasons, not the least of which being that by
    making such a rationalization you are assuming a particular system
    topology -- you are assuming, for example, that the system may contain
    a few large less-important processes and a reasonable number of
    small processes.  But if the system contains hundreds of small processes
    or if some of the large processes turn out to be important, the
    rationalization fails.   

    Also if the large process in question happens to really need the pages
    (is accessing them all the time), trying to page those pages out
    gratuitously does nothing but create a massive paging load on the
    system.  Unless you have a mechanism to (such as FreeBSD has) to 
    impose a 20-second forced sleep under extreme memory loads, any focus
    on large processes will simply result in thrashing (read: screw up
    the system).

    Another reason for not trying to weight things in favor of small
    processes is that the LRU algorithm *already* weights things in favor
    of small processes, simply by virtue of the fact that small processes
    tend to access/touch any given page in their RSS set much more often
    then large processes access/touch their pages.  The same goes for
    shared pages --- which is why basing the algorithms on a physical page
    scan works well.  Basing algorithms on a virtual page scan, with lots
    of physical pages being redundantly scan, skews the statistics badly.

    FreeBSD has two mechanisms to deal with large processes, both used only
    under duress.  The first occurs when FreeBSD hits the memory
    stress point - it starts enforcing the 'memoryuse' resource limit on
    processes.  The second occurs when FreeBSD hits the 'holy shit we're
    starting to thrash' point - it starts forcefully swapping out processes
    and holding them idle for 20-second periods (p.s. I have never personally
    seen a production FreeBSD box get to the second stress point!).

    Keep in mind that memory stress is best defined as "the system reused or
    paged-out a page that some process then tries to use soon after".  When
    this occurs, processes stall, and the system is forced to issue I/O
    (pageins) to unstall them.  Worse, if the system just paged the page out
    and then has to turn around and page it back in, the processes stall even
    longer AND you wind up with a doubly-whammy on the I/O load -- this is
    my definition of thrashing.  Attempting to reuse pages from large 
    processes which are truely accessing those pages will thrash the system
    much sooner then simply treating all pages and processes the same and
    focusing on the page-activity weighting.

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256285.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Date: Tue, 23 May 2000 20:18:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
X-Sender: riel@duckman.distro.conectiva
To: Matthew Dillon <dillon@apollo.backplane.com>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
In-Reply-To: <200005231939.MAA69005@apollo.backplane.com>
Message-ID: <Pine.LNX.4.21.0005231823290.19121-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Tue, 23 May 2000, Matthew Dillon wrote:

> :A = process a, rss size(A)
> :B = process b, rss size(B)    [N times size(A)]
> :P(X) = memory pressure on process X
> :
> :	P(B) = P(A) * (size(B)/size(A)) * sqrt(size(B)/size(A))
> :
> :and the memory pressure on every page from process B will be:
> :
> :	P(page in B) = P(page in A) * sqrt(size(B)/size(A))
> 
>     Well, I have a pretty strong opinion on trying to rationalize
>     penalizing big processes simply because they are big.  It's a bad
>     idea for several reasons, not the least of which being that by
>     making such a rationalization you are assuming a particular system
>     topology -- you are assuming, for example, that the system may contain
>     a few large less-important processes and a reasonable number of
>     small processes.  But if the system contains hundreds of small processes
>     or if some of the large processes turn out to be important, the
>     rationalization fails.   

The main assumption I was making here was that memory usage
would be dominated by a small number bigger programs and not
by a larger number of small processes. I see your point in
that I may be wrong here in some situations.

Also, memory pressure per page increases only two-fold if the
bigger process is four times bigger that the smaller process...
(likewise, 4 times for a 16 times bigger process, etc)

>     Also if the large process in question happens to really need the pages
>     (is accessing them all the time), trying to page those pages out
>     gratuitously does nothing but create a massive paging load on the
>     system.

But we don't. All we do is scan those pages more often. If
the big process is really using them all the time we will
not page them out. But we *will* try the pages of the big
process more often than the pages of smaller processes...

>                Unless you have a mechanism to (such as FreeBSD has) to 
>     impose a 20-second forced sleep under extreme memory loads, any focus
>     on large processes will simply result in thrashing (read: screw up
>     the system).

I have a proposal for this that could be implemented relatively
easily. It is a variant on the swapping scheme that ITS had a
long long time ago and is "somewhat" different from what any of
the Unices has. Since I didn't get a lot of response from the
Linux community (some "sweet, I hope it works" replies on IRC)
I'd be really interested in what someone like you would have to
say (or other people in the know ... do you know any?).

    http://mail.nl.linux.org/linux-mm/2000-05/msg00273.html

>     Another reason for not trying to weight things in favor of small
>     processes is that the LRU algorithm *already* weights things in favor
>     of small processes, simply by virtue of the fact that small processes
>     tend to access/touch any given page in their RSS set much more often
>     then large processes access/touch their pages.  The same goes for
>     shared pages --- which is why basing the algorithms on a physical page
>     scan works well.  Basing algorithms on a virtual page scan, with lots
>     of physical pages being redundantly scan, skews the statistics badly.

I'm curious about this ... would a small interactive task like
an xterm or a shell *really* touch its pages as much as a Netscape
or Mathematica?

I have no doubts about the second point though .. that needs to 
be fixed. (but probably not before Linux 2.5, the changes in the
code would be too invasive)

>     FreeBSD has two mechanisms to deal with large processes, both used only
>     under duress.  The first occurs when FreeBSD hits the memory
>     stress point - it starts enforcing the 'memoryuse' resource limit on

I've grepped the source for this but haven't been able to find
the code which does this. I'm very interested in what is does
and how it is supposed to work (and how it would compare to my
"push memory hogs harder" idea).

>     processes.  The second occurs when FreeBSD hits the 'holy shit we're
>     starting to thrash' point - it starts forcefully swapping out processes
>     and holding them idle for 20-second periods (p.s. I have never personally
>     seen a production FreeBSD box get to the second stress point!).

hehe

>     Keep in mind that memory stress is best defined as "the system reused or
>     paged-out a page that some process then tries to use soon after".  When
>     this occurs, processes stall, and the system is forced to issue I/O
>     (pageins) to unstall them.  Worse, if the system just paged the page out
>     and then has to turn around and page it back in, the processes stall even
>     longer AND you wind up with a doubly-whammy on the I/O load -- this is
>     my definition of thrashing.  Attempting to reuse pages from large 
>     processes which are truely accessing those pages will thrash the system
>     much sooner then simply treating all pages and processes the same and
>     focusing on the page-activity weighting.

Ahh, but if a process is truely using those pages, we won't page
them out. The trick is that the anti-hog code does *not* impose
any limits ... it simply makes sure that a big process *really*
uses its memory before it can stay at a large RSS size.

(but I agree that this is slightly worse from a global, system
throughput point of view .. and I must admit that I have no
idea how much worse it would be)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--655889-1110733960-959184177=:24993
Content-Type: MESSAGE/RFC822; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0005241256286.24993@duckman.distro.conectiva>
Content-Description: Re: Linux VM/IO balancing (fwd to linux-mm?) (fwd)

Return-Path: <dillon@apollo.backplane.com>
Received: from perninha.conectiva.com.br (perninha.conectiva.com.br [200.250.58.156])
	by duckman.distro.conectiva (8.9.3/8.8.7) with ESMTP id VAA23117
	for <riel@duckman.distro.conectiva>; Tue, 23 May 2000 21:32:56 -0300
Received: from apollo.backplane.com (apollo.backplane.com [216.240.41.2])
	by perninha.conectiva.com.br (8.9.3/8.9.3) with ESMTP id VAA06276
	for <riel@conectiva.com.br>; Tue, 23 May 2000 21:32:46 -0300
Received: (from dillon@localhost)
	by apollo.backplane.com (8.9.3/8.9.1) id RAA70157;
	Tue, 23 May 2000 17:31:50 -0700 (PDT)
	(envelope-from dillon)
Date: Tue, 23 May 2000 17:31:50 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005240031.RAA70157@apollo.backplane.com>
To: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Linux VM/IO balancing (fwd to linux-mm?)
References: <Pine.LNX.4.21.0005231823290.19121-100000@duckman.distro.conectiva>



:>     Also if the large process in question happens to really need the pages
:>     (is accessing them all the time), trying to page those pages out
:>     gratuitously does nothing but create a massive paging load on the
:>     system.
:
:But we don't. All we do is scan those pages more often. If
:the big process is really using them all the time we will
:not page them out. But we *will* try the pages of the big
:process more often than the pages of smaller processes...
:...

     I don't think this really accomplishes your goal because the effect
     of choosing the wrong page to reuse/flush is the same whether that
     page comes from a large process or a small process.  The effect 
     being a disk I/O and (if the wrong page is chosen) the process faulting
     it back in immediately (a second disk I/O).  This effects the entire
     system, not just that one process.

     When you skew the algorithm towards the larger process you are in effect
     penalizing the large process, which I think is what you are trying to
     accomplish.  BUT, you are also penalizing the entire system by virtue
     of causing the extra disk I/O.  That's two marks against the idea...
     penalizing a large process without knowing whether it deserves to be
     penalized, and causing extra disk I/O by choosing the 'wrong' page
     (that is, choosing a page that is likely to result in more disk activity
     by being more active then the skewed statistic believes it is).

     In a heavily loaded environment, using the normal center-weighted
     LRU algorithm, a larger process is going to be penalized anyway by
     virtue of the fact that it has more pages to be potentially reused.
     I don't think you want to penalize it even more.

     Quick mathmatical proof:  If you have a small process with 10 pages in
     core and a large process with 100 pages in core, and all the pages have
     the same weighting, and the allocator tries to allocate a new page,
     90% of the allocations are going to be taken from the large process
     and only 10% will be taken from the small process.  Thus the large
     process is already being penalized by the normal algorithm... you 
     don't have to penalize it any more.  The algorithm is self-correcting
     for large processes.

:I have a proposal for this that could be implemented relatively
:..
:
:    http://mail.nl.linux.org/linux-mm/2000-05/msg00273.html

    Very interesting idea!  In reference to your comment 
    'swapping doesn't actually swap anything...' near the end...
    this is *precisely* the method that FreeBSD uses when
    the idle-swap system feature is turned on.  FreeBSD also 
    depresses the activity weight for the pages to make it
    more likely to be reused (FreeBSD does this simply by moving the
    page out of the active queue and onto the inactive queue).

    I'm not sure you can use p->state as one of the basis for your
    memory load calculation, because there are many classes of I/O
    bound applications which nevertheless have low memory footprints.

    You have to be careful not to generate a positive feedback loop.
    That is, where you make some calculation X which has consequence Y
    which has the side effect of increasing the calculation X2, which
    has consequence Y2, and so forth until the calculation of X becomes
    absurd and is no longer a proper measure of the state of the system.

:I'm curious about this ... would a small interactive task like
:an xterm or a shell *really* touch its pages as much as a Netscape
:or Mathematica?
:
:I have no doubts about the second point though .. that needs to 
:be fixed. (but probably not before Linux 2.5, the changes in the
:code would be too invasive)

    Yes, absolutely.  Its simply due to tighter code... with fewer 
    active pages, smaller processes tend to touch more of them whenever
    they do anything (like hitting a key in an xterm).  Larger processes
    tend to zone their memory.   They will have a core set of pages
    they touch as much as any other process, but the more complex issues
    of larger processes will also touch additional pages depending on 
    what they are doing.  

    So with something like Netscape the 'broader core' set of pages it
    touches will be different depending on what site you are visiting.
    As you visit more sites, the RSS footprint starts to bloat, but many
    of those pages will tend to be more 'idle' then the core pages in the
    smaller process.

:>     FreeBSD has two mechanisms to deal with large processes, both used only
:>     under duress.  The first occurs when FreeBSD hits the memory
:>     stress point - it starts enforcing the 'memoryuse' resource limit on
:
:I've grepped the source for this but haven't been able to find
:the code which does this. I'm very interested in what is does
:and how it is supposed to work (and how it would compare to my
:"push memory hogs harder" idea).

    vm/vm_pageout.c, vm_daemon() process, aroudn line 1392.  The vm_daemon
    is only woken up under certain heavy load situations.  The actual
    limit check occurs on line 1417.  The actual forced page deactivation
    occurs on line 1431 (the call to vm_pageout_map_deactivate_pages).

    The enforced sleep is handled by the swapin code.  vm/vm_glue.c
    line 364 (in scheduler()).  If a process is forcefully swapped out,
    it is not allowed to wakeup until the system has recovered sufficiently
    for it to be able to run reasonably well.  The longer the process 
    stays in its forced sleep, the more likely it will be given the cpu back
    so after a certain point it *will* wake up again, even if the system
    is still thrashing.  It's not strictly 20 seconds any more (it was in
    pre-freeware BSDs).

    ( I'm assuming you are using the 4.x source tree as your reference 
    here ).



:>     Keep in mind that memory stress is best defined as "the system reused or
:>     paged-out a page that some process then tries to use soon after".  When
:>     this occurs, processes stall, and the system is forced to issue I/O
:>     (pageins) to unstall them.  Worse, if the system just paged the page out
:...
:
:Ahh, but if a process is truely using those pages, we won't page
:them out. The trick is that the anti-hog code does *not* impose
:any limits ... it simply makes sure that a big process *really*
:uses its memory before it can stay at a large RSS size.

    Everything starts to break down when you hit extreme loads.  Even
    simple things like trying to give priority to one type of process
    over another.  If you weight in favor of smaller processes and happen
    to be running on a system with larger processes, your algorithm could
    (for example) wind up scanning their pages *too* often, depressing their
    priority so quickly that the system may believe it can page out their
    pages when, in fact, those processes are still using the pages.

    Another example:  When a system starts to thrash, *ALL* processes 
    doing any sort of I/O (paging or normal I/O) begin to stall.  If under
    heavy load conditions your algorithm 'speeds up' the page scan on an
    unequal basis (only for certain processes), then the combination of 
    the sped-up scan AND the lower page access rate that is occuring due
    to the thrashing itself may lead your algorithm to believe it can
    steal pages from those processes when in reality stealing pages will
    only result in even worse thrashing.

    In fact, one of the reasons why FreeBSD went to a multi-queue approach
    was to avoid these sorts of positive feedback loops.  It has a separate
    'active' queue as a means of guarenteeing that when a page is faulted in,
    it *stays* in for a certain minimum period of time before being available
    for paging out again, and if the enforced wait causes the system to run 
    low on memory and stall more, then too bad -- the alternative (insane
    thrashing) is worse.

:(but I agree that this is slightly worse from a global, system
:throughput point of view .. and I must admit that I have no
:idea how much worse it would be)
:
:regards,
:
:Rik

					-Matt
					Matthew Dillon 
					<dillon@backplane.com>

--655889-1110733960-959184177=:24993--

--655889-1842000895-959184177=:24993--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
