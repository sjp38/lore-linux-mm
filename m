Date: Tue, 20 May 2008 05:01:11 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080520100111.GC30341@sgi.com>
References: <200805132206.47655.nickpiggin@yahoo.com.au> <20080513153238.GL19717@sgi.com> <20080514041122.GE24516@wotan.suse.de> <20080514112625.GY9878@sgi.com> <20080515075747.GA7177@wotan.suse.de> <Pine.LNX.4.64.0805151031250.18708@schroedinger.engr.sgi.com> <20080515235203.GB25305@wotan.suse.de> <20080516112306.GA4287@sgi.com> <20080516115005.GC4287@sgi.com> <20080520053145.GA19502@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080520053145.GA19502@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 07:31:46AM +0200, Nick Piggin wrote:
> On Fri, May 16, 2008 at 06:50:05AM -0500, Robin Holt wrote:
> > On Fri, May 16, 2008 at 06:23:06AM -0500, Robin Holt wrote:
> > > On Fri, May 16, 2008 at 01:52:03AM +0200, Nick Piggin wrote:
> > > > On Thu, May 15, 2008 at 10:33:57AM -0700, Christoph Lameter wrote:
> > > > > On Thu, 15 May 2008, Nick Piggin wrote:
> > > > > 
> > > > > > Oh, I get that confused because of the mixed up naming conventions
> > > > > > there: unmap_page_range should actually be called zap_page_range. But
> > > > > > at any rate, yes we can easily zap pagetables without holding mmap_sem.
> > > > > 
> > > > > How is that synchronized with code that walks the same pagetable. These 
> > > > > walks may not hold mmap_sem either. I would expect that one could only 
> > > > > remove a portion of the pagetable where we have some sort of guarantee 
> > > > > that no accesses occur. So the removal of the vma prior ensures that?
> > > >  
> > > > I don't really understand the question. If you remove the pte and invalidate
> > > > the TLBS on the remote image's process (importing the page), then it can
> > > > of course try to refault the page in because it's vma is still there. But
> > > > you catch that refault in your driver , which can prevent the page from
> > > > being faulted back in.
> > > 
> > > I think Christoph's question has more to do with faults that are
> > > in flight.  A recently requested fault could have just released the
> > > last lock that was holding up the invalidate callout.  It would then
> > > begin messaging back the response PFN which could still be in flight.
> > > The invalidate callout would then fire and do the interrupt shoot-down
> > > while that response was still active (essentially beating the inflight
> > > response).  The invalidate would clear up nothing and then the response
> > > would insert the PFN after it is no longer the correct PFN.
> > 
> > I just looked over XPMEM.  I think we could make this work.  We already
> > have a list of active faults which is protected by a simple spinlock.
> > I would need to nest this lock within another lock protected our PFN
> > table (currently it is a mutex) and then the invalidate interrupt handler
> > would need to mark the fault as invalid (which is also currently there).
> > 
> > I think my sticking points with the interrupt method remain at fault
> > containment and timeout.  The inability of the ia64 processor to handle
> > provide predictive failures for the read/write of memory on other
> > partitions prevents us from being able to contain the failure.  I don't
> > think we can get the information we would need to do the invalidate
> > without introducing fault containment issues which has been a continous
> > area of concern for our customers.
> 
> Really? You can get the information through via a sleeping messaging API,
> but not a non-sleeping one? What is the difference from the hardware POV?

That was covered in the early very long discussion about 28 seconds.
The read timeout for the BTE is 28 seconds and it automatically retried
for certain failures.  In interrupt context, that is 56 seconds without
any subsequent interrupts of that or lower priority.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
