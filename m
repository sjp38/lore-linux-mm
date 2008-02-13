Date: Tue, 12 Feb 2008 20:25:33 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213032533.GC32047@obsidianresearch.com>
References: <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com> <20080213012638.GD31435@obsidianresearch.com> <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Roland Dreier <rdreier@cisco.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2008 at 06:35:09PM -0800, Christoph Lameter wrote:
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
> 
> You would only use the wire protocols *after* having established the RDMA 
> region. The notifier chains allows a RDMA region (or parts thereof) to be 
> down on demand by the VM. The region can be reestablished if one of 
> the side accesses it. I hope I got that right. Not much exposure to 
> Infiniband so far.

[clip explaination]

But this isn't how IB or iwarp work at all. What you describe is a
significant change to the general RDMA operation and requires changes to
both sides of the connection and the wire protocol.

A few comments on RDMA operation that might clarify things a little
bit more:
 - In RDMA (iwarp and IB versions) the hardware page tables exist to
   linearize the local memory so the remote does not need to be aware
   of non-linearities in the physical address space. The main
   motivation for this is kernel bypass where the user space app wants
   to instruct the remote side to DMA into memory using user space
   addresses. Hardware provides the page tables to switch from
   incoming user space virtual addresses to physical addresess.

   This greatly simplifies the user space programming model since you
   don't need to pass around or create s/g lists for memory that is
   already virtually continuous.

   Many kernel RDMA drivers (SCSI, NFS) only use the HW page tables
   for access control and enforcing the liftime of the mapping.

   The page tables in the RDMA hardware exist primarily to support
   this, and not for other reasons. The pinning of pages is one part
   to support the HW page tables and one part to support the RDMA
   lifetime rules, the liftime rules are what cause problems for
   the VM.
 - The wire protocol consists of packets that say 'Write XXX bytes to
   offset YY in Region RRR'. Creating a region produces the RRR label
   and currently pins the pages. So long as the RRR label is valid the
   remote side can issue write packets at any time without any
   further synchronization. There is no wire level events associated
   with creating RRR. You can pass RRR to the other machine in any
   fashion, even using carrier pigeons :)
 - The RDMA layer is very general (ala TCP), useful protocols (like SCSI)
   are built on top of it and they specify the lifetime rules and
   protocol for exchanging RRR.

   Every protocol is different. In kernel protocols like SRP and NFS
   RDMA seem to have very short lifetimes for RRR and work more like
   pci_map_* in real SCSI hardware.
 - HPC userspace apps, like MPI apps, have different lifetime rules
   and tend to be really long lived. These people will not want
   anything that makes their OPs more expensive and also probably
   don't care too much about the VM problems you are looking at (?)
 - There is no protocol support to exchange RRR. This is all done
   by upper level protocols (ala HTTP vs TCP). You cannot assert
   and revoke RRR in a general way. Every protocol is different
   and optimized.

   This is your step 'A will then send a message to B notifying..'.
   It simply does not exist in the protocol specifications

I don't know much about Quadrics, but I would be hesitant to lump it
in too much with these RDMA semantics. Christian's comments sound like
they operate closer to what you described and that is why the have an
existing patch set. I don't know :)

What it boils down to is that to implement true removal of pages in a
general way the kernel and HCA must either drop packets or stall
incoming packets, both are big performance problems - and I can't see
many users wanting this. Enterprise style people using SCSI, NFS, etc
already have short pin periods and HPC MPI users probably won't care
about the VM issues enough to warrent the performance overhead.

Regards,
Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
