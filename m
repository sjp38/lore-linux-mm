Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070531113011.GN4715@minantech.com>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com>
	 <20070531064753.GA31143@minantech.com> <200705311243.20119.ak@suse.de>
	 <20070531110412.GM4715@minantech.com> <20070531113011.GN4715@minantech.com>
Content-Type: text/plain
Date: Thu, 31 May 2007 11:26:44 -0400
Message-Id: <1180625204.5091.55.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-31 at 14:30 +0300, Gleb Natapov wrote:
> On Thu, May 31, 2007 at 02:04:12PM +0300, Gleb Natapov wrote:
> > On Thu, May 31, 2007 at 12:43:19PM +0200, Andi Kleen wrote:
> > > 
> > > > > The faulted page will use the memory policy of the task that faulted it 
> > > > > in. If that process has numa_set_localalloc() set then the page will be 
> > > > > located as closely as possible to the allocating thread.
> > > > 
> > > > Thanks. But I have to say this feels very unnatural.
> > > 
> > > What do you think is unnatural exactly? First one wins seems like a quite 
> > > natural policy to me.
> > No it is not (not always). I want to create shared memory for
> > interprocess communication. Process A will write into the memory and
> > process B will periodically poll it to see if there is a message there.
> > In NUMA system I want the physical memory for this VMA to be allocated
> > from node close to process B since it will use it much more frequently.
> > But I don't want to pre-fault all pages in process B to achieve this
> > because the region can be huge and because it doesn't guaranty much if
> > swapping is involved. So numa_set_localalloc() looks like it achieves
> > exactly this. Without this function I agree that the "first one wins" is
> > very sensible assumption, but when each process stated it's preferences
> > explicitly by calling the function it is not longer sensible to me as a
> > user of the API. When you start to thing about how memory policy may be
> OK now, rereading man page, I see that numa_tonode_memory() to achieve 
> this without pre-faulting. A should now what CPU B is running on, but
> this is a minor problem.

Gleb:    numa_tonode_memory() won't do what you want if the file is
mapped shared.  The numa_*_memory() interfaces use mbind() which
installs a VMA policy in the address space of the caller.  When a page
is faulted in for a mmap'd file, the page will be allocated using the
faulting task's task policy, if any, else system default.  

Now, if it were a private mapping and you write/store to the pages, the
kernel will COW and give you a page that obeys the policy you installed
in your address space.  But, shared mappings don't COW, so you retain
the original page that followed the faulting task's policy.  There are
currently 2 ways that I know of to explicitly place a page in a shared
file mapping:

1) let the task policy default to local or explicitly specify local
access [numa_set_localalloc()] and then ensure that you prefault the
page while executing on a cpu local to the node where you want the page.

2) set the task policy to bind to the desired node and prefault the
page.

Of course, if the page gets reclaimed and later faulted back in, the
location will depend on the task policy, and possibly the location, of
the task that causes the refault.

I've been proposing patches to generalize the shared policy support
enjoyed by shmem segments for use with shared mmap'd files.  I was
beginning to think that I'm the only one with applications [well, with
customers with applications] that need this behavior.  Sounds like your
requirements are very similar:  huge file [don't want to prefault nor
wait for it to all be read into shmem before starting processing], only
accesses via mmap, ...

> 
> > implemented in the kernel and understand that memory policy is a
> > property of an address space (is it?) and not a file then you start to
> > understand current behaviour, but this is implementation details.
> > 
> > 
> > > 
> > > > So to have 
> > > > desirable effect I have to create shared memory with shmget?
> > > 
> > > shmget behaves the same.
> > > 
> > Then I misinterpreted "Shared Policy" section from Lee's document.
> > It seems that he states that for memory region created with shmget the
> > policy is a property of a shared object and not of a process' address
> > space.
> > 
> Man page states:
>  Memory policy set for memory areas is shared by all threads of the
>  process. Memory policy is also shared by other processes mapping the
>  same memory using shmat(2) or mmap(2) from shmfs/hugetlbfs. It is not
>  shared for disk backed file mappings right now although that may change
>  in the future.
> So what does this mean? If I set local policy for memory region in process
> A it should be obeyed by memory access in process B?

shmem does, indeed, work this way.  Policies installed on ranges of the
shared segment via mbind() are stored with the shared object.

I think the future is now:  time to share policy for disk backed file
mappings.

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
