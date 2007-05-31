Date: Thu, 31 May 2007 23:06:44 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070531200644.GD10459@minantech.com>
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com> <20070531064753.GA31143@minantech.com> <200705311243.20119.ak@suse.de> <20070531110412.GM4715@minantech.com> <20070531113011.GN4715@minantech.com> <1180625204.5091.55.camel@localhost> <20070531174116.GB10459@minantech.com> <1180637765.5091.153.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1180637765.5091.153.camel@localhost>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2007 at 02:56:04PM -0400, Lee Schermerhorn wrote:
> > Suppose I have two processes that want to communicate through the shared memory.
> > They mmap same file with MAP_SHARED. Now first process call
> > numa_setlocal_memory() on the region where it will receive messages and
> > call numa_tonode_memory(second process nodeid) on the region where it
> > will post messages for the second process. The second process does the
> > same thing. After that no matter what process touches memory first,
> > faulted in pages should be allocated from the correct memory node. 
> 
> Not as I understand you're meaning for "correct memory node".  Certainly
> not [necessarily] the one you implied/specified in the numa_*_memory()
> calls.
> 
> > Do I
> > miss something here?
> 
> I think you do.  
OK. It seems I missed the fact that VMA policy is completely ignored for
pagecache backed files and only task policy is used. So prefaulting is
the only option left. Very sad.

> Semantics [with my patches] are as follows:
> 
> If you map a file MAP_PRIVATE, policy only gets applied to the calling
> task's address space.  I.e., current behavior.  It will be ignored by
> page cache allocations.  However, if you write to the page, the kernel
> will COW the page, making a private anonymous copy for your task.  The
> anonymous COWed page WILL follow the VMA policy you installed, but won't
> be visible to any other task mmap()ing the file--shared or private.
> This is also current behavior.
> 
> If you map a file MAP_SHARED and DON'T apply a policy--which covers most
> existing applications, according to Andi--then page cache allocations
> will still default to task policy or system default--again, current
> behavior.  Even if you write to the page, because you've mapped shared,
> you keep the page cache page allocated at fault time.
> 
> If you map a file shared and apply a policy via mbind() or one of the
> libnuma wrappers you mention above, the policy will "punch through" the
> VMA and be installed on the file's internal incarnation [inode +
> address_space structures], dynamically allocating the necessary
> shared_policy structure.  Then, for this file, page_cache allocations
> that hit the range on which you installed a policy will use that shared
> policy.  If you don't cover the entire file with your policy, those
> ranges that you don't cover will continue to use task/system default
> policy--just like shmem.
This sound very reasonable and actually what I expected from the system
in the first place.

> > > > Man page states:
> > > >  Memory policy set for memory areas is shared by all threads of the
> > > >  process. Memory policy is also shared by other processes mapping the
> > > >  same memory using shmat(2) or mmap(2) from shmfs/hugetlbfs. It is not
> > > >  shared for disk backed file mappings right now although that may change
> > > >  in the future.
> > > > So what does this mean? If I set local policy for memory region in process
> > > > A it should be obeyed by memory access in process B?
> > > 
> > > shmem does, indeed, work this way.  Policies installed on ranges of the
> > > shared segment via mbind() are stored with the shared object.
> > > 
> > > I think the future is now:  time to share policy for disk backed file
> > > mappings.
> > > 
> > At least it will be consistent with what you get when shared memory is
> > created via shmget(). It will be very surprising for a programmer if
> > his program' logic will break just because he changes the way how shared
> > memory is created.
> 
> 
> Yes.  A bit inconsistent, from the application programmer's viewpoint.
> 
"A bit" is underestimation :)

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
