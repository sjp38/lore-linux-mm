Date: Tue, 15 Feb 2005 16:51:06 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: manual page migration -- issue list
Message-Id: <20050215165106.61fd4954.pj@sgi.com>
In-Reply-To: <42128B25.9030206@sgi.com>
References: <42128B25.9030206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

Robin, replying to pj, from the earlier thread also on lkml:
> On Tue, Feb 15, 2005 at 08:35:29AM -0800, Paul Jackson wrote:
> > What about ...
> > 
> >     sys_page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes);
> > 
> > to:
> > 
> >     sys_page_migrate(pid, va_start, va_end, old_node, new_node);
> > 
> > ...
> 
> Migration could be done in most cases and would only fall apart when
> there are overlapping node lists and no nodes available as temp space
> and we are not moving large chunks of data.

Given the <va_start, va_end>, which could be reduced to the granularity
of a single page if need be, there should not be an issue with overlapping
node lists.  My "node as temp space" suggestion was insane - nevermind
that one.  If worse comes to worse, you can handle any combination of
nodes, overlapping or not, with no extra or temporary copies, just by
doing one page at a time.

So this seems to boil down to whether it makes more sense to move
several nodes worth of stuff to several corresponding nodes in a single
call, or in several calls, roughly one call for each <to, from> node
pair.

The working example I was carrying around in my mind was of a job that
had one thread per cpu, and that had explicitly used some numa policy
(mbind, mempolicy or cpusets) to place memory on the node local to its
cpu.

Earlier today on the lkml thread, Robin described how a typical MPI job
works.  Seems that it relies on some startup code running in each
thread, carefully touching each page that should be local to that cpu
before any other thread touches said page, and requiring no particular
memory policy facility beyond first touch.  Seems to me that the memory
migration requirements here are the same as they were for the example I
had in mind.  Each task has some currently allocated memory pages in its
address space that are on the local node of that task, and that memory
must stay local to that task, after the migration.

Looking at such an MPI job as a whole, there seems to be pages scattered
across several nodes, where the only place it is 'encoded' how to place
them is in the job startup code that first touched each page.

A successful migration must replicate that memory placement, page for
page, just changing the nodes.  From that perspective, it makes sense to
think of it as an array of old nodes, and a corresponding array of new
nodes, where each page on an old node is to be migrated to the corresponding
new node.

However, since each thread allocated its memory locally, this factors into
N separate migrations, each of one task, one old node, and one new node.
Such a call doesn't migrate all physical pages in the target tasks memory,
rather just the pages that are on the specified old node.

The one thing not trivially covered in such a one task, one node pair at
a time factoring is memory that is placed on a node that is remote from
any of the tasks which map that memory.  Let me call this 'remote
placement.'  Offhand, I don't know why anyone would do this.  If such
were rare, the one task, one node pair at a time factoring can still
migrate it easily enough, so long as it knows to do so, and issue
another system call, for the necessary task and remote nodes (old and
new).  If such remote placement were used in abundance, the one task,
one node pair at a time factoring would become inefficient.  I don't
anticipate that remote placement will be used in abundance.

By the way, what happens if you're doing a move where the to and from
node sets overlap, and the kernel scans in the wrong order, and ends up
trying to put new pages onto a node that is in that overlap, before
pulling the old pages off it, running out of memory on that node?
Perhaps the smarts to avoid that should be in user space ;).  This can
be avoided using the one task, one node pair at a time factored API,
because user space can control the order in which memory is migrated, to
avoid temporarilly overloading the memory on any one node.

With this, I am now more convinced than I was earlier that passing a
single old node, new node pair, rather than the array of old and new
nodes, is just as good (hardly any more system calls in actual usage). 
And it is better in one regard, that it avoids the kernel having to risk
overloading the memory on some node during the migration if it scans in
the wrong order when doing an overlapped migration.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
