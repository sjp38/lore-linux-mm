Date: Thu, 15 May 2008 09:57:47 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080515075747.GA7177@wotan.suse.de>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080508003838.GA9878@sgi.com> <200805132206.47655.nickpiggin@yahoo.com.au> <20080513153238.GL19717@sgi.com> <20080514041122.GE24516@wotan.suse.de> <20080514112625.GY9878@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080514112625.GY9878@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2008 at 06:26:25AM -0500, Robin Holt wrote:
> On Wed, May 14, 2008 at 06:11:22AM +0200, Nick Piggin wrote:
> > 
> > I guess that you have found a way to perform TLB flushing within coherent
> > domains over the numalink interconnect without sleeping. I'm sure it would
> > be possible to send similar messages between non coherent domains.
> 
> I assume by coherent domains, your are actually talking about system
> images.

Yes

>  Our memory coherence domain on the 3700 family is 512 processors
> on 128 nodes.  On the 4700 family, it is 16,384 processors on 4096 nodes.
> We extend a "Read-Exclusive" mode beyond the coherence domain so any
> processor is able to read any cacheline on the system.  We also provide
> uncached access for certain types of memory beyond the coherence domain.

Yes, I understand the basics.

 
> For the other partitions, the exporting partition does not know what
> virtual address the imported pages are mapped.  The pages are frequently
> mapped in a different order by the MPI library to help with MPI collective
> operations.
> 
> For the exporting side to do those TLB flushes, we would need to replicate
> all that importing information back to the exporting side.

Right. Or the exporting side could be passed tokens that it tracks itself,
rather than virtual addresses.

 
> Additionally, the hardware that does the TLB flushing is protected
> by a spinlock on each system image.  We would need to change that
> simple spinlock into a type of hardware lock that would work (on 3700)
> outside the processors coherence domain.  The only way to do that is to
> use uncached addresses with our Atomic Memory Operations which do the
> cmpxchg at the memory controller.  The uncached accesses are an order
> of magnitude or more slower.

I'm not sure if you're thinking about what I'm thinking of. With the
scheme I'm imagining, all you will need is some way to raise an IPI-like
interrupt on the target domain. The IPI target will have a driver to
handle the interrupt, which will determine the mm and virtual addresses
which are to be invalidated, and will then tear down those page tables
and issue hardware TLB flushes within its domain. On the Linux side,
I don't see why this can't be done.

 
> > So yes, I'd much rather rework such highly specialized system to fit in
> > closer with Linux than rework Linux to fit with these machines (and
> > apparently slow everyone else down).
> 
> But it isn't that we are having a problem adapting to just the hardware.
> One of the limiting factors is Linux on the other partition.

In what way is the Linux limiting? 


> > > Additionally, the call to zap_page_range expects to have the mmap_sem
> > > held.  I suppose we could use something other than zap_page_range and
> > > atomically clear the process page tables.
> > 
> > zap_page_range does not expect to have mmap_sem held. I think for anon
> > pages it is always called with mmap_sem, however try_to_unmap_anon is
> > not (although it expects page lock to be held, I think we should be able
> > to avoid that).
> 
> zap_page_range calls unmap_vmas which walks to vma->next.  Are you saying
> that can be walked without grabbing the mmap_sem at least readably?

Oh, I get that confused because of the mixed up naming conventions
there: unmap_page_range should actually be called zap_page_range. But
at any rate, yes we can easily zap pagetables without holding mmap_sem.


> I feel my understanding of list management and locking completely
> shifting.

FWIW, mmap_sem isn't held to protect vma->next there anyway, because at
that point the vmas are detached from the mm's rbtree and linked list.
But sure, in that particular path it is held for other reasons.

 
> > >  Doing that will not alleviate
> > > the need to sleep for the messaging to the other partitions.
> > 
> > No, but I'd venture to guess that is not impossible to implement even
> > on your current hardware (maybe a firmware update is needed)?
> 
> Are you suggesting the sending side would not need to sleep or the
> receiving side?  Assuming you meant the sender, it spins waiting for the
> remote side to acknowledge the invalidate request?  We place the data
> into a previously agreed upon buffer and send an interrupt.  At this
> point, we would need to start spinning and waiting for completion.
> Let's assume we never run out of buffer space.

How would you run out of buffer space if it is synchronous?

 
> The receiving side receives an interrupt.  The interrupt currently wakes
> an XPC thread to do the work of transfering and delivering the message
> to XPMEM.  The transfer of the data which XPC does uses the BTE engine
> which takes up to 28 seconds to timeout (hardware timeout before raising
> and error) and the BTE code automatically does a retry for certain
> types of failure.  We currently need to grab semaphores which _MAY_
> be able to be reworked into other types of locks.

Sure, you obviously would need to rework your code because it's been
written with the assumption that it can sleep.

What is XPMEM exactly anyway? I'd assumed it is a Linux driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
