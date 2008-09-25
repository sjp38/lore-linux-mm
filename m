Date: Thu, 25 Sep 2008 02:30:21 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Message-ID: <20080925003021.GC23494@wotan.suse.de>
References: <20080923091017.GB29718@wotan.suse.de> <1222185029.4873.157.camel@koto.keithp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222185029.4873.157.camel@koto.keithp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Packard <keithp@keithp.com>
Cc: eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 23, 2008 at 08:50:29AM -0700, Keith Packard wrote:
> On Tue, 2008-09-23 at 11:10 +0200, Nick Piggin wrote:
> > I particularly don't like the idea of exposing these vfs objects to random
> > drivers because they're likely to get things wrong or become out of synch
> > or unreviewed if things change. I suggested a simple pageable object allocator
> > that could live in mm and hide the exact details of how shmem / pagecache
> > works. So I've coded that up quickly.
> 
> Thanks for trying another direction; let's see if that will work for us.

Great!

 
> > Upon actually looking at how "GEM" makes use of its shmem_file_setup filp, I
> > see something strange... it seems that userspace actually gets some kind of
> > descriptor, a descriptor to an object backed by this shmem file (let's call it
> > a "file descriptor"). Anyway, it turns out that userspace sometimes needs to
> > pread, pwrite, and mmap these objects, but unfortunately it has no direct way
> > to do that, due to not having open(2)ed the files directly. So what GEM does
> > is to add some ioctls which take the "file descriptor" things, and derives
> > the shmem file from them, and then calls into the vfs to perform the operation.
> 
> Sure, we've looked at using regular file descriptors for these objects
> and it almost works, except for a few things:
> 
>  1) We create a lot of these objects. The X server itself may have tens
>     of thousands of objects in use at any one time (my current session
>     with gitk and firefox running is using 1565 objects). Right now, the
>     maximum number of fds supported by 'normal' kernel configurations
>     is somewhat smaller than this. Even when the kernel is fixed to
>     support lifting this limit, we'll be at the mercy of existing user
>     space configurations for normal applications.
> 
>  2) More annoyingly, applications which use these objects also use
>     select(2) and depend on being able to represent the 'real' file
>     descriptors in a compact space near zero. Sticking a few thousand
>     of these new objects into the system would require some ability to
>     relocate the descriptors up higher in fd space. This could also
>     be done in user space using dup2, but that would require managing
>     file descriptor allocation in user space.
> 
>  3) The pread/pwrite/mmap functions that we use need additional flags
>     to indicate some level of application 'intent'. In particular, we
>     need to know whether the data is being delivered only to the GPU
>     or whether the CPU will need to look at it in the future. This
>     drives the kind of memory access used within the kernel and has
>     a significant performance impact.

Pity. Anyway, I accept that, let's move on.

[...]

> Hiding the precise semantics of the object storage behind our
> ioctl-based API means that we can completely replace in the future
> without affecting user space.

I guess so. A big problem of ioctls is just that they had been easier to
add so they got less thought and review ;) If your ioctls are stable,
correct, cross platform etc. then I guess that's the best you can do.

 
> > BTW. without knowing much of either the GEM or the SPU subsystems, the
> > GEM problem seems similar to SPU. Did anyone look at that code? Was it ever
> > considered to make the object allocator be a filesystem? That way you could
> > control the backing store to the objects yourself, those that want pageable
> > memory could use the following allocator, the ioctls could go away,
> > you could create your own objects if needed before userspace is up...
> 
> Yes, we've considered doing a separate file system, but as we'd start by
> copying shmem directly, we're unsure how that would be received. It
> seems like sharing the shmem code in some sensible way is a better plan.

Well, no not a seperate filesystem to do the pageable backing store, but
a filesystem to do your object management. If there was a need for pageable
RAM backing store, then you would still go back to the pageable allocator. 

 
> We just need anonymous pages that we can read/write/map to kernel and
> user space. Right now, shmem provides that functionality and is used by
> two kernel subsystems (sysv IPC and tmpfs). It seems like any new API
> should support all three uses rather than being specific to GEM.
> 
> > The API allows creation and deletion of memory objects, pinning and
> > unpinning of address ranges within an object, mapping ranges of an object
> > in KVA, dirtying ranges of an object, and operating on pages within the
> > object.
> 
> The only question I have is whether we can map these objects to user
> space; the other operations we need are fairly easily managed by just
> looking at objects one page at a time. Of course, getting to the 'fast'
> memcpy variants that the current vfs_write path finds may be a trick,
> but we should be able to figure that out.

You can map them to userspace if you just take a page at a time and insert
them into the page tables at fault time (or mmap time if you prefer).
Currently, this will mean that mmapped pages would not be swappable; is
that a problem?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
