Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 9B1886B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 16:35:13 -0500 (EST)
Date: Thu, 14 Feb 2013 15:35:12 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130214213512.GH3438@sgi.com>
References: <20130212213534.GA5052@sgi.com>
 <20130212135726.a40ff76f.akpm@linux-foundation.org>
 <20130213150340.GJ3460@sgi.com>
 <20130213121149.25a0e3bd.akpm@linux-foundation.org>
 <20130213210305.GV3438@sgi.com>
 <20130214130856.13d1b5bb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130214130856.13d1b5bb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de

On Thu, Feb 14, 2013 at 01:08:56PM -0800, Andrew Morton wrote:
> On Wed, 13 Feb 2013 15:03:05 -0600
> Robin Holt <holt@sgi.com> wrote:
> 
> > On Wed, Feb 13, 2013 at 12:11:49PM -0800, Andrew Morton wrote:
> > > On Wed, 13 Feb 2013 09:03:40 -0600
> > > Robin Holt <holt@sgi.com> wrote:
> > > 
> > > > > But in a better world, the core kernel would support your machines
> > > > > adequately and you wouldn't need to maintain that out-of-tree MM code. 
> > > > > What are the prospects of this?
> > > > 
> > > > We can put it on our todo list.  Getting a user of this infrastructure
> > > > will require changes by Dimitri for the GRU driver (drivers/misc/sgi-gru).
> > > > He is currently focused on getting the design of some upcoming hardware
> > > > finalized and design changes tested in our simulation environment so he
> > > > will be consumed for the next several months.
> > > > 
> > > > If you would like, I can clean up the driver in my spare time and submit
> > > > it for review.  Would you consider allowing its inclusion without the
> > > > GRU driver as a user?
> > > 
> > > >From Cliff's description it sounded like that driver is
> > > duplicating/augmenting core MM functions.  I was more wondering
> > > whether core MM could be enhanced so that driver becomes obsolete?
> > 
> > That would be fine with me.  The requirements on the driver are fairly
> > small and well known.  We separate virtual addresses above processor
> > addressable space into two "regions".  Memory from 1UL << 53 to 1UL <<
> > 63 is considered one set of virtual addresses.  Memory above 1UL << 63
> > is considered "shared among a process group".
> > 
> > I will only mention in passing that we also have a driver which exposes
> > mega-size pages which the kernel has not been informed of by the EFI
> > memory map and xvma is used to allow the GRU to fault pages of a supported
> > page size (eg: 64KB, 256KB 512KB, 2MB, 8MB, ... 1TB).
> > 
> > The shared address has a couple unusual features.  One task makes a ioctl
> > (happens to come via XPMEM) which creates a shared_xmm.  This is roughly
> > equivalent to an mm for a pthread app.  Once it is created, a shared_xmm
> > id is returned.  Other tasks then join that shared xmm.
> > 
> > At any time, any process can created shared mmap entries (again, currently
> > via XPMEM).  Again, this is like a pthread in that this new mapping is
> > now referencable from all tasks at the same virtual address.
> > 
> > There are similar functions for removing the shared mapping.
> > 
> > The non-shared case is equivalent to a regular mm/vma, but beyond
> > processor addressable space.
> > 
> > SGI's MPI utilizes these address spaces for directly mapping portions
> > of the other tasks address space.  This can include processes in other
> > portions of the machine beyond the processor's ability to physically
> > address.
> 
> What exactly is "SGI's MPI" from the kernel POV?  A separate
> out-of-tree driver?

MPI (Message Passing Interface) is a standardized library of routines
for building parallelized jobs.  It is a standard.  SGI has their
implementation.  Cray has a similar implementation and, as I understand
it, have leveraged an earlier version of xpmem that I posted here a few
years ago.  There are also Intel MPI, HP MPI, IBM MPI, and many others.
They are all libraries that provide a means to rapidly communicate
between processing units.  IBM has, in the past, attempted to get changes
introduced for their direct communications between jobs.

SGI and Cray's implementations both do single copy between ranks without
going to kernel space.  Think of it as RDMA using IB, but the processor
does the work.

> If the objective is to "directly map portions of the other tasks
> address space" then how does this slicing-up of physical address
> regions come into play?  If one wishes to map another mm's memory,
> wouldn't you just go ahead and map it, regardless of physical address?

I probably am not quite understanding your meaning here or not explaining
myself well enough, but the library does not control what portion
of the address space contains the data for use by the collective.
A library call is made and the collective does the work of signalling
to the other ranks where to find the data.  With XPMEM and the GRUs much
larger virtual addresing capabilties, we can have all of the other rank's
virtual address space pre-mapped.

I am open to suggestions.  Can you suggest existing kernel functionality
that allows one task to map another virtual address space into their
va space to allow userland-to-userland copies without system calls?
If there is functionality that has been introduced in the last couple
years, I could very well have missed it as I have been fairly heads-down
on other things for some time.

> To what extent is all this specific to SGI hardware characteristics?

SGI's hardware allows two things, a vastly larger virtual address space
and the ability to access memory in other system images on the same numa
fabric which are beyond the processsors physical addressing capabilities.

I am fairly sure Cray has taken an older version of XPMEM and stripped
out a bunch of SGI specific bits and implemented it on their hardware.

> > The above, of course, is an oversimplification, but should give you and
> > idea of the big picture design goals.
> >
> > Does any of this make sense?  Do you see areas where you think we should
> > extend regular mm functionality to include these functions?
> > 
> > How would you like me to proceed?
> 
> I'm obviously on first base here, but overall approach:
> 
> - Is the top-level feature useful to general Linux users?  Perhaps
>   after suitable generalisations (aka dumbing down :))

I am not sure how useful it is.  I know IBM has tried in the past to
get a similar feature introduced.  I believe they settled on a ptrace
extension to do direct user-to-user copies from within the kernel.

> - Even if the answer to that is "no", should we maintain the feature
>   in-tree rather than out-of-tree?

Not sure on the second one, but I believe Linus' objection is security and
I can certainly understand that.  Right now, SGI's xpmem implementation
enforces that all jobs in the task need to have the same UID.  There is
no exception for root or and administrator.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
