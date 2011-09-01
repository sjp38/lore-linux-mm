Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0E56B00EE
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 14:55:14 -0400 (EDT)
Date: Thu, 1 Sep 2011 20:55:02 +0200
From: "Hans J. Koch" <hjk@hansjkoch.de>
Subject: Re: bade page state while calling munmap() for kmalloc'ed UIO memory
Message-ID: <20110901185502.GB8408@local>
References: <1314630347.2258.150.camel@bender.lan>
 <20110831095825.GC4769@local>
 <20110831161307.d605848b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110831161307.d605848b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Hans J. Koch" <hjk@hansjkoch.de>, Jan Altenberg <jan@linutronix.de>, linux-mm@kvack.org, b.spranger@linutronix.de, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 31, 2011 at 04:13:07PM -0700, Andrew Morton wrote:
> On Wed, 31 Aug 2011 11:58:25 +0200
> "Hans J. Koch" <hjk@hansjkoch.de> wrote:
> 
> > On Mon, Aug 29, 2011 at 05:05:47PM +0200, Jan Altenberg wrote:
> > 
> > [Since we got no reply on linux-mm, I added lkml and Andrew to Cc: (mm doesn't
> > seem to have a maintainer...)]
> > 
> > > Hi,
> > > 
> > > I'm currently analysing a problem similar to some mmap() issue reported
> > > in the past: https://lkml.org/lkml/2010/7/11/140
> > 
> > The arch there was microblaze, and you are working on arm. That means
> > the problem appears on at least to archs.
> > 
> > > 
> > > So, what I'm trying to do is mapping some physically continuous memory
> > > (allocated by kmalloc) to userspace, using a trivial UIO driver (the
> > > idea is that a device can directly DMA to that buffer):
> > > 
> > > [...]
> > > #define MEM_SIZE (4 * PAGE_SIZE)
> > > 
> > > addr = kmalloc(MEM_SIZE, GFP_KERNEL)
> > > [...]
> > > info.mem[0].addr = (unsigned long) addr;
> > > info.mem[0].internal_addr = addr;
> > > info.mem[0].size = MEM_SIZE;
> > > info.mem[0].memtype = UIO_MEM_LOGICAL;
> > > [...]
> > > ret = uio_register_device(&pdev->dev, &info);
> > > 
> > > Userspace maps that memory range and writes its contents to a file:
> > > 
> > > [...]
> > > 
> > > fd = open("/dev/uio0", O_RDWR);
> > > if (fd < 0) {
> > >            perror("Can't open UIO device\n");
> > >            exit(1);
> > > }
> > > 
> > > mem_map = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
> > >                   MAP_PRIVATE, fd, 0);
> > > 
> > > if(mem_map == MAP_FAILED) {
> > >            perror("Can't map UIO memory\n");
> > >            ret = -ENOMEM;
> > >            goto out_file;
> > > }
> > > [...]
> > > bytes_written = write(fd_file, mem_map, MAP_SIZE)
> > > [...]
> > > 
> > > munmap(mem_map);
> > 
> > >From my point of view (I've got Jan's full test case code), this
> > is a completely correct UIO use case.
> > 
> > > 
> > > So, what happens is (I'm currently testing with 3.0.3 on ARM
> > > VersatilePB): When I do the munmap(), I run into the following error:
> > > 
> > > BUG: Bad page state in process uio_test  pfn:078ed
> > > page:c0409154 count:0 mapcount:0 mapping:  (null) index:0x0
> > > page flags: 0x284(referenced|slab|arch_1)
> 
> PG_slab is set.  The kernel is complaining because a page which was
> allocated via kmalloc/kmem_cache_alloc was directly passed to the page
> allocator for freeing.  It should have been passed to kfree().
> 
> Presumably the uio driver expects that its memory was allocated via
> alloc_pages(), not via kmalloc().

Thanks for that hint. I'll check and will update UIO documentation
accordingly if necessary.

BUT the following problems are still threatening my mental health:

If userspace gets a valid and working pointer from mmap(), it is
entitled to expect munmap() to work on that pointer, too, isn't it?
Shouldn't mmap() fail in such a case?

The kernel's behavior should be the same, no matter which SLAB or
SLUB is chosen.

Or am I following wrong philosophies?

Thanks,
Hans


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
