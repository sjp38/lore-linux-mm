Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706290649480.14268@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <1183038137.5697.16.camel@localhost>
	 <Pine.LNX.4.64.0706281835270.9573@schroedinger.engr.sgi.com>
	 <200706291101.41081.ak@suse.de>
	 <Pine.LNX.4.64.0706290649480.14268@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 13:41:49 -0400
Message-Id: <1183138909.5012.40.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-29 at 07:05 -0700, Christoph Lameter wrote:
> On Fri, 29 Jun 2007, Andi Kleen wrote:
> 
> > > I still do not see the rationale for this patchset. This adds more special 
> > > casing. 
> > 
> > The reference count change at least is a good idea.
> 
> Allright lets split that out and look at it?

I think that my patch to get_vma_policy() is still applicable.  My
changes to alloc_page_pol() [only exists in my series] need to be
reworked to restore the tail call in the common cases in
alloc_page_vma().  Should be easy, if 2 separate calls to
__alloc_pages() is acceptable.  As I mentioned to Andy, I won't get to
test this for a couple of weeks.

> 
> > > This all still falls under the category of messing up a bad situation even 
> > > more.
> > 
> > I think you're exaggerating.
> 
> We are creating more weird interactions between processes. The Unix 
> model is to isolate processes from each other. As a result of 
> this patch modifications to allocation policy in the address space of one 
> process can suddenly show up in surprising ways in another.

Some times we WANT interactions between cooperating processes.  That's
why we have shared memory and shared file mappings.  Yes, they need to
be managed/controlled.  The shared policy shouldn't show up in
surprising ways in the address space of a process that is sharing the
file with the one that installed the policy.  They should be cooperating
tasks.  I agree that task executables and shared libraries are
different...  See below

> 
> This in itself is bad enough. Its get worse since there does not seem to 
> be a way to prohibit this.

As I've said before, we can DO that, if you think it's needed.  E.g., we
can require write access to a file in order to install a shared policy.
Probably a good idea anyway.  Processes that have write access to a
shared, mmap()ed file BETTER be cooperating.

If you're worried about Joe User applying miscellaneous shared policies
to his task's executable or, say, libc, we could prevent this in a
couple of ways:

1) only enable shared policies on mapped files in cpusets running
applications that need this feature.

2) by requiring write access.  However, it might be useful to have a
privileged task mmap() libc shared/writable and apply a specific policy.
It certainly would on some HP platforms where we have the hardware
interleaved node.  [Altho' in some cases, replication might be
preferable.]


> 
> The NUMA policy layer is already difficult enough to comprehend for the 
> end user. We already have people not using it because it is too difficult 
> to understand. This will kick it into even weirder areas.

It's difficult for an end user to comprehend why we ignore policy on
shared file mappings [without even giving and error return, I might
add].  It's this inconsistencies in the APIs from the application
viewpoint that I'm trying to address.

> 
> One bad case is that two processes run in different cpusets. Lets say 
> process A is running in cpuset X on nodes 1 and 2. Process B is running in 
> Y on nodes 3 and 4. Both memmap FILE into distinct address ranges.
> 
> Now process A sets a MPOL_BIND policy for FILE to only come from node 1.

If they're cooperating and there is some good reason why the
applications are running in disjoint cpusets--e.g., the application was
written to be deployed this way--then the application shouldn't be
installing policies this way.  Or we can just not enable the feature in
those cpusets.  We can still allow well behaved multi-process
applications to have the feature in their own cpuset.

As above, we can control this for shared libs, etc.

> 
> If process B now follows that policy then process B will allocate outside 
> of the cpuset it is contained it. B will likely OOM since it is not 
> allowed to access node 1. This is rather surprising for the person trying 
> to run the processes in Y because he is unaware of what happens in X. He 
> will likely be unable to debug the situation. I will likely see a flood of 
> bug reports if this goes in.

Mapped shared file policy is off by default.  Documentation explain the
implications of turning on for applications that share mapped files
between cpusets.  We need to do this anyway, for shmem.  How many bug
reports have you seen from this scenario for shmem segments which behave
exactly the same?

> 
> This could be fixed by storing the complete context information with the 
> file in memory. If the policy would contain the cpuset then process B 
> could just be allowed to allocate in cpuset X despite being part of Y.

Might work.  Seems like overkill, but if there is a use case for
applications to shared mapped files and shmem with non-default policy
between processes in disjoint cpusets/containers, then I guess we need
to do this anyway--for shmem.

> 
> All of this points to significant conceptual breakage if twe do this. 
> There has to be some major semantic change to the memory policy layer in 
> order to make shared policies work. 

No, we need to reconcile the issue of sharing between disjoint cpusets.
I see this as augmenting the current semantics to specify either current
behavior or some new behavior that we agree on.  

> But then I do not have any problem 
> reports that require shared policies. The issues that I know about are 
> complaints that the vma policies of a process are not applied to page 
> cache pages like they are for anonymous pages. They are asking for a fix 
> for this and not for shared policies.

Do the bug reports specify whether the mapping is for private or shared
mappings?  VMA policies ARE applied to page cache pages of private
mappings if the process COWs the page.   For shared mappings, if we used
a vma based policy, then different processes could have different
policies for the same page.  Then, the location would depend on which
process touched the page first, thus surprising the application that
touched the page later, expecting it to be placed where ITS policy
specifies.  Sounds like another bug report to me. ;-)  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
