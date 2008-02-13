Date: Tue, 12 Feb 2008 17:55:33 -0800
From: Christian Bell <christian.bell@qlogic.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213015533.GP29340@mv.qlogic.com>
References: <20080209015659.GC7051@v2.random> <Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com> <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Christoph Lameter wrote:

> On Tue, 12 Feb 2008, Jason Gunthorpe wrote:
> 
> > Well, certainly today the memfree IB devices store the page tables in
> > host memory so they are already designed to hang onto packets during
> > the page lookup over PCIE, adding in faulting makes this time
> > larger.
> 
> You really do not need a page table to use it. What needs to be maintained 
> is knowledge on both side about what pages are currently shared across 
> RDMA. If the VM decides to reclaim a page then the notification is used to 
> remove the remote entry. If the remote side then tries to access the page 
> again then the page fault on the remote side will stall until the local 
> page has been brought back. RDMA can proceed after both sides again agree 
> on that page now being sharable.

HPC environments won't be amenable to a pessimistic approach of
synchronizing before every data transfer.  RDMA is assumed to be a
low-level data movement mechanism that has no implied
synchronization.  In some parallel programming models, it's not
uncommon to use RDMA to send 8-byte messages.  It can be difficult to
make and hold guarantees about in-memory pages when many concurrent
RDMA operations are in flight (not uncommon in reasonably large
machines).  Some of the in-memory page information could be shared
with some form of remote caching strategy but then it's a different
problem with its own scalability challenges.

I think there are very potential clients of the interface when an
optimistic approach is used.  Part of the trick, however, has to do
with being able to re-start transfers instead of buffering the data
or making guarantees about delivery that could cause deadlock (as was
alluded to earlier in this thread).  InfiniBand is constrained in
this regard since it requires message-ordering between endpoints (or
queue pairs).  One could argue that this is still possible with IB,
at the cost of throwing more packets away when a referenced page is
not in memory.  With this approach, the worse case demand paging
scenario is met when the active working set of referenced pages is
larger than the amount physical memory -- but HPC applications are
already bound by this anyway.

You'll find that Quadrics has the most experience in this area and
that their entire architecture is adapted to being optimistic about
demand paging in RDMA transfers -- they've been maintaining a patchset
to do this for years.

    . . christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
