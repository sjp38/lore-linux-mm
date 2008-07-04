Date: Fri, 4 Jul 2008 13:37:33 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: How to alloc highmem page below 4GB on i386?
Message-ID: <20080704133733.278b6458@infradead.org>
In-Reply-To: <20080704222323.68afbe88@mjolnir.drzeus.cx>
References: <20080630200323.2a5992cd@mjolnir.drzeus.cx>
	<20080704195800.4ef6e00a@mjolnir.drzeus.cx>
	<20080704111224.68266afc@infradead.org>
	<20080704222323.68afbe88@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008 22:23:23 +0200
Pierre Ossman <drzeus-list@drzeus.cx> wrote:

> On Fri, 4 Jul 2008 11:12:24 -0700
> Arjan van de Ven <arjan@infradead.org> wrote:
> 
> > On Fri, 4 Jul 2008 19:58:00 +0200
> > Pierre Ossman <drzeus-list@drzeus.cx> wrote:
> > 
> > > On Mon, 30 Jun 2008 20:03:23 +0200
> > > Pierre Ossman <drzeus-list@drzeus.cx> wrote:
> > > 
> > > > Simple question. How do I allocate a page from highmem, that's
> > > > still within 32 bits? x86_64 has the DMA32 zone, but i386 has
> > > > just HIGHMEM. As most devices can't DMA above 32 bit, I have 3
> > > > GB of memory that's not getting decent usage (or results in
> > > > needless bouncing). What to do?
> > > > 
> > > > I tried just enabling CONFIG_DMA32 for i386, but there is some
> > > > guard against too many memory zones. I'm assuming this is there
> > > > for a good reason?
> > > > 
> > > 
> > > Anyone?
> > > 
> > 
> > well... the assumption sort of is that all high-perf devices are 64
> > bit capable. For the rest... well you get what you get. There's
> > IOMMU's in modern systems from Intel (and soon AMD) that help you
> > avoid the bounce if you really care. 
> 
> I was under the impression that the PCI bus was utterly incapable of
> any larger address than 32 bits? But perhaps you only consider PCIE
> stuff high-perf. :)

actually your impression is not correct. There's a difference between
how many physical bits the bus has, and the logical data. Specifically,
PCI (and PCIE etc) have something that's called "Dual Address Cycle",
which is a pci bus transaction that sends the 64 bit address using 2
cycles on the bus even if the buswidth is 32 bit (logically).


> > The second assumption sort of is that you don't have 'too much'
> > above 4Gb; once you're over 16Gb or so people assume you will run
> > the 64 bit kernel instead...
> 
> Unfortunately some proprietary crud keeps migration somewhat annoying.
> And in my case it's a 4 GB system, where 1 GB gets mapped up to make
> room for devices, so it's not that uncommon.

4Gb systems are entirely reasonably still with 32 bit kernels (I'm
typing on one right now ;-); it gets problematic in the 12-16Gb range.

> 
> The strange thing is that I keep getting pages from > 4GB all the
> time, even on a loaded system. I would have expected mostly getting
> pages below that limit as that's where most of the memory is. Do you
> have any insight into which areas tend to fill up first?

ok this is tricky and goes way deep into buddy allocator internals.
On the highest level (2Mb chunks iirc, but it could be a bit or
two bigger now) we allocate top down. But once we split such a top level
chunk up, inside the chunk we allocate bottom up (so that the scatter
gather IOs tend to group nicer). 
In addition, the kernel will prefer allocating userspace/pagecache
memory from highmem over lowmem, out of an effort to keep memory
pressure in the lowmem zones lower.



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
