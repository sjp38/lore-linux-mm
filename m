Date: Tue, 26 Sep 2000 13:10:30 +0100 (BST)
From: Mark Hemment <markhe@veritas.com>
Subject: Re: the new VMt
In-Reply-To: <20000925213201.C2615@redhat.com>
Message-ID: <Pine.LNX.4.21.0009261020020.11007-100000@alloc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: yodaiken@fsmlabs.com, Jamie Lokier <lk@tantalophile.demon.co.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 25 Sep 2000, Stephen C. Tweedie wrote: 
> So you have run out of physical memory --- what do you do about it?

  Why let the system get into the state where it is neccessary to kill a
process?
  Per-user/task resource counters should prevent unprivileged users from
soaking up too many resources.  That is the DoS protection.

  So an OOM is possibly;
	1) A privileged, legally resource hungry, app(s) has taken all
	   the memory.  Could be too important to simply kill (it
	   should exit gracefully).
	2) Simply too many tasks*(memory-requirements-of-each-task).

  Ignoring allocations done by the kernel, the suitation comes down to the
fact that the system has over committed its memory resources.  ie. it has
sold too many tickets for the number of seats in the plane, and all the
passengers have turned up.
 (note, I use the term "memory" and not "physical memory", I'm including
swap space).

  Why not protect the system from over committing its memory resources?
  
  It is possible to do true, system wide, resource counting of physical
memory and swap space, and to deny a fork() or mmap() which would cause
over committing of memoy resources if everyone cashed in their
requirements.

  Named pages (those which came from a file) are the simplest to
handle.  If dirty, they already have allocated backing store, so we know
there is somewhere to put them when memory is low.
  How many named pages need to be held in physical memory at any one
instance for the system to function?  Only a few, although if you reach
that state, the system will be thrashing itself to death.

  Anonymous and copied (those faulted from a write to  an
MAP_PRIVATE|MAP_WRITE mapping) pages can be stored in either physical
memory or on swap.  To avoid getting into the OOM suitation, when these
mappings are created the system needs to check that it has (and will have,
in the future) space for every page that _could_ be allocated for the
mapping - ie. work out the worst case (including page-tables).
  This space could be on swap or in physical memory.  It is the accounting
which needs to be done, not the actual allocation (and not even the
decision of where to store the page when allocated - that is made much
later, when it needs to be).  If a machine has 2GB of RAM, a 1MB
swap, and 1GB of dirty anon or copied pages, that is fine.
  I'm stressing this point, as the scheme of reserving space for an (as
yet) unallocated page is sometimes refered to as "eager swap
allocation" (or some such similar term).  This is confusing.  People then
start to believe they need backing store for each anon/copied pages.  You
don't.  You simply need somewhere to store it, and that could be a
physical page.  It is all in the accounting. :)

  Allocations made by the kernel, for the kernel, are (obviously) pinned
memory.  To ensure kernel allocations do not completely exhaust physical
memory (or cause phyiscal memory to be over committed if the worst case
occurs), they need to be limited.
  How to limit?
  As I first guess (and this is only a guess);
	1) don't let kernel allocations exceed 25% of physical memory
	   (tunable)
	2) don't let kernel allocations succeed if they would cause
	   over commitment.
  Both conditions would need to pass before an allocation could succeed.
  This does need much more thought.  Should some tuning be per subsystem?
I don't know....

  Perhaps 1) isn't needed.  I'm not sure.

  Because of 2), the total physical memory accounted for anon/copied
pages needs to have a high watermark.  Otherwise, in the accounting, the
system could allow too much physical memory to be reserved for these
types of pages (there doesn't need to be space on swap for each
anon/copied page, just space somewhere - a watermark would prevent too
much of this being physical memory).  Note, this doesn't mean start
swapping earlier - remember, this is accounting of anon/copied pages to
avoid over commitment.
  For named pages, the page cache needs to have a reserved number of
physical pages (ie. how small is it allowed to get, before pruning
stops).  Again, these reserved pages are in the accounting.

 mlock()ed pages need to have accouting also to prevent over commitment of
physical memory.  All fun.

  The disadvantages;

1) Extra code to do the accouting.
	This shouldn't be too heavy.

2) mmap(MAP_ANON)/mmap(MAP_PRIVATE|MAP_SHARED) can fail more readily.

	Programs which expect to memory map areas (which would created
	anon/copied pages when written to) will see an increased failure
	rate in mmap().  This can be very annoying, espically when you
	know the mapping will be used sparsely.

	One solution is to add a new mmap() flag, which tells the kernel
	to let this mmap() exceed the actually resources.
	With such a flag, the mmap() will be allowed, but the task should
	expected to be killed if memory is exhausted.  (It could be
	possible for the kernel to deliver a SIGDANGER signal to such a
	task, as in AIX, to give it a chance of reducing its requirments
	on the system or to exit gracefully.)

	Another solution is to allow the strict resource accounting to be
	over ridden on a global basis.  Say, by allowing the system to
	over commit the memory resources by 10%. This does remove the
	absolute protection, but leaves some in place.  The OOM killer
	would come into play if the system did over commit.
	Those who don't need/want protection, could set the over commit to
	some large value.  500%?

3) fork() failures.

	There is the problem of a large(ish) process wanting to run a
	small program.  Say, a shell wanting to run a simple utility.

	Because of the memory resource accounting, the fork() is
	disallowed as the newly created child could (in theory) write to
	mmap()ed areas, creating anon/copied pages which would cause the
	kernel to (in the worst case) be OOM for user-pages.  Given that
	the child will almost immediately do an exec(), which could well
	succeed, this is frustrating.

	Again, a small over commit kludge would reduce (but not
	eliminate), this occurance.

	An idea from a colleague, is to allow such a fork() to succeed,
	but to run the child process in a "container".
	Inside the container, the child is allowed to perform operations
	which would be expected before an exec().  Such operations could
	be closing file descriptors.  However, if it tries to do something
	which would _seriously_ affect the state of the system (such as
	remove a file), then it is killed.  ie. given it a chance to
	do an exec().  This could be done by running with an alternative
	system call table for the child process, which refers to bounce
	functions within the kernel where the checks are done (ie. don't
	load the common code path with the checks).
	This could be tricky to do, and there could well be a few
	system (library?) calls which would make it impossible.  However,
	if it could be achieved, it would remove one of the most annoying
	"features" of over commitment protection.


  This sort of protection isn't to prevent DoS attacks; as said above,
they need to be on a per user/task level.  This protection is to protect
against asynchronous failures on page faults due to OOM, and to make
them synchronous (from mmap(), fork(), mlock(), etc) where programs
expected to test for an error code.
  There isn't much an application can do with a synchronous memory
failure; sleep and try again, release some of its own resources, or exit
gracefully.

  Anyway, I've skipped over a lot of interesting details (and problems).
  This stuff isn't new.  Some commercial OS have this type of protection.

  Comments?

Mark






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
