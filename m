Received: from cs.utexas.edu (root@cs.utexas.edu [128.83.139.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA09980
	for <linux-mm@kvack.org>; Mon, 4 Jan 1999 19:32:16 -0500
Message-Id: <199901050031.SAA06940@disco.cs.utexas.edu>
From: "Paul R. Wilson" <wilson@cs.utexas.edu>
Date: Mon, 4 Jan 1999 18:31:25 -0600
Subject: Re: naive questions, docs, etc.
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: linux-mm@kvack.org, wilson@cs.utexas.edu
List-ID: <linux-mm.kvack.org>

Here's my first batch of notes on the VM system.  It's mostly 
introductory, overall-picture kinds of things, but I need
feedback on it before I can write nitty-gritty stuff.

---------------------------------------------------------------------------



          THE GNU/LINUX 2.2 VIRTUAL MEMORY SYSTEM, PART I

              <VERY ROUGH, INCOMPLETE FIRST PASS>

Comments welcome---send to wilson@cs.utexas.edu (Paul Wilson).

I. INTRODUCTION

This document introduces basic aspects of the design of the Linux
virtual memory system, circa version 2.2.  I assume people understand
basic VM concepts (like page tables and clock algorithms) and basically
how the Linux kernel works (system calls, etc.)

---

To understand the caching of pages, we must make a three-way distinction
between virtual pages, logical pages and page frames. 

  * A virtual page is a page as seen through an address mapping
    (e.g., in a page table) of a process.  That is, it's the page
    that lives at a particular page-sized page aligned range
    of addressing, as seen by the process.

  * A logical page is an abstract unit of storage, holding a page
    full of data.   It may be mapped as a particular virtual
    page from the point of view of one process, but as a different
    virtual page from the point of view of another process, or
    as a page-sized hunk of data in the file system when viewed
    through the file system.  (e.g., in the case of memory mapped
    files)

  * A page frame is a physical page of main memory (typically RAM)

There's really another category of page, which is a disk page,
but they're managed in several ways so I'll defer discussing them
until later.  Disk pages and page frames are actual units of storage.
Virtual pages are units of addressing (how pages are "named" by
a process).

---

The important thing to recognize is that logical pages are what
a program sees, but it sees them *as* virtual pages at particular
places in its address space.  Virtual and logical pages aren't
the same thing, and the virtual memory system has two
main jobs:

   1. keeping the active (recently-touched) logical pages in
      page frames (RAM pages).

      This is the job of the replacement mechanism, which evicts
      logical pages which haven't been touched recently from main
      memory, in favor of logical pages which have been touched
      recently.

   2. making sure that the right logical pages show up as the
      right virtual pages in any particular process's virtual
      memory mapping.

      This is the job of the address-mapping mechanisms, including
      page tables and "vm areas".

The virtual memory system also supports copy-on-write sharing
of pages, so that large regions of memory can be logically copied
without actually copying the pages until it's necessary.  In the
case of copy-on-write sharing, a given physical page may represent
multiple logical pages, which were "logically" copied when the
page was shared from one process to another.   (For example, a
vfork() logically copies the entire address space of a process,
but the actual copying occurs a page at a time as attempts
to modify pages cause write faults that transparently copy
the pages rather than letting them be modified.)

In the case of a copy-on-write shared page, the same physical
page (RAM page frame or disk page) represents more than one
logical page of storage, until and unless the actual copying
is done.


2. KERNEL MODE AND MAIN MEMORY ALLOCATION
=========================================

Kernel Mode and Physical Addressing
-----------------------------------

The Linux kernel sees memory at its actual physical addresses, either
by executing in "real mode" on some processors (like the early x86 
family processors), or by using a page table(s?) that map virtual
memory addresses to the corresponding physical addresses (e.g.,
on the Alphas).  One way or another, the kernel sees main memory
"as it is."

[  Question 0:  Is this right?  I've seen several conflicting
   descriptions.  Does the kernel execute in real mode on x86's,
   or use a kernel page table that's an identity function, or
   something else?  

   I actually have a bunch of questions related to this, and
   cache/TLB interactions, and NT-like NEITHER_IO, but I'll put
   off asking them. ]

In contrast, normal processes see memory via page tables that
give them their own virtual address spaces, and the virtual
address of a logical page has little to do with the physical
address it resides in---it's wherever the kernel decided to
put it.

On X86 processors, [the top?] 1 GB of the address space is reserved for
the kernel, and user processes cannot see that part of the address
space at all---no pages are mapped there in user-process page
tables.  On entry to the kernel, the addressing mode is changed,
and the kernel can see physical RAM there.  

   [ Question 0b: Can the kernel also see the user space of the 
     process its executing on behalf of, through the page table
     of the user process it's executing on behalf of?  That's
     how some OS's do it, so that kernel-mode drivers can copy
     straight from userspace to kernel space and vice versa,
     and can address memory either by user virtual address
     or physical address. ]

Kernel Memory Allocation
------------------------

The kernel manages the allocation of physical memory using several
memory allocators, the main one being kmalloc.  Kmalloc keeps track
of which regions of main memory are in use, and divides memory
up into blocks which are powers of two multiples of the virtual
memory page size.  A physical page of memory may be used to
cache a virtual memory page or file page, or as raw memory
for DMA I/0, or to hold page tables used by the VM system, or
to hold data structures belonging to the kernel itself, etc.

kmalloc

The main kernel memory allocator is kmalloc, which uses the
binary buddy system, and only manages blocks of memory whose
are a power-of-two multiple of the page size.  Kmalloc manages
physical memory by physical address---the blocks it returns
are contiguous in physical memory, and kmalloc itself knows
nothing about virtual memory.

This is imporant for supporting certain kinds of devices, which
require large blocks of contiguous physically-addressed memory,
such as DMA devices that bypass the CPU (and its address-translation
hardware).

The binary buddy system is a simple and relatively fast allocator,
but it is a poor allocator in many respects.  The fact that it can 
only manage block sizes in powers of two means that using it 
straightforwardly requires rounding the requested block
sizes up to a power of two, which can incur a large cost
in internal fragmentation, i.e., wasted space within blocks.

Linux therefore provides two other allocators for allocating
memory within the kernel.  The "slab" allocator gets largish
hunks of memory from kmalloc and carves them into smaller
pieces as needed, and vmalloc provides areas of contiguous
virtual memory that aren't necessarily contiguous in physical
memory.

The Slab Allocator

<NOT WRITTEN YET>  [ Is this basically the same design
                     as the "slab" allocator from a USENIX
                     paper a few years back? (McKusick & Karels?)]

vmalloc

<NOT WRITTEN YET>

[ But looking at it, it seems to allocate contiguous physical
  memory by default.  This seems like a mistake, and could
  be one cause of the fragmentation that was a problem before
  the slab allocator was added. ]



3. PAGE FRAMES, CORRESPONDING PAGE STRUCTS, AND LOGICAL PAGES
=============================================================

All page frames (physical RAM pages) have basic metadata stored in
an array named mem_map, which is parallel to the physical address
ordering of page frames in physical memory.  (E.g., the 2nd record
of mem_map describes the 2nd page frame.)  The elements of this
array are of type mem_map_t, better known by the typedef name
"page".  (See the header file mm.h and the comments there.)

(A page struct is not a page, and is not _part_ of a page---it's the
entry in the mem_map array that describes a page frame and its
current contents.  It acts as a kind of header, but the header is
"off to the side" in the mem_map array, rather than at the begining
of the page.)

A page frame may be used for other purposes than caching pages,
e.g., it may be part of an area holding the kernel's own data
structures. 

A page struct contains several fields, including a flags field
that holds flags describing how the page frame is being used

and what is stored in it.  It also holds several link fields,
for linking the page frame into a doubly-linked list and/or a
hash table.  These allow page frames to be linked together into
pools of page frames that are used in particular ways. 

The page struct has several flags used for synchronization purposes
and for the replacement mechanism.  It also has a "count" field 
indicating how many mappings of this page frame currently exist,
e.g., how many page table entries from (possibly) different processes
currently point to this page frame.

---

An important role of the page struct is to serve as a temporary
identifier of a logical page.  The virtual memory system ensures
that a given logical page is cached in at most one page frame
at any given time.   While it's there, a pointer to the corresponding
page struct can act as an identifier of the logical page, as
well as the page frame holding it.


Page Frames Holding Different Kinds of Logical Pages
----------------------------------------------------

A logical page of storage (which may be physically located in
a page frame or on disk) is commonly a page of a process's private
virtual address space, but may be a page of a (System V IPC) shm
(shared memory) segment, shared between processes, or a page of a
memory-mapped file.  (An mmapped page may also be shared, if multiple
processes map the same page(s) of a file into their address spaces.)
Different kinds of logical pages are identified in different
ways.

File pages

If a page frame is used to cache a (logical) page of a normal file,
the corresponding page struct's "inode" and "offset" fields hold
a pointer to the inode struct that the kernel uses to represent
the file, and the offset of the page within that file.  The combination
of the inode and the offset in the file is sufficient to uniquely
identify a logical page.

A page frame may be be subdivided, however, and used to buffer several
file blocks that are smaller than the page size.  In this case, the
corresponding page struct's "buffers" field points to a circular
list of "buffer head" structs representing those buffers.  

  [ QUESTION 1: I haven't looked at this very closely, or not with much
    comprehension.   Do sub-page buffers
    like this have to hold consecutive file blocks, or are
    they managed arbitrarily by the buffer cache replacement
    policy?  How does this interact with the main clock mechanism? ]


Private pages

A page frame may be used to cache an ordinary page of a process's
virtual address space, which is not part of a file or a shm segment
(see below).  [ AS I UNDERSTAND IT ] the page struct corresponding
to such a page does not store the identity of the page whose
contents it stores---the only record of what's there is in the
page tables of the processes.

  [ QUESTION 2: Is that right?  If so, it seems to me it'd be
    nicer to store a pointer to the task, or to a special kind of
    inode object belonging to the task.  This would be much
    more symmetrical, and would make the swapper more modular
    because it wouldn't have to invent identities for teh
    pages it caches.  It'd also be helpful in debugging
    and integrity-checking the kernel, and could be valuable
    information to a smarter swapper/clusterer.   (On a COW, the
    new page frame would get a pointer to the process that
    made the copy.)  Are page frames caching new private pages
    registered in any particular data structure?  ]

shm (IPC shared memory) pages

(This is a bit confusing because there are different senses of the
phrase "shared memory.")  Logical pages of memory mapped files may be
shared, but that's not what "shared memory" means in the Linux
VM system.  (I'll try to use the term "shm" when it's not obvious.)

Linux supports System V interprocess communication, which manages
regions of logical storage.  These are different from files, and
very different from regions of virtual storage.  

   [ QUESTION 2B: hmmm again... it seems like it would be good to 
     put the id of the shm segment in the page struct... or is that
     done? ]


4. ADDRESS MAPPING: VM_OPERATIONS, VM_AREAS, PAGE TABLES, PTE's
===============================================================

Linux uses several kinds of data structures and a hardware cache
(the Page Table Entry cache, a.k.a. TLB for "Translation 
Lookaside Buffer") to present the appropriate logical pages as
the right virtual pages, from a process's point of view.

The virtual memory mappings of a process are represented by two
data structures, one high-level (vm_area_struct's), and the other
low-level (page tables).  The high-level data structure describes
regions of the address space, but does not specify everything
about the state of individual pages.  The low-level data structure
(page table) provides detailed information on individual pages,
such as whether the page is in main memory, and if so, where.


VM AREAS
--------

The high-level structure is a list of vm_area structs summarizes
a process's use of its address space, with an entry for each
contiguous region of the address space (a range of pages) that
is treated differently from the preceding or following pages.
The list is ordered by address (virtual page number).

For example, when a process maps  a file into a previously
unoccupied part of its address space, the mmap system
call creates a vm_area struct recording the virtual page range
it is mapped to and how the kernel should handle operations like
page faults, copy-on-write page copies, and pageouts in that region.

These operations are specified by a pointer from the vm_area_struct
to a vm_operations_struct, which is simply a struct whose fields
contain function pointers, pointing to the functions for those
operations. 

When the kernel needs to perform a given operation on a given
page of a process's address space, it can search the list of
vm_area_struct's for the one describing the region containing
that page.   It can then extract the pointer to the vm_operations
struct, and from that extract the function pointer to perform
that operation.   (This is essentially a manual implementation
of virtual function tables as in C++;  the vm_area_struct is an
instance of of the class described by its vm_operations_struct,
which provide es the code to manipulate the instance.)

  [ QUESTION 3: Why isn't this actually done consistently?
    Some of this stuff is hardcoded, and it uglifies the
    code.

    There are several ugly code sequences that test whether a
    vm_area has a non-null vm_ops, and if so whether
    it has a function pointer for a particular operation,
    with hardcoded defaults for null values.

    Would it be easy to replace the null fields with
    simple wrappers (to either do nothing, or call the
    appropriate existing procedure)?  Or is there deep
    magic that would break because this stuff isn't actually
    modular?   I am a little afraid to touch it near it. ]

  [ QUESTION 4: There used to be AVL trees of vm_area_struct's.
    What happened to them?  Are they going to come back?
    Linear lists are bad news for some apps, including our
    page-faulting persistent object store, and process
    checkpointing.  It's also potentially bad for 
    generational GC's that use page protections to imlement
    the generational write barrier. ]

MULTILEVEL PAGE TABLES
----------------------

[Terminology warning here:  for a few paragraphs, I'll use the
 standard term "page table" to mean a whole (e.g., multilevel)
 page table that describes a whole address space.  Then I'll introduce
 the Linux terminology, in which a "page table" is only a lowest-level
 unit in a hierachical multilevel page table.  Bleah. ]
 
The page table of a process provides detailed information about
the pages visible to a process through its virtual address space,
and are used by the CPU and/or trap handlers to translate the
user processe's virtual addresses into physical addresses, so that
that the user process can access actual memory.

Conceptually, a page table is simply a very large array of "page
table entries," or pte's---one per page of the virtual address space.
Each element in this array corresponds to one page in the address
space, with the ordering of the page table entries corresponding
to the ordering of the virtual address pages they describe.

The PTE for a given virtual page records whether the page is in
main memory, and if so, which page of physical memory (the physical
address of the virtual page).  It also records certain auxiliary
information, such as whether the page has been touched recently,
and whether it has been dirtied (written to) recently---these
bits of information are used by the replacement policy that
manages the main-memory caching of VM pages.

The PTE also records protections that have been set on a page---whetehr
the process is allowed to read from or write to the page, and perhaps
whether it's allowed to execute code residing in that page.  Protectiosn
are used to ensure that processes do not modify things they're not
supposed to (such as a memory-mapped file mapped read-only), and
are also used to implement copy-on-write lazy copying of regions
of memory.

Page tables are not actually represented as very large contiguous
arrays, one per virtual page.  Instead, they are represented sparsely,
as a simple kind of multiway tree with a rigidly fixed geometry,
which typically has many missing subtrees.  (This is the classic
multilevel page table structure you'll see in any introductory
OS textbook.)

Cross-architecture 3-level Abstraction 

Actual computers of different types use different kinds of page
tables, with different numbers of levels.  The architecture-independent
parts of Linux kernel source code is written as though there were
always three levels of the page table structure, which there actually
are in Alpha Linux.

On the x86 processors, the multilevel page tables are actually
only two levels deep, which is sufficient for addressing a 4GB
address space (32-bit addressing) with 4KB pages.  The code
that traverses the "middle levels" of page tables does nothing
on the x86 architecture---it gets preprocessed and compiled
down to essentially nothing via platform-specific #ifdefs.  This
allows other code to be written as though all machines had
three-level page tables.

On x86 processors, the actual (two-level) geometry of page
tables is fixed in the hardware---the CPU actually traverses
the page tables without running any software.

On some other machines, there is no hardware support for
multilevel page tables at all;  these machines may use either
all-software page table searches, or something called an 
"inverted page table", which isn't really a page table in
the normal sense at all.   An inverted page table is
really a kind of secondary cache of page table entries,
stored in main memory, rather than a whole page table.

  [  PPC does this, right?---it has hardware probe of inverted
     page table, and trap to software on miss, IIRC.  Does Alpha
     or ARM, or any MIPS machines Linux runs on? ]

Linux terminology---names for levels

In Linux (Intel-derived?) terminology, the term "page table"
is not generally used for an entire multilevel page table.
Rather, the term "page table" is used to mean only the lowest-level
node of the multiway tree that implements the whole "page table"
in the normal sense.

The abstract three-level page table has a name for each kind of node.

  A top-level node is called a PAGE GLOBAL DIRECTORY, or "pgd",
  because it acts as the index to all the pages belonging to
  the process.

  A middle-level node is called a PAGE MIDDLE DIRECTORY, or "pmd"

  A bottom level is called a "page table,"  because it holds actual
  pte's describing particular (virtual) pages.


The PTE Cache (a.k.a. TLB)
--------------------------

All modern computers designed for virtual memory incorporate
a special hardware cache called a PTE cache or TLB (Translation
Lookaside Buffer), which caches page table entries in the CPU,
so that the CPU usually doesn't have to probe the page table to
find a PTE that lets it translate an address.

The PTE cache is the magic gadget that makes virtual memory
practical.  Without it the CPU would have to do extra main
memory reads for every read or write instruction executed by
the running program, just to look up teh PTE that let it
translate a virtual address into a physical one.

(Amazingly, IBM actually built such a horrible beast at one time.  
It was intended to be a compatible and cheap version of one of 
their expensive mainframes, and was intentionally so slow it didn't
signficantly cut into their market for the expensive fast ones.)

Rather than looking up a PTE in the page table each time it needs
to translate an address, the CPU looks in its page table entry cache
to find the right page table entry.  If it's there already, it reuses
it without actually traversing the page table.  Occasionally, the PTE
cache doesn't hold the PTE it needs, so the CPU loads the needed entry
from the page table, and caches that.

Note that a PTE cache does not cache normal data---it only caches
address translation information from the page table.  A page table
entry is very small, and the PTE cache only caches a relatively small
number of them (depending on the CPU, usually somewhere from 32 and
1024 of them).  This means that PTE cache misses are a couple of
orders of magnitude more common than than page faults---any time you 
touch a page you haven't touched fairly recently, you're likely to miss
the pte cache.  This isn't usually a big deal, because PTE cache misses
are many orders of magnitude cheaper than page faults---you only need
to fetch a pte from main memory, not fetch a page from disk.

A PTE cache is very fast on a hit, and is able to translate addresses
in a fraction of an instruction cycle.  This translation can
generally be overlapped with other parts of instruction setup,
so the PTE hardware gives you virtual memory support at essentially
zero time cost.

---

(Most of the following can be skipped without loss, for most
 kernel-hacking purposes.)

On some machines, such as x86's, the CPU automatically loads page
table entries from the multilevel page table whenever a PTE cache
miss occurs.  On a few machines, a PTE cache miss causes a trap
to software, and the OS does the translation by running a simple
routine. 

   [ Old MIPS machines used to do this.  Do any new machines? ]

On other machines, the CPU automatically probes an inverted page
table when the on-chip PTE cache is missed.   The inverted page
table is really just an off-chip PTE cache, much larger than
the on-chip one, and probing it usually just takes a memory
load.  If this off-chip cache is missed, the CPU traps to the
kernel to do the real page-table lookup.

(Such machines are designed to be able to do entirely without
conventional multilevel page tables.  Rather than probing a
multilevel page table, information about all in-memory pages
is kept in the inverted page table, and information about
out-of memory pages can be kept in other data structures
(e.g., Linux's vm_area lists could hold it.)   Linux does
NOT work this way, however---on such machines, Linux manages
the three-level page tables in software, but only needs to
probe them on the very occasional inverted page table miss.


5. VM CACHING AND REPLACEMENT
=============================

VM caching in Linux is rather complex, and the code is a little
difficult to understand at first, for several reasons.  One is
that some of the names of variables and procedures is less than
intuitive and/or less than consistent.  Another another is that
the coding style takes a little getting used to---lots of one-branch
if's with the following code being an implicit else.  This is 
designed to generate excellent straight-line usual-case code
given GCC's optimization heuristics and some lame branch predictors
in some CPU's that Linux runs on.

Here I'll try to give a basic sketch of what's going on, to show
the forest, not the trees.  The trees will be discussed later.


The Main Clock Algorithm
------------------------

The main component of the VM replacement mechanism is a clock
algorithm.   Clock algorithms are commonly used because they provide
a passible approximation of LRU replacement and are cheap to implement.
(All common general-purpose CPU's have hardware support for clock
algorithms, in the form of the reference bit maintained by the PTE
Cache.  This hardware support is very simple and fast, which is why
all designers of modern general-purpose CPU's put it in.)

A little refresher on the general idea clock algorithms:

A clock algorithm cycles slowly through the pages that are in RAM,
checking to see whether they have been touched (and perhaps dirtied)
lately.

For this, the hardware-supported reference and dirty bits of the page
table entries are used.  The reference bit is automatically set by the 
PTE cache hardware whenever the page is touched---a flag bit is set
in the page table entry, if the PTE is evicted from the PTE
cache, it will be written back to its home position in the page
table.  The clock algorithm can therefore examine the reference
bits in page-table entries to "examine" the corresponding page.

The basic idea of the clock algorithm is that a slow incremental
sweep repeatedly cycles through the all of the cached (in-RAM)
pages, noticing whether each page has been touched (and perhaps
dirtied) since the last time it was examined.  If a page's reference 
bit is set, the clock algorithm doesn't consider it for eviction at
this cycle, and continues its sweep, looking for a better candidate
for eviction.  Before continuing its sweep, however, it resets the
reference bit in the page table entry.

Resetting the reference bit ensures that the next time the page is
reached in the cyclic sweep, it will indicate whether the page was
touched since _this_ time.  Visiting all of the pages cyclically
ensures that a page is only considered for eviction if it hasn't
been touched for at least a whole cycle.

The clock algorithm proceeds in increments, usually sweeping a
small fraction of teh in-memory pages at a time, and keeps a record
of its current position between increments of sweeping.  This
allows it to resume its sweeping from that page at the next increment.

Technically, this simple clock scheme is known as  "second chance"
algorithm, because it gives a page a second chance to stay in
memory---one more sweep cycle.

More refined versions of the clock algorithm may keep multiple bits,
recording whether a page has been touched in the last two cycles,
or even three or four.  Only one hardware-supported bit is needed
for this, however.  Rather than just testing the hardware supported
bit, the clock hand records the current value of the bit before resetting
it, for use next time around.  Intuitively, it would seem that the
more bits are used, the more precise an approximation of LRU we'd
get, but that's usually not the case.  Once two bits are used,
clock algorithms don't generally get much better, due to fundamental
weaknesses of clock algorithms.

   [ I can elaborate on that if anyone's interested. ]

Linux uses a simple second-chance (one-bit clock) algorithm, sort
of, but with several elaborations and complications.

The main clock algorithm is implemented by the kernel swap demon,
a kernel thread that runs the procedure kswapd().  kswapd is 
an infinite loop, which incrmentally scans all the normal VM pages
subject to paging, then starting over.  Kswapd generally does
its clock sweeping in increments, and sleeps in between increments
so that normal processes may run.  (See the file mm/vmscan.c.)

kswapd isn't the only replacement algorithm, however---there are 
actually several interacting replacement algorithms in the Linux 
memory management system.

 * Pages that are part of (System V IPC) shared memory pages are
   swept by a different clock algorithm, implemented by shm_swap()

 * Page frames managed by the file buffering system are managed
   differently, for several reasons.  (For example, file blocks may
   be smaller than the VM page size, and filesystem metadata are
   flushed to disk more often than normal blocks.)  Code for 
   file buffering is in the file fs/buffer.c, including bdflush(),
   which is run as a kernel thread (like kswapd()) to manage 
   buffer flushing.

 *  (Is there another one?  There's the VFS metadata cache, and
   the slab allocator caches, but they're pretty different...)

[ I'm pretty confused about the exact relationships between all
  of the caches and caching algorithms.   There seem to be
  significant changes since last time I studied the kernel
  source, and there are very few big-picture comments.

  QUESTION 5: what exactly does and doesn't go in the page
              cache?

  QUESTION 6: what are the interactions between shm caching,
              other page caching, and file buffer caching?


  I think the source needs some very comments of the form

     The X cache holds Y's and consists of the set of
     page frames entered into the data structure Z.

  It needs these for the page cache, the buffer cache, and
  the swap cache at least.   It also needs comments about
  how these things basically interact.  (Are these caches
  distinct?  What gets moved between them, and when and
  how?
]

Equally important, there is another clock algorithm, implemented
by calling shrink_mmap() from the kernel swap demon (kswapd()).

This clock algorithm is different from the others, in that it's
a "back end" algorithm for the main clock implemented by kswapd().
That is, pages may be evicted from the normal clock but not actually
evicted from memory.

An important distinction between the main kswapd clock and the
auxiliary shrink_mmap clock is that the main clock sweeps over
*virtual* pages, while the shrink_mmap clock sweeps over page
*frames* (RAM pages).  The front-end clock uses the hardware-supported
PTE reference bits, and consolidates the information they hold
into the per-page-frame reference bits held in the PG_referenced
bit (of the "flags" field) in the page structs that represent
page frames.

  [ QUESTION 7: is this right? ]

The relationships between these two clocks are fairly subtle.
[ At least, they're far from obvious to me...]

A Clock Over Virtual Pages
--------------------------

Notice that when the PTE cache sets the reference bit on a page,
it is setting a bit for a page table entry, i.e. for a *virtual*
page, _not_ a page frame or the logical page it holds.  (A logical
page may be cached in a page frame, but be mapped by more than one
page table entry, likely in different processes' page tables.
The same logical page therefore has as many reference bits as there
are mappings of that page as virtual pages in address spaces, each
one recording whether one process has touched the page "lately."
If a logical page has been touched by *any* process recently,
it is a poor candidate for eviction.  We therefore need something
like the OR of the reference bits for different mappings of
the page.

(It might seem as though we'd want to take the sum, and prefer to
keep in memory those pages that have been touched the most.
This is not a good idea.  In general, a single touch by one
process is just as important as a large number of touches
by a large number of processes, if they all occur in a short
amount of time.  The replacement policy's real job is not to
predict how often a page will be touched, and keep the
most-touched pages in RAM.  It is to predict how *soon* 
pages will be touched *next* and keep the soonest-to-be-touched
pages in RAM.  This is a basic fact that too few people really
understand.) 

In general, the replacement mechanism's job is to cache LOGICAL
pages, not virtual pages.  But the hardware gives reference information
about virtual pages, not logical ones---or at least, not directly.

There are two basic approaches to solving this problem.  The obvious
one is to perform a traditional clock sweep over the page frames (RAM
pages) holding the (logical) pages in question, and use the reference
bits from the all of the pte's that map that page frame into any
page table.  The straightforward way of doing this would be to maintain
an index, recording which virtual pages of which processes are mappings 
of each page frame (and the logical page it holds). 

 [ QUESTION 8: is this what the phrases "pte chaining" and/or "pte lists"
   refer to?  I've seen those terms in old mails in the archive, but I'm
   not clear on exactly what was being discussed, what got implemented,
   why it's (apparently) not used, etc. ]

The Linux replacement policy does not do the obvious thing, for
several reasons.

Linux performs a clock sweep over the *virtual* pages, by cycling
through each process's pages in address order.  For this it
uses the vm_area mappings and page tables of the processes,
so that it can scan the pages of each process sequentially. 

Rather than sweeping through all of the pages of an an entire process
before switching to another, the main clock tries to evict a batch
of pages from a process, and then move on to another process.
It visits all of the (pageable) processes and then repeats.  The
effect of this is that there is a large number of distinct clock
sweeps, one per pageable proceses, and the overall clock sweep
advances each of these smaller sweeps periodically.

   [ This used to be a round-robin through the processes, which
     made sense to me.  I don't understand the current thing
     with the two passes over the task list.  I don't see how
     it's fair, or how it's unfair in just the right way.]

Several motivations led to this design:

   1. related pages should be paged out together, to increase
      locality in the paging store (so-called swap files or
      swap partitions).  By evicting a moderate number of
      virtual pages from a given process, in virtual address
      order, the sweep through virtual address space tends
      to group related pages together in the paging store.

   2. by alternating between processes at a coarser granularity,
      it avoids evicting a large number of pages from a given
      victim process---after it's evicted a reasonable number
      of pages from a particular victim, it moves on to another,
      to provide some semblance of fairness between the processes.

   3. The use of a main clock over processes and virtual address pages
      and a secondary clock over page frames provides a way of
      combining the hardware-supported virtual page reference
      bits to get recency-of-touch information about logical pages
      stored in page frames.

   4. The secondary clock (and the use of a separate per-page-frame
      PG_referenced bit maintained in software) can act as an additional
      "aging" period for pages that are evicted from the main
      clock.   A page can be held in the "swap cache" after being
      evicted from the main clock, and allowed to age a while
      before being evicted from RAM.

  [ QUESTION 9: Are all of these things right?  Is there something
                else that's important and should be listed?   I
                got #4 from something someone said in email, but
                I may have completely misunderstood, and from the
                2.2 pre1 sources I don't see how this effect is
                achieved. ]


The last two points require some explanation, and involve something
called the "swap cache."

The Swap Cache
--------------

The swap cache is just a set of page frames holding logical pages that
have been evicted from the main clock, but whose contents are have not
yet been discarded.  The contents of page frames need not be copied to
"move" them into the swap cache---rather, the page frame is simply
marked as "swap cached" by the main clock algorithm, and linked into
a hash table that holds all of the page frames that currently constitute
the swap cache.  (This is done by add_to_swap_cache() in mm/swap_state.c.)

There is some subtlety here. 

When the main clock algorithm (over virtual pages) finds a page whose
(hardware-supported) reference bit (in the pte) IS set, indicating
that the page has been touched recently, it sets the PG_referenced
bit in the page struct for the page frame holding the logical
page.

On the other hand, if the virtual page's pte reference bit is NOT set,
it can be evicted from the main clock pool, but may be retained in the
swap cache.  

  [ QUESTION 10: I'm fairly unclear on all of this.  Can somebody
    write a high-level description of what's going on in 
    try_to_swap_out() after a page has been established to
    be present and pageable?  

    It seems to me that there ought to be a check not only of
    the pte's reference bit, but of the page frame's PG_referenced
    bit---if the page has been referenced recently via another
    mapping, you should NOT page it out. 

    It also seems to me that if there's an aging grace period
    after eviction from the main clock, then there needs to
    be an additional referenced bit per page frame.  As I interpret
    the 2.2 pre1 sources, it looks like try_to_swap_out immediately
    copies a set pte reference bit to the page struct, so the
    single bit in the page struct only tells you whether the
    main clock has noticed a set referenced bit lately.  This may
    or may not give you a grace period depending on the vagaries
    of the two clocks, which don't seem to be coordinated.

    It seems to me that pages evicted from the first clock
    ought to be entered into an LRU list for aging, and
    actual paging to disk would be from the other end of
    that list.   This would mostly decouple the actual paging
    from the front-end clock, make the LRU approximation
    more precise, and give a flexible framework for tweaks.

    Am I all wrong about this?

   ]


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
