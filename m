Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200705292216.31102.ak@suse.de>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <200705292216.31102.ak@suse.de>
Content-Type: text/plain
Date: Wed, 30 May 2007 12:17:29 -0400
Message-Id: <1180541849.5850.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, mtk-manpages@gmx.net, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-29 at 22:16 +0200, Andi Kleen wrote:
> On Tuesday 29 May 2007 22:04, Christoph Lameter wrote:
> 
> > > +	Currently [2.6.22], only shared memory segments, created by shmget(),
> > > +	support shared policy.  When shared policy support was added to Linux,
> > > +	the associated data structures were added to shared hugetlbfs segments.
> > > +	However, at the time, hugetlbfs did not support allocation at fault
> > > +	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
> > > +	up" to the shared policy support.  Although hugetlbfs segments now
> > > +	support lazy allocation, their support for shared policy has not been
> > > +	completed.
> >
> > I guess patches would be welcome to complete it.
> 
> I actually had it working in SLES9 (which sported a lazy hugetlb 
> implementation somewhat different from what mainline has now) 
> Somehow it dropped off the radar in mainline, but it should be easy
> to readd.

Yes.  In progress.  As I mentioned in our previous discussion, if you
just add the policy vm_ops, it works as far as allocating the pages, but
numa_maps hangs displaying the segment.  My series fixed that.  I'm
extracting the numa_maps fix and related clean up, and when that works,
I'll post along with a patch to add the vm_ops.  Fixes come first,
right?

> 
> > But that may only be 
> > releveant if huge pages are shared between processes. 
> 
> NUMA policy is useful for multithreaded processes too

Two orthogonal concepts, right?  A multi-threaded task can use NUMA
policy w/o sharing objects between "processes" [by which I mean a Linux
task plus it's address space and associated resources].  I think that is
what Christoph was referring to?

> 
> > We so far have no 
> > case in which that support is required.
> 
> Besides I think hugetlbfs mappings can be shared anyways.

No use case for sharing huge pages between processes, huh?  

I'm aware of at least one large enterprise database that uses both huge
pages and shmem segments to good advantage, performance-wise, even on
Linux.  That same database uses the NUMA policy support of the various
enterprise unix systems for additional performance gain.  I understand
that this support will be enabled for Linux once a process can determine
which cpu/node it's running on--maybe ~2.6.22?

> 
> 
> > > +	    If the Preferred policy specifies more than one node, the node
> > > +	    with the numerically lowest node id will be selected to start
> > > +	    the allocation scan.
> >
> > AFAIK perferred policy was only intended to specify one node.
> 
> Yes.
> 
> Also the big difference to MPOL_BIND is that it is not strict and will fall 
> back like the default policy.

Right.  And since the API argument is a node mask, one might want to
know what happens if more than one node is specified.  On the other
hand, we could play hardball and reject the call if more than one is
specified.

> 
> > > +	    For allocation of page cache pages, Interleave mode indexes the set
> > > +	    of nodes specified by the policy using a node counter maintained
> > > +	    per task.  This counter wraps around to the lowest specified node
> > > +	    after it reaches the highest specified node.  This will tend to
> > > +	    spread the pages out over the nodes specified by the policy based
> > > +	    on the order in which they are allocated, rather than based on any
> > > +	    page offset into an address range or file.
> >
> > Which is particularly important if random pages in a file are used.
> 
> Not sure that should be documented too closely -- it is a implementation
> detail that could change.

I think it's useful for the kernel documentation.

> 
> >
> > > +	'flags' may also contain 'MPOL_F_NODE'.  This flag has been
> > > +	described in some get_mempolicy() man pages as "not for application
> > > +	use" and subject to change.  Applications are cautioned against
> > > +	using it.  However, for completeness and because it is useful for
> > > +	testing the kernel memory policy support, current behavior is
> > > +	documented here:
> >
> > The docs are wrong. This is fully supported.
> 
> Yes, I gave up on that one and the warning in the manpage should be 
> probably dropped 

OK.  I'll work with the man page maintainers. 

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
