Date: Wed, 13 Feb 2008 10:51:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <20080213032533.GC32047@obsidianresearch.com>
Message-ID: <Pine.LNX.4.64.0802131039160.18472@schroedinger.engr.sgi.com>
References: <20080209075556.63062452@bree.surriel.com>
 <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com>
 <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
 <20080213012638.GD31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
 <20080213032533.GC32047@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Roland Dreier <rdreier@cisco.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Jason Gunthorpe wrote:

> But this isn't how IB or iwarp work at all. What you describe is a
> significant change to the general RDMA operation and requires changes to
> both sides of the connection and the wire protocol.

Yes it may require a separate connection between both sides where a 
kind of VM notification protocol is established to tear these things down and 
set them up again. That is if there is nothing in the RDMA protocol that
allows a notification to the other side that the mapping is being down 
down.

>  - In RDMA (iwarp and IB versions) the hardware page tables exist to
>    linearize the local memory so the remote does not need to be aware
>    of non-linearities in the physical address space. The main
>    motivation for this is kernel bypass where the user space app wants
>    to instruct the remote side to DMA into memory using user space
>    addresses. Hardware provides the page tables to switch from
>    incoming user space virtual addresses to physical addresess.

s/switch/translate I guess. That is good and those page tables could be 
used for the notification scheme to enable reclaim. But they are optional 
and are maintaining the driver state. The linearization could be 
reconstructed from the kernel page tables on demand.

>    Many kernel RDMA drivers (SCSI, NFS) only use the HW page tables
>    for access control and enforcing the liftime of the mapping.

Well the mapping would have to be on demand to avoid the issues that we 
currently have with pinning. The user API could stay the same. If the 
driver tracks the mappings using the notifier then the VM can make sure 
that the right things happen on exit etc etc.

>    The page tables in the RDMA hardware exist primarily to support
>    this, and not for other reasons. The pinning of pages is one part
>    to support the HW page tables and one part to support the RDMA
>    lifetime rules, the liftime rules are what cause problems for
>    the VM.

So the driver software can tear down and establish page tables 
entries at will? I do not see the problem. The RDMA hardware is one thing, 
the way things are visible to the user another. If the driver can 
establish and remove mappings as needed via RDMA then the user can have 
the illusion of persistent RDMA memory. This is the same as virtual memory 
providing the illusion of a process having lots of memory all for itself.


>  - The wire protocol consists of packets that say 'Write XXX bytes to
>    offset YY in Region RRR'. Creating a region produces the RRR label
>    and currently pins the pages. So long as the RRR label is valid the
>    remote side can issue write packets at any time without any
>    further synchronization. There is no wire level events associated
>    with creating RRR. You can pass RRR to the other machine in any
>    fashion, even using carrier pigeons :)
>  - The RDMA layer is very general (ala TCP), useful protocols (like SCSI)
>    are built on top of it and they specify the lifetime rules and
>    protocol for exchanging RRR.

Well yes of course. What is proposed here is an additional notification 
mechanism (could even be via tcp/udp to simplify things) that would manage 
the mappings at a higher level. The writes would not occur if the mapping 
has not been established.
 
>    This is your step 'A will then send a message to B notifying..'.
>    It simply does not exist in the protocol specifications

Of course. You need to create an additional communication layer to get 
that.

> What it boils down to is that to implement true removal of pages in a
> general way the kernel and HCA must either drop packets or stall
> incoming packets, both are big performance problems - and I can't see
> many users wanting this. Enterprise style people using SCSI, NFS, etc
> already have short pin periods and HPC MPI users probably won't care
> about the VM issues enough to warrent the performance overhead.

True maybe you cannot do this by simply staying within the protocol bounds 
of RDMA that is based on page pinning if the RDMA protocol does not 
support a notification to the other side that the mapping is going away. 

If RDMA cannot do this then you would need additional ways of notifying 
the remote side that pages/mappings are invalidated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
