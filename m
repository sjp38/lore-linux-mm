Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <1180544104.5850.70.camel@localhost>
	 <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 14:28:16 -0400
Message-Id: <1180636096.5091.125.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Gleb Natapov <glebn@voltaire.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-05-30 at 10:56 -0700, Christoph Lameter wrote:
> On Wed, 30 May 2007, Lee Schermerhorn wrote:
> 
> > > You can use cpusets to automatically migrate pages and sys_migrate_pages 
> > > to manually migrate pages of a process though.
> > 
> > I consider cpusets, and the explicit migration APIs, orthogonal to
> > mempolicy.  Mempolicy is an application interface, while cpusets are an
> > administrative interface that restricts what mempolicy can ask for.  And
> > sys_migrate_pages/sys_move_pages seem to ignore mempolicy altogether.
> 
> They have to since they may be used to change page locations when policies 
> are active. 

That's fine, I guess.  But I still think that makes them orthogonal to
mempolicy...

> There is a libcpuset library that can be used for application 
> control of cpusets.

libcpusets is part of the SGI ProPack, right?  Is there a generic
version of that available for current kernels?  I see the ProPack 3 on
the SGI web site, but it appears to be for an older version of Linux and
CpuMemSets and a tad Altix specific.  [I've been assuming we're talking
about general Linux capabilities.]  

I did find in several versions of the on-line ProPack documentation this
statement:  "The cpuset facility is primarily a workload manager tool
permitting a system administrator to restrict the number of processors
and memory resources that a process or set of processes may use."  This
matches my understanding that cpusets are a "container-like" facility.
Indeed, they appear to be evolving to this upstream.  

And certainly a "workload manager tool" can be viewed as an application.
I just tend to separate privileged system admin tools and the facilities
they use from applications such as numerical/scientific computation,
enterprise workloads, web servers, ...  Not the only way to view the
world, I agree.

>  I think Paul would disagree with you here.

Paul?

> 
> > I would agree, however, that they could be better integrated.  E.g., how
> > can a NUMA-aware application [one that uses the mempolicy APIs]
> > determine what memories it's allowed to use.  So far, all I've been able
> > to determine is that I try each node in the mask and the ones that don't
> > error out are valid.  Seems a bit awkward...
> 
> The cpuset interfaces provide this information.

Well, NUMA systems don't require cpusets.  I agree tho' that they're
very useful for system partitioning and am glad to see them supported by
the standard kernels in the current generation of Enterprise distros.

>  
> > > There is no way to configure it. So it would be easier to avoid this layer 
> > > and say they fall back to node local
> > 
> > What you describe is, indeed, the effect, but I'm trying to explain why
> > it works that way.  
> 
> But the explanation adds a new element that only serves to complicate the 
> description.

I'm reworking the doc to address this and other comments... Where I
don't disagree too strongly ;-).

> 
> > > > +	VMA policies are shared between all tasks that share a virtual address
> > > > +	space--a.k.a. threads--independent of when the policy is installed; and
> > > > +	they are inherited across fork().  However, because VMA policies refer
> > > > +	to a specific region of a task's address space, and because the address
> > > > +	space is discarded and recreated on exec*(), VMA policies are NOT
> > > > +	inheritable across exec().  Thus, only NUMA-aware applications may
> > > > +	use VMA policies.
> > > 
> > > Memory policies require NUMA. Drop the last sentence? You can set the task 
> > > policy via numactl though.
> > 
> > I disagree about dropping the last sentence.  I can/will define
> > NUMA-aware as applications that directly call the mempolicy APIs.  You
> 
> Or the cpuset APIs.

Yes, an "application" that uses the cpuset APIs would be a NUMA-aware
administration tool. ;-)

> 
> > can run an unmodified, non-NUMA-aware program on a NUMA platform with or
> > without numactl and take whatever performance you get.  In some cases,
> 
> Right.
> 
> > you'll be leaving performance on the table, but that may be a trade-off
> > some are willing to make not to have to modify their existing
> > applications.
> 
> The sentence still does not make sense. There is no point in using numa 
> memory policies if the app is not an NUMA app.

OK. Let me try to explain it this way.  You can take a non-NUMA aware
app, that uses neither the memory policy APIs nor the cpuset interface,
perhaps from a dusty old SMP system, and run that on a NUMA system.
Depending on workload, load balancing, etc., you may end up with a lot
of non-local accesses.  However, with numactl, you can restrict that
application, without modification, to a single node or set of close
neighbor nodes and achieve some of the benefit of memory policy APIs.
If the application fits in the cpu and memory resources of a single
node, then you probably need do no more.  Can't get much more local than
that.  If the application requires more than one node's worth of
resources, then at some point it might be worth while to make the
application NUMA-aware and use the policy APIs directly.  This assumes,
of course, that you have someone who understands the memory access
behavior of the application well enough to specify the policies.
Performance analyzers can help, as can automatic page migration ;-).

> 
> > > > +	Although internal to the kernel shared memory segments are really
> > > > +	files backed by swap space that have been mmap()ed shared into tasks'
> > > > +	address spaces, regular files mmap()ed shared do NOT support shared
> > > > +	policy.  Rather, shared page cache pages, including pages backing
> > > > +	private mappings that have not yet been written by the task, follow
> > > > +	task policy, if any, else system default policy.
> > > 
> > > Yes. shared memory segments do not represent file content. The file 
> > > content of mmap pages may exist before the mmap. Also there may be regular
> > > buffered I/O going on which will also use the task policy. 
> > 
> > Unix/Posix/Linux semantics are very flexible with respect to file
> > description access [read, write, et al] and memory mapped access to
> > files.  One CAN access files via both of these interfaces, and the
> > system jumps through hoops backwards [e.g., consider truncation] to make
> > it work.  However, some applications just access the files via mmap()
> > and want to control the NUMA placement like any other component of their
> > address space.   Read/write access to such a file, while I agree it
> 
> Right but the pages may already have been in memory due to buffered read
> access.

True.  As we've been discussion in another branch with Gleb Natapov
[added to cc list], some applications use "application private" files
[not to be confused with MPA_PRIVATE, please] that they only ever access
via mmap().  Still pages could be in the page cache because the file had
just been backed up or restored from backup.  However, in this case, the
pages' mapcount should be '1'--the first application task to mmap shared
and apply the policy--so MPOL_MF_MOVE should work. 

> 
> > should work, is, IMO, secondary to load/store access.  In such a case,
> > the performance of the load/store access shouldn't be sacrificed for the
> > read/write case, which already has to go through system calls, buffer
> > copies, ...
> 
> Its not a matter of sacrifice. Its consistency. page cache pages are 
> always subject to the tasks memory policy whether you use bufferred I/O or 
> mmapped I/O.

I'm all for consistency when it helps.  Here it hurts.  
> 
> > > Having no vma policy support insures that pagecache pages regardless if 
> > > they are mmapped or not will get the task policy applied.
> > 
> > Which is fine if that's what you want.  If you're using a memory mapped
> > file as a persistent shared memory area that faults pages in where you
> > specified, as you access them, maybe that's not what you want.  I
> > guarantee that's not what I want.
> > 
> > However, it seems to me, this is our other discussion.  What I've tried
> > to do with this patch is document the existing concepts and behavior, as
> > I understand them.  
> 
> It seems that you are creating some artificial problems here.

Christoph:  Let me assume you, I'm not persisting in this exchange
because I'm enjoying it.  Quite the opposite, actually.  However, like
you, my employer asks me to address our customers' requirements.  I'm
trying to understand and play within the rules of the community.  I
attempted this documentation patch to address what I saw as missing
documentation and to provide context for further discussion of my patch
set.  

> 
> > > > +	Default Mode--MPOL_DEFAULT:  The behavior specified by this mode is
> > > > +	context dependent.
> > > > +
> > > > +	    The system default policy is hard coded to contain the Default mode.
> > > > +	    In this context, it means "local" allocation--that is attempt to
> > > > +	    allocate the page from the node associated with the cpu where the
> > > > +	    fault occurs.  If the "local" node has no memory, or the node's
> > > > +	    memory can be exhausted [no free pages available], local allocation
> > > > +	    will attempt to allocate pages from "nearby" nodes, using a per node
> > > > +	    list of nodes--called zonelists--built at boot time.
> > > > +
> > > > +		TODO:  address runtime rebuild of node/zonelists when
> > > > +		supported.
> > > 
> > > Why?
> > 
> > Because "built at boot time" is then not strictly correct, is it?  
> 
> I still do not understand what this is all about. The zonelists are 
> rebuild due to Kame-san's patch for the ZONE_DMA problems. Okay. So what 
> does this have to do with MPOL_DEFAULT?

I'll remove the TODO, OK?

My point was that the description of MPOL_DEFAULT made reference to the
zonelists built at boot time, to distinguish them from the custom
zonelists built for an MPOL_BIND.  Since the zonelist reorder patch
hasn't made it out of Andrew's tree yet, I didn't want to refer to it
this round of the doc.  If it makes it into the tree, I had planned say
something like:  "at boot time or on request".  I should probably add
"or on memory hotplug".

> 
> > > > +	    The Default mode does not use the optional set of nodes.
> > > 
> > > Neither does the preferred node mode.
> > 
> > Actually, it does take the node mask argument.  It just selects the
> > first node therein.  See response to Andi.
> 
> It uses one node yes. It does not support (or is not intended to support) 
> a nodemask.

OK.  In the context of this concepts section, I see your point.  I've
rewritten this section.  

In the context of the API section, the argument is defined as a nodemask
and can have 0 [local allocation], 1, or more [choses the first].  I'll
fix it up.

> 
> > > > +	Note:  the headers that define these APIs and the parameter data types
> > > > +	for user space applications reside in a package that is not part of
> > > > +	the Linux kernel.  The kernel system call interfaces, with the 'sys_'
> > > > +	prefix, are defined in <linux/syscalls.h>; the mode and flag
> > > > +	definitions are defined in <linux/mempolicy.h>.
> > > 
> > > You need to mention the numactl library here.
> > 
> > I'm trying to describe kernel behavior.  I would expect this to be
> > picked up by the man pages at some time.  As I responded to Andi, I'll
> > work the maintainers... When I get the time.
> 
> I though you wanted to explain this to users? If so then you need to 
> mention the user APIs such as numactl and libcpuset.

OK.  Since application developers might come here to get information, I
should probably at least point them at the libnuma for the wrappers, as
that tends to ship with many distros.  I'm still not sure about the
general availability of libcpuset.

But, after I see what gets accepted into the man pages that I've agreed
to update, I'll consider dropping this section altogether.  Maybe the
entire document.

> 
> > You don't get COW if it's a shared mapping.  You use the page cache
> > pages which ignores my mbind().  That's my beef!  [;-)]
> 
> page cache pages are subject to a tasks memory policy regardless of how we 
> get to the page cache page. I think that is pretty consistent.

Oh, it's consistent, alright.  Just not pretty [;-)] when it's not what
the application wants.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
