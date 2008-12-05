Subject: Re: [PATCH 1/1] Userspace I/O (UIO): Add support for userspace DMA
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20081204180809.GB3079@local>
References: <43FC624C55D8C746A914570B66D642610367F29B@cos-us-mb03.cos.agilent.com>
	 <1228379942.5092.14.camel@twins>  <20081204180809.GB3079@local>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 05 Dec 2008 08:10:59 +0100
Message-Id: <1228461060.18899.8.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Hans J. Koch" <hjk@linutronix.de>
Cc: edward_estabrook@agilent.com, linux-kernel@vger.kernel.org, gregkh@suse.de, edward.estabrook@gmail.com, hugh <hugh@veritas.com>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-12-04 at 19:08 +0100, Hans J. Koch wrote:
> On Thu, Dec 04, 2008 at 09:39:02AM +0100, Peter Zijlstra wrote:
> > On Wed, 2008-12-03 at 14:39 -0700, edward_estabrook@agilent.com wrote:
> > > From: Edward Estabrook <Edward_Estabrook@agilent.com>
> > > 
> > > Here is a patch that adds the ability to dynamically allocate (and
> > > use) coherent DMA from userspace by extending the userspace IO driver.
> > > This patch applies against 2.6.28-rc6.
> > > 
> > > The gist of this implementation is to overload uio's mmap
> > > functionality to allocate and map a new DMA region on demand.  The
> > > bus-specific DMA address as returned by dma_alloc_coherent is made
> > > available to userspace in the 1st long word of the newly created
> > > region (as well as through the conventional 'addr' file in sysfs).  
> > > 
> > > To allocate a DMA region you use the following:
> > > /* Pass this magic number to mmap as offset to dynamically allocate a
> > > chunk of memory */ #define DMA_MEM_ALLOCATE_MMAP_OFFSET 0xFFFFF000UL
> > > 
> > > void* memory = mmap (NULL, size, PROT_READ | PROT_WRITE , MAP_SHARED,
> > > fd, DMA_MEM_ALLOCATE_MMAP_OFFSET); u_int64_t *addr = *(u_int64_t *)
> > > memory;
> > > 
> > > where 'size' is the size in bytes of the region you want and fd is the
> > > opened /dev/uioN file.
> > > 
> > > Allocation occurs in page sized pieces by design to ensure that
> > > buffers are page-aligned.
> > > 
> > > Memory is released when uio_unregister_device() is called.
> > >
> > > I have used this extensively on a 2.6.21-based kernel and ported it to
> > > 2.6.28-rc6 for review / submission here.
> > > 
> > > Comments appreciated!
> > 
> > Yuck!
> > 
> > Why not create another special device that will give you DMA memory when
> > you mmap it? That would also allow you to obtain the physical address
> > without this utter horrid hack of writing it in the mmap'ed memory.
> > 
> > /dev/uioN-dma would seem like a fine name for that.
> 
> I don't like to have a separate device for DMA memory. It would completely
> break the current concept of userspace drivers if you had to get normal
> memory from one device and DMA memory from another. Note that one driver
> can have both.

How would that break anything, the one driver can simply open both
files.

> But I agree that it's confusing if the physical address is stored somewhere
> in the mapped memory. That should simply be omitted, we have that information
> in sysfs anyway - like for any other memory mappings. But I guess we need
> some kind of "type" or "flags" attribute for the mappings so that userspace
> can find out if a mapping is DMA capable or not.

We have that, different file.

I'll NAK any attempt that rapes the mmap interface like proposed - that
is just not an option.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
