Date: Tue, 12 Feb 2008 20:09:05 -0800
From: Christian Bell <christian.bell@qlogic.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213040905.GQ29340@mv.qlogic.com>
References: <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com> <20080213012638.GD31435@obsidianresearch.com> <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Christoph Lameter wrote:

> On Tue, 12 Feb 2008, Jason Gunthorpe wrote:
> 
> > The problem is that the existing wire protocols do not have a
> > provision for doing an 'are you ready' or 'I am not ready' exchange
> > and they are not designed to store page tables on both sides as you
> > propose. The remote side can send RDMA WRITE traffic at any time after
> > the RDMA region is established. The local side must be able to handle
> > it. There is no way to signal that a page is not ready and the remote
> > should not send.
> > 
> > This means the only possible implementation is to stall/discard at the
> > local adaptor when a RDMA WRITE is recieved for a page that has been
> > reclaimed. This is what leads to deadlock/poor performance..

You're arguing that a HW page table is not needed by describing a use
case that is essentially what all RDMA solutions already do above the
wire protocols (all solutions except Quadrics, of course).

> You would only use the wire protocols *after* having established the RDMA 
> region. The notifier chains allows a RDMA region (or parts thereof) to be 
> down on demand by the VM. The region can be reestablished if one of 
> the side accesses it. I hope I got that right. Not much exposure to 
> Infiniband so far.

RDMA is already always used *after* memory regions are set up --
they are set up out-of-band w.r.t RDMA but essentially this is the
"before" part.

> Lets say you have a two systems A and B. Each has their memory region MemA 
> and MemB. Each side also has page tables for this region PtA and PtB.
> 
> Now you establish a RDMA connection between both side. The pages in both
> MemB and MemA are present and so are entries in PtA and PtB. RDMA 
> traffic can proceed.
> 
> The VM on system A now gets into a situation in which memory becomes 
> heavily used by another (maybe non RDMA process) and after checking that 
> there was no recent reference to MemA and MemB (via a notifier aging 
> callback) decides to reclaim the memory from MemA.
> 
> In that case it will notify the RDMA subsystem on A that it is trying to
> reclaim a certain page.
> 
> The RDMA subsystem on A will then send a message to B notifying it that 
> the memory will be going away. B now has to remove its corresponding page 
> from memory (and drop the entry in PtB) and confirm to A that this has 
> happened. RDMA traffic is then stopped for this page. Then A can also 
> remove its page, the corresponding entry in PtA and the page is reclaimed 
> or pushed out to swap completing the page reclaim.
> 
> If either side then accesses the page again then the reverse process 
> happens. If B accesses the page then it wil first of all incur a page 
> fault because the entry in PtB is missing. The fault will then cause a 
> message to be send to A to establish the page again. A will create an 
> entry in PtA and will then confirm to B that the page was established. At 
> that point RDMA operations can occur again.

The notifier-reclaim cycle you describe is akin to the out-of-band
pin-unpin control messages used by existing communication libraries.
Also, I think what you are proposing can have problems at scale -- A
must keep track of all of the (potentially many systems) of memA and
cooperatively get an agreement from all these systems before reclaiming
the page.

When messages are sufficiently large, the control messaging necessary
to setup/teardown the regions is relatively small.  This is not
always the case however -- in programming models that employ smaller
messages, the one-sided nature of RDMA is the most attractive part of
it.  

> So the whole scheme does not really need a hardware page table in the RDMA 
> hardware. The page tables of the two systems A and B are sufficient.
> 
> The scheme can also be applied to a larger range than only a single page. 
> The RDMA subsystem could tear down a large section when reclaim is 
> pushing on it and then reestablish it as needed.

Nothing any communication/runtime system can't already do today.  The
point of RDMA demand paging is enabling the possibility of using RDMA
without the implied synchronization -- the optimistic part.  Using
the notifiers to duplicate existing memory region handling for RDMA
hardware that doesn't have HW page tables is possible but undermines
the more important consumer of your patches in my opinion.

One other area that has not been brought up yet (I think) is the
applicability of notifiers in letting users know when pinned memory
is reclaimed by the kernel.  This is useful when a lower-level
library employs lazy deregistration strategies on memory regions that
are subsequently released to the kernel via the application's use of
munmap or sbrk.  Ohio Supercomputing Center has work in this area but
a generalized approach in the kernel would certainly be welcome.


    . . christian

-- 
christian.bell@qlogic.com
(QLogic Host Solutions Group, formerly Pathscale)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
