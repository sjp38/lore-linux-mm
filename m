Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A6B746B0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 16:03:07 -0500 (EST)
Date: Wed, 13 Feb 2013 15:03:05 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130213210305.GV3438@sgi.com>
References: <20130212213534.GA5052@sgi.com>
 <20130212135726.a40ff76f.akpm@linux-foundation.org>
 <20130213150340.GJ3460@sgi.com>
 <20130213121149.25a0e3bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130213121149.25a0e3bd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, Cliff Wickman <cpw@sgi.com>, linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de

On Wed, Feb 13, 2013 at 12:11:49PM -0800, Andrew Morton wrote:
> On Wed, 13 Feb 2013 09:03:40 -0600
> Robin Holt <holt@sgi.com> wrote:
> 
> > > But in a better world, the core kernel would support your machines
> > > adequately and you wouldn't need to maintain that out-of-tree MM code. 
> > > What are the prospects of this?
> > 
> > We can put it on our todo list.  Getting a user of this infrastructure
> > will require changes by Dimitri for the GRU driver (drivers/misc/sgi-gru).
> > He is currently focused on getting the design of some upcoming hardware
> > finalized and design changes tested in our simulation environment so he
> > will be consumed for the next several months.
> > 
> > If you would like, I can clean up the driver in my spare time and submit
> > it for review.  Would you consider allowing its inclusion without the
> > GRU driver as a user?
> 
> >From Cliff's description it sounded like that driver is
> duplicating/augmenting core MM functions.  I was more wondering
> whether core MM could be enhanced so that driver becomes obsolete?

That would be fine with me.  The requirements on the driver are fairly
small and well known.  We separate virtual addresses above processor
addressable space into two "regions".  Memory from 1UL << 53 to 1UL <<
63 is considered one set of virtual addresses.  Memory above 1UL << 63
is considered "shared among a process group".

I will only mention in passing that we also have a driver which exposes
mega-size pages which the kernel has not been informed of by the EFI
memory map and xvma is used to allow the GRU to fault pages of a supported
page size (eg: 64KB, 256KB 512KB, 2MB, 8MB, ... 1TB).

The shared address has a couple unusual features.  One task makes a ioctl
(happens to come via XPMEM) which creates a shared_xmm.  This is roughly
equivalent to an mm for a pthread app.  Once it is created, a shared_xmm
id is returned.  Other tasks then join that shared xmm.

At any time, any process can created shared mmap entries (again, currently
via XPMEM).  Again, this is like a pthread in that this new mapping is
now referencable from all tasks at the same virtual address.

There are similar functions for removing the shared mapping.

The non-shared case is equivalent to a regular mm/vma, but beyond
processor addressable space.

SGI's MPI utilizes these address spaces for directly mapping portions
of the other tasks address space.  This can include processes in other
portions of the machine beyond the processor's ability to physically
address.

The above, of course, is an oversimplification, but should give you and
idea of the big picture design goals.

Does any of this make sense?  Do you see areas where you think we should
extend regular mm functionality to include these functions?

How would you like me to proceed?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
