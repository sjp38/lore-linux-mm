Date: Tue, 23 May 2000 09:35:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Linux VM/IO balancing (fwd to linux-mm?) (fwd)
Message-ID: <Pine.LNX.4.21.0005230934240.19121-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Hi,

here's an interesting tidbit I got from Matthew Dillon. A lot of
this is very interesting indeed and I guess we want some of it
before kernel 2.4 and most of it in kernel 2.5 ...

Rik
---------- Forwarded message ----------
Date: Mon, 22 May 2000 23:32:20 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
