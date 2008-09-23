Message-ID: <48D8C326.80909@tungstengraphics.com>
Date: Tue, 23 Sep 2008 12:21:26 +0200
From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
References: <20080923091017.GB29718@wotan.suse.de>
In-Reply-To: <20080923091017.GB29718@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
>
> So I promised I would look at this again, because I (and others) have some
> issues with exporting shmem_file_setup for DRM-GEM to go off and do things
> with.
>
> The rationale for using shmem seems to be that pageable "objects" are needed,
> and they can't be created by userspace because that would be ugly for some
> reason, and/or they are required before userland is running.
>
> I particularly don't like the idea of exposing these vfs objects to random
> drivers because they're likely to get things wrong or become out of synch
> or unreviewed if things change. I suggested a simple pageable object allocator
> that could live in mm and hide the exact details of how shmem / pagecache
> works. So I've coded that up quickly.
>
> Upon actually looking at how "GEM" makes use of its shmem_file_setup filp, I
> see something strange... it seems that userspace actually gets some kind of
> descriptor, a descriptor to an object backed by this shmem file (let's call it
> a "file descriptor"). Anyway, it turns out that userspace sometimes needs to
> pread, pwrite, and mmap these objects, but unfortunately it has no direct way
> to do that, due to not having open(2)ed the files directly. So what GEM does
> is to add some ioctls which take the "file descriptor" things, and derives
> the shmem file from them, and then calls into the vfs to perform the operation.
>
> If my cursory reading is correct, then my allocator won't work so well as a
> drop in replacement because one isn't allowed to know about the filp behind
> the pageable object. It would also indicate some serious crack smoking by
> anyone who thinks open(2), pread(2), mmap(2), etc is ugly in comparison...
>
> So please, nobody who worked on that code is allowed to use ugly as an
> argument. Technical arguments are fine, so let's try to cover them.
>
>   
Nick,
 From my point of view, this is exactly what's needed, although there 
might be some different opinions among the
DRM developers. A question:

Sometimes it's desirable to indicate that a page / object is "cleaned", 
which would mean data has moved and is backed by device memory. In that 
case one could either free the object or indicate to it that it can 
release it's pages. Is freeing / recreating such an object an expensive 
operation? Would it, in that case, be possible to add an object / page 
"cleaned" function?

/Thomas
 








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
