Date: Tue, 12 Feb 2008 18:35:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <20080213012638.GD31435@obsidianresearch.com>
Message-ID: <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
References: <20080209015659.GC7051@v2.random>
 <Pine.LNX.4.64.0802081813300.5602@schroedinger.engr.sgi.com>
 <20080209075556.63062452@bree.surriel.com> <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com>
 <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
 <20080213012638.GD31435@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Roland Dreier <rdreier@cisco.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, Jason Gunthorpe wrote:

> The problem is that the existing wire protocols do not have a
> provision for doing an 'are you ready' or 'I am not ready' exchange
> and they are not designed to store page tables on both sides as you
> propose. The remote side can send RDMA WRITE traffic at any time after
> the RDMA region is established. The local side must be able to handle
> it. There is no way to signal that a page is not ready and the remote
> should not send.
> 
> This means the only possible implementation is to stall/discard at the
> local adaptor when a RDMA WRITE is recieved for a page that has been
> reclaimed. This is what leads to deadlock/poor performance..

You would only use the wire protocols *after* having established the RDMA 
region. The notifier chains allows a RDMA region (or parts thereof) to be 
down on demand by the VM. The region can be reestablished if one of 
the side accesses it. I hope I got that right. Not much exposure to 
Infiniband so far.

Lets say you have a two systems A and B. Each has their memory region MemA 
and MemB. Each side also has page tables for this region PtA and PtB.

Now you establish a RDMA connection between both side. The pages in both
MemB and MemA are present and so are entries in PtA and PtB. RDMA 
traffic can proceed.

The VM on system A now gets into a situation in which memory becomes 
heavily used by another (maybe non RDMA process) and after checking that 
there was no recent reference to MemA and MemB (via a notifier aging 
callback) decides to reclaim the memory from MemA.

In that case it will notify the RDMA subsystem on A that it is trying to
reclaim a certain page.

The RDMA subsystem on A will then send a message to B notifying it that 
the memory will be going away. B now has to remove its corresponding page 
from memory (and drop the entry in PtB) and confirm to A that this has 
happened. RDMA traffic is then stopped for this page. Then A can also 
remove its page, the corresponding entry in PtA and the page is reclaimed 
or pushed out to swap completing the page reclaim.

If either side then accesses the page again then the reverse process 
happens. If B accesses the page then it wil first of all incur a page 
fault because the entry in PtB is missing. The fault will then cause a 
message to be send to A to establish the page again. A will create an 
entry in PtA and will then confirm to B that the page was established. At 
that point RDMA operations can occur again.

So the whole scheme does not really need a hardware page table in the RDMA 
hardware. The page tables of the two systems A and B are sufficient.

The scheme can also be applied to a larger range than only a single page. 
The RDMA subsystem could tear down a large section when reclaim is 
pushing on it and then reestablish it as needed.

Swapping and page reclaim is certainly not something that improves the 
speed of the application affected by swapping and page reclaim but it 
allows the VM to manage memory effectively if multiple loads are runing on 
a system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
