Received: from flecktone.americas.sgi.com (flecktone.americas.sgi.com [198.149.16.15])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j1G1uSxT023524
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 19:56:28 -0600
Date: Tue, 15 Feb 2005 19:56:22 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: manual page migration -- issue list
Message-ID: <20050216015622.GB28354@lnx-holt.americas.sgi.com>
References: <42128B25.9030206@sgi.com> <20050215165106.61fd4954.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050215165106.61fd4954.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, linux-mm@kvack.org, holt@sgi.com, ak@muc.de, haveblue@us.ibm.com, marcello@cyclades.com, stevel@mwwireless.net, peterc@gelato.unsw.edu.au
List-ID: <linux-mm.kvack.org>

On Tue, Feb 15, 2005 at 04:51:06PM -0800, Paul Jackson wrote:
> Earlier today on the lkml thread, Robin described how a typical MPI job
> works.  Seems that it relies on some startup code running in each
> thread, carefully touching each page that should be local to that cpu
> before any other thread touches said page, and requiring no particular
> memory policy facility beyond first touch.  Seems to me that the memory
> migration requirements here are the same as they were for the example I
> had in mind.  Each task has some currently allocated memory pages in its
> address space that are on the local node of that task, and that memory
> must stay local to that task, after the migration.

One important point I probably forgot to make is there is typically a
very large shared anonymous mapping before the initial fork.  This will
result in many processes sharing the vma discussed below.

> 
> Looking at such an MPI job as a whole, there seems to be pages scattered
> across several nodes, where the only place it is 'encoded' how to place
> them is in the job startup code that first touched each page.
> 
> A successful migration must replicate that memory placement, page for
> page, just changing the nodes.  From that perspective, it makes sense to
> think of it as an array of old nodes, and a corresponding array of new
> nodes, where each page on an old node is to be migrated to the corresponding
> new node.

And given the large single mapping and two arrays corresponding to
old/new nodes, a single call would handle the migration even with
overlapping regions in a single call and pass over the ptes.

> 
> However, since each thread allocated its memory locally, this factors into
> N separate migrations, each of one task, one old node, and one new node.
> Such a call doesn't migrate all physical pages in the target tasks memory,
> rather just the pages that are on the specified old node.

If you do that for each job with the shared mapping and have overlapping
node lists, you end up combining two nodes and not being able to seperate
them.  Oh sure, we could add in a page flag indicating that the page
is going to be migrated, add a syscall which you call on the VMA first
to set all the flags and then as pages are moved with the one-for-one
syscalls, clear the flag.  Oh yeah, we also need to add an additional
syscall to clear any flags for pages that did not get migrated because
they were not in the old list at all.

> The one thing not trivially covered in such a one task, one node pair at
> a time factoring is memory that is placed on a node that is remote from
> any of the tasks which map that memory.  Let me call this 'remote
> placement.'  Offhand, I don't know why anyone would do this.  If such
> were rare, the one task, one node pair at a time factoring can still
> migrate it easily enough, so long as it knows to do so, and issue
> another system call, for the necessary task and remote nodes (old and
> new).  If such remote placement were used in abundance, the one task,
> one node pair at a time factoring would become inefficient.  I don't
> anticipate that remote placement will be used in abundance.

Unfortunately it does happen often for stuff like shared file mappings
that a different job is using in conjuction with this job.  There are
other considerations as well such as shared libraries etc, but we can
minimize that noise in this discussion for the time being.

> By the way, what happens if you're doing a move where the to and from
> node sets overlap, and the kernel scans in the wrong order, and ends up
> trying to put new pages onto a node that is in that overlap, before
> pulling the old pages off it, running out of memory on that node?
> Perhaps the smarts to avoid that should be in user space ;).  This can
> be avoided using the one task, one node pair at a time factored API,
> because user space can control the order in which memory is migrated, to
> avoid temporarilly overloading the memory on any one node.

Unfortunately, userspace can not avoid this easily as it does not know
which pages in the virtual address space are on which nodes.  It could
do some kludge work and only call for va ranges that are smaller than
the most available memory on any of the destination nodes, but that
might make things sort of hackish.  Alternatively, the syscall handler
could do some work to find chunks of memory that are being used by
that node and process that chunk and then return to this.  Makes stuff
ugly, but is a possiblity as well.

> 
> With this, I am now more convinced than I was earlier that passing a
> single old node, new node pair, rather than the array of old and new
> nodes, is just as good (hardly any more system calls in actual usage). 
> And it is better in one regard, that it avoids the kernel having to risk
> overloading the memory on some node during the migration if it scans in
> the wrong order when doing an overlapped migration.

Shared mappings and overlapping regions make the node arrays necessary.
Single old/new pair _DOES_ result in more system calls and therefore
scans over the ptes.  It does result in problems with overlapping old/new
node lists.  It does not help with out of memory issues.  It accomplishes
nothing other than making the syscall interface different.

Thanks,
Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
