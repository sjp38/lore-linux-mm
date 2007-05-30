Date: Wed, 30 May 2007 10:56:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180544104.5850.70.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
 <1180544104.5850.70.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Lee Schermerhorn wrote:

> > You can use cpusets to automatically migrate pages and sys_migrate_pages 
> > to manually migrate pages of a process though.
> 
> I consider cpusets, and the explicit migration APIs, orthogonal to
> mempolicy.  Mempolicy is an application interface, while cpusets are an
> administrative interface that restricts what mempolicy can ask for.  And
> sys_migrate_pages/sys_move_pages seem to ignore mempolicy altogether.

They have to since they may be used to change page locations when policies 
are active. There is a libcpuset library that can be used for application 
control of cpusets. I think Paul would disagree with you here.

> I would agree, however, that they could be better integrated.  E.g., how
> can a NUMA-aware application [one that uses the mempolicy APIs]
> determine what memories it's allowed to use.  So far, all I've been able
> to determine is that I try each node in the mask and the ones that don't
> error out are valid.  Seems a bit awkward...

The cpuset interfaces provide this information.
 
> > There is no way to configure it. So it would be easier to avoid this layer 
> > and say they fall back to node local
> 
> What you describe is, indeed, the effect, but I'm trying to explain why
> it works that way.  

But the explanation adds a new element that only serves to complicate the 
description.

> > > +	VMA policies are shared between all tasks that share a virtual address
> > > +	space--a.k.a. threads--independent of when the policy is installed; and
> > > +	they are inherited across fork().  However, because VMA policies refer
> > > +	to a specific region of a task's address space, and because the address
> > > +	space is discarded and recreated on exec*(), VMA policies are NOT
> > > +	inheritable across exec().  Thus, only NUMA-aware applications may
> > > +	use VMA policies.
> > 
> > Memory policies require NUMA. Drop the last sentence? You can set the task 
> > policy via numactl though.
> 
> I disagree about dropping the last sentence.  I can/will define
> NUMA-aware as applications that directly call the mempolicy APIs.  You

Or the cpuset APIs.

> can run an unmodified, non-NUMA-aware program on a NUMA platform with or
> without numactl and take whatever performance you get.  In some cases,

Right.

> you'll be leaving performance on the table, but that may be a trade-off
> some are willing to make not to have to modify their existing
> applications.

The sentence still does not make sense. There is no point in using numa 
memory policies if the app is not an NUMA app.

> > > +	Although internal to the kernel shared memory segments are really
> > > +	files backed by swap space that have been mmap()ed shared into tasks'
> > > +	address spaces, regular files mmap()ed shared do NOT support shared
> > > +	policy.  Rather, shared page cache pages, including pages backing
> > > +	private mappings that have not yet been written by the task, follow
> > > +	task policy, if any, else system default policy.
> > 
> > Yes. shared memory segments do not represent file content. The file 
> > content of mmap pages may exist before the mmap. Also there may be regular
> > buffered I/O going on which will also use the task policy. 
> 
> Unix/Posix/Linux semantics are very flexible with respect to file
> description access [read, write, et al] and memory mapped access to
> files.  One CAN access files via both of these interfaces, and the
> system jumps through hoops backwards [e.g., consider truncation] to make
> it work.  However, some applications just access the files via mmap()
> and want to control the NUMA placement like any other component of their
> address space.   Read/write access to such a file, while I agree it

Right but the pages may already have been in memory due to buffered read
access.

> should work, is, IMO, secondary to load/store access.  In such a case,
> the performance of the load/store access shouldn't be sacrificed for the
> read/write case, which already has to go through system calls, buffer
> copies, ...

Its not a matter of sacrifice. Its consistency. page cache pages are 
always subject to the tasks memory policy whether you use bufferred I/O or 
mmapped I/O.

> > Having no vma policy support insures that pagecache pages regardless if 
> > they are mmapped or not will get the task policy applied.
> 
> Which is fine if that's what you want.  If you're using a memory mapped
> file as a persistent shared memory area that faults pages in where you
> specified, as you access them, maybe that's not what you want.  I
> guarantee that's not what I want.
> 
> However, it seems to me, this is our other discussion.  What I've tried
> to do with this patch is document the existing concepts and behavior, as
> I understand them.  

It seems that you are creating some artificial problems here.

> > > +	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
> > > +	context dependent.
> > > +
> > > +	    The system default policy is hard coded to contain the Default mode.
> > > +	    In this context, it means "local" allocation--that is attempt to
> > > +	    allocate the page from the node associated with the cpu where the
> > > +	    fault occurs.  If the "local" node has no memory, or the node's
> > > +	    memory can be exhausted [no free pages available], local allocation
> > > +	    will attempt to allocate pages from "nearby" nodes, using a per node
> > > +	    list of nodes--called zonelists--built at boot time.
> > > +
> > > +		TODO:  address runtime rebuild of node/zonelists when
> > > +		supported.
> > 
> > Why?
> 
> Because "built at boot time" is then not strictly correct, is it?  

I still do not understand what this is all about. The zonelists are 
rebuild due to Kame-san's patch for the ZONE_DMA problems. Okay. So what 
does this have to do with MPOL_DEFAULT?

> > > +	    The Default mode does not use the optional set of nodes.
> > 
> > Neither does the preferred node mode.
> 
> Actually, it does take the node mask argument.  It just selects the
> first node therein.  See response to Andi.

It uses one node yes. It does not support (or is not intended to support) 
a nodemask.

> > > +	Note:  the headers that define these APIs and the parameter data types
> > > +	for user space applications reside in a package that is not part of
> > > +	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
> > > +	prefix, are defined in <linux/syscalls.h>; the mode and flag
> > > +	definitions are defined in <linux/mempolicy.h>.
> > 
> > You need to mention the numactl library here.
> 
> I'm trying to describe kernel behavior.  I would expect this to be
> picked up by the man pages at some time.  As I responded to Andi, I'll
> work the maintainers... When I get the time.

I though you wanted to explain this to users? If so then you need to 
mention the user APIs such as numactl and libcpuset.

> You don't get COW if it's a shared mapping.  You use the page cache
> pages which ignores my mbind().  That's my beef!  [;-)]

page cache pages are subject to a tasks memory policy regardless of how we 
get to the page cache page. I think that is pretty consistent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
