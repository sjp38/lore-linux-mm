Date: Wed, 13 Feb 2008 11:00:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <20080213040905.GQ29340@mv.qlogic.com>
Message-ID: <Pine.LNX.4.64.0802131052360.18472@schroedinger.engr.sgi.com>
References: <20080209075556.63062452@bree.surriel.com>
 <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com>
 <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
 <20080213012638.GD31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
 <20080213040905.GQ29340@mv.qlogic.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Bell <christian.bell@qlogic.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Christian Bell wrote:

> You're arguing that a HW page table is not needed by describing a use
> case that is essentially what all RDMA solutions already do above the
> wire protocols (all solutions except Quadrics, of course).

The HW page table is not essential to the notification scheme. That the 
RDMA uses the page table for linearization is another issue. A chip could 
just have a TLB cache and lookup the entries using the OS page table f.e.

> > Lets say you have a two systems A and B. Each has their memory region MemA 
> > and MemB. Each side also has page tables for this region PtA and PtB.
> > If either side then accesses the page again then the reverse process 
> > happens. If B accesses the page then it wil first of all incur a page 
> > fault because the entry in PtB is missing. The fault will then cause a 
> > message to be send to A to establish the page again. A will create an 
> > entry in PtA and will then confirm to B that the page was established. At 
> > that point RDMA operations can occur again.
> 
> The notifier-reclaim cycle you describe is akin to the out-of-band
> pin-unpin control messages used by existing communication libraries.
> Also, I think what you are proposing can have problems at scale -- A
> must keep track of all of the (potentially many systems) of memA and
> cooperatively get an agreement from all these systems before reclaiming
> the page.

Right. We (SGI) have done something like this for a long time with XPmem 
and it scales ok.

> When messages are sufficiently large, the control messaging necessary
> to setup/teardown the regions is relatively small.  This is not
> always the case however -- in programming models that employ smaller
> messages, the one-sided nature of RDMA is the most attractive part of
> it.  

The messaging would only be needed if a process comes under memory 
pressure. As long as there is enough memory nothing like this will occur.

> Nothing any communication/runtime system can't already do today.  The
> point of RDMA demand paging is enabling the possibility of using RDMA
> without the implied synchronization -- the optimistic part.  Using
> the notifiers to duplicate existing memory region handling for RDMA
> hardware that doesn't have HW page tables is possible but undermines
> the more important consumer of your patches in my opinion.

The notifier schemet should integrate into existing memory region 
handling and not cause a duplication. If you already have library layers 
that do this then it should be possible to integrate it.

> One other area that has not been brought up yet (I think) is the
> applicability of notifiers in letting users know when pinned memory
> is reclaimed by the kernel.  This is useful when a lower-level
> library employs lazy deregistration strategies on memory regions that
> are subsequently released to the kernel via the application's use of
> munmap or sbrk.  Ohio Supercomputing Center has work in this area but
> a generalized approach in the kernel would certainly be welcome.

The driver gets the notifications about memory being reclaimed. The driver 
could then notify user code about the release as well.

Pinned memory current *cannot* be reclaimed by the kernel. The refcount is 
elevated. This means that the VM tries to remove the mappings and then 
sees that it was not able to remove all references. Then it gives up and 
tries again and again and again.... Thus the potential for livelock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
