Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070531174116.GB10459@minantech.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com>
	 <20070531064753.GA31143@minantech.com> <200705311243.20119.ak@suse.de>
	 <20070531110412.GM4715@minantech.com> <20070531113011.GN4715@minantech.com>
	 <1180625204.5091.55.camel@localhost> <20070531174116.GB10459@minantech.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 14:56:04 -0400
Message-Id: <1180637765.5091.153.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 20:41 +0300, Gleb Natapov wrote:
> On Thu, May 31, 2007 at 11:26:44AM -0400, Lee Schermerhorn wrote:
> > On Thu, 2007-05-31 at 14:30 +0300, Gleb Natapov wrote:
> > > On Thu, May 31, 2007 at 02:04:12PM +0300, Gleb Natapov wrote:
> > > > On Thu, May 31, 2007 at 12:43:19PM +0200, Andi Kleen wrote:
> > > > > 
> > > > > > > The faulted page will use the memory policy of the task that faulted it 
> > > > > > > in. If that process has numa_set_localalloc() set then the page will be 
> > > > > > > located as closely as possible to the allocating thread.
> > > > > > 
> > > > > > Thanks. But I have to say this feels very unnatural.
> > > > > 
> > > > > What do you think is unnatural exactly? First one wins seems like a quite 
> > > > > natural policy to me.
> > > > No it is not (not always). I want to create shared memory for
> > > > interprocess communication. Process A will write into the memory and
> > > > process B will periodically poll it to see if there is a message there.
> > > > In NUMA system I want the physical memory for this VMA to be allocated
> > > > from node close to process B since it will use it much more frequently.
> > > > But I don't want to pre-fault all pages in process B to achieve this
> > > > because the region can be huge and because it doesn't guaranty much if
> > > > swapping is involved. So numa_set_localalloc() looks like it achieves
> > > > exactly this. Without this function I agree that the "first one wins" is
> > > > very sensible assumption, but when each process stated it's preferences
> > > > explicitly by calling the function it is not longer sensible to me as a
> > > > user of the API. When you start to thing about how memory policy may be
> > > OK now, rereading man page, I see that numa_tonode_memory() to achieve 
> > > this without pre-faulting. A should now what CPU B is running on, but
> > > this is a minor problem.
> > 
> > Gleb:    numa_tonode_memory() won't do what you want if the file is
> > mapped shared.  The numa_*_memory() interfaces use mbind() which
> > installs a VMA policy in the address space of the caller.  When a page
> > is faulted in for a mmap'd file, the page will be allocated using the
> > faulting task's task policy, if any, else system default.  
> > 
> Suppose I have two processes that want to communicate through the shared memory.
> They mmap same file with MAP_SHARED. Now first process call
> numa_setlocal_memory() on the region where it will receive messages and
> call numa_tonode_memory(second process nodeid) on the region where it
> will post messages for the second process. The second process does the
> same thing. After that no matter what process touches memory first,
> faulted in pages should be allocated from the correct memory node. 

Not as I understand you're meaning for "correct memory node".  Certainly
not [necessarily] the one you implied/specified in the numa_*_memory()
calls.

> Do I
> miss something here?

I think you do.  

The policies that each task apply get installed as VMA policies in the
address space of each task.  However, because you have mapped the file
shared, these policies are ignored at fault time.   Rather, because
you're faulting in a file page, the system allocates a page cache page.
The page cache allocation function will just use the faulting task's
task policy [or system default].  It will NOT consult the address space
of the faulting task.  As Christoph pointed out, the page may already be
in the page cache, allocated based on the task policy of the task that
caused the allocation.  In this case, the system will just add a page
table entry for that page to your task's page table.

The Mapped File Policy patch series that I posted addresses the behavior
described above--probably not what you expect nor what you want?--by
using the same shared policy infrastructure used by shmem to control
allocation for regular files mmap()'d shared.  

Semantics [with my patches] are as follows:

If you map a file MAP_PRIVATE, policy only gets applied to the calling
task's address space.  I.e., current behavior.  It will be ignored by
page cache allocations.  However, if you write to the page, the kernel
will COW the page, making a private anonymous copy for your task.  The
anonymous COWed page WILL follow the VMA policy you installed, but won't
be visible to any other task mmap()ing the file--shared or private.
This is also current behavior.

If you map a file MAP_SHARED and DON'T apply a policy--which covers most
existing applications, according to Andi--then page cache allocations
will still default to task policy or system default--again, current
behavior.  Even if you write to the page, because you've mapped shared,
you keep the page cache page allocated at fault time.

If you map a file shared and apply a policy via mbind() or one of the
libnuma wrappers you mention above, the policy will "punch through" the
VMA and be installed on the file's internal incarnation [inode +
address_space structures], dynamically allocating the necessary
shared_policy structure.  Then, for this file, page_cache allocations
that hit the range on which you installed a policy will use that shared
policy.  If you don't cover the entire file with your policy, those
ranges that you don't cover will continue to use task/system default
policy--just like shmem.

> 
> > I've been proposing patches to generalize the shared policy support
> > enjoyed by shmem segments for use with shared mmap'd files.  I was
> > beginning to think that I'm the only one with applications [well, with
> > customers with applications] that need this behavior.  Sounds like your
> > requirements are very similar:  huge file [don't want to prefault nor
> > wait for it to all be read into shmem before starting processing], only
> > accesses via mmap, ...
> I thought this is pretty common user case, but Andi thinks different. I
> don't have any hard evidence one way or the other.

The only evidence I have is from customers I've worked with in the past
that we're trying to convert to Linux and requirements apparently coming
from customers with whom I don't have direct contact--i.e., from
marketing, sales/support, ...  Or maybe they're just making it up to
keep my busy ;-).

> 
> > > Man page states:
> > >  Memory policy set for memory areas is shared by all threads of the
> > >  process. Memory policy is also shared by other processes mapping the
> > >  same memory using shmat(2) or mmap(2) from shmfs/hugetlbfs. It is not
> > >  shared for disk backed file mappings right now although that may change
> > >  in the future.
> > > So what does this mean? If I set local policy for memory region in process
> > > A it should be obeyed by memory access in process B?
> > 
> > shmem does, indeed, work this way.  Policies installed on ranges of the
> > shared segment via mbind() are stored with the shared object.
> > 
> > I think the future is now:  time to share policy for disk backed file
> > mappings.
> > 
> At least it will be consistent with what you get when shared memory is
> created via shmget(). It will be very surprising for a programmer if
> his program' logic will break just because he changes the way how shared
> memory is created.


Yes.  A bit inconsistent, from the application programmer's viewpoint.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
